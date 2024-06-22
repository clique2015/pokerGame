`timescale 1ns / 1ps

module player_logic(
    input [5:0] card4,      //  higest sorted card
    input [5:0] card3,      //  player card
    input [5:0] card2,      //  player card
    input [5:0] card1,      //  player card
    input [5:0] card0,      //  player card 
    output  high_card         ,
    output  one_pair1         ,
    output  one_pair2         ,
    output  one_pair3         ,
    output  one_pair4         ,
    output  two_pair_lower    ,
    output  two_pair_upper_1  ,
    output  two_pair_upper_2  ,    
    output  three_pair_lower  ,
    output  three_pair_mid    ,
    output  three_pair_upper  ,
    output  straight          ,
    output  flush             ,
    output  full_house_lower  ,
    output  full_house_upper  ,
    output  four_kind_lower   ,
    output  four_kind_upper   ,
    output  straight_flush    ,
    output  royal_flush   
    );
wire card01;
wire card12;
wire card23;
wire card34;
wire ace_card;
wire high_card_sig; 

assign card01 = (card0[3:0] == card1[3:0]) ? 1 : 0;
assign card12 = (card1[3:0] == card2[3:0]) ? 1 : 0;
assign card23 = (card2[3:0] == card3[3:0]) ? 1 : 0;
assign card34 = (card3[3:0] == card4[3:0]) ? 1 : 0;

assign ace_card = (card4[3:0] == 4'he) ? 1 : 0;

and(royal_flush		, ace_card , flush);
and(straight_flush	, straight , flush);
and(four_kind_upper	, card34 , card23 , card12);
and(four_kind_lower	, card23 , card12 , card01);
and(full_house_upper	, card34 , card23 , card01);
and(full_house_lower	, card34 , card12 , card01);

and(flush ,(card0[5:4] == card1[5:4]) , (card1[5:4] == card2[5:4]) , (card2[5:4] == card3[5:4]) , (card3[5:4] == card4[5:4]));
assign straight = (
						(card4[3:0] - card3[3:0])
						+(card3[3:0] - card2[3:0])
						+(card2[3:0] - card1[3:0])
						+(card1[3:0] - card0[3:0]) == 4) ? 1 : 0;

and(three_pair_upper , card34 , card23);
and(three_pair_mid   , card23 , card12);
and(three_pair_lower , card12 , card01);
and(two_pair_upper_1 , card34 , card12);
and(two_pair_upper_2 , card34 , card01);
and(two_pair_lower   , card23 , card01);

assign one_pair_1          = card01;
assign one_pair_2          = card12;
assign one_pair_3          = card23;
assign one_pair_4          = card34;

or(high_card_sig, flush , straight , card01 , card12 , card23 , card34);
assign high_card = ~(high_card_sig);
endmodule