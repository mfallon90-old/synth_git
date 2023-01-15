`timescale 1ns / 1ps
`define ADDR_WIDTH  ($clog2(DEPTH))

module note_gen #(
    parameter   COS_LUT_VALUES  = "lut.mem",
    parameter   WIDTH           = 18,
    parameter   DEPTH           = 4096,
    parameter   NUM_BITS        = 32,
    parameter   NUM_CHANNELS    = 16
    )(
    input   wire                            clk,
    input   wire                            rst,
    input   wire    [1:0]                   wave_sel,
    input   wire    [NUM_CHANNELS-1:0]      acc_en,
    input   wire    [NUM_CHANNELS-1:0]      acc_clr,
    input   wire    [NUM_CHANNELS-1:0]      curr_note,
    input   wire    [NUM_BITS-1:0]          tuning_word,
    output  reg     [WIDTH-1:0]             wave_out
    );

    localparam HI = 18'b010000000000000000;
    localparam LO = 18'b110000000000000000;

    wire    [NUM_BITS-1:0]          phi_out;
    wire    [`ADDR_WIDTH+1:0]       addr;
    wire    [`ADDR_WIDTH-1:0]       addr_mapped;
    wire    [WIDTH-1:0]             lut_out;
    wire    [WIDTH-1:0]             sin_out;
    wire    [WIDTH-1:0]             sqr_out;

    assign addr = phi_out[NUM_BITS-1:NUM_BITS-`ADDR_WIDTH-2];

    always @(*) begin
        case (wave_sel)
            0 :         wave_out = sin_out;
            1 :         wave_out = phi_out[NUM_BITS-1:NUM_BITS-WIDTH];
            2 :         wave_out = phi_out[NUM_BITS-1] ? LO : HI;
            default :   wave_out = sin_out;
        endcase
    end

    phase_acc #(
            .NUM_BITS       (NUM_BITS),
            .NUM_CHANNELS   (NUM_CHANNELS))
        accumulator (
            .clk        (clk),
            .rst        (rst),
            .acc_en     (acc_en),
            .acc_clr    (acc_clr),
            .curr_note  (curr_note),
            .phi_in     (tuning_word),
            .phi_out    (phi_out)
        );

    quadrant #(
            .ADDR_BITS  (`ADDR_WIDTH),
            .DATA_BITS  (WIDTH),
            .DEPTH      (DEPTH))
        quad_logic (
            .addr_in    (addr),
            .data_in    (lut_out),
            .addr_out   (addr_mapped),
            .data_out   (sin_out)
        );

    cos_lut #(
            .INIT_VAL   (COS_LUT_VALUES),
            .WIDTH      (WIDTH),
            .DEPTH      (DEPTH),
            .ADDR_WIDTH (`ADDR_WIDTH))
        lut (
            .clk        (clk),
            .addr       (addr_mapped),
            .data_out   (lut_out)
        );

endmodule