MEMORY
{
  /* Define each memory region */
  MFlashA512 (rx)   : ORIGIN = 0x1a000000, LENGTH = 0x80000 /* 512K bytes */
  MFlashB512 (rx)   : ORIGIN = 0x1b000000, LENGTH = 0x80000 /* 512K bytes */
  RamLoc32 (rwx)    : ORIGIN = 0x10000000, LENGTH = 0x8000 /* 32K bytes */
  RamLoc40 (rwx)    : ORIGIN = 0x10080000, LENGTH = 0xa000 /* 40K bytes */
  RamRetained(rwx)  : ORIGIN = 0x10088000, LENGTH = 0x2000 /* 8K bytes */
  RamAHB32 (rwx)    : ORIGIN = 0x20000000, LENGTH = 0x8000 /* 32K bytes */
  RamAHB16 (rwx)    : ORIGIN = 0x20008000, LENGTH = 0x4000 /* 16K bytes */
  RamAHB_ETB16 (rwx): ORIGIN = 0x2000c000, LENGTH = 0x4000 /* 16K bytes */
  SDRam (rwx)     : ORIGIN = 0x28000000, LENGTH = 0x2000000 /* 4 Meg x 16 x 4 banks */
  Shadow_Mem (rwx)  : ORIGIN = 0x00000000, LENGTH = 0x8000 /* 32K bytes */
}
  /* Define a symbol for the top of each memory region */
  __top_MFlashA512 = 0x1a000000 + 0x80000;
  __top_MFlashB512 = 0x1b000000 + 0x80000;
  __top_RamLoc32 = 0x10000000 + 0x8000;
  __top_RamLoc40 = 0x10080000 + 0xa000;
  __top_RamRetained = 0x10088000 + 0x2000;
  __top_RamAHB32 = 0x20000000 + 0x8000;
  __top_RamAHB16 = 0x20008000 + 0x4000;
  __top_RamAHB_ETB16 = 0x2000c000 + 0x4000;
  __top_SDRam = 0x28000000 + 0x10000000;
  __top_Shadow_Mem = 0x00000000 + 0x8000;

ENTRY(ResetISR)

