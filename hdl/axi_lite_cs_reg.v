
`timescale 1 ns / 1 ps
`define NUM_REG (C_NUM_RW_REG + C_NUM_RO_REG)
`define PCKD_BITS (C_DATA_WIDTH * C_NUM_CHAN)

module axi_lite_cs_reg #(
    parameter integer C_DATA_WIDTH      = 32,
    parameter integer C_NUM_RW_REG      = 33,
    parameter integer C_NUM_RO_REG      = 0,
    parameter integer C_NUM_CHAN        = 16,
    parameter integer C_ADDR_WIDTH      = ($clog2(`NUM_REG) + 2)
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
    // Register outputs
    output  wire    [`PCKD_BITS-1:0]        carrier_out,
    output  wire    [`PCKD_BITS-1:0]        modulator_out,
    output  wire    [4:0]                   attack_tau,
    output  wire    [4:0]                   decay_tau,
    output  wire    [4:0]                   release_tau,
    output  wire    [1:0]                   mod_amplitude,
    output  wire    [7:0]                   volume_reg
    );

    localparam  [1:0]   C_OKAY      = 2'b00;
    localparam  [1:0]   C_EX_OKAY   = 2'b01;
    localparam  [1:0]   C_SLV_ERR   = 2'b10;
    localparam  [1:0]   C_DEC_ERR   = 2'b11;

    reg [C_DATA_WIDTH-1:0]  reg_file [0:`NUM_REG-1];
    reg [C_ADDR_WIDTH-1:0]  i;
    reg [C_ADDR_WIDTH-1:0]  read_address;
    reg [C_ADDR_WIDTH-1:0]  write_address;
    reg [C_DATA_WIDTH-1:0]  read_data;
    reg [C_DATA_WIDTH-1:0]  write_data;
    reg [1:0]               read_resp;
    reg [1:0]               write_resp;
    reg                     rd_addr_rdy;
    reg                     rd_data_vld;
    reg                     wr_addr_rdy;
    reg                     wr_data_rdy;
    reg                     write_valid;
    reg                     rd_en;
    reg                     wr_addr_good;
    reg                     wr_data_good;
    genvar                  j;

    generate
        for (j=0; j<(C_NUM_CHAN); j=j+1) begin
            assign carrier_out[C_DATA_WIDTH*(j+1)-1:C_DATA_WIDTH*j]     = reg_file[j];
            assign modulator_out[C_DATA_WIDTH*(j+1)-1:C_DATA_WIDTH*j]   = reg_file[j+C_NUM_CHAN];
        end
    endgenerate

    assign attack_tau       = reg_file[`NUM_REG-1][14:10];
    assign decay_tau        = reg_file[`NUM_REG-1][9:5];
    assign release_tau      = reg_file[`NUM_REG-1][4:0];
    assign mod_amplitude    = reg_file[`NUM_REG-1][31:30];
    assign volume_reg       = reg_file[`NUM_REG-1][29:22];

    assign s_axi_awready    = wr_addr_rdy;
    assign s_axi_wready     = wr_data_rdy;
    assign s_axi_bresp      = write_resp;
    assign s_axi_bvalid     = write_valid;
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
                for (i=0; i<`NUM_REG; i=i+1) begin
                    if (read_address[C_ADDR_WIDTH-1:2] == i) begin
                        read_data   <= reg_file[i];
                        read_resp   <= C_OKAY;
                        rd_data_vld <= 1'b1;
                        rd_en       <= 1'b0;
                    end
                end
            end
            else begin
                if (s_axi_rready & rd_data_vld) begin
                    read_data   <= 0;
                    rd_data_vld <= 1'b0;
                end
            end
        end
    end

    // Write process
    always @(posedge s_axi_aclk) begin
        if (~s_axi_aresetn) begin
            wr_addr_rdy     <= 1'b0;
            write_address   <= 0;
            wr_data_rdy     <= 1'b0;
            write_data      <= 0;
            write_resp      <= 0;
            write_valid     <= 1'b0;
            wr_data_good    <= 1'b0;
            wr_addr_good    <= 1'b0;

            for (i=0; i<`NUM_REG; i=i+1) begin
                reg_file[i] <= 0;
            end
        end

        else begin
            // Latch write address
            if (s_axi_awvalid & ~wr_addr_rdy & ~wr_addr_good) begin
                wr_addr_rdy     <= 1'b1;
                write_address   <= s_axi_awaddr;
                wr_addr_good    <= 1'b1;
            end
            else begin
                wr_addr_rdy     <= 1'b0;
            end

            // Latch write data
            if (s_axi_wvalid & ~wr_data_rdy & ~wr_data_good) begin
                wr_data_rdy     <= 1'b1;
                write_data      <= s_axi_wdata;
                wr_data_good    <= 1'b1;
            end
            else begin
                wr_data_rdy     <= 1'b0;
            end

            // Write write data to register
            if (wr_data_good & wr_addr_good) begin
                for (i=0; i<C_NUM_RW_REG; i=i+1) begin
                    if (i == write_address[C_ADDR_WIDTH-1:2]) begin
                        reg_file[i]     <= write_data;
                        write_resp      <= C_OKAY;
                        write_valid     <= 1'b1;
                        wr_data_good    <= 1'b0;
                        wr_addr_good    <= 1'b0;
                    end
                end
            end
            else if (write_valid & s_axi_bready) begin
                write_valid <= 1'b0;
            end
        end
    end


    // Dump waves
    initial begin
        $dumpfile("dump.vcd");

        for (i=0; i<`NUM_REG; i=i+1) begin
            $dumpvars(0,reg_file[i]);
        end

        $dumpvars;
    end


    endmodule
