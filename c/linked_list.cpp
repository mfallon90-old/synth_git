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
                Xil_Out32(BASE_ADDR + 4*(tmp->chan_num + NUM_CHANNELS), 0);
                Xil_Out32(BASE_ADDR + 4*tmp->chan_num, 0);
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

void linked_list::toggle_note(car_mod note) {
        info note_info = in_use(note.carrier);
        node *tmp = head;

    // If the note is not currently being played, then select the first
    // available channel and play the note
    if (note_info.in_use == false) {
        while (tmp != NULL) {
            if (tmp->available) {
                tmp->note = note.carrier;
                tmp->mod = note.modulator;
                tmp->index = note.index;
                Xil_Out32(BASE_ADDR + 4*(tmp->chan_num + NUM_CHANNELS), note.modulator);
                Xil_Out32(BASE_ADDR + 4*tmp->chan_num, (note.carrier | MASK_ON));
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
        Xil_Out32(BASE_ADDR + 4*tmp->chan_num, (note.carrier | MASK_ON));
        tmp->enable = true;
    }
    // If the note is currently being played then set the enable bit to 0 and 
    // set the reset counter to the last in line
    else {
        tmp = note_info.index;
        tmp->awaiting_reset = note_info.rst_cnt+1;
        Xil_Out32((BASE_ADDR + (4*tmp->chan_num)), (note.carrier & MASK_OFF));
        tmp->enable = false;
    }
    return;
}

void linked_list::toggle_modulator(car_mod note, unsigned char patch) {
    node *tmp = head;
    unsigned int mod_word = 0;

    while (tmp != NULL) {

        if (patch != 0) {
        mod_word = TUNING_WORD[12*patch+tmp->index];
        }
        else {
            mod_word = 0;
        }

        if (!tmp->available) {
            tmp->mod = mod_word;
            Xil_Out32(BASE_ADDR + 4*(tmp->chan_num + NUM_CHANNELS), mod_word);
        }
        tmp = tmp->next;
    }
    return;
}
