`timescale 1ns / 1ps
`define ADDR_WIDTH  ($clog2(DEPTH))
`define MAX THRESHOLD
`define MIN ((~THRESHOLD)+1)

module amp_shaper #
    (
    parameter NUM_BITS_TAU  = 5,
    parameter NUM_BITS_WORD = 18
    )
    (
    input   wire                        clk,
    input   wire                        rst,
    input   wire                        ready,
    input   wire                        note_en,
    input   wire    [NUM_BITS_TAU-1:0]  attack_tau,
    input   wire    [NUM_BITS_TAU-1:0]  decay_tau,
    input   wire    [NUM_BITS_TAU-1:0]  release_tau,
    input   wire    [NUM_BITS_WORD-1:0] word_in,
    output  wire    [NUM_BITS_WORD-1:0] word_out,
    output  wire                        available
    );

    localparam integer ENV_BITS = 24;

    wire    [ENV_BITS-1:0]  envelope;
    
    rc_filter_fsm #(
            .TAU_BITS   (NUM_BITS_TAU),
            .ENV_BITS   (ENV_BITS))
        envelope_shaper (
            .clk            (clk),
            .rst            (rst),
            .en             (note_en),
            .on             (ready),
            .attack_tau     (attack_tau),
            .decay_tau      (decay_tau),
            .release_tau    (release_tau),
            .available      (available),
            .envelope       (envelope)
        );

    fixed_point_mult #(
            .WI_1   (2),
            .WF_1   (ENV_BITS-2),
            .WI_2   (2),
            .WF_2   (NUM_BITS_WORD-2),
            .WI_O   (2),
            .WF_O   (NUM_BITS_WORD-2))
        amplitude_shaper (
            .in_1       (envelope),
            .in_2       (word_in),
            .data_out   (word_out),
            .ovf        ()
        );

endmodule