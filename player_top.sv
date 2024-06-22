`timescale 1ns / 1ps

module player_top(
	input clock,                   // system clock
	input reset,                 // system reset
	input game_over,
	input ack_in,
	input cash_or_card,
	input [7:0] data_in,
	input [2:0] player_id ,        //  player ID  
	input [2:0]winner,       //  winner ID 
	output fold,
	output ackout,
	output reg [7:0] data_out     //  player output data to dealer
 );
	 
wire wr_en, sort_done, chip_sel, start_sort,initial_bet, swap_ready;
wire send_done, receive_done, high_card, one_pair1, one_pair2, one_pair3;
wire one_pair4, two_pair_lower, two_pair_upper_1, two_pair_upper_2, three_pair_lower;
wire three_pair_mid, three_pair_upper, straight, flush, full_house_lower;
wire full_house_upper, four_kind_lower, four_kind_upper, straight_flush, royal_flush, royal_straight;
wire swap0, swap1, swap2, swap3, total_swap, raise;

wire [2:0] select, output_sel, addr_out, state; 
wire [7:0] data_in_memory, cash_out, chip_in; 
wire [5:0] sort_data[5];
wire [5:0] bank_cards[5];

assign royal_straight = (straight_flush | royal_flush ) ? 1 : 0;

assign output_sel = (chip_sel) ? 3'h5 : addr_out;

always @ (output_sel) begin

	case (output_sel)
	 3'b000: data_out = {2'b00 , bank_cards[0]};
	 3'b001: data_out = {2'b00 , bank_cards[1]};
	 3'b010: data_out = {2'b00 , bank_cards[2]};
	 3'b011: data_out = {2'b00 , bank_cards[3]};
	 3'b100: data_out = {2'b00 , bank_cards[4]};
	 3'b101: data_out = cash_out;
	 default: data_out = 3'b000;
	endcase	
end

bank player_bank(
    .clk(clock),   
    .reset(reset),   
    .enable(wr_en),                
    .enable_all(sort_done),           
    .sel(select),            
    .data(data_in_memory),            
    .in_card({sort_data[0],sort_data[1],sort_data[2],sort_data[3],sort_data[4]}),   	 
    .card_out({bank_cards[0],bank_cards[1],bank_cards[2],bank_cards[3],bank_cards[4]}),
    .chip(chip_in)   
    );
	 
stage card_state(
    .clk(clock),              
    .reset(reset),           
    .move_to_1(start_sort),             // move to stage 1    
    .move_to_2(initial_bet),             // move to stage 2
    .move_to_3(swap_ready),             // move to stage 3
    .move_to_4(send_done),             // move to stage 4
    .move_to_5(receive_done),             // move to stage 5
    .reset_game(game_over),
    .state(state)
    );

sorter card_sorter(
    .clk(clock),         
    .reset(reset),        
    .init(start_sort),             // initialize the sort
	 .state(state),
    .card0(bank_cards[0]),     
    .card1(bank_cards[1]),     
    .card2(bank_cards[2]),     
    .card3(bank_cards[3]),      
    .card4(bank_cards[4]),    
    .done(sort_done), 
    .card_output({sort_data[0],sort_data[1],sort_data[2],sort_data[3],sort_data[4]})
    );
 
_logic player_logic(
    .card4(bank_cards[0]),      
    .card3(bank_cards[1]),      
    .card2(bank_cards[2]),      
    .card1(bank_cards[3]),      
    .card0(bank_cards[4]),    
    .high_card (high_card)         ,
    .one_pair1 (one_pair1)         ,
    .one_pair2 (one_pair2)         ,
    .one_pair3 (one_pair3)         ,
    .one_pair4 (one_pair4)         ,
    .two_pair_lower (two_pair_lower)    ,
    .two_pair_upper_1 (two_pair_upper_1)  ,
    .two_pair_upper_2 (two_pair_upper_2)  ,    
    .three_pair_lower (three_pair_lower)  ,
    .three_pair_mid (three_pair_mid)    ,
    .three_pair_upper (three_pair_upper)  ,
    .straight (straight)          ,
    .flush  (flush)           ,
    .full_house_lower (full_house_lower) ,
    .full_house_upper (full_house_upper) ,
    .four_kind_lower (four_kind_lower)  ,
    .four_kind_upper (four_kind_upper)  ,
    .straight_flush (straight_flush)   ,
    .royal_flush (royal_flush)  
    );
	 logic_out player_logic_out(
    .clk(clock),              // system clock
    .reset(reset),            // system reset
    .high_card(high_card)         ,
    .one_pair1(one_pair1)         ,
    .one_pair2(one_pair2)         ,
    .one_pair3(one_pair3)         ,
    .one_pair4(one_pair4)         ,
    .two_pair_lower(two_pair_lower)    ,
    .two_pair_upper_1(two_pair_upper_1)  ,
    .two_pair_upper_2(two_pair_upper_2)  ,    
    .three_pair_lower(three_pair_lower)  ,
    .three_pair_mid (three_pair_mid)   ,
    .three_pair_upper (three_pair_upper) ,
    .straight (straight)         ,
    .flush  (flush)           ,
    .full_house_lower (full_house_lower) ,
    .full_house_upper (full_house_upper) ,
    .four_kind_lower (four_kind_lower)  ,
    .four_kind_upper (four_kind_upper)  ,
    .straight_flush (straight_flush)   ,
    .royal_flush  (royal_flush)     , 

    .card4(bank_cards[0]), 
    .raise(raise),
    .swap0_addr(swap0), 
    .swap1_addr(swap1),    
    .swap2_addr(swap2), 
    .swap3_addr(swap3),       
    .total_swap(total_swap)
    );


	 _control player_control(
    .clk(clock),              // system clock
    .reset(reset),            // system reset
    .ack_in(ack_in),            // dealer acknowledge
    .game_over(game_over),        // end of game signal
	 .cash_card(cash_or_card),
	 .sort_done(sort_done),
	 .raise(raise),
	 .royal_straight(royal_straight),
	 .high_card(high_card),
	 
	 .chip_in_memory(chip_in),	 
	 .data_in(data_in),
    .total_swap(total_swap0),       // number of card to swap
    .swap0(swap0),      //  swap card0 address
    .swap1(swap1),      //  swap card1 address
    .swap2(swap2),      //  swap card2 address
    .swap3(swap3),       //  swap card3 address
	 
    .state(state),       //  game state 
    .pid(player_id) ,        //  player ID  
    .winner(winner),       //  winner ID 

	 .enable(wr_en),
	 .initial_bet(initial_bet),
	 .select(select),
	 .swap_ready(swap_ready),
	 .data_to_bank(data_in_memory),
	 .addr_out(addr_out),
	 .start_sort(start_sort),
	 .send_done(send_done),
	 .receive_done(receive_done),
	 
	 .ackout_reg(ackout), 
	 .fold_reg(fold), 
	 .chipsel_reg(chip_sel),
	 .chipout_reg(cash_out)
    );

endmodule