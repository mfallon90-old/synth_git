`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Engineer: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: phase_modulate
// Tool Versions: Vivado 2020.2
//
// Description:
//////////////////////////////////////////////////////////////////////////////////

module phase_modulate #(
    NUM_BITS    = 32,
    WI          = 2,
    WF          = 16
    )(
    input   wire    [1:0]           mod_scalar,
    input   wire    [NUM_BITS-1:0]  tuning_word,
    input   wire    [WI+WF-1:0]     mod_signal,
    output  wire    [NUM_BITS-1:0]  modulated_tuning_word
    );

    wire    [NUM_BITS-1:0]          mod_scaled_0;
    reg     [NUM_BITS-1:0]          mod_scaled_1;

    // assign modulated_tuning_word = mod_scaled_0 + tuning_word;
    assign modulated_tuning_word = mod_scaled_1 + tuning_word;

    always @(*) begin
        case (mod_scalar)
            2'b00 : mod_scaled_1 = mod_scaled_0;
            2'b01 : mod_scaled_1 = mod_scaled_0 << 1;
            2'b10 : mod_scaled_1 = mod_scaled_0 << 2;
            2'b11 : mod_scaled_1 = mod_scaled_0 << 3;
        endcase
    end
    
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
    // fixed_point_mult #(
    //         .WI_1   (NUM_BITS),
    //         .WF_1   (0),
    //         .WI_2   (16),
    //         .WF_2   (16),
    //         .WI_O   (NUM_BITS),
    //         .WF_O   (0))
    //     scale (
    //         .in_1       (mod_scaled_0),
    //         .in_2       (mod_scalar),
    //         .data_out   (mod_scaled_1),
    //         .ovf        ()
    //     );

endmodule