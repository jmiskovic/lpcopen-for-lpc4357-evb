#include <stdint.h>
#include "board.h"

void sound_init(void)
{
    Status ret;
    I2S_AUDIO_FORMAT_T audio_config;
    audio_config.SampleRate = 48000;
    audio_config.ChannelNumber = 2;
    audio_config.WordWidth = 16;
    Board_Audio_Init(LPC_I2S0, UDA1380_LINE_IN);
    Chip_I2S_Init(LPC_I2S0);
    do {
        ret = Chip_I2S_RxConfig(LPC_I2S0, &audio_config);
    } while (ret != SUCCESS);
    do {
        ret = Chip_I2S_TxConfig(LPC_I2S0, &audio_config);
    } while (ret != SUCCESS);
    Chip_I2S_TxStop(LPC_I2S0);
    Chip_I2S_DisableMute(LPC_I2S0);
    Chip_I2S_TxStart(LPC_I2S0);
    Chip_I2S_RxStart(LPC_I2S0);
}

void sound_blocking_passthrough(void)
{
    uint8_t send_flag;
    uint32_t polling_data = 0;
    for (;;) {
        if (Chip_I2S_GetRxLevel(LPC_I2S0) > 0) {
            polling_data = Chip_I2S_Receive(LPC_I2S0);
            send_flag = 1;
        }
        if ((Chip_I2S_GetTxLevel(LPC_I2S0) < 4) && (send_flag == 1)) {
            Chip_I2S_Send(LPC_I2S0, polling_data);
            send_flag = 0;
        }
    }
}
