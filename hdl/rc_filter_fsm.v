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

module rc_filter_fsm #(
    TAU_BITS    = 5,
    ENV_BITS    = 24
    )(
    input   wire                        clk,
    input   wire                        rst,
    input   wire                        en,
    input   wire                        on,
    input   wire        [31:0]          velocity,
    input   wire        [TAU_BITS-1:0]  attack_tau,
    input   wire        [TAU_BITS-1:0]  decay_tau,
    input   wire        [TAU_BITS-1:0]  release_tau,
    output  wire                        available,
    output  wire signed [ENV_BITS-1:0]  envelope
    );

// CONSTANTS

    localparam      [ENV_BITS-1:0]  ATTACK_STEP     = 24'b01_0000_0000_0000_0000_0000_00;
    localparam      [ENV_BITS-1:0]  DECAY_STEP      = 24'b00_1100_0000_0000_0000_0000_00;
    localparam      [ENV_BITS-1:0]  RELEASE_STEP    = 24'b00_0000_0000_0000_0000_0000_00;

    localparam      [ENV_BITS-1:0]  MAX             = 24'b0000_1111_0000_0000_0000_0000;
    localparam      [ENV_BITS-1:0]  MIN             = 24'b0000_0000_0000_0000_0001_0000;
    localparam      [1:0]           S_IDLE          = 2'b00;
    localparam      [1:0]           S_ATTACK        = 2'b01;
    localparam      [1:0]           S_DECAY         = 2'b10;
    localparam      [1:0]           S_RELEASE       = 2'b11;

    reg                             avail;
    reg             [2:0]           state;
    reg     signed  [ENV_BITS-1:0]  env_delay;
    reg     signed  [ENV_BITS-1:0]  step_delay;
    wire    signed  [ENV_BITS-1:0]  product;
    wire    signed  [ENV_BITS-1:0]  sum;
    reg             [TAU_BITS-1:0]  tau;

    wire            [15:0]          attack;
    wire            [15:0]          decay;

    assign attack = velocity[31:16];
    assign decay = velocity[15:0];

    assign  product  = sum >>> tau;
    assign  sum      = step_delay - env_delay;
    assign  envelope = product + env_delay;
    assign available = avail;

    always @(posedge clk) begin
        if (rst) begin
            state       <= S_IDLE;
            env_delay   <= 0;
            step_delay  <= 0;
            tau         <= 0;
            avail       <= 0;
        end

        else begin
            avail   <= 0;
            case (state)
                S_IDLE : begin
                    if (en) begin
                        state       <= S_ATTACK;
                        // step_delay  <= ATTACK_STEP;
                        step_delay  <= {attack, 8'd0};
                        tau         <= attack_tau;
                    end
                end

                S_ATTACK : begin
                    if (on) begin
                        env_delay   <= envelope;
                    end
                    
                    if (envelope > MAX) begin
                        state       <= S_DECAY;
                        // step_delay  <= DECAY_STEP;
                        step_delay  <= {decay, 8'd0};
                        tau         <= decay_tau;
                    end

                    if (~en) begin
                        state       <= S_RELEASE;
                        step_delay  <= RELEASE_STEP;
                        tau         <= release_tau;
                    end
                end

                S_DECAY : begin
                    if (on) begin
                        env_delay   <= envelope;
                    end

                    if (~en) begin
                        state       <= S_RELEASE;
                        step_delay  <= RELEASE_STEP;
                        tau         <= release_tau;
                    end
                end

                S_RELEASE : begin
                    if (on) begin
                        env_delay   <= envelope;
                    end

                    if (en) begin
                        state       <= S_ATTACK;
                        // step_delay  <= ATTACK_STEP;
                        step_delay  <= {attack, 8'd0};
                        tau         <= attack_tau;
                    end

                    if (envelope < MIN) begin
                        state       <= S_IDLE;
                        env_delay   <= 0;
                        tau         <= 0;
                        avail       <= 1;
                    end
                end

                default : begin
                    state   <= S_IDLE;
                end
            endcase
        end
    end

    // Dump waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

endmodule