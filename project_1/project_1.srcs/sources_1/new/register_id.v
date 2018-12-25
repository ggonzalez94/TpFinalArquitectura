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

`define N_regs 32

module register_id(
    in_rs,
    in_rd,
    in_rt,
    in_wdata,
    in_reg_write,
    in_addr_wire,
    out_data1,
    out_data2,
    out_wire_reg,
    out_jump_reg,
    clk,
    reset
    );

parameter NB_addr = 5;
parameter NB_data = 32;
parameter N_regs = `N_regs;


input [NB_addr - 1 : 0] in_rs;
input [NB_addr - 1 : 0] in_rd;
input [NB_addr - 1 : 0] in_rt;
input [NB_data - 1 : 0] in_wdata;
input [NB_addr - 1 : 0] in_addr_wire;

//Enable de escritura de registros
input in_reg_write;
input clk;
input reset;

output reg [NB_data - 1 : 0] out_data1;
output reg [NB_data - 1 : 0] out_data2;
output [NB_data - 1 : 0] out_wire_reg;
output [NB_data - 1 : 0] out_jump_reg;

reg [NB_data - 1 : 0] registros [N_regs - 1 : 0];

assign out_wire_reg = registros[in_addr_wire];
assign out_jump_reg = registros[in_rs];

generate
    integer ram_index;
    initial
    for (ram_index = 0; ram_index < N_regs; ram_index = ram_index + 1) 
        registros[ram_index] = ram_index ;
endgenerate

always @(negedge clk) begin
    if (reset == 1'b1)begin
      registros[in_rd] <= registros[in_rd];
    end
    else begin
        if (in_reg_write == 1'b1) begin
            registros[in_rd] <= in_wdata;
        end
        else begin
            registros[in_rd] <= registros[in_rd];
        end
    end    
end

always@(posedge clk) begin
    if (reset == 1'b1)begin
        out_data1 <=  {NB_data{1'b0}};
        out_data2 <=  {NB_data{1'b0}};
    end
    else begin
        out_data1 <= registros[in_rs];
        out_data2 <= registros[in_rt];
    end
end

endmodule


    