`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Engineer: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: rc_filter
// Tool Versions: Vivado 2020.2
//
// Description:
//////////////////////////////////////////////////////////////////////////////////

module rc_filter #(
    NUM_BITS    = 32
    )(
    input   wire                clk,
    input   wire                rst,
    input   wire                en,
    input   wire                on,
    output  reg                 available,
    output  wire [NUM_BITS-1:0] envelope
    );

// CONSTANTS
    localparam  [NUM_BITS-1:0]  TAU = 32'h0808BE38;
    localparam  [NUM_BITS-1:0]  STEP = 1 << NUM_BITS-2;
    localparam  [NUM_BITS-1:0]  MIN  = 32'h00400000;

    reg     [NUM_BITS-1:0]  env_delay;
    reg     [NUM_BITS-1:0]  step_delay;
    wire    [NUM_BITS-1:0]  product;
    wire    [NUM_BITS-1:0]  sum;

    assign  sum = step_delay - env_delay;
    assign  envelope = product + env_delay;

    always@(posedge clk) begin
        if (rst) begin
            env_delay   <= 0;
            step_delay  <= 0;
            available   <= 0;
        end

        else begin
            available   <= 0;
            if (en) begin
                if (on) begin
                    step_delay  <= STEP;
                    env_delay   <= envelope;
                end
            end

            else begin
                if (on) begin
                    step_delay  <= 0;
                    env_delay   <= envelope;
                end

                if (envelope < MIN) begin
                    available   <= 1;
                end

                if (available) begin
                    env_delay   <= 0;
                    step_delay  <= 0;
                end
            end
        end
    end
    
    fixed_point_mult #(
            .WI_1   (2),
            .WF_1   (30),
            .WI_2   (2),
            .WF_2   (30),
            .WI_O   (2),
            .WF_O   (30))
        scalar (
            .in_1       (TAU),
            .in_2       (sum),
            .data_out   (product),
            .ovf        ()
        );

endmodule