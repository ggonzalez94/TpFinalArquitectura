`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2017 05:55:33 PM
// Design Name: 
// Module Name: ID_EX_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define NB_addr 5
`define NB_data 32

module top_pipe_tb();

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

reg clk;
reg reset;

top_pipe#(.NB_addr(NB_addr), .NB_data(NB_data))
u_top_pipe(.clk(clk), .reset(reset));

initial begin
  clk = 1'b1;
  reset = 1'b1;
  #10 reset = 1'b0;
end

always #2 clk = ~clk;

endmodule