#include "functions.hpp"
#include "xil_printf.h"
#include "xil_io.h"
#include "constants.hpp"

    void synth_init(unsigned int init) {
    Xil_Out32(CTRL_REG_ADDR, init);
    for (int i=0; i<NUM_CHANNELS; i=i+1) {
        Xil_Out32(VEL_BASE_ADDR + 4*i, VELOCITY_INIT);
    }
    }

    void decode_volume(unsigned char x) {
        unsigned int vol, mask, reset;

        mask = x << 15;
        vol = Xil_In32(CTRL_REG_ADDR);
        reset = VOLUME_RST & vol;

        Xil_Out32(CTRL_REG_ADDR, mask | reset);
        return;
    }

    void decode_mod_amp(unsigned char x) {
        unsigned int mod_amp, mask, reset;

        mask = x << 23;
        mod_amp = Xil_In32(CTRL_REG_ADDR);
        reset = MOD_AMP_RST & mod_amp;

        Xil_Out32(CTRL_REG_ADDR, mask | reset);
        return;
    }

    void decode_patch(unsigned char x, unsigned char* patch) {

        if (x < 18) {
            *patch = 0;
        }

        else if (x < 36) {
            *patch = 1;
        }

        else if (x < 54) {
            *patch = 2;
        }

        else if (x < 72) {
            *patch = 3;
        }

        else if (x < 90) {
            *patch = 4;
        }

        else if (x < 108) {
            *patch = 5;
        }

        else {
            *patch = 6;
        }

        return;
    }

   car_mod decode_note(unsigned char x, unsigned char patch, unsigned char mod_byte) {
        car_mod notes;
        switch(x) {
            case 12  : notes.index = 0;   break;
            case 13  : notes.index = 1;   break;
            case 14  : notes.index = 2;   break;
            case 15  : notes.index = 3;   break;
            case 16  : notes.index = 4;   break;
            case 17  : notes.index = 5;   break;
            case 18  : notes.index = 6;   break;
            case 19  : notes.index = 7;   break;
            case 20  : notes.index = 8;   break;
            case 21  : notes.index = 9;   break;
            case 22  : notes.index = 10;  break;
            case 23  : notes.index = 11;  break;
            //------------------------------------
            case 24  : notes.index = 12;  break;
            case 25  : notes.index = 13;  break;
            case 26  : notes.index = 14;  break;
            case 27  : notes.index = 15;  break;
            case 28  : notes.index = 16;  break;
            case 29  : notes.index = 17;  break;
            case 30  : notes.index = 18;  break;
            case 31  : notes.index = 19;  break;
            case 32  : notes.index = 20;  break;
            case 33  : notes.index = 21;  break;
            case 34  : notes.index = 22;  break;
            case 35  : notes.index = 23;  break;
            //------------------------------------
            case 36  : notes.index = 24;  break;
            case 37  : notes.index = 25;  break;
            case 38  : notes.index = 26;  break;
            case 39  : notes.index = 27;  break;
            case 40  : notes.index = 28;  break;
            case 41  : notes.index = 29;  break;
            case 42  : notes.index = 30;  break;
            case 43  : notes.index = 31;  break;
            case 44  : notes.index = 32;  break;
            case 45  : notes.index = 33;  break;
            case 46  : notes.index = 34;  break;
            case 47  : notes.index = 35;  break;
            //------------------------------------
            case 48  : notes.index = 36;  break;
            case 49  : notes.index = 37;  break;
            case 50  : notes.index = 38;  break;
            case 51  : notes.index = 39;  break;
            case 52  : notes.index = 40;  break;
            case 53  : notes.index = 41;  break;
            case 54  : notes.index = 42;  break;
            case 55  : notes.index = 43;  break;
            case 56  : notes.index = 44;  break;
            case 57  : notes.index = 45;  break;
            case 58  : notes.index = 46;  break;
            case 59  : notes.index = 47;  break;
            //-----------------------------------
            case 60  : notes.index = 48;  break;
            case 61  : notes.index = 49;  break;
            case 62  : notes.index = 50;  break;
            case 63  : notes.index = 51;  break;
            case 64  : notes.index = 52;  break;
            case 65  : notes.index = 53;  break;
            case 66  : notes.index = 54;  break;
            case 67  : notes.index = 55;  break;
            case 68  : notes.index = 56;  break;
            case 69  : notes.index = 57;  break;
            case 70  : notes.index = 58;  break;
            case 71  : notes.index = 59;  break;
            //-----------------------------------
            case 72  : notes.index = 60;  break;
            case 73  : notes.index = 61;  break;
            case 74  : notes.index = 62;  break;
            case 75  : notes.index = 63;  break;
            case 76  : notes.index = 64;  break;
            case 77  : notes.index = 65;  break;
            case 78  : notes.index = 66;  break;
            case 79  : notes.index = 67;  break;
            case 80  : notes.index = 68;  break;
            case 81  : notes.index = 69;  break;
            case 82  : notes.index = 70;  break;
            case 83  : notes.index = 71;  break;
            //-----------------------------------
            case 84  : notes.index = 72;  break;
            case 85  : notes.index = 73;  break;
            case 86  : notes.index = 74;  break;
            case 87  : notes.index = 75;  break;
            case 88  : notes.index = 76;  break;
            case 89  : notes.index = 77;  break;
            case 90  : notes.index = 78;  break;
            case 91  : notes.index = 79;  break;
            case 92  : notes.index = 80;  break;
            case 93  : notes.index = 81;  break;
            case 94  : notes.index = 82;  break;
            case 95  : notes.index = 83;  break;
            //------------------------------------
            case 96  : notes.index = 84;  break;
            case 97  : notes.index = 85;  break;
            case 98  : notes.index = 86;  break;
            case 99  : notes.index = 87;  break;
            case 100 : notes.index = 88;  break;
            case 101 : notes.index = 89;  break;
            case 102 : notes.index = 90;  break;
            case 103 : notes.index = 91;  break;
            case 104 : notes.index = 92;  break;
            case 105 : notes.index = 93;  break;
            case 106 : notes.index = 94;  break;
            case 107 : notes.index = 95;  break;
            //-----------------------------------
            case 108 : notes.index = 96;  break;
            case 109 : notes.index = 97;  break;
            case 110 : notes.index = 98;  break;
            case 111 : notes.index = 99;  break;
            case 112 : notes.index = 100; break;
            case 113 : notes.index = 101; break;
            case 114 : notes.index = 102; break;
            case 115 : notes.index = 103; break;
            case 116 : notes.index = 104; break;
            case 117 : notes.index = 105; break;
            case 118 : notes.index = 106; break;
            case 119 : notes.index = 107; break;
            //---------------------------------
            case 120 : notes.index = 108; break;
            case 121 : notes.index = 109; break;
            case 122 : notes.index = 110; break;
            case 123 : notes.index = 111; break;
            case 124 : notes.index = 112; break;
            case 125 : notes.index = 113; break;
            case 126 : notes.index = 114; break;
            case 127 : notes.index = 115; break;
            case 128 : notes.index = 116; break;
            case 129 : notes.index = 117; break;
            case 130 : notes.index = 118; break;
            case 131 : notes.index = 119; break;
            //---------------------------------
            case 132 : notes.index = 120; break;
            case 133 : notes.index = 121; break;
            case 134 : notes.index = 122; break;
            case 135 : notes.index = 123; break;
            case 136 : notes.index = 124; break;
            case 137 : notes.index = 125; break;
            case 138 : notes.index = 126; break;
            case 139 : notes.index = 127; break;
            case 140 : notes.index = 128; break;
            case 141 : notes.index = 129; break;
            case 142 : notes.index = 130; break;
            case 143 : notes.index = 131; break;



            default  : notes.index = 255;   break;
        }

        if (notes.index != 255) {
            notes.carrier = TUNING_WORD[notes.index];
            notes.modulator = TUNING_WORD[12*patch+notes.index];
        }

        else {
            notes.carrier = 0;
            notes.modulator = 0;
        }

        if (patch == 0) {
            notes.modulator = 0;
        }
        else if (patch == 6) {
            notes.modulator = TUNING_WORD[mod_byte];
        }

        return notes;
    }


