//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// Date : 2/2/23
// Design Name: FM SYNTHESIZER
//
// Description: 
//////////////////////////////////////////////////////////////////////////////////

#include "xparameters.h"
#include "xil_printf.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "xil_io.h"
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <cstdio>
#include "constants.hpp"
#include "linked_list.hpp"
#include "functions.hpp"

/*
General Interrupt Controller definitions and functions, these are necessary
to use interrupts in the zynq architecture
    -GIC_DEVICE_ID  : used to specify general interrupt controller in device
    -INTC_HANDLER   : used to specify interrupt handler function
    -GIC_Setup      : function to intialize interrupt controller
    -GIC            : instance of the General Interrupt Controller
*/
#define GIC_DEVICE_ID XPAR_SCUGIC_0_DEVICE_ID
#define INTC_HANDLER XScuGic_InterruptHandler
static int GIC_Setup(XScuGic* GicInst, u16 IntrId_1, u16 IntrId_2, u16 IntrId_3);
XScuGic GIC;

/*
Specific Interrupt definitions and functions unique to this design, one per interrupt
    -Interrupt ID's : used to address specific interrupts in build
    -Interrupt handler functions : user defined functions to service IRQ
*/
#define FPGA_SYNTH_INTR_ID XPAR_FABRIC_FM_SYNTH_WRAPPER_0_INTERRUPT_INTR
#define FPGA_UART_INTR_ID XPAR_FABRIC_AXI_UART_WRAPPER_0_MIDI_INTR_INTR
#define FPGA_WAVE_SEL_INTR_ID XPAR_FABRIC_DEBOUNCE_PULSE_0_INTERRUPT_INTR
void Synth_IRQ_Handler(void *CallbackRef);
void UART_IRQ_Handler(void *CallbackRef);
void Wave_Sel_IRQ_Handler(void *CallbackRef);

// Global linked list
linked_list channels;

int main(void) {

    // Used to verify correct initialization of interrupt controller
    int Status;
    Status = GIC_Setup(&GIC, FPGA_SYNTH_INTR_ID, FPGA_UART_INTR_ID, FPGA_WAVE_SEL_INTR_ID);

    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // Initialize synthesizer
    synth_init(CTRL_INIT);

    // Infinite while loop for
    // real-time embedded system
    while(1){}

return 1;
}

static int GIC_Setup(XScuGic *GicInst, u16 IntrId_1, u16 IntrId_2, u16 IntrId_3) {
    int Status;

    XScuGic_Config *IntcConfig;

    //Initialize the interrupt controller.
    IntcConfig = XScuGic_LookupConfig(GIC_DEVICE_ID);
    if (NULL == IntcConfig) {
        return XST_FAILURE;
    }

    Status = XScuGic_CfgInitialize(GicInst, IntcConfig,
    IntcConfig->CpuBaseAddress);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    XScuGic_SetPriorityTriggerType(GicInst, IntrId_1, 0xA0, 0x3);
    XScuGic_SetPriorityTriggerType(GicInst, IntrId_2, 0xA0, 0x3);
    XScuGic_SetPriorityTriggerType(GicInst, IntrId_3, 0xA0, 0x3);

    //Connect the interrupt handler to the GIC.
    Status = XScuGic_Connect(GicInst, IntrId_1, (Xil_ExceptionHandler)Synth_IRQ_Handler, 0);
    if (Status != XST_SUCCESS) {
        return Status;
    }

    //Connect the interrupt handler to the GIC.
    Status = XScuGic_Connect(GicInst, IntrId_2, (Xil_ExceptionHandler)UART_IRQ_Handler, 0);
    if (Status != XST_SUCCESS) {
        return Status;
    }

    //Connect the interrupt handler to the GIC.
    Status = XScuGic_Connect(GicInst, IntrId_3, (Xil_ExceptionHandler)Wave_Sel_IRQ_Handler, 0);
    if (Status != XST_SUCCESS) {
        return Status;
    }

    //Enable the interrupt for this specific device.
    XScuGic_Enable(GicInst, IntrId_1);
    XScuGic_Enable(GicInst, IntrId_2);
    XScuGic_Enable(GicInst, IntrId_3);

    //Initialize the exception table.
    Xil_ExceptionInit();

    //Register the interrupt controller handler with the exception table.
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) INTC_HANDLER, GicInst);

    //Enable non-critical exceptions.
    Xil_ExceptionEnable();

return XST_SUCCESS;
}

// IRQ Handling function
void Wave_Sel_IRQ_Handler(void *callbackRef){
    static unsigned char wave_sel = 0;
    unsigned int ctrl_reg = 0;
    unsigned int ctrl_reg_mskd = 0;

    ctrl_reg = Xil_In32(CTRL_REG_ADDR);
    ctrl_reg_mskd = WAVE_SEL_MASK & ctrl_reg;

    if (wave_sel < 3) {
        wave_sel = wave_sel + 1;
    }
    else {
        wave_sel = 0;
    }

    switch(wave_sel) {
        case 0 : Xil_Out32(CTRL_REG_ADDR, ctrl_reg_mskd | SIN_WAVE_MASK);    break;
        case 1 : Xil_Out32(CTRL_REG_ADDR, ctrl_reg_mskd | SAW_WAVE_MASK);    break;
        case 2 : Xil_Out32(CTRL_REG_ADDR, ctrl_reg_mskd | SQR_WAVE_MASK);    break;
        case 3 : Xil_Out32(CTRL_REG_ADDR, ctrl_reg_mskd | TRI_WAVE_MASK);    break;
    }
}

