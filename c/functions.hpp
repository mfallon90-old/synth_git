#ifndef MYLIB_FUNCTIONS_HPP
#define MYLIB_FUNCTIONS_HPP

    #include <stdio.h>
	#include "constants.hpp"

//    void decode_mod_amp();
    void decode_volume(unsigned char);
    void decode_patch(unsigned char, unsigned char*);
    car_mod decode_note(unsigned char, unsigned char);

#endif
