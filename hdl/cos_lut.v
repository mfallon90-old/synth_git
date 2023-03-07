`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: cos_lut
// Tool Versions: Vivado 2020.2
//
// Description: This module infers a dual port BRAM based LUT used to store values
// of cos. The bit-width is given by the WIDTH parameter and the LUT depth is given
// by the DEPTH parameter. The LUT is initialized with a .mem file containing the
// binary values to be stored in the LUT. This is referenced by INIT_VAL.
//////////////////////////////////////////////////////////////////////////////////

module cos_lut #(
    INIT_VAL    = "",   // Initial values of LUT
    WIDTH       = 18,   // Bit-width
    DEPTH       = 4096, // Depth of LUT
    ADDR_WIDTH  = 12    // Address width
    )(
    input   wire                    clk,
    input   wire [ADDR_WIDTH-1:0]   addr,
    output  reg  [WIDTH-1:0]        data_out
    );

// SIGNAL DECLARATION
    reg [WIDTH-1:0] lut [0:DEPTH-1];
    integer i;
// LUT INITIALIZATION
    initial begin
        $readmemb(INIT_VAL, lut, 0);
    end

// SYNCHRONOUS READS FROM LUT
    always@(posedge clk) begin
        data_out <= lut[addr];
    end

endmodule