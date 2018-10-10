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
`define N_regs 32

module EX(
    clk,
    reset,
    in_branch,
    in_ex,
    in_mem,
    in_wb,
    in_reg1,
    in_reg2,
    in_inmediato,
    in_shamt,
    in_rt,
    in_rd,
    in_c_reg_w_34,
    in_c_reg_w_45,
    in_c_rd_34,
    in_c_rd_45,
    in_c_wb_data,
    in_c_mem_data,
    in_rs,
    out_branch,
    out_alu,
    out_reg_dest,
    out_w_data,
    out_zero,
    out_sign,
    out_mem,
    out_wb
);

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

input clk;
input reset;
input [NB_data - 1 : 0] in_branch;
input [8 - 1 : 2] in_ex;
input [9 - 1 : 0] in_mem;
input [2 - 1 : 0] in_wb;
input [NB_data - 1 : 0] in_reg1;
input [NB_data - 1 : 0] in_reg2;
input [NB_data - 1 : 0] in_inmediato;
input [NB_addr - 1 : 0] in_shamt;
input [NB_addr - 1 : 0] in_rt;
input [NB_addr - 1 : 0] in_rd;
input [NB_addr - 1 : 0] in_rs;

input in_c_reg_w_34;
input in_c_reg_w_45;
input [NB_addr - 1 : 0] in_c_rd_34;
input [NB_addr - 1 : 0] in_c_rd_45;
input [NB_data - 1 : 0] in_c_wb_data;
input [NB_data - 1 : 0] in_c_mem_data;

output reg [NB_data - 1 : 0] out_branch;
output reg [NB_data - 1 : 0] out_alu;
output reg [NB_addr - 1 : 0] out_reg_dest;
output reg [NB_data - 1 : 0] out_w_data;
output reg out_zero;
output reg out_sign;
output reg [9 - 1 : 0] out_mem;
output reg [2 - 1 : 0] out_wb;

wire [NB_data - 1 : 0] in_alu_a;
wire [NB_data - 1 : 0] in_alu_b;
wire [NB_data - 1 : 0] connect_alu_out;
wire connect_zero;
wire connect_signo;
wire [3 : 0] connect_alu_code;
wire [NB_data - 1 : 0] connect_reg_dest;


wire [1 : 0] connect_c_mux_a;
wire [1 : 0] connect_c_mux_b;

wire [NB_data - 1 : 0] connect_mux_ac;
wire [NB_data - 1 : 0] connect_mux_bc;

//assign connect_c_mux_a

assign connect_mux_ac = (connect_c_mux_a == 2'b00) ? in_reg1 : 
                        (connect_c_mux_a == 2'b01) ? in_c_mem_data : in_c_wb_data;

assign connect_mux_bc = (connect_c_mux_b == 2'b00) ? in_reg2 : 
                        (connect_c_mux_b == 2'b01) ? in_c_mem_data : in_c_wb_data;

assign in_alu_a = (in_ex[2] == 1'b0) ? connect_mux_ac : {{(NB_data-5){1'b0}},in_shamt};
assign in_alu_b = (in_ex[3] == 1'b0) ? connect_mux_bc : in_inmediato;

assign connect_reg_dest = (in_ex[7] == 1'b0) ? in_rt : in_rd;

alu
u_alu(.A(in_alu_a), .B(in_alu_b), .alu_code(connect_alu_code), .x(connect_alu_out), 
        .flag_zero(connect_zero), .signo(connect_signo));

alu_control
u_alu_control(.in_alu_op(in_ex[6 : 4]), .in_function(in_inmediato[5:0]),
                 .out_alu_code(connect_alu_code));

cortocircuito
u_cortocircuito( .in_reg_w_34(in_c_reg_w_34), .in_reg_w_45(in_c_reg_w_45), .in_rd_34(in_c_rd_34),
                 .in_rs_23(in_rs), .in_rd_45(in_c_rd_45), .in_rt_23(in_rt), 
                 .out_mux_a(connect_c_mux_a), .out_mux_b(connect_c_mux_b));




always @(posedge clk) begin
  if (reset) begin
    out_mem <= 3'b000;
    out_wb <= 3'b00;
    out_branch <= {NB_data{1'b0}};
    out_alu <= {NB_data{1'b0}};
    out_reg_dest <= {NB_data{1'b0}};
    out_w_data <= {NB_data{1'b0}};
  end else begin
    out_mem <= in_mem;
    out_wb <= in_wb;
    out_branch <= in_branch + in_inmediato;
    out_alu <= connect_alu_out;
    out_zero <= connect_zero;
    out_sign <= connect_signo;
    out_w_data <= in_reg2;
    out_reg_dest <= connect_reg_dest;
  end

end

endmodule