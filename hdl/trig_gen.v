`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: phase_acc
// Tool Versions: Vivado 2020.2
//
// Description: This is a simple mod NUM_BIT counter used to index the LUT. The
// key to this module is that it takes advantage of the wrap-around nature of a 
// mod-n counter to index a periodic function LUT
//////////////////////////////////////////////////////////////////////////////////

module trig_gen #(
    parameter   NUM_BITS        = 32,
    parameter   NUM_CHANNELS    = 16
    )(
    input   wire                                clk,
    input   wire                                rst,
    input   wire                                trig_en,
    input   wire            [NUM_CHANNELS-1:0]  curr_note,
    input   wire unsigned   [NUM_BITS-1:0]      tuning_word,
    output  wire                                trigger
    );

    reg     [NUM_BITS-1:0]  acc;
    reg     [NUM_BITS-1:0]  trig_word;
    wire                    is_less;

    assign  trigger = acc[NUM_BITS-1];
    assign  is_zero = trig_word == 0 ? 1'b1 : 1'b0;
    assign  is_less = (tuning_word != 0) && (tuning_word < trig_word) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (rst) begin
            trig_word       <= 0;
            acc             <= 0;
        end

        else begin
            if (is_zero | is_less) begin
                trig_word   <= tuning_word;
            end

            if (trig_en) begin
                acc         <= acc + trig_word;
                trig_word   <= tuning_word;
                if (trig_word == 0) begin
                    acc <= 0;
                end
            end
        end
    end

endmodule