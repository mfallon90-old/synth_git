`timescale 1ns / 1ps

module i2s_transmitter #
    (
    parameter NUM_BITS = 24,
    parameter NUM_CHAN = 16
    )
    (
    input   wire                    clk,
    input   wire                    rst,
    input   wire                    s_clk_pos,
    input   wire                    s_clk_neg,
    input   wire    [NUM_BITS-1:0]  word_in,
    output  wire                    serial_out,
    output  wire                    word_select,
    output  wire                    ready
    );

    wire                load;
    wire                ready_i;
    reg                 ready_1;
    reg                 ready_2;
    reg                 ready_3;
    reg [NUM_BITS-1:0]  count;
    reg                 ws_d0;
    reg                 ws_d1;
    reg                 ws_d2;

    assign  load        = ws_d1 ^ ws_d2;
    assign  word_select = ws_d0;

    generate 
        if (NUM_CHAN == 16) begin
            assign ready = ready_i & ready_3;
        end

        else if (NUM_CHAN == 8) begin
            assign  ready = ready_i & ready_1;
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            ready_1   <= 0;
            ready_2   <= 0;
            ready_3   <= 0;
        end

        else begin
                ready_1 <= ready_i;
                ready_2 <= ready_1;
                ready_3 <= ready_2;
        end
    end

    // always @(posedge s_clk) begin
    always @(posedge clk) begin
        if (rst) begin
            ws_d1   <= 0;
            ws_d2   <= 0;
        end

        else if (s_clk_pos) begin
            ws_d1   <= ws_d0;
            ws_d2   <= ws_d1;
        end
    end

    // always @(negedge s_clk) begin
    always @(posedge clk) begin
        if (rst) begin
            ws_d0   <= 0;
            count   <= 1;
        end

        else if (s_clk_neg) begin
            count   <= count << 1;
            if (count[NUM_BITS-1]) begin
                ws_d0   <= ~ws_d0;
                count   <= 1;
            end
        end
    end
    
    shift_reg #(
            .NUM_BITS   (NUM_BITS))
        serializer (
            .clk        (clk),
            .clk_en     (s_clk_neg),
            .rst        (rst),
            .load       (load),
            .word_in    (word_in),
            .serial_out (serial_out),
            .ready      (ready_i)
        );

endmodule