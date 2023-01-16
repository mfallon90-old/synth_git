`timescale 1ns / 1ps
`define TOTAL_BITS (NUM_BITS*NUM_CHANNELS)
//////////////////////////////////////////////////////////////////////////////////
//
// Engineer: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: fm_synth_top
// Tool Versions: Vivado 2020.2
//
// Description: This is the top level wrapper for the fm synthesizer project.
//////////////////////////////////////////////////////////////////////////////////
//    parameter   TAU             = 32'h0008BE38,

module fm_synth_top #(
    parameter   COS_LUT_VALUES  = "lut.mem",
    parameter   NUM_CHANNELS    = 16,
    parameter   LATENCY         = 3,
    parameter   NUM_BRAM        = 32,
    parameter   NUM_BITS        = 32,
    parameter   WI_OUT          = 2,
    parameter   WF_OUT          = 16,
    parameter   NUM_BITS_DAC    = 24
    )(
    input   wire                        clk,
    input   wire                        rst,
    input   wire    [1:0]               wave_sel,
    input   wire    [`TOTAL_BITS-1:0]   carrier_in,
    input   wire    [`TOTAL_BITS-1:0]   modulator_in,
    input   wire    [`TOTAL_BITS-1:0]   velocity_in,
    input   wire    [4:0]               attack_tau,
    input   wire    [4:0]               decay_tau,
    input   wire    [4:0]               release_tau,
    input   wire    [7:0]               mod_amplitude,
    input   wire    [7:0]               volume_reg,
    output  wire                        word_select,
    output  wire                        serial_data,
    output  wire                        interrupt_out,
    output  wire                        s_clk
    );

    localparam DEPTH = NUM_BRAM*1024;
    localparam WIDTH = 18;

    wire    [NUM_BITS-1:0]          carrier_word;
    wire    [NUM_BITS-1:0]          mod_word;
    wire    [NUM_BITS-1:0]          modulated_tuning_word;
    wire    [WI_OUT+WF_OUT-1:0]     car_out;
    wire    [WI_OUT+WF_OUT-1:0]     mod_sig;
    wire    [NUM_BITS_DAC-1:0]      final_word;
    wire    [NUM_BITS_DAC-1:0]      final_word_vol;
    wire    [NUM_CHANNELS-1:0]      note_en;
    wire    [NUM_CHANNELS-1:0]      car_reg_en;
    wire    [NUM_CHANNELS-1:0]      car_acc_en;
    wire    [NUM_CHANNELS-1:0]      mod_reg_en;
    wire    [NUM_CHANNELS-1:0]      mod_acc_en;
    wire    [NUM_CHANNELS-1:0]      mod_acc_clr;
    wire    [NUM_CHANNELS-1:0]      curr_note;
    wire    [NUM_CHANNELS-1:0]      available;
    wire                            ready;
    wire                            s_clk_pos;
    wire                            s_clk_neg;

    // CONTROL UNIT
    control_unit #(
            .NUM_BITS       (NUM_BITS),
            .NUM_CHANNELS   (NUM_CHANNELS),
            .LATENCY        (LATENCY))
        controller (
            .clk            (clk),
            .rst            (rst),
            .en             (ready),
            .carrier_in     (carrier_in),
            .modulator_in   (modulator_in),
            .available      (available),
            .note_en        (note_en),
            .car_reg_en     (car_reg_en),
            .car_acc_en     (car_acc_en),
            .mod_reg_en     (mod_reg_en),
            .mod_acc_en     (mod_acc_en),
            .mod_acc_clr    (mod_acc_clr),
            .curr_note      (curr_note),
            .carrier_word   (carrier_word),
            .mod_word       (mod_word),
            .interrupt_out  (interrupt_out),
            .s_clk          (s_clk),
            .s_clk_pos      (s_clk_pos),
            .s_clk_neg      (s_clk_neg)
        );

    // GENERATE MODULATING SIGNAL
    note_gen #(
            .COS_LUT_VALUES (COS_LUT_VALUES),
            .WIDTH          (WIDTH),
            .DEPTH          (DEPTH),
            .NUM_BITS       (NUM_BITS))
        modulating_signal (
            .clk            (clk),
            .rst            (rst),
            .wave_sel       (0),
            .acc_en         (mod_acc_en),
            .acc_clr        (mod_acc_clr),
            .curr_note      (curr_note),
            .tuning_word    (mod_word),
            .wave_out       (mod_sig)
        );

    // APPLY MODULATING SIGNAL
    phase_modulate #(
            .NUM_BITS   (NUM_BITS),
            .WI         (WI_OUT),
            .WF         (WF_OUT))
        apply_modulation (
            .mod_scalar             (mod_amplitude),
            .tuning_word            (carrier_word),
            .mod_signal             (mod_sig),
            .modulated_tuning_word  (modulated_tuning_word)
        );

    // GENERATE FM SIGNAL
    note_gen #(
            .COS_LUT_VALUES (COS_LUT_VALUES),
            .WIDTH          (WIDTH),
            .DEPTH          (DEPTH),
            .NUM_BITS       (NUM_BITS))
        carrier_signal (
            .clk            (clk),
            .rst            (rst),
            .wave_sel       (wave_sel),
            .acc_en         (car_acc_en),
            .acc_clr        (0),
            .curr_note      (curr_note),
            .tuning_word    (modulated_tuning_word),
            .wave_out       (car_out)
        );

    // REGISTER OUTPUTS
    note_registers #(
            .NUM_BITS_IN    (WIDTH),
            .NUM_BITS_OUT   (NUM_BITS_DAC),
            .NUM_BITS_TAU   (5),
            .NUM_CHANNELS   (NUM_CHANNELS))
        note_sum_point (
            .clk            (clk),
            .rst            (rst),
            .reg_en         (car_reg_en),
            .note_en        (note_en),
            .note_in        (car_out),
            .velocity_in    (velocity_in),
            .attack_tau     (attack_tau),
            .decay_tau      (decay_tau),
            .release_tau    (release_tau),
            .note_out       (final_word),
            .available      (available)
        );

    // SCALE MODULATING SIGNAL TO USER DEFINED VALUED
    fixed_point_mult #(
            .WI_1   (8),
            .WF_1   (16),
            .WI_2   (8),
            .WF_2   (0),
            .WI_O   (10),
            .WF_O   (14))
        volume (
            .in_1       (final_word),
            .in_2       (volume_reg),
            .data_out   (final_word_vol),
            .ovf        ()
        );

    // TRANSMIT AUDIO WORDS
    i2s_transmitter #(
            .NUM_BITS   (NUM_BITS_DAC),
            .NUM_CHAN   (NUM_CHANNELS))
        i2s_tx (
            .clk        (clk),
            .rst        (rst),
            .s_clk_pos  (s_clk_pos),
            .s_clk_neg  (s_clk_neg),
            .word_in    (final_word_vol),
            .serial_out (serial_data),
            .word_select(word_select),
            .ready      (ready)
        );

endmodule