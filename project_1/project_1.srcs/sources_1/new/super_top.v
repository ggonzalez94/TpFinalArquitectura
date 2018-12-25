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
`define NB_UART 8

module super_top(
                clk,
                reset,
                UART_TXD_IN, 
                UART_RXD_OUT
);

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;
parameter NB_UART = `NB_UART;


input clk;
input reset;
input UART_TXD_IN;

output UART_RXD_OUT;

wire connect_clk_mips;
wire connect_reset_mips;
wire connect_clk_enb;
wire connect_clk_uart;
wire connect_reset_uart; //Ver como se usa
wire [NB_UART - 1 : 0] connect_uart_rx_data;
wire [NB_UART - 1 : 0] connect_uart_tx_data;
wire connect_halt;

wire [NB_data - 1 : 0] connect_pc;

assign connect_clk_mips = (connect_clk_enb) ? connect_clk_mips : 1'b1;


top_pipe
u_top_pipe(.clk(connect_clk_mips), .reset(connect_reset_mips), .out_pc(connect_pc), .out_halt(connect_halt));


estados
u_estados( 
        .clk(clk), .reset(reset), .in_rx_reg(connect_uart_rx_data), .in_halt(connect_halt), .in_pc(connect_pc),
        .latch12(), .latch23(), .latch34(), .out_tx_reg(connect_uart_tx_data), .out_data(),
        .out_addr(), .out_clk_enb(connect_clk_enb), .out_reset(connect_reset_mips));

//--------------------------------UART--------------------------------------------
//brg
//u_brg(.clk_in(clk),.clk_out(connect_clk_uart));

//rx
//u_rx(.clk(connect_clk_uart),.i_rx(UART_TXD_IN),.d_out(connect_uart_rx_data),
//        .rx_done(),.reset(connect_reset_uart));

//tx
//u_tx(.clk(connect_clk_uart),.d_in(connect_uart_tx_data),.tx_done(),
//        .tx_start(),.tx(UART_RXD_OUT),.reset(connect_reset_uart));

//---------------------------------------------------------------------------------
endmodule