
`ifndef CONST_PCKG_DONE
`define CONST_PCKG_DONE

//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// Date : 2/2/23
// Design Name: FM SYNTHESIZER
//
// Description: 
//////////////////////////////////////////////////////////////////////////////////

    package const_pckg;

        // CARRIER ADDRESSES
        localparam CARRIER_0_ADDR  = 0;
        localparam CARRIER_1_ADDR  = 1;
        localparam CARRIER_2_ADDR  = 2;
        localparam CARRIER_3_ADDR  = 3;
        localparam CARRIER_4_ADDR  = 4;
        localparam CARRIER_5_ADDR  = 5;
        localparam CARRIER_6_ADDR  = 6;
        localparam CARRIER_7_ADDR  = 7;
        localparam CARRIER_8_ADDR  = 8;
        localparam CARRIER_9_ADDR  = 9;
        localparam CARRIER_10_ADDR = 10;
        localparam CARRIER_11_ADDR = 11;
        localparam CARRIER_12_ADDR = 12;
        localparam CARRIER_13_ADDR = 13;
        localparam CARRIER_14_ADDR = 14;
        localparam CARRIER_15_ADDR = 15;

        // MODULATOR ADDRESSES
        localparam MODULATOR_0_ADDR  = 16;
        localparam MODULATOR_1_ADDR  = 17;
        localparam MODULATOR_2_ADDR  = 18;
        localparam MODULATOR_3_ADDR  = 19;
        localparam MODULATOR_4_ADDR  = 20;
        localparam MODULATOR_5_ADDR  = 21;
        localparam MODULATOR_6_ADDR  = 22;
        localparam MODULATOR_7_ADDR  = 23;
        localparam MODULATOR_8_ADDR  = 24;
        localparam MODULATOR_9_ADDR  = 25;
        localparam MODULATOR_10_ADDR = 26;
        localparam MODULATOR_11_ADDR = 27;
        localparam MODULATOR_12_ADDR = 28;
        localparam MODULATOR_13_ADDR = 29;
        localparam MODULATOR_14_ADDR = 30;
        localparam MODULATOR_15_ADDR = 31;

        // VELOCITY ADDRESSES
        localparam VELOCITY_0_ADDR  = 32;
        localparam VELOCITY_1_ADDR  = 33;
        localparam VELOCITY_2_ADDR  = 34;
        localparam VELOCITY_3_ADDR  = 35;
        localparam VELOCITY_4_ADDR  = 36;
        localparam VELOCITY_5_ADDR  = 37;
        localparam VELOCITY_6_ADDR  = 38;
        localparam VELOCITY_7_ADDR  = 39;
        localparam VELOCITY_8_ADDR  = 40;
        localparam VELOCITY_9_ADDR  = 41;
        localparam VELOCITY_10_ADDR = 42;
        localparam VELOCITY_11_ADDR = 43;
        localparam VELOCITY_12_ADDR = 44;
        localparam VELOCITY_13_ADDR = 45;
        localparam VELOCITY_14_ADDR = 46;
        localparam VELOCITY_15_ADDR = 47;

        // CONTROL ADDRESS
        localparam CONTROL_REG_ADDR = 48;
        localparam RC_ATTACK_ADDR   = 49;
        localparam RC_DECAY_ADDR    = 50;
        localparam RC_RELEASE_ADDR  = 51;
        localparam MOD_TAU_ADDR     = 52;

    endpackage

`endif