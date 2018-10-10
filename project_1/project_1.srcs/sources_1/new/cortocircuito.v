`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2017 11:50:36 PM
// Design Name: 
// Module Name: interface_circuit
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

module cortocircuito(
    in_reg_w_34,
    in_reg_w_45,
    in_rd_34,
    in_rs_23,
    in_rd_45,
    in_rt_23,
    out_mux_a,
    out_mux_b
);

parameter NB_addr = `NB_addr;

input in_reg_w_34;
input in_reg_w_45;
input [NB_addr - 1 : 0] in_rd_34;
input [NB_addr - 1 : 0] in_rs_23;
input [NB_addr - 1 : 0] in_rd_45;
input [NB_addr - 1 : 0] in_rt_23;
output [1 : 0] out_mux_a;
output [1 : 0] out_mux_b;

//assign out_mux_a = 2'b00;
//assign out_mux_b = 2'b00;

assign out_mux_a = ( in_reg_w_45 == 1'b1 & in_rd_45 == in_rs_23 & ( in_reg_w_34 == 1'b0 | in_rd_34 != in_rs_23) ) ? 2'b10 :
                   (in_reg_w_34 == 1'b1 & in_rd_34 == in_rs_23) ? 2'b01 : 2'b00;

assign out_mux_b = ( in_reg_w_45 == 1'b1 & in_rd_45 == in_rt_23 & ( in_reg_w_34 == 1'b0 | in_rd_34 != in_rt_23) ) ? 2'b10 :
                   (in_reg_w_34 == 1'b1 & in_rd_34 == in_rt_23) ? 2'b01 : 2'b00;

endmodule

                   