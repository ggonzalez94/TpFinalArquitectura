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

module ID(
    in_instruction,
    in_branch,
    in_reg_write,
    in_wdata,
    in_rd,
    clk,
    reset,
    out_branch,
    out_ex,
    out_mem,
    out_wb,
    out_reg1,
    out_reg2,
    out_inmediato,
    out_shamt,
    out_jump_dir,
    out_rt,
    out_rs,
    out_rd,
    out_stall
);

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

input [NB_data - 1 : 0] in_instruction;
input [NB_data - 1 : 0] in_branch;
input [NB_data - 1 : 0] in_wdata;
input [NB_addr - 1 : 0] in_rd;
input in_reg_write;
input clk;
input reset;

output reg [NB_data - 1 : 0] out_branch;
output reg [8 - 1 : 0] out_ex;
output reg [9 - 1 : 0] out_mem;
output reg [2 - 1 : 0] out_wb;
output [NB_data - 1 : 0] out_reg1;
output [NB_data - 1 : 0] out_reg2;
output reg [NB_addr - 1 : 0] out_shamt;
output reg [NB_data - 1 : 0] out_inmediato;
output reg [25 : 0] out_jump_dir;
output reg [NB_addr - 1 : 0] out_rt;
output reg [NB_addr - 1 : 0] out_rd;
output reg [NB_addr - 1 : 0] out_rs;
output out_stall;

wire [1 : 0] connect_wb;
wire [9 - 1 : 0] connect_mem;
wire [8 - 1 : 0] connect_ex;

wire [NB_data - 1 : 0] connect_out_reg1;
wire [NB_data - 1 : 0] connect_out_reg2;

wire connect_out_stall ;
wire connect_mem_read;
wire [19 - 1 : 0] control_out;

control_id
u_control_id(.in_opcode(in_instruction[31:26]), .in_function(in_instruction[5:0]), .out_ex(connect_ex), 
                            .out_mem(connect_mem), .out_wb(connect_wb));

register_id #(.NB_data(NB_data), .NB_addr(NB_addr), .N_regs(32))
u_register_id(.in_rs(in_instruction[25:21]), .in_rd(in_rd), .in_rt(in_instruction[20:16]),
                 .in_wdata(in_wdata), .in_reg_write(in_reg_write), .out_data1(out_reg1),.out_data2(out_reg2),
                 .clk(clk), .reset(reset));

hazard_detection #(.NB_addr(NB_addr))
u_hazard_detection(
   .in_rt_23(out_rt),
   .in_rt_12(in_instruction[20:16]),
   .in_rs_12(in_instruction[25:21]),
   .in_mem_read_23(connect_mem_read),
   .out_stall(connect_out_stall)
);

assign control_out = ( connect_out_stall == 1'b0 ) ? {connect_ex, connect_mem, connect_wb} : 18'h000;
assign out_stall = connect_out_stall;
assign connect_mem_read = out_mem[1];

always@(posedge clk) begin
        out_branch <= in_branch;
        out_inmediato <= $signed(in_instruction[15:0]);
        out_rd <= in_instruction[15:11];
        out_rt <= in_instruction[20:16];
        out_rs <= in_instruction[25:21];
        out_shamt <= in_instruction[10:6];
        out_ex <= control_out[18:11];
        out_mem <= control_out[10:2];
        out_wb <= control_out[1:0];
        out_jump_dir <= in_instruction[25:0];
        
end

endmodule