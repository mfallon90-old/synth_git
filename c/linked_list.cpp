//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// Date : 2/2/23
// Design Name: FM SYNTHESIZER
//
// Description: 
//////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include "xil_printf.h"
#include "xil_io.h"
#include "linked_list.hpp"

// Function to append a node to the list
void linked_list::append_node(unsigned int channel) {
    // Create new node
    node *tmp = new node;
    tmp->next = NULL;
    tmp->chan_num = channel;

    // If this is the first node,
    // make it the first and last
    if(head == NULL) {
        head = tmp;
        tail = tmp;
    }
    
    // Otherwise, append it to the end
    else {
        tail->next = tmp;
        tail = tail->next;
    }
    return;
}


// Set available to high when interrupt is seen
void linked_list::make_available() {
    node *tmp = head;
    while (tmp != NULL) {
        if (tmp->awaiting_reset != 0) {
            if (tmp->awaiting_reset == 1) {
                tmp->awaiting_reset = 0;
                Xil_Out32(VEL_BASE_ADDR + 4*tmp->chan_num, 0);
                Xil_Out32(MOD_BASE_ADDR + 4*tmp->chan_num, 0);
                Xil_Out32(CAR_BASE_ADDR + 4*tmp->chan_num, 0);
                tmp->note = 0;
                tmp->mod = 0;
                tmp->index = 255;
                tmp->available = true;
            }

            else {
                tmp->awaiting_reset -= 1;
            }
        }
        tmp = tmp->next;
    }
    return;
}


// Traverse the linked list and keep track of whether
// the note is being played, and how many paths are
// waiting to be reset
info linked_list::in_use(unsigned int note) {
    node *tmp = head;
    info note_info;
    while (tmp != NULL) {
        if (tmp->note == note) {
            note_info.in_use = true;
            note_info.index = tmp;
            note_info.awaiting_rst = tmp->awaiting_reset;
        }
        if (tmp->awaiting_reset != 0) {
            note_info.rst_cnt += 1;
        }
        tmp = tmp->next;
    }
    return note_info;
}

// Traverse through the linked list and play the note on the first
// available channel
void linked_list::note_on(car_mod note, unsigned char velocity) {
        info note_info = in_use(note.carrier);
        node *tmp = head;
        unsigned int attack = velocity << 26;
        unsigned int decay = velocity << 6;
        // unsigned int decay = velocity << 8;
        unsigned int velocity_in = attack | decay;

    // If the note is not currently being played, then select the first
    // available channel and play the note
    if (note_info.in_use == false) {
        while (tmp != NULL) {
            if (tmp->available) {
                tmp->note = note.carrier;
                tmp->mod = note.modulator;
                tmp->index = note.index;
                Xil_Out32(VEL_BASE_ADDR + 4*tmp->chan_num, velocity_in);
                Xil_Out32(MOD_BASE_ADDR + 4*tmp->chan_num, note.modulator);
                Xil_Out32(CAR_BASE_ADDR + 4*tmp->chan_num, (note.carrier | MASK_ON));
                tmp->available = false;
                tmp->enable = true;
                return;
            }
            else {
                tmp = tmp->next;
            }
        }
    }
        
    // If the note is being played but has been turned off and is awaiting the
    // hardware interrupt, then re-enable the channel and note
    else if (note_info.awaiting_rst != 0) {
        tmp = note_info.index;
        tmp->awaiting_reset = 0;
        Xil_Out32(VEL_BASE_ADDR + 4*tmp->chan_num, velocity_in);
        Xil_Out32(CAR_BASE_ADDR + 4*tmp->chan_num, (note.carrier | MASK_ON));
        tmp->enable = true;
    }
    return;
}

// Traverse the linked list, find which channel
// is playing the note, and turn it off
void linked_list::note_off(car_mod note) {
        info note_info = in_use(note.carrier);
        node *tmp = head;

    // If the note is currently being played then set the enable bit to 0 and 
    // set the reset counter to the last in line
    if (note_info.in_use == true) {
        tmp = note_info.index;
        tmp->awaiting_reset = note_info.rst_cnt+1;
        Xil_Out32((CAR_BASE_ADDR + 4*tmp->chan_num), (note.carrier & MASK_OFF));
        tmp->enable = false;
    }
    return;
}

// Traverse the linked list and apply the new modulation patch to 
// every note currently being played
void linked_list::toggle_modulator(car_mod note, unsigned char patch) {
    node *tmp = head;
    unsigned int mod_word = 0;

    while (tmp != NULL) {

        mod_word = TUNING_WORD[(patch-60)+tmp->index];

        if (!tmp->available) {
            tmp->mod = mod_word;
            Xil_Out32(MOD_BASE_ADDR + 4*tmp->chan_num, mod_word);
        }
        tmp = tmp->next;
    }
    return;
}

// Traverse the linked list and apply the new
// modulation to every note that is being played
void linked_list::modulate(unsigned char x) {
    node *tmp = head;
    while (tmp != NULL) {
        if (tmp->enable == true) {
            tmp->mod = TUNING_WORD[x];
            Xil_Out32(MOD_BASE_ADDR + 4*tmp->chan_num, tmp->mod);
        }
        tmp = tmp->next;
    }
    return;
}

// Apply pitch bend
void linked_list::bend_pitch(unsigned int x) {
    node *tmp = head;
    unsigned int bend = x & 0x00001FFF;
    unsigned int bend_up;
    unsigned int bend_down;
    unsigned int sign = x >> 13;
    unsigned int diff_up;
    unsigned int diff_down;
    unsigned int interval_up;
    unsigned int interval_down;
    unsigned int new_note;
    while (tmp != NULL) {
        if (tmp->enable == true) {
            diff_up   = (TUNING_WORD[tmp->index+1] - tmp->note);
            diff_down = (tmp->note - TUNING_WORD[tmp->index-1]);
            interval_up   = diff_up   >> 13;
            interval_down = diff_down >> 13;
            bend_up = bend*interval_up;
            bend_down = (8192-bend)*interval_down;
            new_note = sign ? tmp->note+bend_up : tmp->note-bend_down;
            Xil_Out32(CAR_BASE_ADDR + 4*tmp->chan_num, new_note | MASK_ON);
        }
        tmp = tmp->next;
    }
    return;
}
