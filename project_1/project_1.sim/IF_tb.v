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
`define NB 32

module IF_tb( );

parameter NB = `NB;

reg [NB - 1 : 0] in_pc_jump_addr;
reg [NB - 1 : 0] in_pc_branch_addr;
reg [NB - 1 : 0] in_pc_jump_reg;
reg in_ctl_jump;
reg in_ctl_jump_reg;
reg in_ctl_branch;
reg clk;
reg reset;

wire [NB - 1 : 0] instruction_out;
wire [NB - 1 : 0] adder_out;



IF
u_IF (.instruction_out(instruction_out),.adder_out(adder_out),.in_pc_jump_addr(in_pc_jump_addr),.in_pc_branch_addr(in_pc_branch_addr),.in_pc_jump_reg(in_pc_jump_reg),.in_ctl_jump(in_ctl_jump), 
      .in_ctl_jump_reg(in_ctl_jump_reg), .in_ctl_branch(in_ctl_branch), .reset(reset), .clk(clk));


initial begin
    in_ctl_jump = 1'b0;
    in_ctl_jump_reg = 1'b0;
    in_ctl_branch = 1'b0;
    
    in_pc_jump_addr = 32'h0000;
    in_pc_branch_addr = 32'h0000;
    in_pc_jump_reg = 32'h0000;

    clk = 1'b0;
    reset = 1'b1;

    #5 reset = 1'b0;
    
    #10 in_ctl_jump = 1'b1;

end
 always #2 clk = ~clk;
endmodule
