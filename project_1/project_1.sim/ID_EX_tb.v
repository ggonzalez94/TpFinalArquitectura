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

module ID_EX_tb( );

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;


/*Input ID*/
reg clk;
reg reset;

reg [NB_data - 1 : 0] in_wdata;
reg [NB_addr - 1 : 0] in_rd;
reg in_reg_write;


wire [3 - 1 : 0] out_mem_ex;
wire [2 - 1 : 0] out_wb_ex;

wire [NB_data - 1 : 0] out_branch_ex;

wire [NB_data - 1 : 0] connect_pc_branch_addr;

wire [NB_data - 1 :0] connect_pc_jump_reg;


wire connect_ctl_branch;
assign connect_ctl_branch = 1'b0; //------------>Solo para testear

wire [NB_data - 1 : 0] connect_instruction_if_id;
wire [NB_data - 1 : 0] connect_pc_if_id;

wire [NB_data - 1 : 0] connect_reg_1;
wire [NB_data - 1 : 0] connect_reg_2;

wire [NB_data - 1 : 0] connect_inmediato;
wire [NB_addr - 1 : 0] connect_shamt;

wire [NB_addr -1 : 0] connect_rd;
wire [NB_addr -1 : 0] connect_rt;

wire [2 - 1 : 0] connect_wb;
wire [3 - 1 : 0] connect_mem;

wire [8 - 1 : 0] connect_ex;

wire [25 : 0] connect_branch_dir;

//----------estas señales no se usan en EX pero es un viaaaaje sacarlas
wire [NB_data - 1 : 0] connect_jump_addr;
wire connect_ctl_jump;

assign connect_ctl_jump = connect_ex[1];

wire connect_ctl_jump_reg;
assign connect_ctl_jump_reg = connect_ex[0];
//--------------------------------------

assign connect_pc_jump_reg = connect_reg_2;



IF
u_IF (.instruction_out(connect_instruction_if_id),.adder_out(connect_pc_if_id),
        .in_pc_jump_addr(connect_jump_addr),.in_pc_branch_addr(connect_pc_branch_addr),
        .in_pc_jump_reg(connect_pc_jump_reg),.in_ctl_jump(connect_ctl_jump),
        .in_ctl_jump_reg(connect_ctl_jump_reg), .in_ctl_branch(connect_ctl_branch), 
        .reset(reset), .clk(clk));

ID#(.NB_addr(NB_addr), .NB_data(NB_data))
u_ID(
    .in_instruction(connect_instruction_if_id), .in_branch(connect_pc_if_id), .in_reg_write(in_reg_write), .in_wdata(in_wdata),
    .in_rd(connect_rd), .clk(clk), .reset(reset), .out_jump_dir(connect_jump_addr), .out_branch(connect_branch_dir), 
    .out_ex(connect_ex), .out_mem(connect_mem), .out_wb(connect_wb), .out_reg1(connect_reg_1),
     .out_reg2(connect_reg_2), .out_shamt(connect_shamt),
    .out_inmediato(connect_inmediato), .out_rt(connect_rt), .out_rd(connect_rd)
    );

EX
u_EX(
    .clk(clk),
    .reset(reset),
    .in_branch(connect_branch_dir),
    .in_ex(connect_ex),
    .in_mem(connect_mem),
    .in_wb(connect_wb),
    .in_reg1(connect_reg_1),
    .in_reg2(connect_reg_2),
    .in_inmediato(connect_inmediato),
    .in_shamt(connect_shamt),
    .in_rt(connect_rt),
    .in_rd(connect_rd),
   	.in_jump_reg(connect_jump_addr),
    .out_branch(connect_pc_branch_addr),
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
    in_reg_write = 1'b0;
    in_wdata = 32'h0044;
    in_rd = 5'b00001;
    // in_branch = 32'hffff0000;
     
    #5 reset = 1'b0;
    // #10 in_instruction = `NB_data'h3C000001; //
    //#10 in_instruction = `NB_data'h20200001; // 

end
 always #2 clk = ~clk;
endmodule
