`timescale 1ns / 1ps

module shift_reg #
    (
    parameter NUM_BITS = 24
    )
    (
    input   wire                    clk,
    input   wire                    clk_en,
    input   wire                    rst,
    input   wire                    load,
    input   wire    [NUM_BITS-1:0]  word_in,
    output  wire                    serial_out,
    output  reg                     ready
    );

    reg [NUM_BITS-1:0]          word_reg;
    reg [NUM_BITS-1:0]          count;

    assign  serial_out = word_reg[NUM_BITS-1];

    // always @(negedge clk)
    always @(posedge clk)
        if (rst) begin
            word_reg    <= 0;
            count       <= 0;
            ready       <= 0;
        end 

        else if (clk_en) begin
            // Default values
            word_reg    <= word_reg << 1;
            count       <= count << 1;
            ready       <= 0;

            if (load) begin
                word_reg    <= word_in;
                count       <= 1;
            end

            else if (count[NUM_BITS-2]) begin
                ready       <= 1;
            end

        end
endmodule