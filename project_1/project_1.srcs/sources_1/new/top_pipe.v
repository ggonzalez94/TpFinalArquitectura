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

module top_pipe(
    clk,
    reset,
    out_pc,
    out_halt
);

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

input clk;
input reset;

output [NB_data - 1 : 0] out_pc;
output out_halt;


wire connect_ctl_branch;

wire [NB_data - 1 : 0] connect_instruction_if_id;
wire [NB_data - 1 : 0] connect_pc_if_id;

wire [NB_data - 1 : 0] connect_reg_1;
wire [NB_data - 1 : 0] connect_reg_2;

wire [NB_data - 1 : 0] connect_inmediato;
wire [NB_addr - 1 : 0] connect_shamt;
wire [NB_data - 1 : 0] connect_pc_branch_addr;
wire [NB_data - 1 : 0] connect_pc_jump_reg;

wire [NB_addr -1 : 0] connect_rd;
wire [NB_addr -1 : 0] connect_rt;

wire [2 - 1 : 0] connect_wb;
wire [2 - 1 : 0] connect_wb_ex;
wire [2 - 1 : 0] connect_wb_ex_mem;
wire [9 - 1 : 0] connect_mem;
wire [9 - 1 : 0] connect_mem_ex;

wire [10 - 1 : 0] connect_ex;

wire [NB_data - 1 : 0] connect_branch_dir;

//----------estas señales no se usan en EX pero es un viaaaaje sacarlas
wire [25 : 0] connect_jump_addr;
wire connect_ctl_jump;

assign connect_ctl_jump = connect_ex[1];

wire connect_ctl_jump_reg;
assign connect_ctl_jump_reg = connect_ex[0];


//--------------------------------------

assign connect_pc_jump_reg = connect_reg_1;

wire [NB_data - 1 : 0] connect_alu_out;
wire [NB_data - 1 : 0] connect_wdata;
wire [NB_data - 1 : 0] connect_wdata_reg;
wire connect_alu_zero;
wire [NB_addr - 1 : 0] connect_reg_dst;

wire [NB_data - 1 : 0] connect_rd_mem;
wire [NB_data - 1 : 0] connect_addrin_mem;
wire [NB_addr - 1 : 0] connect_reg_dst_ex_mem;
wire connect_reg_write;
wire [NB_addr - 1 : 0] connect_rd_id_mem;

wire [NB_addr - 1 : 0] connect_rs;
wire connect_ctl_stall;
wire out_sign;
wire connect_flush;
assign connect_flush = connect_ctl_branch;

assign out_pc = connect_pc_if_id;
assign out_halt = & connect_instruction_if_id;


IF#(.NB(NB_data))
u_IF (.instruction_out(connect_instruction_if_id),.adder_out(connect_pc_if_id),
        .in_pc_jump_addr(connect_jump_addr),.in_pc_branch_addr(connect_pc_branch_addr),
        .in_pc_jump_reg(connect_pc_jump_reg),.in_ctl_jump(connect_ctl_jump), .in_flush(connect_flush),
        .in_ctl_jump_reg(connect_ctl_jump_reg), .in_ctl_branch(connect_ctl_branch),
        .in_ctl_stall(connect_ctl_stall),
        .reset(reset), .clk(clk));

ID#(.NB_addr(NB_addr), .NB_data(NB_data))
u_ID(
    .in_instruction(connect_instruction_if_id), .in_branch(connect_pc_if_id), .in_reg_write(connect_reg_write), 
    .in_wdata(connect_wdata_reg), .in_flush(connect_flush),
    .in_rd(connect_rd_id_mem), .clk(clk), .reset(reset), .out_jump_dir(connect_jump_addr), .out_branch(connect_branch_dir), 
    .out_ex(connect_ex), .out_mem(connect_mem), .out_wb(connect_wb), .out_reg1(connect_reg_1),
    .out_reg2(connect_reg_2), .out_shamt(connect_shamt), .out_rs(connect_rs),
    .out_inmediato(connect_inmediato), .out_rt(connect_rt), .out_rd(connect_rd), .out_stall(connect_ctl_stall)
    );

EX#(.NB_addr(NB_addr), .NB_data(NB_data))
u_EX( .clk(clk), .reset(reset), .in_branch(connect_branch_dir), .in_ex(connect_ex[10 - 1 : 2]), .in_mem(connect_mem), 
      .in_wb(connect_wb), .in_reg1(connect_reg_1), .in_reg2(connect_reg_2), .in_inmediato(connect_inmediato), 
      .in_shamt(connect_shamt), .in_rt(connect_rt), .in_rd(connect_rd), 
      .in_c_reg_w_34(connect_wb_ex[1]), .in_flush(connect_flush),
      .in_c_reg_w_45(connect_wb_ex_mem[1]),
      .in_c_rd_34(connect_reg_dst),
      .in_c_rd_45(connect_reg_dst_ex_mem),
      .in_c_wb_data(connect_wdata_reg),
      .in_c_mem_data(connect_alu_out),
      .in_rs(connect_rs),
      .out_branch(connect_pc_branch_addr),
      .out_alu(connect_alu_out), .out_reg_dest(connect_reg_dst), .out_w_data(connect_wdata), .out_zero(connect_alu_zero), 
      .out_sign(out_sign), .out_mem(connect_mem_ex), .out_wb(connect_wb_ex)
    );

MEM#(.NB_addr(NB_addr), .NB_data(NB_data))
u_MEM(.clk(clk), .reset(reset), .in_address(connect_alu_out), .in_wdata(connect_wdata), 
      .in_mem_ctl(connect_mem_ex), .in_alu_zero(connect_alu_zero), .in_reg_dst(connect_reg_dst), 
      .in_wb(connect_wb_ex), .out_wb(connect_wb_ex_mem), .out_rdata(connect_rd_mem), .out_addr_in(connect_addrin_mem), 
      .out_reg_dst(connect_reg_dst_ex_mem), .out_ctl_branch(connect_ctl_branch)
    );

WB#(.NB_addr(NB_addr), .NB_data(NB_data))
u_WB( .reset(reset), .in_ctl_wb(connect_wb_ex_mem), .in_rd_data(connect_rd_mem), .in_addr_mem(connect_addrin_mem), 
      .in_reg_dst(connect_reg_dst_ex_mem), .out_ctl_wreg(connect_reg_write), .out_reg_addr(connect_rd_id_mem), 
      .out_reg_wdata(connect_wdata_reg)
    );
    

endmodule


