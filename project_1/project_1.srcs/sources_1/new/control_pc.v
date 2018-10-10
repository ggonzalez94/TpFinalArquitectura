`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2017 12:32:56 AM
// Design Name: 
// Module Name: datapath
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
`define NB_data 32


module control_pc(
    in_pc,
    in_pc_jump,
    in_pc_jump_reg,
    in_pc_branch,
    in_jump,
    in_jump_reg,
    in_pc_src,
    out_pc  
    );

parameter NB_data = `NB_data;
input [NB_data - 1 : 0] in_pc;
input [25 : 0] in_pc_jump;
input [NB_data - 1 : 0] in_pc_jump_reg;
input [NB_data - 1 : 0] in_pc_branch;

input in_jump;
input in_jump_reg;
input in_pc_src;

wire [2:0] in_ctrl;

assign in_ctrl = {in_jump, in_jump_reg, in_pc_src};

output [NB_data - 1 : 0] out_pc;

assign out_pc = (in_ctrl == 3'b100) ? { {6{1'b0}} , (in_pc_jump)} : 
                (in_ctrl == 3'b010) ? (in_pc_jump_reg) :
                (in_ctrl == 3'b001) ? (in_pc_branch) : 
                (in_pc);

endmodule
