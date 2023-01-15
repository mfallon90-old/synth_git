`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: San Diego State University
// Engineer: Michael Fallon
// 
// Create Date: 11/02/2021 06:12:08 AM
// Design Name: UART
// Tool Versions: Vivado 2020.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
//      clk frequency       = 22.580647 MHz
//      baud rate           = 31.250 Kbs
//      clk cycles per bit  = 722.581
//      sample point        = 361.29
// 
//      clk frequency       = 32.653061 MHz
//      baud rate           = 31.250 Kbs
//      clk cycles per bit  = 1044
//      sample point        = 522.5
// 
//////////////////////////////////////////////////////////////////////////////////
module uart_rx # (
    parameter LSB_FIRST = 1
    )(
    input   wire            clk,            //clock signal
    input   wire            rst_n,            //reset line
    input   wire            i_data,         //incoming serial data line
    output  reg     [7:0]   o_data,         //output 8 bit data register
    output  wire            rdy_flg         //register ready to be read
    );
    
    localparam  SAMPLE_POINT    = 522;              //number of clock cycles until sample point
    localparam  BIT_COUNT       = 2*SAMPLE_POINT;   //number of clock cycles in one UART bit
    localparam  NUM_BITS        = 8;                //number of bits in UART word
    
    localparam  s_IDLE          = 2'b00;    //IDLE state, waiting to receive new data
    localparam  s_START         = 2'b01;    //START state, verify that start bit is valid
    localparam  s_RX            = 2'b10;    //RX state, receive data 
    localparam  s_DONE          = 2'b11;    //DONE state, wait for data to be read
    
    reg [NUM_BITS-1:0]  data;               //register to hold recieved data
    reg [1:0]           state;              //register to hold current state
    reg [13:0]          bit_cnt;            //counter to count clock cycles per bit
    reg [3:0]           bits_rx;            //counter to count number of bits received
    reg                 rdy;                //receive complete and ready to be read
    
    assign  rdy_flg = rdy;
    
    always @(posedge clk) begin
        if(~rst_n) begin
            state   <= s_IDLE;
            data    <= 0;
            bit_cnt <= 0;
            bits_rx <= 0;
            rdy     <= 0;
            o_data  <= 0;
        end

        else begin
            case(state) 
                s_IDLE : begin
                    bit_cnt <= 0;
                    bits_rx <= 0;
                    rdy     <= 0;
                    if(~i_data)
                        state   <= s_START;
                    else
                        state   <= s_IDLE;
                end

                s_START : begin
                    bit_cnt <= bit_cnt+1;
                    state   <= s_START;

                    if(bit_cnt >= SAMPLE_POINT) begin
                        if(~i_data) begin
                            state   <= s_RX;
                            bit_cnt <= 0;
                        end

                        else begin
                            state   <= s_IDLE;
                        end
                    end
                end
                
                s_RX : begin
                    state   <= s_RX;
                    if(bits_rx < NUM_BITS) begin

                        if(bit_cnt==BIT_COUNT) begin
                            if (LSB_FIRST == 1) begin
                                data[bits_rx]   <= i_data;
                            end

                            else if (LSB_FIRST == 0) begin
                                data[(NUM_BITS-1)-bits_rx] <= i_data;
                            end

                            bit_cnt         <= 0;
                            bits_rx         <= bits_rx+1;
                        end

                        else begin
                            bit_cnt <= bit_cnt+1;
                        end
                    end

                    else begin
                        state   <= s_DONE;
                    end
                end

                s_DONE : begin
                    rdy     <= 1;
                    o_data  <= data;
                    state   <= s_IDLE;
                end

                 default : state <= s_IDLE;
            endcase
        end
    end
    
   endmodule
