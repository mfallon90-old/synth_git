`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: phase_modulate
// Tool Versions: Vivado 2020.2
//
// Description:
//           
//                       tau
//  step_delay     sum    |   product       envelope
//  ---------->(-)------>(x)--------->(+)----.----->
//              ^                      ^     |     
//              |                      |   .----.  
//              |     env_delay        |   |  -1|  
//              '----------------------'---| Z  |  
//                                         '----'  
//                                                 
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

module phase_modulate #(
    NUM_BITS    = 32,
    WI          = 2,
    WF          = 16
    )(
    input   wire                    clk,
    input   wire                    rst,
    input   wire    [7:0]           mod_scalar,
    input   wire    [NUM_BITS-1:0]  tuning_word,
    input   wire    [WI+WF-1:0]     mod_signal,
    input   wire                    acc_en,
    input   wire    [15:0]          curr_note,
    input   wire    [15:0]          note_enable,
    input   wire    [NUM_BITS-1:0]  mod_tau,
    input   wire                    mod_enable,
    output  wire    [NUM_BITS-1:0]  modulated_tuning_word
    );

    localparam  [NUM_BITS-1:0]  STEP = 32'h40000000;
    localparam  [NUM_BITS-1:0]  MAX  = 32'h3F000000;
    localparam  [NUM_BITS-1:0]  MIN  = 32'h00800000;

    reg                     state;

    localparam  S_RISE = 1'b0;
    localparam  S_FALL = 1'b1;

    wire    [NUM_BITS-1:0]  mod_scaled_0;
    wire    [NUM_BITS-1:0]  mod_scaled_1;

    wire    [NUM_BITS-1:0]  envelope;
    reg     [NUM_BITS-1:0]  envelope_reg;
    reg     [NUM_BITS-1:0]  env_delay;
    reg     [NUM_BITS-1:0]  step_delay;
    wire    [NUM_BITS-1:0]  product;
    wire    [NUM_BITS-1:0]  sum;
    reg     [NUM_BITS-1:0]  channel [0:15];
    integer                 i;

    assign  sum = step_delay - env_delay;
    assign  envelope = product + env_delay;
    assign  modulated_tuning_word = mod_scaled_1 + tuning_word;

    always @(posedge clk) begin
        if (rst) begin
            step_delay  <= 0;
            env_delay   <= 0;
            state       <= S_RISE;
        end

        else begin
            if (mod_enable) begin
                step_delay  <= STEP;
            end
            else begin
                step_delay  <= 0;
            end
                    
            if (acc_en) begin
                env_delay   <= envelope;
            end
        end
    end

    // Calculate the envelope value
    fixed_point_mult #(
            .WI_1   (4),
            .WF_1   (28),
            .WI_2   (4),
            .WF_2   (28),
            .WI_O   (4),
            .WF_O   (28))
        scalar (
            .in_1       (mod_tau),
            .in_2       (sum),
            .data_out   (product),
            .ovf        ()
        );

    
    // SCALE MODULATING SIGNAL TO A NORMALIZED VALUE OF 1
    fixed_point_mult #(
            .WI_1   (NUM_BITS),
            .WF_1   (0),
            .WI_2   (WI),
            .WF_2   (WF),
            .WI_O   (NUM_BITS),
            .WF_O   (0))
        normalize (
            .in_1       (tuning_word),
            .in_2       (mod_signal),
            .data_out   (mod_scaled_0),
            .ovf        ()
        );

    // SCALE MODULATING SIGNAL TO USER DEFINED VALUED
    fixed_point_mult #(
            .WI_1   (NUM_BITS),
            .WF_1   (0),
            .WI_2   (4),
            .WF_2   (28),
            .WI_O   (NUM_BITS),
            .WF_O   (0))
        scale (
            .in_1       (mod_scaled_0),
            .in_2       (envelope),
            .data_out   (mod_scaled_1),
            .ovf        ()
        );

endmodule
