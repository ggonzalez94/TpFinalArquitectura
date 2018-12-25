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


`define NB_UART 8
`define NB_data 32

module estados(clk,
                reset,
                in_rx_reg,
                in_halt,
                in_pc,
                latch12,
                latch23,
                latch34,
                out_tx_reg,
                out_data,
                out_addr,
                out_clk_enb,
                out_reset);

parameter NB_UART = `NB_UART;
parameter NB_data = `NB_data;
parameter NB_latch_12 = 36;
parameter NB_latch_23 = 36;
parameter NB_latch_34 = 36;

parameter N_CHAN_latch_12 = (NB_latch_12 - 1)/NB_data;
parameter N_CHAN_latch_23 = (NB_latch_23 - 1)/NB_data;
parameter N_CHAN_latch_34 = (NB_latch_34 - 1)/NB_data;

//Por que 6 canales ??
// 1 para el pc
// 3 para latches (un para c/u de los latches ) (resolver porque estas cacas no son de 32 bits)
// 1 para las salidas de las memorias
// 1 para la cantidad de ciclos
parameter N_CHAN = N_CHAN_latch_12 + N_CHAN_latch_23 + N_CHAN_latch_34 + 3 + 3 ;
parameter NB_SELECT = $clog2(N_CHAN - 1) + 3;

input clk;
input reset;
input [NB_UART - 1 : 0] in_rx_reg;
input in_halt;
input [NB_data - 1 : 0] in_pc;
input [NB_latch_12 - 1 : 0] latch12;
input [NB_latch_23 - 1 : 0] latch23;
input [NB_latch_34 - 1 : 0] latch34;

output reg [(NB_UART*4) - 1 : 0] out_data;
output reg [(NB_UART*4) - 1 : 0] out_addr;
output reg [NB_UART - 1 : 0] out_tx_reg;
output reg out_reset;
output reg out_clk_enb;


//TODO
wire [NB_data - 1 : 0] clk_counter;
//TODO
reg [NB_SELECT - 1 : 0] mux_select;

reg halt;
reg [(NB_UART*4) - 1 : 0]out_reg;

reg [2 : 0] estado_actual; 
reg [2 : 0] estado_proximo; 

// wire [ $clog2(N_CHAN - 1) - 1 : 0] mux_select;
wire [NB_data - 1 : 0] mux_array [0 : N_CHAN - 1];
reg [NB_UART - 1 : 0] mux_out;

wire [NB_data - 1 : 0] mem_out;

localparam STATE_IDLE = 3'b000,
            STATE_PROGRAMMING = 3'b001,
            STATE_WAITING = 3'b010,
            STATE_COTINUOUS = 3'b011,
            STATE_SEND_DATA = 3'b100,
            STATE_STEP = 3'b101,
            STATE_STEPPING = 3'b110;

reg [2 : 0] estado_actual_prog; 
reg [2 : 0] estado_proximo_prog;

localparam BYTE_1 = 3'b000,
            BYTE_2 = 3'b001,
            BYTE_3 = 3'b010,
            BYTE_4 = 3'b011,
            SEND_OUT = 3'b100;

localparam start = 8'd1,
            continuous = 8'd2,
            step_by = 8'd3,
            reset_mips = 8'd4,
            step = 8'd5;


//Organizo los datos a enviar por UARTen un primer mux
generate
  genvar jj;
  assign mux_array[0] = in_pc;
  assign mux_array[1] = clk_counter;
  assign mux_array[2] = mem_out;
  for ( jj = 0 ; jj < N_CHAN_latch_12; jj = jj + 1 ) begin: for1
    assign mux_array[jj+3] = latch12[(jj+1)*NB_data - 1 : (jj * NB_data)];
  end
  assign mux_array[N_CHAN_latch_12+3] = latch12[NB_latch_12 - 1 : (N_CHAN_latch_12 * NB_data)];

  for ( jj = 0 ; jj < N_CHAN_latch_23 ; jj = jj + 1 ) begin: for2
    assign mux_array[jj+N_CHAN_latch_12+3+1] = latch23[(jj+1)*NB_data - 1 : (jj * NB_data)];
  end
  assign mux_array[N_CHAN_latch_23+N_CHAN_latch_12+3+1] = latch23[NB_latch_23 - 1 : (N_CHAN_latch_23 * NB_data)];

  for ( jj = 0 ; jj < N_CHAN_latch_34 ; jj = jj + 1 ) begin: for3
    assign mux_array[jj+N_CHAN_latch_12+N_CHAN_latch_23+3+2] = latch34[(jj+1)*NB_data - 1 : (jj * NB_data)];
  end
  assign mux_array[N_CHAN_latch_34+N_CHAN_latch_12+N_CHAN_latch_23+3+2] = latch34[NB_latch_34 - 1 : (N_CHAN_latch_34 * NB_data)];
