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
`define N_regs 32

module ID_tb( );

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

reg [NB_data - 1 : 0] in_instruction;
reg [NB_data - 1 : 0] in_branch;
reg [NB_data - 1 : 0] in_wdata;
reg [NB_addr - 1 : 0] in_rd;
reg in_reg_write;
reg clk;
reg reset;

wire [NB_data - 1 : 0] out_branch;
wire [4 - 1 : 0] out_ex;
wire [3 - 1 : 0] out_mem;
wire [2 - 1 : 0] out_wb;
wire [NB_data - 1 : 0] out_reg1;
wire [NB_data - 1 : 0] out_reg2;
wire [NB_data - 1 : 0] out_inmediato;
wire [NB_addr - 1 : 0] out_rt;
wire [NB_addr - 1 : 0] out_rd;

ID#(.NB_addr(NB_addr), .NB_data(NB_data))
u_ID(
    .in_instruction(in_instruction), .in_branch(in_branch), .in_reg_write(in_reg_write), .in_wdata(in_wdata),
    .in_rd(in_rd), .clk(clk), .reset(reset), .out_branch(out_branch), .out_ex(out_ex), .out_mem(out_mem),
    .out_wb(out_wb), .out_reg1(out_reg1), .out_reg2(out_reg2), .out_inmediato(out_inmediato),
    .out_rt(out_rt), .out_rd(out_rd)
    );

initial begin
    clk = 1'b0;
    reset = 1'b1;
    in_reg_write = 1'b1;
    in_wdata = 32'h0044;
    in_rd = 5'b00001;
    in_branch = 32'hffff0000;
     
    #5 reset = 1'b0;
    
    #7 in_instruction = `NB_data'h8C200000;

end
 always #2 clk = ~clk;
endmodule