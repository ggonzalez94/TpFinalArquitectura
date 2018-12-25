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

`define NB_op 6

module control_id(
  in_opcode,
  in_function,
  out_ex,
  out_mem,
  out_wb
  );

parameter NB_op = `NB_op;

input [NB_op - 1 : 0] in_opcode;
input [NB_op - 1 : 0] in_function;
output reg [10 - 1 : 0] out_ex;
output reg [9 - 1 : 0] out_mem;
output reg [2 - 1 : 0] out_wb;

//reg [2:0] alu_op; 


always@(*)begin
out_ex = 10'b0000000000;
out_mem = 9'b000000000;
out_wb = 2'b00;
case(in_opcode)
  //Instruccion tipo R
  6'b000000: begin
  case(in_function)
            // SLL - SRL - SRA
            6'b000000, 6'b000010, 
            6'b000011: begin
            out_ex = 10'b0010000100;
            out_mem = 9'b000000000;
            out_wb = 2'b10;
            end
            // SLLV - SRLV - SRAV - ADDU - SUBU - AND - OR - XOR - NOR - SLT
            6'b000100, 6'b000110, 6'b000111,
            6'b100001, 6'b100011, 6'b100100,
            6'b100101, 6'b100110, 6'b100111,
            6'b101010: begin
            out_ex = 10'b0010000000;
            out_mem = 9'b000000000;
            out_wb = 2'b10;
            end
            // JR 
            6'b001000: begin
            out_ex = 10'b0000000001;
            out_mem = 9'b000000000;
            out_wb = 2'b01;
            end
            // JALR
            6'b001001: begin
            out_ex = 10'b1010000001;
            out_mem = 9'b000000000;
            out_wb = 2'b10;
            end
            endcase
            end
    // LW 100011
    6'b100011: begin
    out_ex = 10'b0000011000;
    out_mem = 9'b000000010;
    out_wb = 2'b11;
    end
    //LB 100000
    6'b100000: begin
    out_ex = 10'b0000011000;
    out_mem = 9'b000101010;
    out_wb = 2'b11;
    end
    // LH 100001
    6'b100001: begin
    out_ex = 10'b0000011000;
    out_mem = 9'b000011010;
    out_wb = 2'b11;
    end
    
    //LBU 100100
    6'b100100:begin
    out_ex = 10'b0000011000;
    out_mem = 9'b000100010;
    out_wb = 2'b11;
    end
    // LHU 100101
    6'b100101: begin
    out_ex = 10'b0000011000;
    out_mem = 9'b000010010;
    out_wb = 2'b11;
    end

    // SW 101011
    6'b101011: begin
    out_ex = 10'b0000011000;
    out_mem = 9'b000000001;
    out_wb = 2'b00;
    end

    // SB 101000
    6'b101000: begin
    out_ex = 10'b0000011000;
    out_mem = 9'b010001001;
    out_wb = 2'b00;
    end
    // SH 101001
    6'b101001: begin
    out_ex = 10'b0000011000;
    out_mem = 9'b001001001;
    out_wb = 2'b00;
    end

    // ADDI
    6'b001000: begin
    out_ex = 10'b0000011000;
    out_mem = 9'b00000000;
    out_wb = 2'b10;
    end 

    //ANDI 
    6'b001100: begin
    out_ex = 10'b0000101000; 
    out_mem = 9'b000000000;
    out_wb = 2'b10;
    end
    //ORI
    6'b001101: begin
    out_ex = 10'b0000111000; 
    out_mem = 9'b000000000;
    out_wb = 2'b10;
    end
    //XORI
    6'b001110: begin
    out_ex = 10'b0001001000;
    out_mem = 9'b000000000;
    out_wb = 2'b10;
    end
    //LUI
    6'b001111: begin
    out_ex = 10'b0001111000;
    out_mem = 9'b000000000;
    out_wb = 2'b10;
    end
    //SLTI
    6'b001010: begin
    out_ex = 10'b0001101000;
    out_mem = 9'b000000000;
    out_wb = 2'b10;
    end
    //BEQ
    6'b000100: begin
    out_ex = 10'b0001100000;
    out_mem = 9'b000000100;
    out_wb = 2'b00;
    end
    // BNEQ 
    6'b000101: begin
    out_ex = 10'b0001100000;
    out_mem = 9'b100000100;
    out_wb = 2'b00;
    end
    //J
    6'b000010: begin
    out_ex = 10'b0000000010;
    out_mem = 9'b000000000;
    out_wb = 2'b00;
    end
    // JAL
    6'b000011: begin
    out_ex = 10'b1100000010;
    out_mem = 9'b000000000;
    out_wb = 2'b10;
    end
    default: begin
    out_ex = 10'b0000000000;
    out_mem = 9'b000000000;
    out_wb = 2'b00;
     end
  endcase
end

endmodule