`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2017 06:29:47 PM
// Design Name: 
// Module Name: instruction_decoder
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
`define NB 32

module alu_control(
    in_alu_op,
    in_function,
    out_alu_code
);
input [2 : 0] in_alu_op;
input [5 : 0] in_function;
output reg[3 : 0] out_alu_code;

always@(*)begin
  case (in_alu_op)
    3'b000: begin
      case (in_function)
        6'b000000: out_alu_code = 4'b0000;
        6'b000010: out_alu_code = 4'b0001;
        6'b000011: out_alu_code = 4'b0010;
        6'b000100: out_alu_code = 4'b0000;
        6'b000110: out_alu_code = 4'b0001;
        6'b000111: out_alu_code = 4'b0010;

        6'b100001: out_alu_code = 4'b0011;
        6'b100011: out_alu_code = 4'b0100;
        6'b100100: out_alu_code = 4'b0101;  
        6'b100101: out_alu_code = 4'b0110;
        6'b100110: out_alu_code = 4'b0111;
        6'b100111: out_alu_code = 4'b1000;

        6'b101010: out_alu_code = 4'b1010;

        6'b001001: out_alu_code = 4'b0011;     

      endcase
    end
    3'b001: out_alu_code = 4'b0011;
    3'b010: out_alu_code = 4'b0101; 
    3'b011: out_alu_code = 4'b0110;
    3'b100: out_alu_code = 4'b0111;
    3'b101: out_alu_code = 4'b0000;
    3'b110: out_alu_code = 4'b1010;
    3'b111: out_alu_code = 4'b1001;
  endcase
end

endmodule