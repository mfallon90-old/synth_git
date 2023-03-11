//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// Date : 2/2/23
// Design Name: FM SYNTHESIZER
//
// Description: 
//////////////////////////////////////////////////////////////////////////////////

#ifndef MYLIB_FUNCTIONS_HPP
#define MYLIB_FUNCTIONS_HPP

    #include <stdio.h>
    #include "constants.hpp"

    void synth_init(unsigned int);
    void decode_volume(unsigned char);
    void decode_mod_amp(unsigned char);
    void decode_tau(unsigned char);
    car_mod decode_note(unsigned char, unsigned char, unsigned char);

#endif
