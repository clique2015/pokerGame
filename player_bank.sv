`timescale 1ns / 1ps

module player_bank(
    input clk,                   // system clock
    input reset,                 // system reset
    input enable,                // write enable
    input enable_all,            // parallel write enable
    input [2:0] sel,            //  register address
    input [7:0] data,            //  register data 

    input [5:0] in_card[5],      //  player card

    output reg [5:0] card_reg[5],      //  output player card
    output reg [7:0] chip_reg     //  player chip
    );
	 
parameter n = 5;         //Number of card output registers
integer i;


always @ (posedge clk) begin
    if(reset) begin
        chip_reg <= 8'd0;
        for(i=0; i<n; i=i+1)
            card_reg [i] <= 6'd0;
    end
    else	 
        if(enable) begin
                case (sel)
                    3'b000: card_reg [0] = data[5:0];
                    3'b001: card_reg [1] = data[5:0];
                    3'b010: card_reg [2] = data[5:0];
                    3'b011: card_reg [3] = data[5:0];
                    3'b100: card_reg [4] = data[5:0];
                    3'b101: chip_reg  = data;
                endcase
        end
    else
        if(enable_all) begin
            for(i=0; i<n; i=i+1)
            card_reg [i] <= in_card[i];
        end    
    end 

endmodule