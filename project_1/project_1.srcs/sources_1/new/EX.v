`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: execute
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
    in_exec,
    in_mem,
    in_wb,
    in_flush,
    in_branch,
    in_inmediato,
    in_shamt,
    in_rt,
    in_rd,
    in_rs,
    in_halt,
    in_temp1,
    in_temp2,
    in_wb_data,
    in_mem_data,
    in_reg_34,
    in_reg_45,
    in_c_rd_34,
    in_c_rd_45,
    out_memory,
    out_wb,
    out_branch,
    out_alu,
    out_zero,
    out_sign,
    out_halt,
    out_reg_dest,
    out_write_data
);

parameter NB_data = `NB_data;
parameter NB_addr = `NB_addr;

input clk;
input reset;
input in_flush;
input [NB_data - 1 : 0] in_branch;
input [10 - 1 : 2] in_exec;
input [9 - 1 : 0] in_mem;
input [2 - 1 : 0] in_wb;
input [NB_data - 1 : 0] in_temp1;
input [NB_data - 1 : 0] in_temp2;
input [NB_data - 1 : 0] in_inmediato;
input [NB_addr - 1 : 0] in_shamt;
input [NB_addr - 1 : 0] in_rt;
input [NB_addr - 1 : 0] in_rd;
input [NB_addr - 1 : 0] in_rs;

input in_reg_34;
input in_reg_45;
input [NB_addr - 1 : 0] in_c_rd_34;
input [NB_addr - 1 : 0] in_c_rd_45;
input [NB_data - 1 : 0] in_wb_data;
input [NB_data - 1 : 0] in_mem_data;
input in_halt;

output reg out_halt;

output reg [NB_data - 1 : 0] out_branch;
output reg [NB_data - 1 : 0] out_alu;
output reg [NB_addr - 1 : 0] out_reg_dest;
output reg [NB_data - 1 : 0] out_write_data;
output reg out_zero;
output reg out_sign;
output reg [9 - 1 : 0] out_memory;
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

wire [1:0] ctl_alu_src_a;
//assign connect_c_mux_a

assign connect_mux_ac = (connect_c_mux_a == 2'b00) ? in_temp1 : 
                        (connect_c_mux_a == 2'b01) ? in_mem_data : in_wb_data;

assign connect_mux_bc = (connect_c_mux_b == 2'b00) ? in_temp2 : 
                        (connect_c_mux_b == 2'b01) ? in_mem_data : in_wb_data;

assign in_alu_a =   (in_exec[2] == 1'b1) ? {{(NB_data-5){1'b0}},in_shamt} :
                    (in_exec[9] == 1'b1) ? in_branch :
                    connect_mux_ac; 
assign in_alu_b =   (in_exec[3] == 1'b1) ? in_inmediato : 
                    (in_exec[9] == 1'b1) ? `NB_addr'd1 :
                    connect_mux_bc;

assign connect_reg_dest = (in_exec[8 : 7] == 2'b00) ? in_rt : 
                          (in_exec[8 : 7] == 2'b01) ? in_rd :
                          (in_exec[8 : 7] == 2'b10) ? `NB_addr'd31 : {NB_addr{1'b0}};

alu
u_alu(.A(in_alu_a), .B(in_alu_b), .alu_code(connect_alu_code), .x(connect_alu_out), 
        .flag_zero(connect_zero), .signo(connect_signo));

alu_control
u_alu_control(.in_alu_op(in_exec[6 : 4]), .in_function(in_inmediato[5:0]),
                 .out_alu_code(connect_alu_code));

cortocircuito
u_cortocircuito( .in_reg_w_34(in_reg_34), .in_reg_w_45(in_reg_45), .in_rd_34(in_c_rd_34),
                 .in_rs_23(in_rs), .in_rd_45(in_c_rd_45), .in_rt_23(in_rt), 
                 .out_mux_a(connect_c_mux_a), .out_mux_b(connect_c_mux_b));




always @(posedge clk or posedge reset) begin
  if (reset) begin
    out_memory <= 9'b000;
    out_wb <= 2'b00;
    out_branch <= {NB_data{1'b0}};
    out_alu <= {NB_data{1'b0}};
    out_reg_dest <= {NB_data{1'b0}};
    out_write_data <= {NB_data{1'b0}};
    out_sign <= 1'b0;
    out_zero <= 1'b0;
    out_halt <= 1'b0;
  end 
  
  else if(in_flush) begin
    out_memory <= 9'b000;
    out_wb <= 2'b00;
    out_branch <= {NB_data{1'b0}};
    out_alu <= {NB_data{1'b0}};
    out_reg_dest <= {NB_data{1'b0}};
    out_write_data <= {NB_data{1'b0}};
    out_sign <= 1'b0;
    out_zero <= 1'b0;
    out_halt <= 1'b0;
  end
  
  else begin
    out_halt <= in_halt;
    out_memory <= in_mem;
    out_wb <= in_wb;
    out_branch <= in_branch + in_inmediato;
    out_alu <= connect_alu_out;
    out_zero <= connect_zero;
    out_sign <= connect_signo;
    out_write_data <= in_temp2;
    out_reg_dest <= connect_reg_dest;
  end

end

endmodule