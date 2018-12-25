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
`define NB_mem 11

module super_top(
                CLK100MHZ,
                reset,
                UART_TXD_IN, 
                UART_RXD_OUT,
                led,
                led0_r,
                led1_r
);

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;
parameter NB_UART = `NB_UART;
parameter NB_mem = `NB_mem;

parameter NB_latch12 = 64;
parameter NB_latch23 = 218;
parameter NB_latch34 = 113;
parameter NB_latch45 = 71;


input CLK100MHZ;
input reset;
input UART_TXD_IN;
output [3 : 0]led;
output led0_r;
output led1_r;

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
wire connect_tx_start;
wire connect_tx_done;
wire connect_rx_done;
wire [NB_data - 1 : 0] connect_reg_data;
wire [NB_data - 1 : 0] connect_wire_dmem;
wire [NB_mem - 1 : 0] connect_addr_wire;

wire [NB_data - 1 : 0] connect_instruction;
wire [NB_mem - 1 : 0] connect_addr_prog;

wire [NB_latch12 - 1 : 0] connect_l12;
wire [NB_latch23 - 1 : 0] connect_l23;
wire [NB_latch34 - 1 : 0] connect_l34;
wire [NB_latch45 - 1 : 0] connect_l45;
wire connect_wea_prog;
wire [3:1]connect_estado;
wire clk;

wire conect_ok;
// assign connect_clk_mips = clk;
assign connect_clk_mips = (connect_clk_enb) ? clk : 1'b1;

assign led[0] = reset;
assign led[3:1]= connect_estado;
assign led0_r = conect_ok;
assign led1_r = connect_halt;

//clk_wiz_0
//u_clk_wiz_0(.clk_in1(CLK100MHZ), .clk_out1(clk),.reset(reset), .locked());



top_pipe#(.NB_latch12(NB_latch12), .NB_latch23(NB_latch23), .NB_latch34(NB_latch34), .NB_latch45(NB_latch45))
u_top_pipe(.clk(connect_clk_mips), .reset(connect_reset_mips), 
                .in_addr_wire(connect_addr_wire), .out_wire_reg(connect_reg_data), .in_instruction_addr(connect_addr_prog),
                .in_instruction(connect_instruction), .in_wea_prog(connect_wea_prog), .out_latch12(connect_l12),
                .out_latch23(connect_l23), .out_latch34(connect_l34), .out_latch45(connect_l45),
                .out_pc(connect_pc), .out_halt(connect_halt), .out_wire_dmem(connect_wire_dmem));


estados#(.NB_latch_12(NB_latch12), .NB_latch_23(NB_latch23), .NB_latch_34(NB_latch34), .NB_latch_45(NB_latch45))
u_estados( 
        .clk(clk), .reset(reset), .in_rx_reg(connect_uart_rx_data), .in_halt(connect_halt), .in_pc(connect_pc),
        .in_tx_done(connect_tx_done), .in_rx_done(connect_rx_done), .in_reg_mem(connect_reg_data), .in_data_mem(connect_wire_dmem),
        .latch12(connect_l12), .latch23(connect_l23), .latch34(connect_l34), .latch45(connect_l45), .out_tx_reg(connect_uart_tx_data), 
        .out_data(connect_instruction), .out_wea_prog(connect_wea_prog),
        .out_tx_start(connect_tx_start), .out_rd_addr(connect_addr_wire), .out_send_ok(conect_ok), .out_estado(connect_estado),
        .out_addr(connect_addr_prog), .out_clk_enb(connect_clk_enb), .out_reset(connect_reset_mips));

//--------------------------------UART--------------------------------------------

//uart#(.NBITS(8), .NUM_TICKS(16), .BAUD_RATE(9600), .CLK_RATE(40000000))
//u_uart(.CLK_100MHZ(clk), .reset(reset), .tx_start(connect_tx_start),
//        .rx(UART_TXD_IN), .data_in(connect_uart_tx_data), .data_out(connect_uart_rx_data),
//        .rx_done_tick(connect_rx_done), .tx(UART_RXD_OUT), .tx_done_tick(connect_tx_done));
endmodule