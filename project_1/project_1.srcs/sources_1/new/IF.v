`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
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

`define NB 32

module IF( in_flush,
           out_instr,
           out_adder,
           in_jump_addr,
           in_branch_addr,
           in_jump_reg,
           in_wea_prog,
           in_prog_instruction,
           in_prog_addr,
           in_ctl_jump,
           in_ctl_jump_reg,
           in_ctl_branch,
           in_ctl_stall,
           reset,
           clk
);

parameter NB = `NB;
parameter NB_mem = 11;

 input [25 : 0] in_jump_addr;
 input [NB - 1 : 0] in_branch_addr;
 input [NB - 1 : 0] in_jump_reg;
 input in_ctl_jump;
 input in_ctl_jump_reg;
 input in_ctl_branch;
 input clk;
 input reset;
 input in_ctl_stall;
 input in_flush;
 input in_wea_prog;
 input [NB - 1 : 0] in_prog_instruction;
 input [NB_mem - 1 : 0] in_prog_addr;
 
 output reg [NB - 1 : 0] out_instr;
 output reg [NB - 1 : 0] out_adder;

 reg [NB - 1 : 0] pc;

 wire [NB - 1 : 0] connect_pc;
 wire [NB - 1 : 0] connect_pc_mem;
 wire [NB - 1 : 0] connect_instruction;
 wire [NB - 1 : 0] connect_adder;
 wire connect_halt;
 wire [NB_mem - 1 : 0] connect_addr_mem;
//  assign connect_pc = (mux_ctl == 1'b1) ? jmp_reg : connect_adder;
 assign connect_pc_mem = (connect_halt == 1'b0 ) ? pc : pc;
 assign connect_addr_mem = (in_wea_prog)? in_prog_addr : connect_pc_mem[10:0]; 

 

 adder # (.NB(NB))
 u_adder(.A(connect_pc_mem), .B(32'h0001), .x(connect_adder));
 
 control_pc
 u_control_pc(.in_pc(connect_adder), 
            .in_pc_jump(in_jump_addr), 
            .in_pc_jump_reg(in_jump_reg), 
            .in_pc_branch(in_pc_branch_addr),
            .in_jump(in_ctl_jump), 
            .in_jump_reg(in_ctl_jump_reg), 
            .in_pc_src(in_ctl_branch), 
            .out_pc(connect_pc));

 prog_mem #(
    .NB_COL(4),                       // Specify RAM data width
    .COL_WIDTH(8),
    .RAM_DEPTH(2048),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    //.INIT_FILE("/home/gustav/ArquiGustavoWolfmann/instructions.hex")                                            // Specify name/location of RAM initialization file if using one (leave blank if not)
    .INIT_FILE("/home/fabian/Documents/Facultad/Arquitectura/Trabajo Practico Final/TpFinalArquitectura/instructions.hex")                                           // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) u_prog_mem (
    .addra(connect_addr_mem),   // Write address bus, width determined from RAM_DEPTH
    .dina(in_prog_instruction),     // RAM input data, width determined from RAM_WIDTH
    .clka(clk),     // Clock
    .wea(in_wea_prog),       // Write enable
    .ena((!in_ctl_stall)&&(!reset)),
    .out_halt(connect_halt),
    .douta(connect_instruction)    // RAM output data, width determined from RAM_WIDTH
  );


always@(posedge clk or posedge reset)begin
    if(reset == 1'b1) begin
        pc <= 32'b0000;
        out_adder <= 32'b0000;
    end
    else  begin
        if (in_ctl_stall == 1'b1 || connect_halt == 1'b1) begin
        pc <= pc;
        out_adder <= out_adder;
        end
        else begin
            pc <= connect_pc;
            out_adder <= connect_adder;
        end
    end
end

always@(posedge clk or posedge reset)begin 
if ( in_flush==1'b1 || reset)
    out_instr <= 32'h00000000;
else
    out_instr <= connect_instruction;

end

endmodule