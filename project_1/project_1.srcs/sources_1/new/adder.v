`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2017 05:04:46 PM
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

module adder( A,
            B,
            x
);

parameter NB = 32;

 input wire [NB - 1 : 0] A;
 input wire [NB - 1 : 0] B;
 output [NB - 1 : 0] x;
 
 
 assign x = A + B; 
// always@(*) begin
//  x = A + B;
//end
endmodule