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
    in_flush,
    in_instruction,
    in_branch,
    in_reg_write,
    in_wdata,
    in_rd,
    in_addr_wire,
    clk,
    reset,
    in_halt,
    out_halt,
    out_branch,
    out_wire_reg,
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
    out_stall,
    out_jump_reg,
    out_jump_ctl
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
input in_flush;
input [NB_addr - 1 : 0] in_addr_wire;
input in_halt;

output reg out_halt;
output reg [10 - 1 : 0] out_ex;
output reg [9 - 1 : 0] out_mem;
output reg [2 - 1 : 0] out_wb;

output [NB_data - 1 : 0] out_reg1;
output [NB_data - 1 : 0] out_reg2;

output reg [NB_addr - 1 : 0] out_shamt;
output reg [NB_data - 1 : 0] out_inmediato;

output reg [NB_data - 1 : 0] out_branch;
output [25 : 0] out_jump_dir;

output reg [NB_addr - 1 : 0] out_rt;
output reg [NB_addr - 1 : 0] out_rd;
output reg [NB_addr - 1 : 0] out_rs;

output out_stall;
output [NB_data - 1 : 0] out_wire_reg;
output [NB_data - 1 : 0] out_jump_reg;
output [1:0] out_jump_ctl;

wire [1 : 0] connect_wb;
wire [9 - 1 : 0] connect_mem;
wire [10 - 1 : 0] connect_ex;

wire [NB_data - 1 : 0] connect_out_reg1;
wire [NB_data - 1 : 0] connect_out_reg2;

wire connect_out_stall ;
wire connect_mem_read;
wire [21 - 1 : 0] control_out;

control_id
u_control_id(.in_opcode(in_instruction[31:26]), .in_function(in_instruction[5:0]), .out_ex(connect_ex), 
                            .out_mem(connect_mem), .out_wb(connect_wb));

register_id #(.NB_data(NB_data), .NB_addr(NB_addr), .N_regs(32))
u_register_id(.in_rs(in_instruction[25:21]), .in_rd(in_rd), .in_rt(in_instruction[20:16]),
                 .in_addr_wire(in_addr_wire),
                 .in_wdata(in_wdata), .in_reg_write(in_reg_write), .out_data1(connect_out_reg1),.out_data2(connect_out_reg2),
                 .out_wire_reg(out_wire_reg), 
                 .out_jump_reg(out_jump_reg),
                 .clk(clk), .reset(reset));

hazard_detection #(.NB_addr(NB_addr))
u_hazard_detection(
   .in_rt_23(out_rt),
   .in_rt_12(in_instruction[20:16]),
   .in_rs_12(in_instruction[25:21]),
   .in_mem_read_23(connect_mem_read),
   .out_stall(connect_out_stall)
);

assign control_out = ( connect_out_stall == 1'b1 || in_flush == 1'b1) ?  20'h000 : {connect_ex, connect_mem, connect_wb};
assign out_stall = (in_flush == 1'b0) ? connect_out_stall : 1'b0;
assign out_reg1 = (in_flush == 1'b0) ? connect_out_reg1 : 32'h00000000;
assign out_reg2 = (in_flush == 1'b0) ? connect_out_reg2 : 32'h00000000;
assign connect_mem_read = out_mem[1];
assign out_jump_dir =  in_instruction[25:0];
assign out_jump_ctl =  control_out[12:11];



always@(posedge clk or posedge reset) begin    
    if (reset ) begin
        out_branch <= 32'h00000000;
        out_inmediato <= 32'h00000000;
        out_rd <= 32'h00000000;
        out_rt <= 32'h00000000;
        out_rs <= 32'h00000000;
        out_shamt <= 32'h00000000;
        out_ex <= 32'h00000000;
        out_mem <= 32'h00000000;
        out_halt <= 1'b0;
        out_wb <= 32'h00000000;
    end 

    else if ( in_flush ) begin
        out_branch <= 32'h00000000;
        out_inmediato <= 32'h00000000;
        out_rd <= 32'h00000000;
        out_rt <= 32'h00000000;
        out_rs <= 32'h00000000;
        out_shamt <= 32'h00000000;
        out_ex <= 32'h00000000;
        out_mem <= 32'h00000000;
        out_halt <= 1'b0;
        out_wb <= 32'h00000000;
        // out_jump_dir <= 32'h00000000;
    end 

    else begin
        out_halt <= in_halt;
        out_branch <= in_branch;
        out_inmediato <= $signed(in_instruction[15:0]);
        out_rd <= in_instruction[15:11];
        out_rt <= in_instruction[20:16];
        out_rs <= in_instruction[25:21];
        out_shamt <= in_instruction[10:6];
        out_ex <= control_out[20:11];
        out_mem <= control_out[10:2];
        out_wb <= control_out[1:0];
    end
end
endmodule