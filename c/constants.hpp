//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// Date : 2/2/23
// Design Name: FM SYNTHESIZER
//
// Description: 
//////////////////////////////////////////////////////////////////////////////////

#ifndef MYLIB_CONSTANTS_H
#define MYLIB_CONSTANTS_H


    //Register Base Address
    #define CAR_BASE_ADDR XPAR_FM_SYNTH_WRAPPER_0_BASEADDR
    #define MOD_BASE_ADDR (CAR_BASE_ADDR + (4*NUM_CHANNELS))
    #define VEL_BASE_ADDR (MOD_BASE_ADDR + (4*NUM_CHANNELS))
    #define CTRL_REG_ADDR (VEL_BASE_ADDR + (4*NUM_CHANNELS))

    //UART Base Address
    #define UART_ADDR XPAR_AXI_UART_WRAPPER_0_BASEADDR

    /*
    Basic structure for linked list, one is created for each channel in synthesizer. 
    Holds information regarding current state of channel
         -chan_num          : channel number
         -note              : holds tuning word for carrier note
         -mod               : holds tuning word for modulator note
         -index             : index to select carrier note from array
         -awaiting_reset    : set to 1 after note off from midi and reset to zero by interrupt
         -available         : set to 1 if channel not in use
         -enable            : set to 1 if channel in use, set to 0 to begin note off decay
    */
    struct node {
        unsigned int chan_num = 0;
        unsigned int note = 0;
        unsigned int mod = 0;
        unsigned char index = 255;
        int awaiting_reset = 0;
        bool available = true;
        bool enable = false;
        struct node *next;
    };

    /*
    Structure to hold information regarding a specific channel. Used when traversing linked list
        -rst_cnt        : hold current place in reset queue so each note is turned off in order
        -in_use         : boolean to determine if channel is in use
        -awaiting_rst   : set to 1 after note off from midi and reset to zero by interrupt
    */
    struct info {
        int rst_cnt = 0;
        bool in_use = false;
        int awaiting_rst = 0;
        node *index = NULL;
    };

    /*
    Used to associate carrier/modulator information with a specific channel
        -carrier    : tuning word of carrier
        -modulator  : tuning word of modulator
        -index      : used to index the tuning word array
    */
    struct car_mod {
        unsigned int carrier = 0;
        unsigned int modulator = 0;
        unsigned char index = 255;
    };

    /*
    Simple struct to hold each byte of a midi message
    */
    struct midi_message {
        unsigned char byte_1 = 0;
        unsigned char byte_2 = 0;
        unsigned char byte_3 = 0;
    };

    extern node *head, *tail;
    extern info note_info;
    extern car_mod notes;

    #define NOTE_OFF                0x80
    #define NOTE_ON                 0x90
    #define POLYPHONIC_AFTERTOUCH   0xA0
    #define CONTROL_CHANGE          0xB0
    #define PROGRAM_CHANGE          0xC0
    #define CHANNEL_AFTERTOUCH      0xD0
    #define PITCH_BEND              0xE0

    #define PATCH                   0x07
    #define MODULATE                0x0A
    #define MOD_AMP                 0x0B
    #define VOLUME                  0x5B

    #define S_STATUS            0
    #define S_NOTE_ON           1
    #define S_NOTE_OFF          2
    #define S_CONTROL_CHANGE    3
    #define S_VELOCITY_ON       4
    #define S_VELOCITY_OFF      5
    #define S_PATCH             6
    #define S_VOLUME            7
    #define S_MODULATE          8
    #define S_MOD_AMP           9
    #define S_PITCH_BEND_LSB    10
    #define S_PITCH_BEND_MSB    11

    #define NUM_CHANNELS 16
    #define MASK_ON  0X80000000
    #define MASK_OFF 0X7FFFFFFF

    #define TAU_ADDR 128

    #define VELOCITY_INIT   0b01000000000000000011000000000000

    #define WAVE_SEL_MASK   0b00111111111111111111111111111111
    #define SIN_WAVE_MASK   0b00000000000000000000000000000000
    #define SAW_WAVE_MASK   0b01000000000000000000000000000000
    #define SQR_WAVE_MASK   0b10000000000000000000000000000000
    #define TRI_WAVE_MASK   0b11000000000000000000000000000000
    
    #define CTRL_INIT       0b00000100000010000011110111101111

    #define MOD_AMP_RST 0b11000000001111111111111111111111
    #define VOLUME_RST  0b11111111110000000111111111111111

    /*
    These tuning words were calculated based on a MATLAB
    script and are a function of the sampling rate, 
    number of bits in the phase accumulator, and system
    clock frequency.

    These tuning words are only valid for a sampling
    rate of 128KHz. This was chosen to allow for highest
    possible frequency before aliasing for modulation.
    */
    #define C0    0b00000000000000110010011010001011
    #define CS0   0b00000000000000110101011010000001
    #define D0    0b00000000000000111000100101010000
    #define DS0   0b00000000000000111011111100100110
    #define E0    0b00000000000000111111100000101110
    #define F0    0b00000000000001000011010010011011
    #define FS0   0b00000000000001000111010010100000
    #define G0    0b00000000000001001011100001110011
    #define GS0   0b00000000000001010000000001001111
    #define A0    0b00000000000001010100110001110000
    #define AS0   0b00000000000001011001110100011001
    #define B0    0b00000000000001011111001010001101
    #define C1    0b00000000000001100100110100010110
    #define CS1   0b00000000000001101010110100000001
    #define D1    0b00000000000001110001001010100001
    #define DS1   0b00000000000001110111111001001011
    #define E1    0b00000000000001111111000001011100
    #define F1    0b00000000000010000110100100110110
    #define FS1   0b00000000000010001110100100111111
    #define G1    0b00000000000010010111000011100110
    #define GS1   0b00000000000010100000000010011101
    #define A1    0b00000000000010101001100011100000
    #define AS1   0b00000000000010110011101000110001
    #define B1    0b00000000000010111110010100011010
    #define C2    0b00000000000011001001101000101100
    #define CS2   0b00000000000011010101101000000011
    #define D2    0b00000000000011100010010101000001
    #define DS2   0b00000000000011101111110010010110
    #define E2    0b00000000000011111110000010111001
    #define F2    0b00000000000100001101001001101100
    #define FS2   0b00000000000100011101001001111111
    #define G2    0b00000000000100101110000111001100
    #define GS2   0b00000000000101000000000100111010
    #define A2    0b00000000000101010011000111000001
    #define AS2   0b00000000000101100111010001100010
    #define B2    0b00000000000101111100101000110100
    #define C3    0b00000000000110010011010001011000
    #define CS3   0b00000000000110101011010000000101
    #define D3    0b00000000000111000100101010000011
    #define DS3   0b00000000000111011111100100101100
    #define E3    0b00000000000111111100000101110010
    #define F3    0b00000000001000011010010011011000
    #define FS3   0b00000000001000111010010011111110
    #define G3    0b00000000001001011100001110011000
    #define GS3   0b00000000001010000000001001110101
    #define A3    0b00000000001010100110001110000001
    #define AS3   0b00000000001011001110100011000101
    #define B3    0b00000000001011111001010001100111
    #define C4    0b00000000001100100110100010110000
    #define CS4   0b00000000001101010110100000001010
    #define D4    0b00000000001110001001010100000101
    #define DS4   0b00000000001110111111001001011000
    #define E4    0b00000000001111111000001011100011
    #define F4    0b00000000010000110100100110110001
    #define FS4   0b00000000010001110100100111111100
    #define G4    0b00000000010010111000011100101111
    #define GS4   0b00000000010100000000010011101010
    #define A4    0b00000000010101001100011100000011
    #define AS4   0b00000000010110011101000110001010
    #define B4    0b00000000010111110010100011001110
    #define C5    0b00000000011001001101000101100000
    #define CS5   0b00000000011010101101000000010100
    #define D5    0b00000000011100010010101000001011
    #define DS5   0b00000000011101111110010010110001
    #define E5    0b00000000011111110000010111000110
    #define F5    0b00000000100001101001001101100010
    #define FS5   0b00000000100011101001001111110111
    #define G5    0b00000000100101110000111001011110
    #define GS5   0b00000000101000000000100111010100
    #define A5    0b00000000101010011000111000000101
    #define AS5   0b00000000101100111010001100010100
    #define B5    0b00000000101111100101000110011100
    #define C6    0b00000000110010011010001010111111
    #define CS6   0b00000000110101011010000000101001
    #define D6    0b00000000111000100101010000010110
    #define DS6   0b00000000111011111100100101100010
    #define E6    0b00000000111111100000101110001100
    #define F6    0b00000001000011010010011011000011
    #define FS6   0b00000001000111010010011111101111
    #define G6    0b00000001001011100001110010111100
    #define GS6   0b00000001010000000001001110101000
    #define A6    0b00000001010100110001110000001010
    #define AS6   0b00000001011001110100011000100111
    #define B6    0b00000001011111001010001100111000
    #define C7    0b00000001100100110100010101111111
    #define CS7   0b00000001101010110100000001010001
    #define D7    0b00000001110001001010100000101100
    #define DS7   0b00000001110111111001001011000100
    #define E7    0b00000001111111000001011100011000
    #define F7    0b00000010000110100100110110000110
    #define FS7   0b00000010001110100100111111011110
    #define G7    0b00000010010111000011100101111001
    #define GS7   0b00000010100000000010011101001111
    #define A7    0b00000010101001100011100000010101
    #define AS7   0b00000010110011101000110001001110
    #define B7    0b00000010111110010100011001110001
    #define C8    0b00000011001001101000101011111110
    #define CS8   0b00000011010101101000000010100010
    #define D8    0b00000011100010010101000001011000
    #define DS8   0b00000011101111110010010110001000
    #define E8    0b00000011111110000010111000110000
    #define F8    0b00000100001101001001101100001100
    #define FS8   0b00000100011101001001111110111100
    #define G8    0b00000100101110000111001011110001
    #define GS8   0b00000101000000000100111010011111
    #define A8    0b00000101010011000111000000101001
    #define AS8   0b00000101100111010001100010011101
    #define B8    0b00000101111100101000110011100010
    #define C9    0b00000110010011010001010111111100
    #define CS9   0b00000110101011010000000101000101
    #define D9    0b00000111000100101010000010101111
    #define DS9   0b00000111011111100100101100001111
    #define E9    0b00000111111100000101110001100001
    #define F9    0b00001000011010010011011000011001
    #define FS9   0b00001000111010010011111101111000
    #define G9    0b00001001011100001110010111100010
    #define GS9   0b00001010000000001001110100111101
    #define A9    0b00001010100110001110000001010011
    #define AS9   0b00001011001110100011000100111001
    #define B9    0b00001011111001010001100111000100
    #define C10   0b00001100100110100010101111111000
    #define CS10  0b00001101010110100000001010001001
    #define D10   0b00001110001001010100000101011111
    #define DS10  0b00001110111111001001011000011110
    #define E10   0b00001111111000001011100011000001
    #define F10   0b00010000110100100110110000110010
    #define FS10  0b00010001110100100111111011110000
    #define G10   0b00010010111000011100101111000101
    #define GS10  0b00010100000000010011101001111011
    #define A10   0b00010101001100011100000010100101
    #define AS10  0b00010110011101000110001001110010
    #define B10   0b00010111110010100011001110001000
    #define C11   0b00011001001101000101011111110000
    #define CS11  0b00011010101101000000010100010011
    #define D11   0b00011100010010101000001010111110
    #define DS11  0b00011101111110010010110000111101
    #define E11   0b00011111110000010111000110000011
    #define F11   0b00100001101001001101100001100011
    #define FS11  0b00100011101001001111110111100000
    #define G11   0b00100101110000111001011110001001
    #define GS11  0b00101000000000100111010011110101
    #define A11   0b00101010011000111000000101001011
    #define AS11  0b00101100111010001100010011100101
    #define B11   0b00101111100101000110011100001111

    // Tuning word array
    static const unsigned int TUNING_WORD[144] =   {C0,  CS0,  D0,  DS0,  E0,  F0,  FS0,  G0,  GS0,  A0,  AS0,  B0,
                                                    C1,  CS1,  D1,  DS1,  E1,  F1,  FS1,  G1,  GS1,  A1,  AS1,  B1,
                                                    C2,  CS2,  D2,  DS2,  E2,  F2,  FS2,  G2,  GS2,  A2,  AS2,  B2,
                                                    C3,  CS3,  D3,  DS3,  E3,  F3,  FS3,  G3,  GS3,  A3,  AS3,  B3,
                                                    C4,  CS4,  D4,  DS4,  E4,  F4,  FS4,  G4,  GS4,  A4,  AS4,  B4,
                                                    C5,  CS5,  D5,  DS5,  E5,  F5,  FS5,  G5,  GS5,  A5,  AS5,  B5,
                                                    C6,  CS6,  D6,  DS6,  E6,  F6,  FS6,  G6,  GS6,  A6,  AS6,  B6,
                                                    C7,  CS7,  D7,  DS7,  E7,  F7,  FS7,  G7,  GS7,  A7,  AS7,  B7,
                                                    C8,  CS8,  D8,  DS8,  E8,  F8,  FS8,  G8,  GS8,  A8,  AS8,  B8,
                                                    C9,  CS9,  D9,  DS9,  E9,  F9,  FS9,  G9,  GS9,  A9,  AS9,  B9,
                                                    C10, CS10, D10, DS10, E10, F10, FS10, G10, GS10, A10, AS10, B10,
                                                    C11, CS11, D11, DS11, E11, F11, FS11, G11, GS11, A11, AS11, B11};

#endif
