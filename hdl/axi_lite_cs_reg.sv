
`timescale 1 ns / 1 ps
`define NUM_REG (C_NUM_RW_REG + C_NUM_RO_REG)
`define PCKD_BITS (C_DATA_WIDTH * 16)

import const_pckg::*;

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
    output  wire    [`PCKD_BITS-1:0]        velocity_out,
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

    reg [C_DATA_WIDTH-1:0]  carrier_0;
    reg [C_DATA_WIDTH-1:0]  carrier_1;
    reg [C_DATA_WIDTH-1:0]  carrier_2;
    reg [C_DATA_WIDTH-1:0]  carrier_3;
    reg [C_DATA_WIDTH-1:0]  carrier_4;
    reg [C_DATA_WIDTH-1:0]  carrier_5;
    reg [C_DATA_WIDTH-1:0]  carrier_6;
    reg [C_DATA_WIDTH-1:0]  carrier_7;
    reg [C_DATA_WIDTH-1:0]  carrier_8;
    reg [C_DATA_WIDTH-1:0]  carrier_9;
    reg [C_DATA_WIDTH-1:0]  carrier_10;
    reg [C_DATA_WIDTH-1:0]  carrier_11;
    reg [C_DATA_WIDTH-1:0]  carrier_12;
    reg [C_DATA_WIDTH-1:0]  carrier_13;
    reg [C_DATA_WIDTH-1:0]  carrier_14;
    reg [C_DATA_WIDTH-1:0]  carrier_15;

    reg [C_DATA_WIDTH-1:0]  modulator_0;
    reg [C_DATA_WIDTH-1:0]  modulator_1;
    reg [C_DATA_WIDTH-1:0]  modulator_2;
    reg [C_DATA_WIDTH-1:0]  modulator_3;
    reg [C_DATA_WIDTH-1:0]  modulator_4;
    reg [C_DATA_WIDTH-1:0]  modulator_5;
    reg [C_DATA_WIDTH-1:0]  modulator_6;
    reg [C_DATA_WIDTH-1:0]  modulator_7;
    reg [C_DATA_WIDTH-1:0]  modulator_8;
    reg [C_DATA_WIDTH-1:0]  modulator_9;
    reg [C_DATA_WIDTH-1:0]  modulator_10;
    reg [C_DATA_WIDTH-1:0]  modulator_11;
    reg [C_DATA_WIDTH-1:0]  modulator_12;
    reg [C_DATA_WIDTH-1:0]  modulator_13;
    reg [C_DATA_WIDTH-1:0]  modulator_14;
    reg [C_DATA_WIDTH-1:0]  modulator_15;

    reg [C_DATA_WIDTH-1:0]  velocity_0;
    reg [C_DATA_WIDTH-1:0]  velocity_1;
    reg [C_DATA_WIDTH-1:0]  velocity_2;
    reg [C_DATA_WIDTH-1:0]  velocity_3;
    reg [C_DATA_WIDTH-1:0]  velocity_4;
    reg [C_DATA_WIDTH-1:0]  velocity_5;
    reg [C_DATA_WIDTH-1:0]  velocity_6;
    reg [C_DATA_WIDTH-1:0]  velocity_7;
    reg [C_DATA_WIDTH-1:0]  velocity_8;
    reg [C_DATA_WIDTH-1:0]  velocity_9;
    reg [C_DATA_WIDTH-1:0]  velocity_10;
    reg [C_DATA_WIDTH-1:0]  velocity_11;
    reg [C_DATA_WIDTH-1:0]  velocity_12;
    reg [C_DATA_WIDTH-1:0]  velocity_13;
    reg [C_DATA_WIDTH-1:0]  velocity_14;
    reg [C_DATA_WIDTH-1:0]  velocity_15;

    reg [C_DATA_WIDTH-1:0]  control_reg;

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

    assign carrier_out =   {carrier_15, carrier_14, carrier_13, carrier_12,
                            carrier_11, carrier_10, carrier_9,  carrier_8,
                            carrier_7,  carrier_6,  carrier_5,  carrier_4,
                            carrier_3,  carrier_2,  carrier_1,  carrier_0};

    assign modulator_out = {modulator_15, modulator_14, modulator_13, modulator_12,
                            modulator_11, modulator_10, modulator_9,  modulator_8,
                            modulator_7,  modulator_6,  modulator_5,  modulator_4,
                            modulator_3,  modulator_2,  modulator_1,  modulator_0};

    assign velocity_out =  {velocity_15, velocity_14, velocity_13, velocity_12,
                            velocity_11, velocity_10, velocity_9,  velocity_8,
                            velocity_7,  velocity_6,  velocity_5,  velocity_4,
                            velocity_3,  velocity_2,  velocity_1,  velocity_0};

    assign mod_amplitude    = control_reg[30:23];
    assign volume_reg       = control_reg[22:15];
    assign attack_tau       = control_reg[14:10];
    assign decay_tau        = control_reg[9:5];
    assign release_tau      = control_reg[4:0];

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
                    //---------------------------------------------
                    CARRIER_0_ADDR      : read_data   <= carrier_0;
                    CARRIER_1_ADDR      : read_data   <= carrier_1;
                    CARRIER_2_ADDR      : read_data   <= carrier_2;
                    CARRIER_3_ADDR      : read_data   <= carrier_3;
                    CARRIER_4_ADDR      : read_data   <= carrier_4;
                    CARRIER_5_ADDR      : read_data   <= carrier_5;
                    CARRIER_6_ADDR      : read_data   <= carrier_6;
                    CARRIER_7_ADDR      : read_data   <= carrier_7;
                    CARRIER_8_ADDR      : read_data   <= carrier_8;
                    CARRIER_9_ADDR      : read_data   <= carrier_9;
                    CARRIER_10_ADDR     : read_data   <= carrier_10;
                    CARRIER_11_ADDR     : read_data   <= carrier_11;
                    CARRIER_12_ADDR     : read_data   <= carrier_12;
                    CARRIER_13_ADDR     : read_data   <= carrier_13;
                    CARRIER_14_ADDR     : read_data   <= carrier_14;
                    CARRIER_15_ADDR     : read_data   <= carrier_15;
                    //-----------------------------------------------
                    MODULATOR_0_ADDR    : read_data   <= modulator_0;
                    MODULATOR_1_ADDR    : read_data   <= modulator_1;
                    MODULATOR_2_ADDR    : read_data   <= modulator_2;
                    MODULATOR_3_ADDR    : read_data   <= modulator_3;
                    MODULATOR_4_ADDR    : read_data   <= modulator_4;
                    MODULATOR_5_ADDR    : read_data   <= modulator_5;
                    MODULATOR_6_ADDR    : read_data   <= modulator_6;
                    MODULATOR_7_ADDR    : read_data   <= modulator_7;
                    MODULATOR_8_ADDR    : read_data   <= modulator_8;
                    MODULATOR_9_ADDR    : read_data   <= modulator_9;
                    MODULATOR_10_ADDR   : read_data   <= modulator_10;
                    MODULATOR_11_ADDR   : read_data   <= modulator_11;
                    MODULATOR_12_ADDR   : read_data   <= modulator_12;
                    MODULATOR_13_ADDR   : read_data   <= modulator_13;
                    MODULATOR_14_ADDR   : read_data   <= modulator_14;
                    MODULATOR_15_ADDR   : read_data   <= modulator_15;
                    //------------------------------------------------
                    VELOCITY_0_ADDR     : read_data   <= velocity_0;
                    VELOCITY_1_ADDR     : read_data   <= velocity_1;
                    VELOCITY_2_ADDR     : read_data   <= velocity_2;
                    VELOCITY_3_ADDR     : read_data   <= velocity_3;
                    VELOCITY_4_ADDR     : read_data   <= velocity_4;
                    VELOCITY_5_ADDR     : read_data   <= velocity_5;
                    VELOCITY_6_ADDR     : read_data   <= velocity_6;
                    VELOCITY_7_ADDR     : read_data   <= velocity_7;
                    VELOCITY_8_ADDR     : read_data   <= velocity_8;
                    VELOCITY_9_ADDR     : read_data   <= velocity_9;
                    VELOCITY_10_ADDR    : read_data   <= velocity_10;
                    VELOCITY_11_ADDR    : read_data   <= velocity_11;
                    VELOCITY_12_ADDR    : read_data   <= velocity_12;
                    VELOCITY_13_ADDR    : read_data   <= velocity_13;
                    VELOCITY_14_ADDR    : read_data   <= velocity_14;
                    VELOCITY_15_ADDR    : read_data   <= velocity_15;
                    //------------------------------------------------
                    CONTROL_REG_ADDR    : read_data   <= control_reg;
                
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

            carrier_0       <= 0;
            carrier_1       <= 0;
            carrier_2       <= 0;
            carrier_3       <= 0;
            carrier_4       <= 0;
            carrier_5       <= 0;
            carrier_6       <= 0;
            carrier_7       <= 0;
            carrier_8       <= 0;
            carrier_9       <= 0;
            carrier_10      <= 0;
            carrier_11      <= 0;
            carrier_12      <= 0;
            carrier_13      <= 0;
            carrier_14      <= 0;
            carrier_15      <= 0;
            modulator_0     <= 0;
            modulator_1     <= 0;
            modulator_2     <= 0;
            modulator_3     <= 0;
            modulator_4     <= 0;
            modulator_5     <= 0;
            modulator_6     <= 0;
            modulator_7     <= 0;
            modulator_8     <= 0;
            modulator_9     <= 0;
            modulator_10    <= 0;
            modulator_11    <= 0;
            modulator_12    <= 0;
            modulator_13    <= 0;
            modulator_14    <= 0;
            modulator_15    <= 0;
            velocity_0      <= 0;
            velocity_1      <= 0;
            velocity_2      <= 0;
            velocity_3      <= 0;
            velocity_4      <= 0;
            velocity_5      <= 0;
            velocity_6      <= 0;
            velocity_7      <= 0;
            velocity_8      <= 0;
            velocity_9      <= 0;
            velocity_10     <= 0;
            velocity_11     <= 0;
            velocity_12     <= 0;
            velocity_13     <= 0;
            velocity_14     <= 0;
            velocity_15     <= 0;
            control_reg     <= 0;

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
                    //-------------------------------------------------
                    CARRIER_0_ADDR      : carrier_0      <= write_data;
                    CARRIER_1_ADDR      : carrier_1      <= write_data;
                    CARRIER_2_ADDR      : carrier_2      <= write_data;
                    CARRIER_3_ADDR      : carrier_3      <= write_data;
                    CARRIER_4_ADDR      : carrier_4      <= write_data;
                    CARRIER_5_ADDR      : carrier_5      <= write_data;
                    CARRIER_6_ADDR      : carrier_6      <= write_data;
                    CARRIER_7_ADDR      : carrier_7      <= write_data;
                    CARRIER_8_ADDR      : carrier_8      <= write_data;
                    CARRIER_9_ADDR      : carrier_9      <= write_data;
                    CARRIER_10_ADDR     : carrier_10     <= write_data;
                    CARRIER_11_ADDR     : carrier_11     <= write_data;
                    CARRIER_12_ADDR     : carrier_12     <= write_data;
                    CARRIER_13_ADDR     : carrier_13     <= write_data;
                    CARRIER_14_ADDR     : carrier_14     <= write_data;
                    CARRIER_15_ADDR     : carrier_15     <= write_data;
                    //-------------------------------------------------
                    MODULATOR_0_ADDR    : modulator_0    <= write_data;
                    MODULATOR_1_ADDR    : modulator_1    <= write_data;
                    MODULATOR_2_ADDR    : modulator_2    <= write_data;
                    MODULATOR_3_ADDR    : modulator_3    <= write_data;
                    MODULATOR_4_ADDR    : modulator_4    <= write_data;
                    MODULATOR_5_ADDR    : modulator_5    <= write_data;
                    MODULATOR_6_ADDR    : modulator_6    <= write_data;
                    MODULATOR_7_ADDR    : modulator_7    <= write_data;
                    MODULATOR_8_ADDR    : modulator_8    <= write_data;
                    MODULATOR_9_ADDR    : modulator_9    <= write_data;
                    MODULATOR_10_ADDR   : modulator_10   <= write_data;
                    MODULATOR_11_ADDR   : modulator_11   <= write_data;
                    MODULATOR_12_ADDR   : modulator_12   <= write_data;
                    MODULATOR_13_ADDR   : modulator_13   <= write_data;
                    MODULATOR_14_ADDR   : modulator_14   <= write_data;
                    MODULATOR_15_ADDR   : modulator_15   <= write_data;
                    //-------------------------------------------------
                    VELOCITY_0_ADDR     : velocity_0     <= write_data;
                    VELOCITY_1_ADDR     : velocity_1     <= write_data;
                    VELOCITY_2_ADDR     : velocity_2     <= write_data;
                    VELOCITY_3_ADDR     : velocity_3     <= write_data;
                    VELOCITY_4_ADDR     : velocity_4     <= write_data;
                    VELOCITY_5_ADDR     : velocity_5     <= write_data;
                    VELOCITY_6_ADDR     : velocity_6     <= write_data;
                    VELOCITY_7_ADDR     : velocity_7     <= write_data;
                    VELOCITY_8_ADDR     : velocity_8     <= write_data;
                    VELOCITY_9_ADDR     : velocity_9     <= write_data;
                    VELOCITY_10_ADDR    : velocity_10    <= write_data;
                    VELOCITY_11_ADDR    : velocity_11    <= write_data;
                    VELOCITY_12_ADDR    : velocity_12    <= write_data;
                    VELOCITY_13_ADDR    : velocity_13    <= write_data;
                    VELOCITY_14_ADDR    : velocity_14    <= write_data;
                    VELOCITY_15_ADDR    : velocity_15    <= write_data;
                    //-------------------------------------------------
                    CONTROL_REG_ADDR    : control_reg    <= write_data;
                
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
