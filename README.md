# Introduction

This is working example of blinky program (with additional hardware support) for LPC4357-EVB board, adapted to open source toolchain. The used toolchain consists of:

* [LPCopen](http://www.lpcware.com/content/nxpfile/lpcopen-platform) v2.12 (sources included in repo), ported from Hitex board
* [gcc-arm-none-eabi](https://launchpad.net/gcc-arm-embedded/) v4_8-2014q3, CMSIS is not used
* [OpenOCD](openocd.sourceforge.net) built from source with BusPirate support
* [BusPirate](http://dangerousprototypes.com/docs/Bus_Pirate) with v6.1 firmware
* [dfu-util](http://dfu-util.gnumonks.org/) (built from source).


Supported features:

* external SDRAM (MT48LC16M16)
* remote debugging using GDB, OpenOCD and BusPirate as JTAG interface
* executing code from RAM, either by loading with GDB or by uploading via USB cable to built-in DFU bootloader
* audio codec (UDA1380), not included in this codebase
* semihosting (OpenOCD displays stdout messages)
* buttons and joystick

Not yet supported:

* activating Cortex M0 core
* Embedded Trace Buffer to enable OpenOCD tracing
* SPI flash memory (S25FL256S)
* I2C accelerometer (ADXL345)
* link to shadow memory region to allow same code to be loaded into RAM or internal flash
* VCOM (virtual com port) USB functionality

# Using DFU bootloader

NXP LPC 43xx parts have DFU (device firmware upgrade) bootloader inside the ROM section that can be used to upload user code to RAM and execute it. Bootloader only supports writting (and jumping) to RAM, so if internal FLASH or SPI FLASH is needed, one should look for second-stage RAM bootloader that supports full DFU protocol.

On PC side DFU client with sufficient USB access privileges communicates with LPC43xx chip and transfers the binary image to be executed right after downloading. Windows utility is provided by NXP ([DFU Programmer](http://www.lpcware.com/content/project/dfu-download-programming-utility-and-security-lpcdfusec-tool/dfusec-dfu-production-p)). In Linux environment dfu-util serves the same purpose. Please build newest version from source. Makefile target *make ram* will build, download and execute built project from RAM using DFU transfer.

One extra gotcha is that NXP rapes the standard DFU protocol by insisting on mandatory useless header. Included Makefile shows python command that adds this header to binary image.

Another detail - if internal flash contains a valid image, DFU will only be executed if P2_7 pin is low. On LPC4357-EVB board this pin is not connected to header. One option is to use JTAG to wipe internal flash, another is to modify board to allow grounding of P2_7 pin (part of SDRAM address bus).

Semihosting is obviously not supported when OpenOCD/GDB is not used, so -DDEBUG and -DDEBUG_ENABLE flags should be commented out in Makefile.

# Using GDB with LPC43xx

This project assumes BusPirate as JTAG interface, OpenOCD as GDB host, and command line GDB as debugger. Makefile target *make gdb* will build project, connect to OpenOCD GDB host and load binary to RAM. Code is executed using *continue* command.

Some other useful commands within GDB shell:

    monitor halt - let GDB assume command over controller (if code was running before GDB was lunched, or if reset button is pressed)
    make - run build process from withing GDB
    load - load newly built code into controller memory
    target remote localhost:3333 - reconnect to OpenOCD GDB host
    cortex_m maskisr (auto|on|off) - control interrupt routines masking when debugging (see OpenOCD manual for details)
