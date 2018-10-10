`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2017 05:55:33 PM
// Design Name: 
// Module Name: EX_tb
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

module EX_tb( );

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;


reg clk;
reg reset;
reg [NB_data - 1 : 0] in_branch;
reg [8 - 1 : 0] in_ex;
reg [3 - 1 : 0] in_mem;
reg [2 - 1 : 0] in_wb;
reg [NB_data - 1 : 0] in_reg1;
reg [NB_data - 1 : 0] in_reg2;
reg [NB_data - 1 : 0] in_inmediato;
reg [25 : 0] in_jump_reg;
reg [NB_addr - 1 : 0] in_shamt;
reg [NB_addr - 1 : 0] in_rt;
reg [NB_addr - 1 : 0] in_rd;

wire [25 : 0] out_jump_reg;
wire [NB_data - 1 : 0] out_branch;
wire [NB_data - 1 : 0] out_alu;
wire [NB_addr - 1 : 0] out_reg_dest;
wire [NB_data - 1 : 0] out_w_data;
wire out_zero;
wire out_sign;
wire [3 - 1 : 0] out_mem;
wire [2 - 1 : 0] out_wb;

EX
u_EX(
    .clk(clk),
    .reset(reset),
    .in_branch(in_branch),
    .in_ex(in_ex),
    .in_mem(in_mem),
    .in_wb(in_wb),
    .in_reg1(in_reg1),
    .in_reg2(in_reg2),
    .in_inmediato(in_inmediato),
    .in_shamt(in_shamt),
    .in_rt(in_rt),
    .in_rd(in_rd),
   	.in_jump_reg(in_jump_reg),
    .out_branch(out_branch),
    .out_alu(out_alu),
    .out_reg_dest(out_reg_dest),
    .out_w_data(out_w_data),
    .out_zero(out_zero),
    .out_sign(out_sign),
    .out_mem(out_mem),
    .out_wb(out_wb),
);

initial begin
    clk = 1'b0;
    reset = 1'b1;
    in_branch = `NB_data'h0025;
    //in_ex = 8'b10000000; // ANDA
    //in_ex = 8'b10000100; // ANDA
    in_ex = 8'b01111000;
    in_reg1 = `NB_data'h01;
    in_reg2 = `NB_data'h03;

    in_inmediato = `NB_data'h02;
    in_shamt = `NB_addr'b00001;

    in_mem = 3'b001;
    in_wb = 2'b01;
    in_jump_reg = 25'h02;
    
    in_rt = `NB_addr'b00001;
    in_rd = `NB_addr'b00010;
    
    #5 reset = 1'b0;

    //#10	in_ex = 7'b1000100;

end
 always #2 clk = ~clk;
endmodule
