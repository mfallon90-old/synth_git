`timescale 1ns / 1ps
`define TOTAL_BITS (NUM_BITS*NUM_CHANNELS)
`define C_ADDR_WIDTH  ($clog2(NUM_REG) + 2)
//////////////////////////////////////////////////////////////////////////////////
//
// Author: Michael Fallon
//
// Design Name: FM SYNTHESIZER
// Module Name: fm_synth_wrapper
// Tool Versions: Vivado 2020.2
//
// Description: This is the top level wrapper for the fm synthesizer project.
//////////////////////////////////////////////////////////////////////////////////

module fm_synth_wrapper #(
    parameter   COS_LUT_VALUES  = "C:/Users/mfall/Documents/School/year_4/senior_design/v_3/hdl/lut.mem",
    // parameter   COS_LUT_VALUES  = "lut.mem",
    parameter   NUM_CHANNELS    = 16,
    parameter   NUM_REG         = 52,
    parameter   LATENCY         = 3,
    parameter   NUM_BRAM        = 32,
    parameter   NUM_BITS        = 32,
    parameter   WI_OUT          = 2,
    parameter   WF_OUT          = 16,
    parameter   NUM_BITS_DAC    = 24
    )(
    // Clock and reset
    input   wire                            s_axi_aclk,
    input   wire                            s_axi_aresetn,
    // Write address channel
    input   wire    [`C_ADDR_WIDTH-1:0]     s_axi_awaddr,
    input   wire    [2:0]                   s_axi_awprot,
    input   wire                            s_axi_awvalid,
    output  wire                            s_axi_awready,
    // Write data channel
    input   wire    [NUM_BITS-1:0]          s_axi_wdata,
    input   wire    [(NUM_BITS/8)-1:0]      s_axi_wstrb,
    input   wire                            s_axi_wvalid,
    output  wire                            s_axi_wready,
    // Write response channel
    output  wire    [1:0]                   s_axi_bresp,
    output  wire                            s_axi_bvalid,
    input   wire                            s_axi_bready,
    // Read address channel
    input   wire    [`C_ADDR_WIDTH-1:0]     s_axi_araddr,
    input   wire    [2:0]                   s_axi_arprot,
    input   wire                            s_axi_arvalid,
    output  wire                            s_axi_arready,
    // Read data channel
    output  wire    [NUM_BITS-1:0]          s_axi_rdata,
    output  wire    [1:0]                   s_axi_rresp,
    output  wire                            s_axi_rvalid,
    input   wire                            s_axi_rready,
    // Synth Signals
    input   wire                            sys_rst,
    output  wire                            word_select,
    output  wire                            serial_data,
    output  wire                            interrupt,
    output  wire                            s_clk,
    output  wire                            trig_out
    );

    localparam  NUM_BITS_TAU = 16;

    wire    [NUM_CHANNELS*NUM_BITS-1:0] carriers;
    wire    [NUM_CHANNELS*NUM_BITS-1:0] modulators;
    wire    [NUM_CHANNELS*NUM_BITS-1:0] velocities;
    wire    [NUM_BITS_TAU-1:0]          attack_tau;
    wire    [NUM_BITS_TAU-1:0]          decay_tau;
    wire    [NUM_BITS_TAU-1:0]          release_tau;
    wire    [NUM_BITS-1:0]              mod_tau;
    wire    [7:0]                       mod_amplitude;
    wire    [7:0]                       volume_reg;
    wire    [1:0]                       wave_sel;
    wire                                mod_enable;


    // CONTROL AND STATUS REGISTERS
    axi_lite_cs_reg #(
            .C_DATA_WIDTH   (NUM_BITS),
            .C_NUM_REG      (NUM_REG),
            .C_ADDR_WIDTH   (`C_ADDR_WIDTH),
            .C_NUM_BITS_TAU (NUM_BITS_TAU))
        c_s_reg (
            .s_axi_aclk     (s_axi_aclk),
            .s_axi_aresetn  (s_axi_aresetn),
            .s_axi_awaddr   (s_axi_awaddr),
            .s_axi_awprot   (s_axi_awprot),
            .s_axi_awvalid  (s_axi_awvalid),
            .s_axi_awready  (s_axi_awready),
            .s_axi_wdata    (s_axi_wdata),
            .s_axi_wstrb    (s_axi_wstrb),
            .s_axi_wvalid   (s_axi_wvalid),
            .s_axi_wready   (s_axi_wready),
            .s_axi_bresp    (s_axi_bresp),
            .s_axi_bvalid   (s_axi_bvalid),
            .s_axi_bready   (s_axi_bready),
            .s_axi_araddr   (s_axi_araddr),
            .s_axi_arprot   (s_axi_arprot),
            .s_axi_arvalid  (s_axi_arvalid),
            .s_axi_arready  (s_axi_arready),
            .s_axi_rdata    (s_axi_rdata),
            .s_axi_rresp    (s_axi_rresp),
            .s_axi_rvalid   (s_axi_rvalid),
            .s_axi_rready   (s_axi_rready),
            .carrier_out    (carriers),
            .modulator_out  (modulators),
            .velocity_out   (velocities),
            .attack_tau     (attack_tau),
            .decay_tau      (decay_tau),
            .release_tau    (release_tau),
            .mod_amplitude  (mod_amplitude),
            .volume_reg     (volume_reg),
            .wave_sel       (wave_sel),
            .mod_tau        (mod_tau),
            .mod_enable     (mod_enable)
        );


    // FM SYNTH TOP
    fm_synth_top #(
            .COS_LUT_VALUES (COS_LUT_VALUES),
            .NUM_CHANNELS   (NUM_CHANNELS),
            .LATENCY        (LATENCY),
            .NUM_BRAM       (NUM_BRAM),
            .NUM_BITS       (NUM_BITS),
            .WI_OUT         (WI_OUT),
            .WF_OUT         (WF_OUT),
            .NUM_BITS_DAC   (NUM_BITS_DAC),
            .NUM_BITS_TAU   (NUM_BITS_TAU))
        synth (
            .clk            (s_axi_aclk),
            .rst            (sys_rst),
            .wave_sel       (wave_sel),
            .carrier_in     (carriers),
            .modulator_in   (modulators),
            .velocity_in    (velocities),
            .attack_tau     (attack_tau),
            .decay_tau      (decay_tau),
            .release_tau    (release_tau),
            .volume_reg     (volume_reg),
            .mod_enable     (mod_enable),
            .mod_amplitude  (mod_amplitude),
            .word_select    (word_select),
            .serial_data    (serial_data),
            .interrupt_out  (interrupt),
            .s_clk          (s_clk),
            .trig_out       (trig_out),
            .mod_tau        (mod_tau)
        );

    // Dump waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
    end


endmodule