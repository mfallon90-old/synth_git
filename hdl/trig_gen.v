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
    input   wire            [NUM_CHANNELS-1:0]  curr_note,
    input   wire unsigned   [NUM_BITS-1:0]      tuning_word,
    output  wire                                trigger
    );

    localparam  S_CHAN_0    = 4'b0000;
    localparam  S_CHAN_1    = 4'b0001;
    localparam  S_CHAN_2    = 4'b0010;
    localparam  S_CHAN_3    = 4'b0011;
    localparam  S_CHAN_4    = 4'b0100;
    localparam  S_CHAN_5    = 4'b0101;
    localparam  S_CHAN_6    = 4'b0110;
    localparam  S_CHAN_7    = 4'b0111;
    localparam  S_CHAN_8    = 4'b1000;
    localparam  S_CHAN_9    = 4'b1001;
    localparam  S_CHAN_10   = 4'b1010;
    localparam  S_CHAN_11   = 4'b1011;
    localparam  S_CHAN_12   = 4'b1100;
    localparam  S_CHAN_13   = 4'b1101;
    localparam  S_CHAN_14   = 4'b1110;
    localparam  S_CHAN_15   = 4'b1111;

    reg     [NUM_BITS-1:0]  acc;
    reg     [NUM_BITS-1:0]  trig_word;
    reg     [3:0]           state;
    wire                    is_less;

    assign  trigger = acc[NUM_BITS-1];
    assign  is_less = (tuning_word != 0) && (tuning_word < trig_word) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (rst) begin
            state           <= S_CHAN_0;
            trig_word       <= 0;
            acc             <= 0;
        end

        else begin
            case(state)
                S_CHAN_0 : begin
                    if (curr_note[1]) begin 
                        state       <= S_CHAN_1;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end
                
                S_CHAN_1 : begin
                    if (curr_note[2]) begin 
                        state       <= S_CHAN_2;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_2 : begin
                    if (curr_note[3]) begin 
                        state       <= S_CHAN_3;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_3 : begin
                    if (curr_note[4]) begin 
                        state       <= S_CHAN_4;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end
                
                S_CHAN_4 : begin
                    if (curr_note[5]) begin 
                        state       <= S_CHAN_5;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end
                
                S_CHAN_5 : begin
                    if (curr_note[6]) begin 
                        state       <= S_CHAN_6;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_6 : begin
                    if (curr_note[7]) begin 
                        state       <= S_CHAN_7;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_7 : begin
                    if (curr_note[8]) begin 
                        state       <= S_CHAN_8;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_8 : begin
                    if (curr_note[9]) begin 
                        state       <= S_CHAN_9;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end
                
                S_CHAN_9 : begin
                    if (curr_note[10]) begin 
                        state       <= S_CHAN_10;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_10 : begin
                    if (curr_note[11]) begin 
                        state       <= S_CHAN_11;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_11 : begin
                    if (curr_note[12]) begin 
                        state       <= S_CHAN_12;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_12 : begin
                    if (curr_note[13]) begin 
                        state       <= S_CHAN_13;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end
                
                S_CHAN_13 : begin
                    if (curr_note[14]) begin 
                        state       <= S_CHAN_14;
                         if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_14 : begin
                    if (curr_note[15]) begin 
                        state       <= S_CHAN_15;
                        if ((trig_word == 0) || is_less) begin 
                            trig_word   <= tuning_word;
                        end
                    end
                end

                S_CHAN_15 : begin
                    if (curr_note[0]) begin
                        state           <= S_CHAN_0;
                        trig_word       <= tuning_word;
                        if (trig_word == 0) begin
                            acc <= 0;
                        end
                        else begin
                            acc <= acc + trig_word;
                        end
                    end
                end
            endcase
        end
    end

endmodule