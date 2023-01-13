
`timescale 1 ns / 1 ps
`define NUM_REG (C_NUM_RW_REG + C_NUM_RO_REG)
`define PCKD_BITS (C_DATA_WIDTH * 16)

module axi_lite_cs_reg #(
    parameter integer C_DATA_WIDTH      = 32,
    parameter integer C_NUM_REG         = 33,
    parameter integer C_ADDR_WIDTH      = ($clog2(C_NUM_REG) + 2)
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
    output  wire    [7:0]                   mod_amplitude,
    output  wire    [7:0]                   volume_reg
    );

    // 31   mod_amp     vol    a_tau   d_tau   r_tau
    // 31   30:23      22:15    14:10   9:5    4:0
    // 0  0000.0000  0000.0000  00000  00000  00000

    localparam  [1:0]   C_OKAY      = 2'b00;
    localparam  [1:0]   C_EX_OKAY   = 2'b01;
    localparam  [1:0]   C_SLV_ERR   = 2'b10;
    localparam  [1:0]   C_DEC_ERR   = 2'b11;

    reg [C_DATA_WIDTH-1:0]  register_0;
    reg [C_DATA_WIDTH-1:0]  register_1;
    reg [C_DATA_WIDTH-1:0]  register_2;
    reg [C_DATA_WIDTH-1:0]  register_3;
    reg [C_DATA_WIDTH-1:0]  register_4;
    reg [C_DATA_WIDTH-1:0]  register_5;
    reg [C_DATA_WIDTH-1:0]  register_6;
    reg [C_DATA_WIDTH-1:0]  register_7;
    reg [C_DATA_WIDTH-1:0]  register_8;
    reg [C_DATA_WIDTH-1:0]  register_9;
    reg [C_DATA_WIDTH-1:0]  register_10;
    reg [C_DATA_WIDTH-1:0]  register_11;
    reg [C_DATA_WIDTH-1:0]  register_12;
    reg [C_DATA_WIDTH-1:0]  register_13;
    reg [C_DATA_WIDTH-1:0]  register_14;
    reg [C_DATA_WIDTH-1:0]  register_15;
    reg [C_DATA_WIDTH-1:0]  register_16;
    reg [C_DATA_WIDTH-1:0]  register_17;
    reg [C_DATA_WIDTH-1:0]  register_18;
    reg [C_DATA_WIDTH-1:0]  register_19;
    reg [C_DATA_WIDTH-1:0]  register_20;
    reg [C_DATA_WIDTH-1:0]  register_21;
    reg [C_DATA_WIDTH-1:0]  register_22;
    reg [C_DATA_WIDTH-1:0]  register_23;
    reg [C_DATA_WIDTH-1:0]  register_24;
    reg [C_DATA_WIDTH-1:0]  register_25;
    reg [C_DATA_WIDTH-1:0]  register_26;
    reg [C_DATA_WIDTH-1:0]  register_27;
    reg [C_DATA_WIDTH-1:0]  register_28;
    reg [C_DATA_WIDTH-1:0]  register_29;
    reg [C_DATA_WIDTH-1:0]  register_30;
    reg [C_DATA_WIDTH-1:0]  register_31;
    reg [C_DATA_WIDTH-1:0]  register_32;

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

    assign carrier_out =   {register_0,  register_1,  register_2,  register_3,
                            register_4,  register_5,  register_6,  register_7,
                            register_8,  register_9,  register_10, register_11,
                            register_12, register_13, register_14, register_15};

    assign modulator_out = {register_16, register_17, register_18, register_19,
                            register_20, register_21, register_22, register_23,
                            register_24, register_25, register_26, register_27,
                            register_28, register_29, register_30, register_31};

    assign mod_amplitude    = register_32[30:23];
    assign volume_reg       = register_32[22:15];
    assign attack_tau       = register_32[14:10];
    assign decay_tau        = register_32[9:5];
    assign release_tau      = register_32[4:0];

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
                read_resp   <= C_OKAY;
                rd_data_vld <= 1'b1;
                rd_en       <= 1'b0;
                case (read_address[C_ADDR_WIDTH-1:2])
                    0  : read_data   <= register_0;
                    1  : read_data   <= register_1;
                    2  : read_data   <= register_2;
                    3  : read_data   <= register_3;
                    4  : read_data   <= register_4;
                    5  : read_data   <= register_5;
                    6  : read_data   <= register_6;
                    7  : read_data   <= register_7;
                    8  : read_data   <= register_8;
                    9  : read_data   <= register_9;
                    10 : read_data   <= register_10;
                    11 : read_data   <= register_11;
                    12 : read_data   <= register_12;
                    13 : read_data   <= register_13;
                    14 : read_data   <= register_14;
                    15 : read_data   <= register_15;
                    16 : read_data   <= register_16;
                    17 : read_data   <= register_17;
                    18 : read_data   <= register_18;
                    19 : read_data   <= register_19;
                    20 : read_data   <= register_20;
                    21 : read_data   <= register_21;
                    22 : read_data   <= register_22;
                    23 : read_data   <= register_23;
                    24 : read_data   <= register_24;
                    25 : read_data   <= register_25;
                    26 : read_data   <= register_26;
                    27 : read_data   <= register_27;
                    28 : read_data   <= register_28;
                    29 : read_data   <= register_29;
                    30 : read_data   <= register_30;
                    31 : read_data   <= register_31;
                    32 : read_data   <= register_32;
                
                    default : begin
                        read_data <= 0;
                        read_resp   <= C_DEC_ERR;
                        rd_data_vld <= 1'b0;
                    end
                endcase
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

            register_0     <= 0;
            register_1     <= 0;
            register_2     <= 0;
            register_3     <= 0;
            register_4     <= 0;
            register_5     <= 0;
            register_6     <= 0;
            register_7     <= 0;
            register_8     <= 0;
            register_9     <= 0;
            register_10    <= 0;
            register_11    <= 0;
            register_12    <= 0;
            register_13    <= 0;
            register_14    <= 0;
            register_15    <= 0;
            register_16    <= 0;
            register_17    <= 0;
            register_18    <= 0;
            register_19    <= 0;
            register_20    <= 0;
            register_21    <= 0;
            register_22    <= 0;
            register_23    <= 0;
            register_24    <= 0;
            register_25    <= 0;
            register_26    <= 0;
            register_27    <= 0;
            register_28    <= 0;
            register_29    <= 0;
            register_30    <= 0;
            register_31    <= 0;
            register_32    <= 0;

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

                write_resp      <= C_OKAY;
                write_valid     <= 1'b1;
                wr_data_good    <= 1'b0;
                wr_addr_good    <= 1'b0;
                case (write_address[C_ADDR_WIDTH-1:2])
                    0  : register_0     <= write_data;
                    1  : register_1     <= write_data;
                    2  : register_2     <= write_data;
                    3  : register_3     <= write_data;
                    4  : register_4     <= write_data;
                    5  : register_5     <= write_data;
                    6  : register_6     <= write_data;
                    7  : register_7     <= write_data;
                    8  : register_8     <= write_data;
                    9  : register_9     <= write_data;
                    10 : register_10    <= write_data;
                    11 : register_11    <= write_data;
                    12 : register_12    <= write_data;
                    13 : register_13    <= write_data;
                    14 : register_14    <= write_data;
                    15 : register_15    <= write_data;
                    16 : register_16    <= write_data;
                    17 : register_17    <= write_data;
                    18 : register_18    <= write_data;
                    19 : register_19    <= write_data;
                    20 : register_20    <= write_data;
                    21 : register_21    <= write_data;
                    22 : register_22    <= write_data;
                    23 : register_23    <= write_data;
                    24 : register_24    <= write_data;
                    25 : register_25    <= write_data;
                    26 : register_26    <= write_data;
                    27 : register_27    <= write_data;
                    28 : register_28    <= write_data;
                    29 : register_29    <= write_data;
                    30 : register_30    <= write_data;
                    31 : register_31    <= write_data;
                    32 : register_32    <= write_data;
                
                    default : begin
                        write_resp      <= C_DEC_ERR;
                        write_valid     <= 1'b0;;
                    end
                endcase
            end
            else if (write_valid & s_axi_bready) begin
                write_valid <= 1'b0;
            end
        end
    end


    // Dump waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end


    endmodule
