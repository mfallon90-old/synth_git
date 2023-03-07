`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: quadrant
// Tool Versions: Vivado 2020.2
//
// Description: This module takes in the unmapped LUT address, determines the 
// current quadrant, and maps the address for the correct LUT value and maps
// the sine wave ouput for the correct current quadrant
//////////////////////////////////////////////////////////////////////////////////

module quadrant #
    (
    parameter ADDR_BITS = 12,
    parameter DATA_BITS = 36,
    parameter DEPTH     = 4096
    )
    (
    input   wire    [ADDR_BITS+1:0] addr_in,
    input   wire    [DATA_BITS-1:0] data_in,
    output  reg     [ADDR_BITS-1:0] addr_out,
    output  reg     [DATA_BITS-1:0] data_out
    );

    wire    [1:0]   quad;

    assign quad = addr_in[ADDR_BITS+1:ADDR_BITS];

    always @(*) begin
        case(quad)
            2'b00 : addr_out    = addr_in[ADDR_BITS-1:0];
            2'b01 : addr_out    = DEPTH-1-addr_in[ADDR_BITS-1:0];
            2'b10 : addr_out    = addr_in[ADDR_BITS-1:0];
            2'b11 : addr_out    = DEPTH*2-1-addr_in[ADDR_BITS-1:0];
        endcase
    end

    always @(*) begin
        case(quad)
            2'b00 : data_out    =  data_in;
            2'b01 : data_out    =  data_in;
            2'b10 : data_out    = ~data_in+1;
            2'b11 : data_out    = ~data_in+1;
        endcase
    end

endmodule