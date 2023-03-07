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

module phase_acc #(
    parameter   NUM_BITS        = 32,
    parameter   NUM_CHANNELS    = 16
    )(
    input   wire                                clk,
    input   wire                                rst,
    input   wire            [NUM_CHANNELS-1:0]  acc_en,
    input   wire            [NUM_CHANNELS-1:0]  acc_clr,
    input   wire            [NUM_CHANNELS-1:0]  curr_note,
    input   wire unsigned   [NUM_BITS-1:0]      phi_in,
    output  reg  unsigned   [NUM_BITS-1:0]      phi_out
    );

    reg [NUM_BITS-1:0]  acc [0:NUM_CHANNELS-1];
    integer             i;

    always@(posedge clk) begin
        if (rst) begin
            for (i=0; i<NUM_CHANNELS; i=i+1) begin
                acc[i]  <= 0;
            end
        end

        else begin
            for (i=0; i<NUM_CHANNELS; i=i+1) begin
                if (acc_clr[i]) begin
                    acc[i]  <= 0;
                end

                else if (acc_en[i]) begin
                    acc[i]  <= acc[i] + phi_in;
                end
            end
        end
    end

    always @(*) begin
        for (i=0; i<NUM_CHANNELS; i=i+1) begin
            if (curr_note[i]) begin
                phi_out  = acc[i];
            end
        end
    end
endmodule