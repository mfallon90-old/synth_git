`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Author: Michael Fallon
// Date : 2/2/23
// Design Name: FM SYNTHESIZER
//
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module debounce_pulse #(
    parameter   PULSE_WIDTH = 1
    )
    (
    input   wire    clk,
    input   wire    rst_n,
    input   wire    btn_in,
    output  wire    interrupt
    );
    
    localparam  IDLE    =   1'b0;
    localparam  ACTIVE  =   1'b1;
    localparam  MAX_VAL =   1_632_650;
    
    reg                         state;
    reg     [20:0]              count;
    reg     [PULSE_WIDTH-1:0]   pulse;
    
    assign interrupt = pulse[0];
    
    always @(posedge clk)
    begin

        if (~rst_n) begin
            state   <= IDLE;
            count   <= 0;
            pulse   <= 0;
        end
        else begin
            pulse   <=  (pulse >> 1);
            
            case (state)
                IDLE : begin
                    if ((count<MAX_VAL)&&(btn_in))
                    begin
                        count   <=  count+1;
                        state   <=  IDLE;
                        pulse   <=  0;
                    end
                    else if (!btn_in)
                    begin
                        count   <=  0;
                        state   <=  IDLE;
                        pulse   <=  0;
                    end
                    else
                    begin
                        count   <=  0;
                        state   <=  ACTIVE;
                        pulse   <=  ~0;
                    end
                end
                ACTIVE : begin
                    if ((count<MAX_VAL)&&(!btn_in))
                    begin
                        count   <=  count+1;
                        state   <=  ACTIVE;
                        pulse   <=  0;
                    end
                    else if (btn_in)
                    begin
                        count   <=  0;
                        state   <=  ACTIVE;
                        pulse   <=  0;                    
                    end
                    else
                    begin
                        count   <=  0;
                        state   <=  IDLE;
                        pulse   <=  0;
                    end
                end
                default : state <=  IDLE;            
            endcase
        end
    end
endmodule
