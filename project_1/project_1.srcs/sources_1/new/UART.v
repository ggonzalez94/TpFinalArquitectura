`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:41:40 10/13/2017
// Design Name: 
// Module Name:    UART 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module UART(
	input                                              reset,
	input                                              clk,
	input                                              rx,
	
	input      [7:0]                                   tx_in,
	input                                              tx_start,
	
	output                                             tx,
	output                                             tx_done_tick,
	output                                             rx_done_tick,
	      
	output     [7:0]                       rx_out      
    );
	 
	wire                                   tick;
	
	uart_baudrate baudrate
	(
	   .clk(clk),
	   .tick(tick)
	);
	
	Rx rx_module
	(
	   .reset(reset),
	   .clk(tick),
	   .rx(rx),
	   .d_out(rx_out),
	   .rx_done_tick(rx_done_tick)
   );
	
	Tx tx_module(
	   .reset(reset),
	   .clk(tick),
	   .tx_start(tx_start),
	   .tx(tx),
	   .d_in(tx_in),
	   .tx_done_tick(tx_done_tick)
   );
	
endmodule
