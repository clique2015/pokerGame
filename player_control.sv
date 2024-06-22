`timescale 1ns / 1ps
    parameter player_id = 6;  
module player_control(
    input clk,              // system clock
    input reset,            // system reset
    input ack_in,            // dealer acknowledge
    input game_over,        // end of game signal
	 input cash_card,
	 input sort_done,
	 input raise,
	 input royal_straight,
	 input high_card,
	 
	 input [7:0] chip_in_memory,	 
	 input [7:0] data_in,
    input [2:0]total_swap,       // number of card to swap
    input [2:0] swap0,      //  swap card0 address
    input [2:0] swap1,      //  swap card1 address
    input [2:0] swap2,      //  swap card2 address
    input [2:0] swap3,       //  swap card3 address
	 
    input [2:0] state,       //  game state 
    input [2:0] pid ,        //  player ID  
    input [2:0]winner,       //  winner ID 

	 output enable,
	 output initial_bet,
	 output swap_ready,
	 output send_done,
	 output receive_done,
	 output [2:0] select,
	 output [7:0] data_to_bank,
	 output reg [2:0]addr_out,
	 output start_sort,
    output reg ackout_reg, 
	 output reg fold_reg, 
	 output reg chipsel_reg,
	 output reg [7:0]chipout_reg
    );


reg [2:0]swap0_reg;
reg [2:0]swap1_reg;
reg [2:0]swap2_reg;
reg [2:0]swap3_reg;

reg [2:0]total_swap_reg;
reg [2:0]counter_reg;



		
wire  [7:0] chipout_sig;
wire  [7:0] remove_chip;

wire player_set, zero_swap, card_ready_sig, initial_bet_sig,	swap_ready_sig;

wire send_card, send_done_sig, add_chip, receive_done_sig, receive_card, ack_sig;

wire bet_again, bet_chip, fold_sig, no_cash, player_ack;

assign initial_bet = initial_bet_sig;

assign swap_ready  = swap_ready_sig;

assign send_done   = send_done_sig;

assign receive_done= receive_done_sig;

assign player_set = (pid == player_id) ? 1 : 0;

assign player_ack = player_set & ack_in;

assign no_cash    = (chip_in_memory <= data_in) ? 1 : 0;

assign zero_swap  = (total_swap_reg == counter_reg) ? 1 : 0;

assign fold_sig   = (initial_bet_sig &  no_cash) | (receive_done_sig   &  (high_card | no_cash));

assign bet_chip   = ~fold_sig & (initial_bet_sig | receive_done_sig);

assign sel_chip   = (cash_card & card_ready_sig) | add_chip | sel_chip;

assign select     = (sel_chip) ? 3'h5 : (card_ready_sig) ? counter_reg : (receive_card) ? addr_out : 3'h0;

assign enable     = card_ready_sig | receive_card | sel_chip ;

assign chip_avail = (chip_in_memory - data_in) > 3'hfff ? 1:0 ;

assign chipout_sig= (royal_straight ? chip_in_memory : (raise & chip_avail)? data_in + 3'hfff: data_in);

assign remove_chip= (receive_done_sig) ?  chipout_sig : data_in;

assign ack_sig    = card_ready_sig | initial_bet_sig | swap_ready_sig | send_card | receive_card | receive_done_sig;
 
assign data_to_bank = (sel_chip) ? ((card_ready_sig | add_chip) ? chip_in_memory + data_in: chip_in_memory - remove_chip): data_in;


assign 	card_ready_sig = (state == 3'b000) ? player_ack : 0;

assign	start_sort =  (counter_reg == 3'h5 && state == 3'b000) ? 1 : 0;

assign initial_bet_sig = (state == 3'b001) ? player_ack : 0;

assign swap_ready_sig = (state == 3'b010 && player_set && sort_done) ? 1 : 0 ; 

assign send_card = (state == 3'b011 && player_ack && ~zero_swap) ? 1 : 0;

assign send_done_sig = (state == 3'b011 && player_ack && zero_swap) ? 1 : 0;

assign receive_card =  (state == 3'b100 && player_ack && ~zero_swap) ? 1 : 0;

assign receive_done_sig  =  (state == 3'b100 && player_ack && zero_swap) ? 1 : 0;

assign add_chip  =  (state == 3'b101 && game_over && (winner == player_id)) ? 1 : 0;

always @ (posedge clk) begin
    if(reset) begin
        swap0_reg = 3'b000;
        swap1_reg = 3'b000;
        swap2_reg = 3'b000;
        swap3_reg = 3'b000;
		  total_swap_reg 	= 3'b000;
    end
    else    if(sort_done) begin
        swap0_reg = swap0;
        swap1_reg = swap1;
        swap2_reg = swap2;
        swap3_reg = swap3;
        total_swap_reg = total_swap;
    end

end 

always @ (posedge clk) begin
    if(reset) begin
	 
        counter_reg 		= 3'b000;
		  chipout_reg 		= 8'h00;
		  ackout_reg 		= 1'b0;
        fold_reg 			= 1'b0;
        chipsel_reg 		= 1'b0;       
    end
    else if(game_over || sort_done || send_done_sig)
        counter_reg 		= 3'b000;
	 else if(send_card || receive_card || (card_ready_sig && ~cash_card))
			counter_reg++ ;
    else begin
		chipsel_reg = receive_done_sig;
		fold_reg    = fold_sig;
		ackout_reg  = ack_sig;
		chipout_reg = chipout_sig;
		end

	case (counter_reg)
		 3'b001: assign addr_out = swap0_reg;
		 3'b010: assign addr_out = swap1_reg;
		 3'b011: assign addr_out = swap2_reg;
		 3'b100: assign addr_out = swap3_reg;
		 default: assign addr_out = 3'b000;
	endcase	
end
endmodule