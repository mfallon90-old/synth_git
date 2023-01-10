`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Engineer: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: sum_notes_16
// Tool Versions: Vivado 2020.2
//
// Description: This is a simple mod NUM_BIT counter used to index the LUT. The
// key to this module is that it takes advantage of the wrap-around nature of a 
// mod-n counter to index a periodic function LUT
//////////////////////////////////////////////////////////////////////////////////

module sum_notes_16 #(
    parameter   NUM_BITS_IN     = 18,
    parameter   NUM_BITS_OUT    = 24
    )(
    input   wire    [16*NUM_BITS_IN-1:0]    notes_in,
    output  wire    [NUM_BITS_OUT-1:0]      note_out
    );

    wire    [NUM_BITS_IN-1:0]   notes_0 [0:15];
    wire    [NUM_BITS_IN:0]     notes_1 [0:7];
    wire    [NUM_BITS_IN+1:0]   notes_2 [0:3];
    wire    [NUM_BITS_IN+2:0]   notes_3 [0:1];

    genvar i;
    genvar k;
    genvar f;
    genvar h;

    generate 
        for (i=0; i<16; i=i+1) begin
            assign notes_0[i] = notes_in[NUM_BITS_IN*(i+1)-1:NUM_BITS_IN*i];
        end
    endgenerate

    //16 IN
    generate
        for (k=0; k<16; k=k+2) begin
            fixed_point_adder #(
                    .WI_1   (2),
                    .WF_1   (16),
                    .WI_2   (2),
                    .WF_2   (16),
                    .WI_O   (3),
                    .WF_O   (16))
                first_sum (
                    .in_1       (notes_0[k]),
                    .in_2       (notes_0[k+1]),
                    .data_out   (notes_1[k/2]),
                    .ovf        ()
                );
        end
    endgenerate

    //8 IN
    generate
        for (f=0; f<8; f=f+2) begin
            fixed_point_adder #(
                    .WI_1   (3),
                    .WF_1   (16),
                    .WI_2   (3),
                    .WF_2   (16),
                    .WI_O   (4),
                    .WF_O   (16))
                second_sum (
                    .in_1       (notes_1[f]),
                    .in_2       (notes_1[f+1]),
                    .data_out   (notes_2[f/2]),
                    .ovf        ()
                );
        end
    endgenerate

    // 4 IN
    generate
        for (h=0; h<4; h=h+2) begin
            fixed_point_adder #(
                    .WI_1   (4),
                    .WF_1   (16),
                    .WI_2   (4),
                    .WF_2   (16),
                    .WI_O   (5),
                    .WF_O   (16))
                second_sum (
                    .in_1       (notes_2[h]),
                    .in_2       (notes_2[h+1]),
                    .data_out   (notes_3[h/2]),
                    .ovf        ()
                );
        end
    endgenerate

    fixed_point_adder #(
            .WI_1   (5),
            .WF_1   (16),
            .WI_2   (5),
            .WF_2   (16),
            .WI_O   (6),
            .WF_O   (18))
        third_sum (
            .in_1       (notes_3[0]),
            .in_2       (notes_3[1]),
            .data_out   (note_out),
            .ovf        ()
        );
    
endmodule