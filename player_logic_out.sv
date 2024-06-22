`timescale 1ns / 1ps
//this module takes 5 cards 
module player_logic_out(
    input clk,              // system clock
    input reset,            // system reset
    input  high_card         ,
    input  one_pair1         ,
    input  one_pair2         ,
    input  one_pair3         ,
    input  one_pair4         ,
    input  two_pair_lower    ,
    input  two_pair_upper_1  ,
    input  two_pair_upper_2  ,    
    input  three_pair_lower  ,
    input  three_pair_mid    ,
    input  three_pair_upper  ,
    input  straight          ,
    input  flush             ,
    input  full_house_lower  ,
    input  full_house_upper  ,
    input  four_kind_lower   ,
    input  four_kind_upper   ,
    input  straight_flush,
	 input  royal_flush    ,

    input  [5:0]card4 , 
    output raise,
    output reg [2:0]swap0_addr, 
    output reg [2:0]swap1_addr,    
    output reg [2:0]swap2_addr, 
    output reg [2:0]swap3_addr,       
    output reg [2:0]total_swap
    );

/**
* card swaps
*   high_card           => 029c => card0, card1, card2, card3
*   one_pair1           => 04e3 => card2, card3, card4 when card4 < 8, else card2, card3
*   one_pair2           => 00e3 => card0, card3, card4 when card4 < 8, else card0, card3
*   one_pair3           => 0063 => card0, card1, card4 when card4 < 8, else card0, card1
*   one_pair4           => 0053 => card0, card1, card2 
*   two_pair_lower      => 029c => card0, card1, card2, card3
*   two_pair_upper_1    => 0001 => card2
*   two_pair_upper_2    => 0011 => card0
*   three_pair_lower    => 00e2 => card3, card4
*   three_pair_mid      => 0022 => card0, card4
*   three_pair_upper    => 000a => card0, card1
*   straight            => 0000 => no swap
*   flush               => 0000 => no swap
*   full_house_lower    => 011a => card3, card4
*   full_house_upper    => 000a => card0, card1
*   four_kind_lower     => 0021 => card4 when card4 < 8 else no swap
*   four_kind_upper     => 0001 => card0
*   straight_flush      => 0000 => no swap
*   royal_flush         => 0000 => no swap
*/

wire add_card4;

assign raise = full_house_lower | full_house_upper | four_kind_lower | four_kind_upper;
assign add_card4 = card4[3:0] < 8 ? 1 : 0;

always @(*) 
    if(straight_flush || royal_flush)
        total_swap = 3'b000;
    else

    if(four_kind_upper) begin
        total_swap = 1;
        swap0_addr = 0;
    end else

    if(four_kind_lower) begin
        if(add_card4) begin
        total_swap = 1;
        swap0_addr = 4;
        end else
        total_swap = 0;
    end else

    if(full_house_upper) begin
        total_swap = 2;
        swap0_addr = 0;
        swap1_addr = 1;
    end else

    if(full_house_lower) begin
        total_swap = 2;
        swap0_addr = 3;
        swap1_addr = 4;
    end else

    if(flush || straight) begin
        total_swap = 0;
    end else

    if(three_pair_upper) begin
        total_swap = 2;
        swap0_addr = 0;
        swap1_addr = 1;
    end else

    if(three_pair_mid) begin
        total_swap = 2;
        swap0_addr = 0;
        swap1_addr = 4;
    end else

    if(three_pair_lower) begin
        total_swap = 2;
        swap0_addr = 3;
        swap1_addr = 4;
    end else

    if(two_pair_upper_2) begin
        total_swap = 1;
        swap0_addr = 0;
    end else

    if(two_pair_upper_1) begin
        total_swap = 1;
        swap0_addr = 2;
    end else  

    if(two_pair_lower) begin
        total_swap = 4;
        swap0_addr = 0;
        swap1_addr = 1;
        swap2_addr = 2;
        swap3_addr = 3;
    end else

    if(one_pair4) begin
        total_swap = 3;
        swap0_addr = 0;
        swap1_addr = 1;    
        swap2_addr = 2;
    end else

    if(one_pair3) begin
        swap0_addr = 0;
        swap1_addr = 1;
        if(add_card4) begin
            swap2_addr = 4;
            total_swap = 3;
        end else
        total_swap = 2;
    end else

    if(one_pair2) begin
        swap0_addr = 0;
        swap1_addr = 3;
        if(add_card4) begin
            swap2_addr = 4;
            total_swap = 3;
        end else
        total_swap = 2;
    end else

    if(one_pair1) begin
    swap0_addr = 2;
    swap1_addr = 3;
    if(add_card4) begin
        swap2_addr = 4;
        total_swap = 3;
    end else
    total_swap = 2;
    end else

    if(high_card) begin
        total_swap = 4;
        swap0_addr = 0;
        swap1_addr = 1;
        swap2_addr = 2;
        swap3_addr = 3;    
    end


endmodule