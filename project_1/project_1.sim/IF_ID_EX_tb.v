`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2017 05:55:33 PM
// Design Name: 
// Module Name: ID_EX_tb
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

module IF_ID_EX_tb( );

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;
parameter NB = `NB;

reg clk;
reg reset;

/*Input IF*/
reg [NB - 1 : 0] in_pc_jump_addr;
reg [NB - 1 : 0] in_pc_branch_addr;
reg [NB - 1 : 0] in_pc_jump_reg;
reg in_ctl_jump;
reg in_ctl_jump_reg;
reg in_ctl_branch;

/*Input ID*/
wire [NB - 1 : 0] instruction_out;
wire [NB - 1 : 0] adder_out;

reg [NB_data - 1 : 0] in_instruction;
wire [NB_data - 1 : 0] in_branch;
wire [NB_data - 1 : 0] in_wdata;
wire [NB_addr - 1 : 0] in_rd;
wire in_reg_write;

/*Input EX*/
wire [NB_data - 1 : 0] out_branch;
wire [8 - 1 : 0] out_ex;
wire [3 - 1 : 0] out_mem;
wire [2 - 1 : 0] out_wb;
wire [NB_data - 1 : 0] out_reg1;
wire [NB_data - 1 : 0] out_reg2;
wire [NB_data - 1 : 0] out_inmediato;

wire [25 : 0] in_jump_reg;
wire [NB_addr - 1 : 0] in_shamt;

//assign in_jump_reg = in_instruction[25 : 0];
//assign in_shamt = in_instruction[25 : 0];

wire [NB_addr - 1 : 0] out_rt;
wire [NB_addr - 1 : 0] out_rd;

/*Output EX*/
reg [25 : 0] out_jump_reg;
wire [NB_data - 1 : 0] out_alu;
wire [NB_addr - 1 : 0] out_reg_dest;
wire [NB_data - 1 : 0] out_w_data;
wire out_zero;
wire out_sign;
wire [3 - 1 : 0] out_mem_ex;
wire [2 - 1 : 0] out_wb_ex;
wire [NB_data - 1 : 0] out_branch_ex;

IF#(.NB(NB))
u_IF (.instruction_out(instruction_out),.adder_out(adder_out),.in_pc_jump_addr(in_pc_jump_addr),.in_pc_branch_addr(in_pc_branch_addr),.in_pc_jump_reg(in_pc_jump_reg),.in_ctl_jump(in_ctl_jump), 
      .in_ctl_jump_reg(in_ctl_jump_reg), .in_ctl_branch(in_ctl_branch), .reset(reset), .clk(clk));

ID#(.NB_addr(NB_addr), .NB_data(NB_data))
u_ID(
    .in_instruction(instruction_out), .in_branch(adder_out), .in_reg_write(in_reg_write), .in_wdata(in_wdata),
    .in_rd(in_rd), .clk(clk), .reset(reset), .out_branch(out_branch), .out_ex(out_ex), .out_mem(out_mem),
    .out_wb(out_wb), .out_reg1(out_reg1), .out_reg2(out_reg2), .out_inmediato(out_inmediato),
    .out_rt(out_rt), .out_rd(out_rd)
    );

EX
u_EX(
    .clk(clk),
    .reset(reset),
    .in_branch(in_branch),
    .in_ex(out_ex),
    .in_mem(out_mem),
    .in_wb(out_wb),
    .in_reg1(out_reg1),
    .in_reg2(out_reg2),
    .in_inmediato(out_inmediato),
    .in_shamt(in_shamt),
    .in_rt(out_rt),
    .in_rd(out_rd),
   	.in_jump_reg(in_jump_reg),
    .out_branch(out_branch_ex),
    .out_alu(out_alu),
    .out_reg_dest(out_reg_dest),
    .out_w_data(out_w_data),
    .out_zero(out_zero),
    .out_sign(out_sign),
    .out_mem(out_mem_ex),
    .out_wb(out_wb_ex),
    .out_jump_reg(out_jump_reg)
);




initial begin
    clk = 1'b0;
    reset = 1'b1;

    in_ctl_jump = 1'b0;
    in_ctl_jump_reg = 1'b0;
    in_ctl_branch = 1'b0;
    in_pc_jump_addr = 32'h0000;
    in_pc_branch_addr = 32'h0000;
    in_pc_jump_reg = 32'h0000;


    #5 reset = 1'b0;
    
    #10 in_ctl_jump = 1'b1;
     
    #5 reset = 1'b0;
    #10 in_instruction = `NB_data'h3C000001; //
    //#10 in_instruction = `NB_data'h20200001; // 

end
 always #2 clk = ~clk;
endmodule
