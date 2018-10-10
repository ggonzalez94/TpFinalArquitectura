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

module WB(  reset,
            in_ctl_wb,
            in_rd_data,
            in_addr_mem,
            in_reg_dst,
            out_ctl_wreg,
            out_reg_addr,
            out_reg_wdata
);
parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

input reset;
input [2 - 1 : 0] in_ctl_wb;
input [NB_data - 1 : 0] in_rd_data;
input [NB_data - 1 : 0] in_addr_mem;
input [NB_addr - 1 : 0] in_reg_dst;

output reg out_ctl_wreg;
output reg [NB_addr - 1 : 0] out_reg_addr;
output reg [NB_data - 1 : 0] out_reg_wdata;

always @(*) begin
  if (reset == 1'b1) begin
    out_ctl_wreg <= 1'b0;
    out_reg_addr <= {NB_addr{1'b0}};
    out_reg_wdata <= {NB_data{1'b0}};
    
  end else begin
    out_ctl_wreg <= in_ctl_wb[1];
    out_reg_addr <= in_reg_dst;
    out_reg_wdata <= (in_ctl_wb[0] == 1'b1) ? in_rd_data : in_addr_mem;
  end
  
end

endmodule