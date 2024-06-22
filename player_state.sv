`timescale 1ns / 1ps
//this module takes 5 cards 
module card_state(
    input clk,              // system clock
    input reset,            // system reset
    input move_to_1,             // move to stage 1    
    input move_to_2,             // move to stage 2
    input move_to_3,             // move to stage 3
    input move_to_4,             // move to stage 4
    input move_to_5,             // move to stage 5
    input reset_game,

    output reg [2:0]state       // game stage
    );
wire sig;
or(sig, move_to_1, move_to_2 , move_to_3 , move_to_4 , move_to_5);
always @ (posedge clk) begin
    if(reset) begin
        state = 3'h0;
    end
    else    if(sig) begin
                state++;
				end
				else  if(reset_game) begin
                state = 0;
                end
    
end 

endmodule