`timescale 1ns / 1ps

module fixed_point_mult #
    (
    parameter   WI_1    = 3,
    parameter   WF_1    = 5,
    parameter   WI_2    = 3,
    parameter   WF_2    = 5,
    parameter   WI_O    = WI_1+WI_2,
    parameter   WF_O    = WF_1+WF_2
    )
    (
    input   wire    signed  [WI_1+WF_1-1:0] in_1,
    input   wire    signed  [WI_2+WF_2-1:0] in_2,
    output  reg     signed  [WI_O+WF_O-1:0] data_out,
    output  reg                             ovf
    );

    wire    signed  [WI_1+WI_2+WF_1+WF_2-1:0]   product;

    always @(*)
    begin
        ovf = 1'b0;
        if (WI_O > WI_1+WI_2)
            data_out[WI_O+WF_O-1:WF_O] =  {{WI_O-WI_1-WI_2{product[WI_1+WI_2+WF_1+WF_2-1]}}, 
                                            product[WI_1+WI_2+WF_1+WF_2-1:WF_1+WF_2]};

        else if (WI_O == WI_1+WI_2)
            data_out[WI_O+WF_O-1:WF_O] = product[WI_1+WI_2+WF_1+WF_2-1:WF_1+WF_2];

        else
        begin
            data_out[WI_O+WF_O-1:WF_O] = {product[WI_1+WI_2+WF_1+WF_2-1], product[WI_O+WF_1+WF_2-2:WF_1+WF_2]};
            ovf = ((product[WI_1+WI_2+WF_1+WF_2-1] && ~&product[WI_1+WI_2+WF_1+WF_2-1:WI_O+WF_1+WF_2-1]) || 
                  (~product[WI_1+WI_2+WF_1+WF_2-1] && |product[WI_1+WI_2+WF_1+WF_2-1:WI_O+WF_1+WF_2-1])) ? 1'b1 : 1'b0;
        end

        if (WF_O > WF_1+WF_2)
            data_out[WF_O-1:0] = {product[WF_1+WF_2-1:0], {WF_O-WF_1-WF_2{1'b0}}};

        else if (WF_O == WF_1+WF_2)
            data_out[WF_O-1:0] = product[WF_1+WF_2-1:0];

        else if (WF_O == 0) begin
        end


        else 
            data_out[WF_O-1:0] = product[WF_1+WF_2-1:WF_1+WF_2-WF_O];

    end
    
    assign product = in_1 * in_2;
   
endmodule
