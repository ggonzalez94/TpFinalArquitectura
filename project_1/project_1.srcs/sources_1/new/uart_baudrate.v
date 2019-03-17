`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:46:08 10/13/2016 
// Design Name: 
// Module Name:    uart_baudrate 
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
module uart_baudrate(
	input clk,
	output reg tick
    );
	// count = CLK / (BAUD * 16)
	// count = 100MHz / (9600 * 16)
	reg [9:0] count = 0;

	always @(posedge clk)
	begin
	   if(count == 651)
		begin
			tick = 1;
			count = 0;
		end
		else
		begin
			tick = 0;
			count = count + 1;
		end
	end		

endmodule