SECTIONS
{
    /* MAIN TEXT SECTION */
    .text : ALIGN(4)
    {
        FILL(0xff)
        __vectors_start__ = ABSOLUTE(.) ;
        KEEP(*(.isr_vector))

        /* Global Section Table */
        . = ALIGN(4) ;
        __section_table_start = .;
        __data_section_table = .;
        LONG(LOADADDR(.data));
        LONG(    ADDR(.data));
        LONG(  SIZEOF(.data));
        LONG(LOADADDR(.data_RAM2));
        LONG(    ADDR(.data_RAM2));
        LONG(  SIZEOF(.data_RAM2));
        LONG(LOADADDR(.data_RAM3));
        LONG(    ADDR(.data_RAM3));
        LONG(  SIZEOF(.data_RAM3));
        LONG(LOADADDR(.data_RAM4));
        LONG(    ADDR(.data_RAM4));
        LONG(  SIZEOF(.data_RAM4));
        LONG(LOADADDR(.data_RAM5));
        LONG(    ADDR(.data_RAM5));
        LONG(  SIZEOF(.data_RAM5));
        __data_section_table_end = .;
        __bss_section_table = .;
        LONG(    ADDR(.bss));
        LONG(  SIZEOF(.bss));
        LONG(    ADDR(.bss_RAM2));
        LONG(  SIZEOF(.bss_RAM2));
        LONG(    ADDR(.bss_RAM3));
        LONG(  SIZEOF(.bss_RAM3));
        LONG(    ADDR(.bss_RAM4));
        LONG(  SIZEOF(.bss_RAM4));
        LONG(    ADDR(.bss_RAM5));
        LONG(  SIZEOF(.bss_RAM5));
        __bss_section_table_end = .;
        __section_table_end = . ;
        /* End of Global Section Table */


        *(.after_vectors*)
/*        . = . + 2000;  dfu-util reports error if image is too small */

    } >RamLoc32

    .text : ALIGN(4)
    {
         *(.text*)
        *(.rodata .rodata.* .constdata .constdata.*)
        . = ALIGN(4);

    } > RamLoc32

    /*
     * for exception handling/unwind - some Newlib functions (in common
     * with C++ and STDC++) use this.
     */
    .ARM.extab : ALIGN(4)
    {
      *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > RamLoc32
    __exidx_start = .;

    .ARM.exidx : ALIGN(4)
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > RamLoc32
    __exidx_end = .;

    _etext = .;


    /* DATA section for RamLoc32 */
    .data_RAM2 : ALIGN(4)
    {
       FILL(0xff)
       *(.ramfunc.$RAM2)
       *(.ramfunc.$RamLoc32)
      *(.data.$RAM2*)
      *(.data.$RamLoc32*)
       . = ALIGN(4) ;
    } > RamLoc32 AT>RamLoc32

    /* DATA section for RamAHB32 */
    .data_RAM3 : ALIGN(4)
    {
       FILL(0xff)
       *(.ramfunc.$RAM3)
       *(.ramfunc.$RamAHB32)
      *(.data.$RAM3*)
      *(.data.$RamAHB32*)
       . = ALIGN(4) ;
    } > RamAHB32 AT>RamLoc32

    /* DATA section for RamAHB16 */
    .data_RAM4 : ALIGN(4)
    {
       FILL(0xff)
       *(.ramfunc.$RAM4)
       *(.ramfunc.$RamAHB16)
      *(.data.$RAM4*)
      *(.data.$RamAHB16*)
       . = ALIGN(4) ;
    } > RamAHB16 AT>RamLoc32

    /* DATA section for RamAHB_ETB16 */
    .data_RAM5 : ALIGN(4)
    {
       FILL(0xff)
       *(.ramfunc.$RAM5)
       *(.ramfunc.$RamAHB_ETB16)
      *(.data.$RAM5*)
      *(.data.$RamAHB_ETB16*)
       . = ALIGN(4) ;
    } > RamAHB_ETB16 AT>RamLoc32

    /* MAIN DATA SECTION */


    .uninit_RESERVED : ALIGN(4)
    {
        KEEP(*(.bss.$RESERVED*))
        . = ALIGN(4) ;
        _end_uninit_RESERVED = .;
    } > RamLoc32


  /* Main DATA section (RamLoc32) */
  .data : ALIGN(4)
  {
     FILL(0xff)
     _data = . ;
     *(vtable)
     *(.ramfunc*)
     *(.data*)
     . = ALIGN(4) ;
     _edata = . ;
  } > RamLoc32 AT>RamLoc32

    /* BSS section for RamLoc32 */
    .bss_RAM2 : ALIGN(4)
    {
      *(.bss.$RAM2*)
      *(.bss.$RamLoc32*)
       . = ALIGN(4) ;
    } > RamLoc32
    /* BSS section for RamAHB32 */
    .bss_RAM3 : ALIGN(4)
    {
      *(.bss.$RAM3*)
      *(.bss.$RamAHB32*)
       . = ALIGN(4) ;
    } > RamAHB32
    /* BSS section for RamAHB16 */
    .bss_RAM4 : ALIGN(4)
    {
      *(.bss.$RAM4*)
      *(.bss.$RamAHB16*)
       . = ALIGN(4) ;
    } > RamAHB16
    /* BSS section for RamAHB_ETB16 */
    .bss_RAM5 : ALIGN(4)
    {
      *(.bss.$RAM5*)
      *(.bss.$RamAHB_ETB16*)
       . = ALIGN(4) ;
    } > RamAHB_ETB16

    /* MAIN BSS SECTION */
    .bss : ALIGN(4)
    {
        _bss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4) ;
        _ebss = .;
        PROVIDE(end = .);
    } > RamLoc32

    /* NOINIT section for RamLoc32 */
    .noinit_RAM2 (NOLOAD) : ALIGN(4)
    {
      *(.noinit.$RAM2*)
      *(.noinit.$RamLoc32*)
       . = ALIGN(4) ;
    } > RamLoc32
    /* NOINIT section for RamAHB32 */
    .noinit_RAM3 (NOLOAD) : ALIGN(4)
    {
      *(.noinit.$RAM3*)
      *(.noinit.$RamAHB32*)
       . = ALIGN(4) ;
    } > RamAHB32
    /* NOINIT section for RamAHB16 */
    .noinit_RAM4 (NOLOAD) : ALIGN(4)
    {
      *(.noinit.$RAM4*)
      *(.noinit.$RamAHB16*)
       . = ALIGN(4) ;
    } > RamAHB16
    /* NOINIT section for RamAHB_ETB16 */
    .noinit_RAM5 (NOLOAD) : ALIGN(4)
    {
      *(.noinit.$RAM5*)
      *(.noinit.$RamAHB_ETB16*)
       . = ALIGN(4) ;
    } > RamAHB_ETB16

    /* DEFAULT NOINIT SECTION */
    .noinit (NOLOAD): ALIGN(4)
    {
        _noinit = .;
        *(.noinit*)
         . = ALIGN(4) ;
        _end_noinit = .;
    } > RamLoc32

    PROVIDE(_pvHeapStart = DEFINED(__user_heap_base) ? __user_heap_base : .);
    PROVIDE(_vStackTop = DEFINED(__user_stack_top) ? __user_stack_top : __top_RamLoc32 - 0);
}