endgenerate

wire [NB_data -1 : 0] connect_muxes;
assign connect_muxes = mux_array[mux_select[NB_SELECT - 1 : 2]];

//Este always hace el segundo multiplexor que selcciona que byte se va a enviar del resultado del primer mux
always @(*) begin
  case (mux_select[1:0])
    2'b00: mux_out = connect_muxes[(NB_UART) - 1 : 0];
    2'b01: mux_out = connect_muxes[(2*NB_UART) - 1 : NB_UART];
    2'b10: mux_out = connect_muxes[(3*NB_UART) - 1 : NB_UART*2];
    2'b11: mux_out = connect_muxes[(4*NB_UART) - 1 : NB_UART*3];
  endcase
end

//---------------------------------------------
//Transicion de estados 
//---------------------------------------------
always @(*) begin
    //por defecto me quedo en el estado actual
    case (estado_actual)
        STATE_IDLE: begin
          if(in_rx_reg == start)
            estado_proximo = STATE_PROGRAMMING;
        end
        STATE_PROGRAMMING: begin
          if (halt == 1'b1) 
            estado_proximo = STATE_WAITING;
          else begin
            estado_proximo = estado_actual;
            if (estado_actual_prog == SEND_OUT)
              estado_proximo_prog = BYTE_1;
            else
              estado_proximo_prog = estado_actual + 1'b1;
          end
        end
        STATE_WAITING: begin
          if (in_rx_reg == step_by)
            estado_proximo = STATE_STEP;
          else if (in_rx_reg == continuous)
            estado_proximo = STATE_COTINUOUS;
          else  
            estado_proximo = estado_actual;
        end
        STATE_COTINUOUS: begin
          if (in_halt == 1'b1)
            estado_proximo = STATE_SEND_DATA;
          else
            estado_proximo = estado_actual;
        end
        STATE_SEND_DATA: begin
          if (in_halt == 1'b1)
            estado_proximo = STATE_WAITING;
          else
            estado_proximo = STATE_STEP;
        end 
        STATE_STEP: begin
          if (in_rx_reg == step) begin
            estado_proximo = STATE_SEND_DATA;
          end
        end
    endcase
end
//--------------------------------------------------------------------------
//Asignacion de salidas segun el estado
//--------------------------------------------------------------------------
always @(posedge clk) begin
    out_reset = 1'b0;
    // out_data = 32'd0;
    estado_proximo = estado_actual;
     out_addr = out_addr;
  case (estado_actual)
    STATE_IDLE : begin 
        out_addr = 32'd0;
        out_reset =1'b1;
        out_clk_enb = 1'b0;
    end
    STATE_PROGRAMMING: begin
      out_clk_enb = 1'b1;
      out_reset = 1'b1;
      //Maquina de estados dentro de programming que deberia cargar la memoria de datos hasta que enchentre un halt
      estado_actual_prog = estado_proximo_prog;
      case (estado_actual_prog)
        BYTE_1: out_reg[NB_UART - 1 : 0] = in_rx_reg;
        BYTE_2: out_reg[(NB_UART*2) - 1 : NB_UART] = in_rx_reg;
        BYTE_3: out_reg[(NB_UART*3) - 1 : (NB_UART*2)] = in_rx_reg;
        BYTE_4: out_reg[(NB_UART*4) - 1 : (NB_UART*3)] = in_rx_reg;
        SEND_OUT: begin
          if (out_reg == 32'hffffffff)
              halt = 1'b1;
        out_data = out_reg;
        out_addr = out_addr + 1'b1;
        end
      endcase
    end
    STATE_COTINUOUS: begin
      out_clk_enb = 1'b1;
      out_reset = 1'b0;
    end
    STATE_WAITING: begin
      out_reset =1'b1;
      out_clk_enb = 1'b0;
    end
    STATE_SEND_DATA: begin
      out_reset =1'b0;
      out_clk_enb = 1'b0;

      mux_select = mux_select + 1;
      out_tx_reg = mux_out;
    end
  endcase
end


  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
endmodule