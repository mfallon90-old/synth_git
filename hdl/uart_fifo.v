`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
//////////////////////////////////////////////////////////////////////////////////
module uart_fifo # (
    parameter NUM_BITS      = 8,
    parameter FIFO_DEPTH    = 4
    )(
    input   wire                    clk,
    input   wire                    rst_n,
    input   wire    [NUM_BITS-1:0]  word_in,
    input   wire                    word_in_valid,
    input   wire                    word_out_valid,
    output  wire    [NUM_BITS-1:0]  word_out
    );
    
    reg [NUM_BITS-1:0]              fifo [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH)-1:0]    write_ptr;
    reg [$clog2(FIFO_DEPTH)-1:0]    read_ptr;
    reg                             wrap;
    wire                            full;
    wire                            empty;
    integer                         i;
    
    assign  word_out    = fifo[read_ptr];
    assign  empty       = (write_ptr == read_ptr) && ~wrap ? 1 : 0;
    assign  full        = (write_ptr == read_ptr) && wrap  ? 1 : 0;
    
    always @(posedge clk) begin
        if(~rst_n) begin
            for (i=0; i<FIFO_DEPTH-1; i=i+1) begin
                fifo[i] <= 0;
            end
            write_ptr   <= 0;
            read_ptr    <= 0;
            wrap        <= 0;
        end

        else begin
            if (word_in_valid) begin
                if (~full) begin
                    fifo[write_ptr] <= word_in;
                    if (write_ptr == FIFO_DEPTH-1) begin
                        write_ptr   <= 0;
                        wrap        <= 1;
                    end
                    else begin
                        write_ptr   <= write_ptr+1;
                    end
                end
            end

            if (word_out_valid) begin
                if (~empty) begin
                    fifo[read_ptr]  <= 0;
                    if (read_ptr == FIFO_DEPTH-1) begin
                        read_ptr    <= 0;
                        wrap        <= 0;
                    end
                    else begin
                        read_ptr    <= read_ptr+1;
                    end
                end
            end
        end
    end
    
   endmodule
