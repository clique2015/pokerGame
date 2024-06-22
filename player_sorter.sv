`timescale 1ns / 1ps
//this module takes 5 cards 
module card_sorter(
    input clk,              // system clock
    input reset,            // system reset
    input init,             // initialize the sort
	 input [2:0] state,
    input [5:0] card0,      //  player card
    input [5:0] card1,      //  player card
    input [5:0] card2,      //  player card
    input [5:0] card3,      //  player card
    input [5:0] card4,      //  player card 
    output done,            //  marks completion of the sorting process
 //   output enable,          // enable storage of cards after sorting
    output reg[5:0]card_output[5] // card output after sorting
    );

 parameter n = 5;         //Number of card output registers
integer i;

reg  [5:0] temp_reg[4];//stores card during sorting
//reg  debounce_reg;
reg  [3:0] counter_reg;         //card counter register
wire enc;
wire [5:0] serial_card;

and(done , (counter_reg == 4'h9) , (state <= 3'h3));
//and(enable , ~debounce_reg , done);

always @ (posedge clk) begin
    if(reset || init) begin
	 
		//debounce_reg = 1'd0;
		
		 for(i=0; i<n; i=i+1)
		 card_output[i] = 6'd0;
		 
		 for(i=0; i<n-1; i=i+1)
		 temp_reg[i] = 6'd0;

       counter_reg = 4'h0;
    end
    else
        if(counter_reg < 4'd9) begin
        counter_reg++;
        end

            if(counter_reg < 4'd5) begin
                case (counter_reg[2:0])
                    3'b000: begin
                            card_output[0] = (card0 >= card_output[0]) ? card0 : card_output[0];
                            temp_reg[0] = (card0 >= card_output[0]) ? card_output[0]: card0;
                            end
                    3'b001: begin 
                            card_output[0] = (card1 >= card_output[0]) ? card1 : card_output[0];
                            temp_reg[0] = (card1 >= card_output[0]) ? card_output[0]: card1;
                            end
                    3'b010: begin
                            card_output[0] = (card2 >= card_output[0]) ? card2 : card_output[0];
                            temp_reg[0] = (card2 >= card_output[0]) ? card_output[0]: card2;
                            end
                    3'b011: begin
                            card_output[0] = (card3 >= card_output[0]) ? card3 : card_output[0];
                            temp_reg[0] = (card3 >= card_output[0]) ? card_output[0]: card3;
                            end
                    3'b100: begin
                            card_output[0] = (card4 >= card_output[0]) ? card4 : card_output[0];
                            temp_reg[0] = (card4 >= card_output[0]) ? card_output[0]: card4;
                            end
                    default: begin
                            card_output[0] = card_output[0];
                            temp_reg[0] = temp_reg[0];
                            end
                endcase
            end

        for(i=1; i<n; i=i+1) begin
        if(temp_reg[i-1][3:0] >= card_output[i][3:0])begin
        card_output[i] = temp_reg[i-1];
        temp_reg[i] = card_output[i];
        end
        else
        if(n < 4) begin
        temp_reg[i] = temp_reg[i-1];
            end
		end
		//debounce_reg = done;
end 

endmodule