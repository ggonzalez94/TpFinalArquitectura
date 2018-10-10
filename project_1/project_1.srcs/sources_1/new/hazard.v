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

module hazard_detection(
   in_rt_23,
   in_rt_12,
   in_rs_12,
   in_mem_read_23,
   out_stall
);

parameter NB_addr = `NB_addr;

input [NB_addr - 1 : 0] in_rt_23;
input [NB_addr - 1 : 0] in_rt_12;
input [NB_addr - 1 : 0] in_rs_12;
input in_mem_read_23;
output out_stall;
// output out_pc_write;
// output out_if_write;
// output out_mux_ctl;

// wire stall;

assign out_stall = ( (in_rt_23 == in_rs_12) | (in_rt_23 == in_rt_12) ) & (in_mem_read_23 == 1'b1);

// assign out_if_write ~= stall;
// assign out_pc_write ~= stall;
// assign out_mux_ctl  ~= stall;

endmodule