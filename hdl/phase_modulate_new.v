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

module phase_modulate_new #(
    NUM_BITS    = 32,
    WI          = 2,
    WF          = 16,
    NUM_CHAN    = 16
    )(
    input   wire                    clk,
    input   wire                    rst,
    input   wire    [7:0]           mod_scalar,
    input   wire    [NUM_BITS-1:0]  tuning_word,
    input   wire    [WI+WF-1:0]     mod_signal,
    input   wire    [NUM_CHAN-1:0]  acc_en,
    input   wire    [NUM_CHAN-1:0]  curr_note,
    input   wire    [NUM_CHAN-1:0]  note_enable,
    input   wire    [NUM_BITS-1:0]  mod_tau,
    input   wire                    mod_enable,
    output  wire    [NUM_BITS-1:0]  modulated_tuning_word
    );

    localparam  [NUM_BITS-1:0]  STEP = 32'h40000000;
    localparam  [NUM_BITS-1:0]  MAX  = 32'h3F000000;
    localparam  [NUM_BITS-1:0]  MIN  = 32'h00800000;

    wire    [NUM_BITS-1:0]  mod_scaled_0;
    wire    [NUM_BITS-1:0]  mod_scaled_1;

    wire    [NUM_BITS-1:0]  envelope;
    reg     [NUM_BITS-1:0]  env_delay;
    reg     [NUM_BITS-1:0]  step_delay;
    wire    [NUM_BITS-1:0]  product;
    wire    [NUM_BITS-1:0]  sum;
    integer                 i;

    reg     [NUM_BITS-1:0]  env_reg     [NUM_CHAN-1:0];

    assign  sum = step_delay - env_delay;
    assign  envelope = product + env_delay;
    assign  modulated_tuning_word = mod_scaled_1 + tuning_word;

    always @(*) begin
        step_delay  = 0;
        case (1'b1)
            curr_note[0]  : begin
                env_delay   = env_reg[0];
                if (note_enable[0]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[1]  : begin
                env_delay   = env_reg[1];
                if (note_enable[1]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[2]  : begin
                env_delay   = env_reg[2];
                if (note_enable[2]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[3]  : begin
                env_delay   = env_reg[3];
                if (note_enable[3]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[4]  : begin
                env_delay   = env_reg[4];
                if (note_enable[4]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[5]  : begin
                env_delay   = env_reg[5];
                if (note_enable[5]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[6]  : begin
                env_delay   = env_reg[6];
                if (note_enable[6]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[7]  : begin
                env_delay   = env_reg[7];
                if (note_enable[7]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[8]  : begin
                env_delay   = env_reg[8];
                if (note_enable[8]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[9]  : begin
                env_delay   = env_reg[9];
                if (note_enable[9]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[10] : begin
                env_delay =  env_reg[10];
                if (note_enable[10]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[11] : begin
                env_delay =  env_reg[11];
                if (note_enable[11]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[12] : begin
                env_delay =  env_reg[12];
                if (note_enable[12]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[13] : begin
                env_delay =  env_reg[13];
                if (note_enable[13]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[14] : begin
                env_delay =  env_reg[14];
                if (note_enable[14]) begin
                    step_delay  = STEP;
                end
            end
            curr_note[15] : begin
                env_delay =  env_reg[15];
                if (note_enable[15]) begin
                    step_delay  = STEP;
                end
            end
            default       : begin
                env_delay    = env_reg[0];
                if (note_enable[0]) begin
                    step_delay  = STEP;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<NUM_CHAN; i=i+1) begin
                env_reg[i]  <= 0;
            end
        end

        else begin
            for (i=0; i<NUM_CHAN; i=i+1) begin
                if (acc_en[i]) begin
                    env_reg[i]    <= envelope;
                end
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
