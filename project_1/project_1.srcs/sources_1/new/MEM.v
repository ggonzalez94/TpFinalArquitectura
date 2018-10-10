`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2017 05:04:46 PM
// Design Name: 
// Module Name: alu
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

module MEM(clk,
            reset,
            in_address,
            in_wdata,
            in_mem_ctl,
            in_alu_zero,
            in_reg_dst,
            in_wb,
            // in_branch_addr,
            out_wb,
            out_rdata,
            out_addr_in,
            out_reg_dst,
            out_ctl_branch
            // out_branch_addr
            );
parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

input clk;
input reset;
input [NB_data - 1 : 0] in_address;
input [NB_data - 1 : 0] in_wdata;
// input [NB_data - 1 : 0] in_branch_addr;
input [9 - 1 : 0] in_mem_ctl;
input in_alu_zero;
input [2 - 1 : 0] in_wb;
input [NB_addr - 1 : 0] in_reg_dst;

output reg [2 - 1 : 0] out_wb;
output reg [NB_data - 1 : 0] out_rdata;
output reg [NB_data - 1 : 0] out_addr_in;
output reg [NB_addr - 1 : 0] out_reg_dst;
output out_ctl_branch;

wire [NB_data - 1 : 0] connect_data_out;
wire [NB_data - 1 : 0] connect_data_in;

assign out_ctl_branch = in_mem_ctl[2] & (in_alu_zero ^ in_mem_ctl[8]);

assign connect_data_in = (in_mem_ctl[7] == 1'b1) ?{ {24{in_wdata[7]}}, in_wdata[7:0] } :
                  (in_mem_ctl[6] == 1'b1) ? { {16{in_wdata[15]}}, in_wdata[15:0] }:
                  // (in_mem_ctl[6] == 1'b1) ? $signed(in_wdata[15:0]):
                  in_wdata;

data_mem #(
    .RAM_WIDTH(32),
    .RAM_DEPTH(2048),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
   .INIT_FILE("C:/Users/nati/Documents/FACULTAD/QUINTO/Aquitectura/PracticoArqui/mips/files/data_mem.txt") 
    // .INIT_FILE("E:/datos_mips/data_mem.txt") 

  ) u_data_mem (
    .addra(in_address),         // Write address bus, width determined from RAM_DEPTH
    .addrb(in_address),
    .dina(connect_data_in),            // RAM input data, width determined from RAM_WIDTH
    .clka(clk),                 // Clock
    .enb(in_mem_ctl[1]),
    .wea(in_mem_ctl[0]),        // Write enable
    .rsta(reset),
    .doutb(connect_data_out)    // RAM output data, width determined from RAM_WIDTH
  );

always @(posedge clk) begin
  if (reset == 1'b1) begin
    out_rdata <= 0;
    out_addr_in <= 0;
    out_reg_dst <= 0;
    out_wb <= 0;
//    out_ctl_branch <= 0;
  end else begin
    
    out_rdata <= (in_mem_ctl[5] == 1'b1) ? ( (in_mem_ctl[3] == 1'b0) ? {{24{1'b0}},connect_data_out[7:0]}
                  : { {24{connect_data_out[7]}}, connect_data_out[7:0]} ) :
                 (in_mem_ctl[4] == 1'b1) ? ( (in_mem_ctl[3] == 1'b0) ? {{16{1'b0}},connect_data_out[15:0]}
                  : { {16{connect_data_out[15]}}, connect_data_out[15:0]} ) :
                  connect_data_out;
    out_addr_in <= in_address;
    out_reg_dst <= in_reg_dst;
    out_wb <= in_wb;
    
    
  end
end

endmodule