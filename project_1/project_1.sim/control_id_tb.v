`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2017 05:55:33 PM
// Design Name: 
// Module Name: cpu_tb
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

module control_id_tb( );

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

reg [NB_data - 1 : 0] in_instruction;
wire [1 : 0] connect_wb;
wire [9 - 1 : 0] connect_mem;
wire [8 - 1 : 0] connect_ex;

control_id
u_control_id(
    .in_opcode(in_instruction[31:26]),
    .in_function(in_instruction[5:0]), 
    .out_ex(connect_ex), 
    .out_mem(connect_mem), 
    .out_wb(connect_wb));


initial begin   
    in_instruction = `NB_data'h8C200000;
    //in_instruction = `NB_data'h22D5FFCE; // addi $21, $22, -50
    //in_instruction = `NB_data'h012A4020; // add $8, $9, $10
    //in_instruction = `NB_data'h1243a820; // beq $s, $t, C
end

endmodule