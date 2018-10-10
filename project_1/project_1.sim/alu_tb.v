`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2017 05:11:14 PM
// Design Name: 
// Module Name: alu_tb
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
`define NB_OP 4
`define NB_A 32

module alu_tb();

                
parameter NB_OP = `NB_OP;
parameter NB_A = `NB_A;

reg [NB_A - 1 : 0] A;
reg [NB_A - 1 : 0] B;
reg [NB_OP - 1 : 0] op;

wire [NB_A - 1 : 0]x;
wire out_flag_zero;
wire out_signo;

alu
u_alu(.A(A),.B(B), .alu_code(op),.x(x), .flag_zero(out_flag_zero), .signo(out_signo));

initial begin
A = `NB_A'h80;
B = `NB_A'h80;
op = `NB_OP'b0100;
//op = `NB_OP'b1001;
end


endmodule
