#ifndef MYLIB_LINKED_LIST_HPP
#define MYLIB_LINKED_LIST_HPP

#include <stdio.h>
#include "constants.hpp"

class linked_list {
    node *head;
    node *tail;

    public:

        linked_list() {
            head = NULL;

            for (unsigned int i=0; i<NUM_CHANNELS; ++i) {
                append_node(i);
            }
        }

        void append_node(unsigned int);
        void make_available();
        info in_use(unsigned int);
        void toggle_note(car_mod);
        void toggle_modulator(car_mod, unsigned char);
};

#endif