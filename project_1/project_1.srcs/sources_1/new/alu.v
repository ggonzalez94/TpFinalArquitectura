`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2017 05:04:46 PM
// Design Name: 
// Module Name: alu
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

`define NB_A 32
`define NB_B 32
`define NB_ALU_CODE 4
`define NB_X 32

module alu( A,
    B,
    alu_code,
    x,
    flag_zero,
    signo
    );

parameter NB_A = `NB_A;
parameter NB_B = `NB_B;
parameter NB_ALU_CODE = `NB_ALU_CODE;
parameter NB_X = `NB_X;


input wire signed [NB_A - 1 : 0] A;
input wire signed [NB_B - 1 : 0] B;
input wire [NB_ALU_CODE - 1 : 0] alu_code;
output reg signed [NB_X - 1 : 0] x;
output flag_zero;
output signo;

assign signo = x[NB_ALU_CODE - 1];
assign flag_zero  = (A == B) ?  (1'b1) : (1'b0);
// assign flag_zero  = (x == `NB_X'h00) ?  (1'b1) : (1'b0);

always@(*)begin
    x = A;
    case(alu_code)                                
        4'b0000  :  x = B << A; //shift left
        4'b0001  :  x = B >> A; // shift right logico  
        4'b0010  :  x = B >>> A; // shift right aritmetico
        4'b0011  :  x = A + B; // sumar
        4'b0100  :  x = A - B; //restar
        4'b0101  :  x = A & B; //and
        4'b0110  :  x = A | B; // or
        4'b0111  :  x = A ^ B; // xor
        4'b1000  :  x = ~(A | B); // nor
        4'b1001  :  x = B << 16; // B shift 16 << LUI
        4'b1010  :  x = (A < B); //comparacion para slt
        // 4'b1011  :  x = (A == B); //comparacion para slt

        //default:  x = 8'hFF;
        endcase
end


endmodule
