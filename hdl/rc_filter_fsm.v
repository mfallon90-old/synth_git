`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: rc_filter
// Tool Versions: Vivado 2020.2
//
// Description:
//
//  step_delay is where you want to end up
//  Tau is how fast you want to get there, the bigger the tau, the faster you arrive at step_delay
//           
//           
//                       tau
//  step_delay     sum    |   product       envelope
//  ---------->(-)------>(x)--------->(+)----.----->
//              ^                      ^     |     
//              |                      |   .----.  
//              |     env_delay        |   |  -1|  
//              '----------------------'---| Z  |  
//                                         '----'  
//                                                 
//////////////////////////////////////////////////////////////////////////////////

module rc_filter_fsm #(
    TAU_BITS    = 16,
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

    localparam      [ENV_BITS-1:0]  MAX             = 24'b00_1111000000000000000000;
    localparam      [ENV_BITS-1:0]  MIN             = 24'b00_0000000000000000001000;
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

    assign  attack  = velocity[31:16];
    assign  decay   = velocity[15:0];

    assign  sum         = step_delay - env_delay;
    assign  envelope    = product + env_delay;
    assign  available   = avail;

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
                        step_delay  <= {attack, 8'h00};
                        tau         <= {8'h00, attack_tau};
                    end
                end

                S_ATTACK : begin
                    if (on) begin
                        env_delay   <= envelope;
                    end
                    
                    if (envelope > MAX) begin
                        state       <= S_DECAY;
                        step_delay  <= {decay, 8'h00};
                        tau         <= {8'h00, decay_tau};
                    end

                    if (~en) begin
                        state       <= S_RELEASE;
                        step_delay  <= 0;
                        tau         <= {8'h00, release_tau};
                    end
                end

                S_DECAY : begin
                    if (on) begin
                        env_delay   <= envelope;
                    end

                    if (~en) begin
                        state       <= S_RELEASE;
                        step_delay  <= 0;
                        tau         <= {8'h00, release_tau};
                    end
                end

                S_RELEASE : begin
                    if (on) begin
                        env_delay   <= envelope;
                    end

                    if (en) begin
                        state       <= S_ATTACK;
                        step_delay  <= {attack, 8'h00};
                        tau         <= {8'h00, attack_tau};
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

    fixed_point_mult #(
            .WI_1   (2),
            .WF_1   (TAU_BITS+6),
            .WI_2   (2),
            .WF_2   (ENV_BITS-2),
            .WI_O   (2),
            .WF_O   (ENV_BITS-2))
        scalar (
            .in_1       (tau),
            .in_2       (sum),
            .data_out   (product),
            .ovf        ()
        );


    // // Dump waves
    // initial begin
    //     $dumpfile("dump.vcd");
    //     $dumpvars;
    // end

endmodule