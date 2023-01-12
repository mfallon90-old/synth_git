
`timescale 1 ns / 1 ps

module axi_uart_wrapper #(
    parameter integer C_DATA_WIDTH      = 32,
    parameter integer C_ADDR_WIDTH      = 4,
    parameter integer C_LSB_FIRST       = 1,
    parameter integer C_FIFO_DEPTH      = 8

    )(
    // Clock and reset
    input   wire                            s_axi_aclk,
    input   wire                            s_axi_aresetn,
    // Write address channel
    input   wire    [C_ADDR_WIDTH-1:0]      s_axi_awaddr,
    input   wire    [2:0]                   s_axi_awprot,
    input   wire                            s_axi_awvalid,
    output  wire                            s_axi_awready,
    // Write data channel
    input   wire    [C_DATA_WIDTH-1:0]      s_axi_wdata,
    input   wire    [(C_DATA_WIDTH/8)-1:0]  s_axi_wstrb,
    input   wire                            s_axi_wvalid,
    output  wire                            s_axi_wready,
    // Write response channel
    output  wire    [1:0]                   s_axi_bresp,
    output  wire                            s_axi_bvalid,
    input   wire                            s_axi_bready,
    // Read address channel
    input   wire    [C_ADDR_WIDTH-1:0]      s_axi_araddr,
    input   wire    [2:0]                   s_axi_arprot,
    input   wire                            s_axi_arvalid,
    output  wire                            s_axi_arready,
    // Read data channel
    output  wire    [C_DATA_WIDTH-1:0]      s_axi_rdata,
    output  wire    [1:0]                   s_axi_rresp,
    output  wire                            s_axi_rvalid,
    input   wire                            s_axi_rready,
    // Midi signals
    input   wire                            midi_in,
    output  wire                            midi_intr
    );

    localparam  [1:0]   C_OKAY      = 2'b00;
    localparam  [1:0]   C_EX_OKAY   = 2'b01;
    localparam  [1:0]   C_SLV_ERR   = 2'b10;
    localparam  [1:0]   C_DEC_ERR   = 2'b11;

    reg [C_DATA_WIDTH-1:0]  register;

    wire[7:0]               midi_out;
    wire[7:0]               fifo_out;
    reg [C_ADDR_WIDTH-1:0]  read_address;
    reg [C_DATA_WIDTH-1:0]  read_data;
    reg [1:0]               read_resp;
    reg                     rd_addr_rdy;
    reg                     rd_data_vld;
    reg                     rd_en;

    assign s_axi_arready    = rd_addr_rdy;
    assign s_axi_rdata      = read_data;
    assign s_axi_rresp      = read_resp;
    assign s_axi_rvalid     = rd_data_vld;

    // Read process
    always @(posedge s_axi_aclk) begin
        if (~s_axi_aresetn) begin
            rd_addr_rdy     <= 1'b0;
            read_address    <= 0;
            read_data       <= 0;
            read_resp       <= 0;
            rd_data_vld     <= 1'b0;
            rd_en           <= 1'b0;
        end

        else begin
            // Latch read address
            if (s_axi_arvalid & ~rd_addr_rdy) begin
                rd_addr_rdy     <= 1'b1;
                read_address    <= s_axi_araddr;
                rd_en           <= 1'b1;
            end
            else begin
                rd_addr_rdy     <= 1'b0;
            end

            // Output read data
            if (rd_en) begin
                read_data   <= {{24{1'b0}}, fifo_out};
                read_resp   <= C_OKAY;
                rd_data_vld <= 1'b1;
                rd_en       <= 1'b0;
            end

            else begin
                if (s_axi_rready & rd_data_vld) begin
                    read_data   <= 0;
                    rd_data_vld <= 1'b0;
                end
            end
        end
    end

    uart_rx #(
            .LSB_FIRST  (C_LSB_FIRST))
        midi_rx (
            .clk        (s_axi_aclk),
            .rst_n      (s_axi_aresetn),
            .i_data     (midi_in),
            .o_data     (midi_out),
            .rdy_flg    (midi_intr)
        );

    uart_fifo #(
            .NUM_BITS   (8),
            .FIFO_DEPTH (C_FIFO_DEPTH))
        midi_fifo (
            .clk            (s_axi_aclk),
            .rst_n          (s_axi_aresetn),
            .word_in        (midi_out),
            .word_in_valid  (midi_intr),
            .word_out_valid (rd_en),
            .word_out       (fifo_out)
        );


    // Dump waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end


    endmodule