// IRQ Handling function
void Synth_IRQ_Handler(void *CallbackRef) {
    channels.make_available();
}

enum states {S_STATUS, S_NOTE_ON, S_NOTE_OFF, S_CONTROL_CHANGE,
             S_VELOCITY_ON, S_VELOCITY_OFF, S_PATCH, S_VOLUME,
             S_MOD_TAU, S_RC_TAU, S_PITCH_BEND_LSB, S_PITCH_BEND_MSB,
             S_MODULATE, S_ERROR};

struct midi_message {
    enum states curr_state;
    unsigned char curr_byte;
};

// unsigned int state = S_STATUS;
enum states state = S_STATUS;

unsigned char byte_in = 0;


unsigned char mode;
unsigned char status;
unsigned char on_note;
unsigned char off_note;
unsigned char control_change;
unsigned char velocity;
unsigned char volume;
unsigned char mod_byte = 0;
unsigned char mod_tau_byte;
unsigned int  pitch_bend_lsb;
unsigned int  pitch_bend_msb;
unsigned int  pitch_bend;
unsigned int  i = 0;
unsigned char patch = 60;
struct midi_message midi[40];

// IRQ Handling function
void UART_IRQ_Handler(void *CallbackRef) {

    car_mod notes;

    byte_in = (char) Xil_In32(UART_ADDR);
        
    // switch (i) {
    //     case 0 : midi->byte_1 = byte_in; i = i+1;   break;
    //     case 1 : midi->byte_2 = byte_in; i = i+1;   break;
    //     case 2 : midi->byte_3 = byte_in; i = 0;     break;
    // }

    midi[i].curr_state = state;
    midi[i].curr_byte = byte_in;
    if (i<40-1) {
        i=i+1;
    }
    else {
        i = 0;
    }

    switch (state) {
        case S_STATUS:
            status = byte_in;
            switch (status) {
                case NOTE_ON : 
                    state = S_NOTE_ON;
                    break;

                case NOTE_OFF : 
                    state = S_NOTE_OFF;
                    break;

                case CONTROL_CHANGE :
                    state = S_CONTROL_CHANGE;
                    break;

                case PITCH_BEND :
                    state = S_PITCH_BEND_LSB;
                    break;

                default :
                    state = S_ERROR;
                    break;
            }
            break;


        case S_ERROR:
            state = S_STATUS;
            break;

        case S_NOTE_ON:
            on_note = byte_in;
            state = S_VELOCITY_ON;
            break;


        case S_NOTE_OFF:
            off_note = byte_in;
            notes = decode_note(off_note, patch, mod_byte);
            if (notes.index != 255) {
                channels.note_off(notes);
            }
            state = S_VELOCITY_OFF;
            break;


        case S_CONTROL_CHANGE:
            control_change = byte_in;
            switch (control_change) {
                case PATCH    : state = S_PATCH;    break;
                case RC_TAU   : state = S_RC_TAU;   break;
                case MOD_AMP  : state = S_MOD_TAU;  break;
                case VOLUME   : state = S_VOLUME;   break;
                case MODULATE : state = S_MODULATE; break;
                default       : state = S_ERROR;    break;
            }
            break;


        case S_PATCH:
            patch = byte_in;
            channels.toggle_modulator(notes, patch);
            state = S_STATUS;
            break;


        case S_VOLUME:
            volume = byte_in;
            decode_volume(volume);
            state = S_STATUS;
            break;


        case S_RC_TAU:
            mod_byte = byte_in;
            decode_tau(mod_byte);
            state = S_STATUS;
            break;


        case S_MOD_TAU:
            mod_tau_byte = byte_in;
            decode_mod_tau(mod_tau_byte);
            state = S_STATUS;
            break;


        case S_MODULATE:
            modulate(byte_in);
            state = S_STATUS;
            break;


        case S_VELOCITY_ON:
            velocity = byte_in;
            notes = decode_note(on_note, patch, mod_byte);
            if (notes.index != 255) {
                channels.note_on(notes, velocity);
            }
            state = S_STATUS;
            break;


        case S_VELOCITY_OFF:
            velocity = byte_in;
            state = S_STATUS;
            break;


        case S_PITCH_BEND_LSB:
            pitch_bend_lsb = (unsigned int) byte_in;
            state = S_PITCH_BEND_MSB;
            break;

        case S_PITCH_BEND_MSB:
            pitch_bend_msb = (unsigned int) byte_in;
            pitch_bend = (pitch_bend_msb << 7) | pitch_bend_lsb;
            channels.bend_pitch(pitch_bend);
            state = S_STATUS;
            break;
    }

}



