`timescale 1ns / 1ps

module bank_test;
    reg clk;                   // system clock
    reg reset;                 // system reset
    reg enable;                // write enable
    reg enable_all;            // parallel write enable
    reg [2:0] sel;            //  register address
    reg [7:0] data;            //  register data 
    reg [5:0] in_card[5];      //  player card
    wire [5:0] card_reg[5]; 
    wire [7:0] chip_reg;     //  player chip
    
    
    parameter counts = 15;

	 player_bank uut(
    .clk(clk),
    .reset(reset),
    .enable(enable), 
    .enable_all(enable_all),
    .sel(sel),
    .data(data), 
    .card_reg(card_reg),
    .in_card(in_card),
    .chip_reg(chip_reg));

  always
  begin
    clk = 0;
    for(int i = 0; i <= counts; i=i+1)begin
      #2; // delay for 10 time units
      clk = ~clk;
      if(clk)
      begin
        if(i <= 10)begin
          enable <= 1;
          sel <= i/2;
          data <= counts;
        end 
        else
        begin
          enable <= 0;
          sel <= 0;
          data <= 0;
          enable_all <= 1;
          in_card[(i - 11) / 2] <= counts;
        end
      end

    end

    $finish; // end simulation
  end


	 
endmodule