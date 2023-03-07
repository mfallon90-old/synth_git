`timescale 1ns / 1ps
`define TOTAL_BITS (NUM_BITS*NUM_CHANNELS)
`define STEP (6)

//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// Date : 2/2/23
// Design Name: FM SYNTHESIZER
//
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module control_unit #(
    parameter   NUM_BITS        = 32,
    parameter   NUM_CHANNELS    = 16,
    parameter   LATENCY         = 3
    )(
    input   wire                        clk,
    input   wire                        rst,
    input   wire                        en,
    input   wire    [`TOTAL_BITS-1:0]   carrier_in,
    input   wire    [`TOTAL_BITS-1:0]   modulator_in,
    input   wire    [NUM_CHANNELS-1:0]  available,
    output  wire    [NUM_CHANNELS-1:0]  note_en,
    output  wire    [NUM_CHANNELS-1:0]  car_reg_en,
    output  wire    [NUM_CHANNELS-1:0]  car_acc_en,
    output  wire    [NUM_CHANNELS-1:0]  mod_reg_en,
    output  wire    [NUM_CHANNELS-1:0]  mod_acc_en,
    output  wire    [NUM_CHANNELS-1:0]  mod_acc_clr,
    output  wire    [NUM_CHANNELS-1:0]  curr_note,
    output  reg     [NUM_BITS-1:0]      carrier_word,
    output  reg     [NUM_BITS-1:0]      mod_word,
    output  wire                        interrupt_out,
    output  wire                        s_clk,
    output  reg                         s_clk_pos,
    output  reg                         s_clk_neg
    );

    wire    [NUM_BITS-1:0]          carriers    [0:NUM_CHANNELS-1];
    wire    [NUM_BITS-1:0]          modulators  [0:NUM_CHANNELS-1];
    reg     [6*NUM_CHANNELS-1:0]    count_0;
    reg     [6*NUM_CHANNELS-1:0]    count_1;
    reg     [1:0]                   s_cnt;
    genvar                          i;
    integer                         j;

    assign interrupt_out    = |available;
    assign s_clk            = s_cnt[1];

    generate
        for (i=0; i<NUM_CHANNELS; i=i+1) begin
            assign mod_acc_clr[i]   = modulators[i] == 0 ? 1 : 0;

            assign note_en[i]       = carrier_in[NUM_BITS*(i+1)-1];
            assign carriers[i]      = {1'b0,carrier_in[NUM_BITS*(i+1)-2:NUM_BITS*i]};
            assign modulators[i]    = modulator_in[NUM_BITS*(i+1)-1:NUM_BITS*i];

            assign curr_note[i]     = count_1[`STEP*(i+1)-1];

            assign mod_acc_en[i]    = count_0[`STEP*i];
            assign mod_reg_en[i]    = count_0[`STEP*i+(LATENCY-1)];

            assign car_acc_en[i]    = count_0[`STEP*i+LATENCY];
            assign car_reg_en[i]    = count_0[`STEP*(i+1)-1];
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            s_clk_pos   <= 0;
            s_clk_neg   <= 0;
            s_cnt       <= 0;
        end

        else begin
            s_clk_pos   <= 0;
            s_clk_neg   <= 0;
            s_cnt       <= s_cnt+1;

            if (s_cnt == 2'b00) begin
                s_clk_pos   <= 1;
            end

            if (s_cnt == 2'b10) begin
                s_clk_neg   <= 1;
            end

        end
    end

    always @(*) begin
        for (j=0; j<NUM_CHANNELS; j=j+1) begin
            if (curr_note[j]) begin
                carrier_word    = carriers[j];
                mod_word        = modulators[j];
            end
        end
    end

    always@(posedge clk) begin
        if (rst) begin
            count_0         <= 1;
            count_1         <= 63;
        end

        else begin
            if (en) begin
                count_0 <= 1;
                count_1 <= 63;
            end

            else begin
                count_0 <= count_0 << 1;
                count_1 <= count_1 << 1;
            end
        end
    end

endmodule

