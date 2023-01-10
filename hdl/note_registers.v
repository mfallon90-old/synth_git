`timescale 1ns / 1ps
`define TOTAL_BITS (NUM_CHANNELS*NUM_BITS_IN)
//////////////////////////////////////////////////////////////////////////////////
//
// Engineer: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: note_registers
// Tool Versions: Vivado 2020.2
//
// Description: This is a simple mod NUM_BIT counter used to index the LUT. The
// key to this module is that it takes advantage of the wrap-around nature of a 
// mod-n counter to index a periodic function LUT
//////////////////////////////////////////////////////////////////////////////////

module note_registers #(
    parameter   NUM_BITS_IN     = 18,
    parameter   NUM_BITS_OUT    = 24,
    parameter   NUM_BITS_TAU    = 5,
    parameter   NUM_CHANNELS    = 16
    )(
    input   wire                        clk,
    input   wire                        rst,
    input   wire    [NUM_CHANNELS-1:0]  reg_en,
    input   wire    [NUM_CHANNELS-1:0]  note_en,
    input   wire    [NUM_BITS_IN-1:0]   note_in,
    input   wire    [NUM_BITS_TAU-1:0]  attack_tau,
    input   wire    [NUM_BITS_TAU-1:0]  decay_tau,
    input   wire    [NUM_BITS_TAU-1:0]  release_tau,
    output  wire    [NUM_BITS_OUT-1:0]  note_out,
    output  wire    [NUM_CHANNELS-1:0]  available
    );

    reg     [NUM_BITS_IN-1:0]   notes           [0:NUM_CHANNELS-1];
    wire    [NUM_BITS_IN-1:0]   notes_shaped    [0:NUM_CHANNELS-1];
    wire    [`TOTAL_BITS-1:0]   notes_shaped_flat;
    reg     [NUM_BITS_OUT-1:0]  note_out_reg;
    wire    [NUM_BITS_OUT-1:0]  note_out_i;
    reg                         latch;
    integer                     i;
    genvar                      j;
    genvar                      k;
    genvar                      f;
    genvar                      h;

    assign  note_out = note_out_reg;

    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<NUM_CHANNELS; i=i+1) begin
                notes[i]    <= 0;
            end
        end

        else begin
            for (i=0; i<NUM_CHANNELS; i=i+1) begin
                if (reg_en[i]) begin
                    notes[i]    <= note_in;
                end
            end
        end
    end

    generate
        for (j=0; j<NUM_CHANNELS; j=j+1) begin
            assign notes_shaped_flat[NUM_BITS_IN*(j+1)-1:NUM_BITS_IN*j] = notes_shaped[j];

            amp_shaper #(
                    .NUM_BITS_TAU   (NUM_BITS_TAU),
                    .NUM_BITS_WORD  (NUM_BITS_IN))
                envelope_shaper (
                    .clk            (clk),
                    .rst            (rst),
                    .ready          (reg_en[j]),
                    .note_en        (note_en[j]),
                    .attack_tau     (attack_tau),
                    .decay_tau      (decay_tau),
                    .release_tau    (release_tau),
                    .word_in        (notes[j]),
                    .word_out       (notes_shaped[j]),
                    .available      (available[j])
                );
        end
    endgenerate

    generate
        if (NUM_CHANNELS == 8) begin
            sum_notes_8 #(
                    .NUM_BITS_IN    (NUM_BITS_IN),
                    .NUM_BITS_OUT   (NUM_BITS_OUT))
                sum_8 (
                    .notes_in   (notes_shaped_flat),
                    .note_out   (note_out_i)
                );
            end

        else if (NUM_CHANNELS == 16) begin
            sum_notes_16 #(
                    .NUM_BITS_IN    (NUM_BITS_IN),
                    .NUM_BITS_OUT   (NUM_BITS_OUT))
                sum_16 (
                    .notes_in   (notes_shaped_flat),
                    .note_out   (note_out_i)
                );
            end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            note_out_reg    <= 0;
            latch           <= 0;
        end

        else begin
            if (latch) begin
                note_out_reg    <= note_out_i;
                latch           <= 0;
            end

            else begin
                latch   <= reg_en[NUM_CHANNELS-1];
            end
        end
    end

endmodule