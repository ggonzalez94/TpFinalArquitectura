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
           instruction_out,
           adder_out,
           in_pc_jump_addr,
           in_pc_branch_addr,
           in_pc_jump_reg,
           in_ctl_jump,
           in_ctl_jump_reg,
           in_ctl_branch,
           in_ctl_stall,
           reset,
           clk
);

parameter NB = `NB;

 input [25 : 0] in_pc_jump_addr;
 input [NB - 1 : 0] in_pc_branch_addr;
 input [NB - 1 : 0] in_pc_jump_reg;
 input in_ctl_jump;
 input in_ctl_jump_reg;
 input in_ctl_branch;
 input clk;
 input reset;
 input in_ctl_stall;
 input in_flush;
 
 output reg [NB - 1 : 0] instruction_out;
 output reg [NB - 1 : 0] adder_out;

 reg [NB - 1 : 0] pc;

 wire [NB - 1 : 0] connect_pc;
 wire [NB - 1 : 0] connect_pc_mem;
 wire [NB - 1 : 0] connect_instruction;
 wire [NB - 1 : 0] connect_adder;
 wire connect_halt;
 
//  assign connect_pc = (mux_ctl == 1'b1) ? jmp_reg : connect_adder;
 assign connect_pc_mem = (connect_halt == 1'b0 ) ? pc : connect_pc_mem;

 

 adder # (.NB(NB))
 u_adder(.A(connect_pc_mem), .B(32'h0001), .x(connect_adder));
 
 control_pc
 u_control_pc(.in_pc(connect_adder), 
            .in_pc_jump(in_pc_jump_addr), 
            .in_pc_jump_reg(in_pc_jump_reg), 
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
    .INIT_FILE("/home/gustav/ArquiGustavoWolfmann/instructions.hex")                                            // Specify name/location of RAM initialization file if using one (leave blank if not)
    // .INIT_FILE("E:/datos_mips/instructions.hex")                                            // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) u_prog_mem (
    .addra(connect_pc_mem[10:0]),   // Write address bus, width determined from RAM_DEPTH
    .dina(32'b0000),     // RAM input data, width determined from RAM_WIDTH
    .clka(clk),     // Clock
    .wea(1'b0),       // Write enable
    .ena((!in_ctl_stall)&&(!reset)),
    .rsta(reset),
    .out_halt(connect_halt),
    .douta(connect_instruction)    // RAM output data, width determined from RAM_WIDTH
  );

always@(posedge clk)begin
    if(reset == 1'b1) begin
        pc <= 32'b0000;
        adder_out <= 32'b0000;
    end
    else  begin
        if (in_ctl_stall == 1'b1 || connect_halt == 1'b1) begin
        pc <= pc;
        adder_out <= adder_out;
        end
        else begin
            pc <= connect_pc;
            adder_out <= connect_adder;
        end
    end
end

always@(*)begin 
if ( in_flush==1'b1 )
    instruction_out <= 32'h00000000;
else
    instruction_out <= connect_instruction;

end

endmodule