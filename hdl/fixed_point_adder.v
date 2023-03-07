`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// Date : 2/2/23
// Design Name: FM SYNTHESIZER
//
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module fixed_point_adder #
    (
    parameter   WI_1    = 8,
    parameter   WF_1    = 8,
    parameter   WI_2    = 8,
    parameter   WF_2    = 8,
    parameter   WI_O    = 16,
    parameter   WF_O    = 16
    )
    (
    input   wire    [WI_1+WF_1-1:0] in_1,
    input   wire    [WI_2+WF_2-1:0] in_2,
    output  reg     [WI_O+WF_O-1:0] data_out,
    output  reg                     ovf
    );

    // Establish number integer and fraction bits
    localparam  I_BITS  = WI_1>WI_2 ? WI_1 : WI_2;
    localparam  F_BITS  = WF_1>WF_2 ? WF_1 : WF_2;

    // Calculate difference between input integer and fraction bits
    localparam  I_DIFF  = WI_1>WI_2 ? WI_1-WI_2 : WI_2-WI_1;
    localparam  F_DIFF  = WF_1>WF_2 ? WF_1-WF_2 : WF_2-WF_1;

    // Internal signals
    wire    [I_BITS-1:0]        int_1;
    wire    [I_BITS-1:0]        int_2;
    wire    [F_BITS-1:0]        frac_1;
    wire    [F_BITS-1:0]        frac_2;
    wire    [I_BITS:0]          i_out;
    wire    [F_BITS-1:0]        f_out;
    wire    [I_BITS+F_BITS:0]   input_1;
    wire    [I_BITS+F_BITS:0]   input_2;
    wire    [I_BITS+F_BITS:0]   result;

    // This logic aligns the integer field of the inputs by sign extending the smaller input
    assign  int_1   = WI_1>WI_2 ? in_1[WI_1+WF_1-1:WF_1] : {{I_DIFF{in_1[WI_1+WF_1-1]}}, in_1[WI_1+WF_1-1:WF_1]};
    assign  int_2   = WI_2>WI_1 ? in_2[WI_2+WF_2-1:WF_2] : {{I_DIFF{in_2[WI_2+WF_2-1]}}, in_2[WI_2+WF_2-1:WF_2]};
    
    // This logic aligns the fraction field of the inputs by adding 0's to the smaller input
    assign  frac_1  = WF_1>WF_2 ? in_1[WF_1-1:0] : {in_1[WF_1-1:0], {F_DIFF{1'b0}}};
    assign  frac_2  = WF_2>WF_1 ? in_2[WF_2-1:0] : {in_2[WF_2-1:0], {F_DIFF{1'b0}}};
    
    // This concatenates the integer and fraction parts, aligning the inputs
    assign  input_1 = {{1{int_1[I_BITS-1]}}, int_1, frac_1};
    assign  input_2 = {{1{int_2[I_BITS-1]}}, int_2, frac_2};
    
    // This calculates the output and separates the integer and fraction fields
    assign  result  = input_1 + input_2;
    assign  {i_out, f_out} = result;

    always @(*)
    begin
        ovf = 1'b0;

        // If the desired integer bits are greater than the result then
        // sign extend the result to provide the additional bits, no overflow
        if (WI_O >= I_BITS+1)
            data_out[WI_O+WF_O-1:WF_O] = {{WI_O-(I_BITS+1'b1),{i_out[I_BITS]}}, i_out};

        // If the requested integer bits match the result, the pass the result.
        // If an overflow occurs then the wrapped value is passed through
        else if (WI_O == I_BITS)
        begin
            data_out[WI_O+WF_O-1:WF_O] = {i_out[I_BITS], i_out[I_BITS-2:0]};
            ovf = (in_1[WI_1+WF_1-1] && in_2[WI_2+WF_2-1] && ~result[I_BITS+F_BITS-1]) ||
                  (~in_1[WI_1+WF_1-1] && ~in_2[WI_2+WF_2-1] && result[I_BITS+F_BITS-1]) ?
                  1'b1 : 1'b0;
        end

        // If the requested integer bits are less than keep the sign bit and pass the
        // wrapped value through. If an overflow occurs than assert overflow flag
        else
        begin
            if (i_out[I_BITS] && ~&i_out[I_BITS-1:WI_O-1])
                ovf = 1'b1;

            else if(~i_out[I_BITS] && |i_out[I_BITS-1:WI_O-1])
                ovf = 1'b1;

            if (WI_O > 1)
                data_out[WI_O+WF_O-1:WF_O] = {i_out[I_BITS], i_out[WI_O-2:0]};
                
            else
                data_out[WI_O+WF_O-1:WF_O] = i_out[I_BITS];
        end

        // If the requested fraction bits are greater than the result
        // then add 0's to the end of the result
        if (WF_O >= F_BITS)
            data_out[WF_O-1:0] = {f_out, {WF_O-F_BITS{1'b0}}};

        // If the requested fraction bits match the result then pass
        // the result
        else if (WF_O == F_BITS)
            data_out[WF_O-1:0] = f_out;

        // If the requested fraction bits are less the the result then
        // truncate the bits from LSB up.
        else
            data_out[WF_O-1:0] = f_out[F_BITS-1:F_BITS-WF_O];
    end
endmodule