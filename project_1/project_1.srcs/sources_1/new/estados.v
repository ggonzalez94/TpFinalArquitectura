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
                in_tx_done,
                in_reg_mem,
                in_data_mem,
                in_rx_done,
                latch12,
                latch23,
                latch34,
                latch45,
                out_tx_reg,
                out_data,
                out_addr,
                out_tx_start,
                out_clk_enb,
                out_rd_addr,
                out_wea_prog,
                out_send_ok,
                out_estado,
                out_reset);

parameter NB_UART = `NB_UART;
parameter NB_data = `NB_data;
parameter NB_latch_12 = 64;
parameter NB_latch_23 = 218;
parameter NB_latch_34 = 113;
parameter NB_latch_45 = 71;
parameter NB_mem = 11;

parameter N_CHAN_latch_12 = (NB_latch_12 - 1)/NB_data;
parameter N_CHAN_latch_23 = (NB_latch_23 - 1)/NB_data;
parameter N_CHAN_latch_34 = (NB_latch_34 - 1)/NB_data;
parameter N_CHAN_latch_45 = (NB_latch_45 - 1)/NB_data;

//Por que 6 canales ??
// 1 para el pc
// 3 para latches (un para c/u de los latches ) (resolver porque estas cacas no son de 32 bits)
// 1 para las salidas de las memorias
// 1 para la cantidad de ciclos
parameter N_CHAN = N_CHAN_latch_12 + N_CHAN_latch_23 + N_CHAN_latch_34 + N_CHAN_latch_45 + 4 + 3 ;
parameter NB_SELECT = $clog2(N_CHAN) + 2;

input clk;
input reset;
input in_rx_done;
input [NB_UART - 1 : 0] in_rx_reg;
input in_halt;
input [NB_data - 1 : 0] in_pc;
input [NB_latch_12 - 1 : 0] latch12;
input [NB_latch_23 - 1 : 0] latch23;
input [NB_latch_34 - 1 : 0] latch34;
input [NB_latch_45 - 1 : 0] latch45;
input in_tx_done;
input [NB_data - 1 : 0] in_data_mem;
input [NB_data - 1 : 0] in_reg_mem;

output reg [(NB_UART*4) - 1 : 0] out_data; //Dato a escribir en la memoria
output reg [NB_mem - 1 : 0] out_addr; //Direccion de memoria de programa para escribir

output reg [NB_mem - 1 : 0] out_rd_addr; //Direccion de lectura de las memorias para SEND_DATA
output [NB_UART - 1 : 0] out_tx_reg;
output reg out_reset;
output reg out_clk_enb;
//tx start para el transmisor de la UART
output reg out_tx_start;
//Wriete enable para programar la memoria de programa
output out_wea_prog;
output out_send_ok;
output reg [2:0] out_estado;


reg [NB_mem - 1 : 0] prog_addr;
reg [(NB_UART*4) - 1 : 0] prog_data;
reg [NB_mem - 1 : 0] rd_addr;
reg [NB_UART - 1 : 0] tx_reg;
reg tx_start;
reg wea_prog;
reg [NB_data - 1 : 0] clk_counter_prox;
reg [NB_mem - 1 : 0] addr_tmp_prox;

reg [NB_data - 1 : 0] clk_counter;

reg [NB_SELECT - 1 : 0] mux_select;
reg [NB_SELECT - 1 : 0] mux_sel_prox;

reg mem_sel_prox;

wire halt;
reg [(NB_UART*4) - 1 : 0]out_reg;
reg [(NB_UART*4) - 1 : 0]out_reg_prox;

reg out_reset_prox;

reg [2 : 0] estado_actual; 
reg [2 : 0] estado_proximo; 

reg mem_select;
wire [NB_data - 1 : 0] mux_array [0 : N_CHAN - 1];
reg [NB_UART - 1 : 0] mux_out;

wire [NB_data - 1 : 0] mem_out;


assign mem_out = (mem_select)? in_data_mem : in_reg_mem;
assign halt = & out_data;

localparam STATE_IDLE = 3'b000,
            STATE_PROGRAMMING = 3'b001,
            STATE_WAITING = 3'b010,
            STATE_COTINUOUS = 3'b011,
            STATE_SEND_DATA = 3'b100,
            STATE_STEP = 3'b101;

assign out_send_ok = (estado_actual == STATE_SEND_DATA) ? 1'b1 : 1'b0;
reg [2 : 0] estado_actual_prog; 
reg [2 : 0] estado_proximo_prog;

localparam  BYTE_1 = 3'b000,
            BYTE_2 = 3'b001,
            BYTE_3 = 3'b010,
            BYTE_4 = 3'b011,
            START = 3'b100;

localparam start = 8'd1,
            continuous = 8'd2,
            step_by = 8'd3,
            reset_mips = 8'd4,
            step = 8'd5,
            reprogramar = 8'd6;

reg halt_flag;
reg halt_flag_next;
reg clk_enb;
//Organizo los datos a enviar por UARTen un primer mux
generate
  genvar jj;
  assign mux_array[0] = {{31{1'b0}}, in_halt};
  assign mux_array[1] = clk_counter;
  // assign mux_array[2] = mem_out;
  for ( jj = 0 ; jj < N_CHAN_latch_12; jj = jj + 1 ) begin: for1
    assign mux_array[jj+2] = latch12[(jj+1)*NB_data - 1 : (jj * NB_data)];
  end
  assign mux_array[N_CHAN_latch_12+2] = latch12[NB_latch_12 - 1 : (N_CHAN_latch_12 * NB_data)];

  for ( jj = 0 ; jj < N_CHAN_latch_23 ; jj = jj + 1 ) begin: for2
    assign mux_array[jj+N_CHAN_latch_12+2+1] = latch23[(jj+1)*NB_data - 1 : (jj * NB_data)];
  end
  assign mux_array[N_CHAN_latch_23+N_CHAN_latch_12+2+1] = latch23[NB_latch_23 - 1 : (N_CHAN_latch_23 * NB_data)];

  for ( jj = 0 ; jj < N_CHAN_latch_34 ; jj = jj + 1 ) begin: for3
    assign mux_array[jj+N_CHAN_latch_12+N_CHAN_latch_23+2+2] = latch34[(jj+1)*NB_data - 1 : (jj * NB_data)];
  end
  assign mux_array[N_CHAN_latch_34+N_CHAN_latch_12+N_CHAN_latch_23+2+2] = latch34[NB_latch_34 - 1 : (N_CHAN_latch_34 * NB_data)];

  for ( jj = 0 ; jj < N_CHAN_latch_45 ; jj = jj + 1 ) begin: for4
    assign mux_array[jj+N_CHAN_latch_12+N_CHAN_latch_23+N_CHAN_latch_34+2+3] = latch45[(jj+1)*NB_data - 1 : (jj * NB_data)];
  end
  assign mux_array[N_CHAN_latch_34+N_CHAN_latch_12+N_CHAN_latch_23+N_CHAN_latch_34+N_CHAN_latch_45+2] = latch45[NB_latch_45 - 1 : (N_CHAN_latch_45 * NB_data)];
  assign mux_array[N_CHAN_latch_34+N_CHAN_latch_12+N_CHAN_latch_23+N_CHAN_latch_34+N_CHAN_latch_45+3] = mem_out;
endgenerate

wire [NB_data -1 : 0] connect_muxes;
assign connect_muxes = mux_array[mux_select[NB_SELECT - 1 : 2]];
assign out_wea_prog = wea_prog;

//Este always hace el segundo multiplexor que selcciona que byte se va a enviar del resultado del primer mux
always @(*) begin
  case (mux_select[1:0])
    2'b00: mux_out = connect_muxes[(NB_UART) - 1 : 0];
    2'b01: mux_out = connect_muxes[(2*NB_UART) - 1 : NB_UART];
    2'b10: mux_out = connect_muxes[(3*NB_UART) - 1 : NB_UART*2];
    2'b11: mux_out = connect_muxes[(4*NB_UART) - 1 : NB_UART*3];
  endcase
end
reg rx_ant;
reg [NB_mem - 1 : 0] addr_tmp;


assign out_tx_reg = mux_out;

//---------------------------------------------
//Transicion de estados 
//---------------------------------------------
always @(*) begin
    //por defecto me quedo en el estado actual
    if (reset) begin
      out_reg_prox = {NB_data{1'b0}};
    end
    halt_flag_next = halt_flag;
    estado_proximo = estado_actual;
    estado_proximo_prog = estado_actual_prog;
    prog_addr = out_addr;
    prog_data = out_data;
    rd_addr = out_rd_addr;
    // tx_reg = out_tx_reg;
    tx_start = out_tx_start;
    wea_prog = out_wea_prog;
    clk_counter_prox = clk_counter;
    // mux_select = mux_select;
    mux_sel_prox = mux_select;
    mem_sel_prox = mem_select;
    out_reset =out_reset;
    addr_tmp_prox = addr_tmp;
    out_reg_prox = out_reg;
    out_reset_prox = out_reset;
        
    out_clk_enb = 1'b0;
    out_estado = estado_actual;
    case (estado_actual)
        STATE_IDLE: begin
            out_clk_enb = 1'b0;
            out_reset_prox = 1'b1;
            addr_tmp_prox = 32'd0;
            prog_addr = {NB_data{1'b0}};
            clk_counter_prox = 1'b0;
            out_reg_prox <=  {NB_data{1'b0}};

            if(in_rx_done) begin
                if(in_rx_reg == start)
                    estado_proximo = STATE_PROGRAMMING;
            end          
        end

        STATE_PROGRAMMING: begin
            out_clk_enb = 1'b1;
            out_reset_prox = 1'b0;
            wea_prog = 1'b0;
            clk_counter_prox = 1'b0;
            out_reg_prox = out_reg;
            case (estado_actual_prog)
                BYTE_4: out_reg_prox[NB_UART - 1 : 0] = in_rx_reg;
                BYTE_3: out_reg_prox[(NB_UART*2) - 1 : NB_UART] = in_rx_reg;
                BYTE_2: out_reg_prox[(NB_UART*3) - 1 : (NB_UART*2)] = in_rx_reg;
                BYTE_1: out_reg_prox[(NB_UART*4) - 1 : (NB_UART*3)] = in_rx_reg;
                START: begin
                    prog_data = out_reg;
                    wea_prog = 1'b1;
                    prog_addr = addr_tmp;// delay de un registro para poder escribir la direccion cero de la memoria
                    addr_tmp_prox = addr_tmp + 1'b1;
                    if ( & prog_data ) estado_proximo = STATE_WAITING;
                end
            endcase

            if (estado_actual_prog == START) estado_proximo_prog = BYTE_1;
            // if (halt == 1'b1) 
            //     estado_proximo = STATE_WAITING;
            if (in_rx_done) begin
                if (estado_actual_prog == START)
                    estado_proximo_prog = BYTE_1;
                else 
                    estado_proximo_prog = estado_actual_prog + 1'b1;
          end  
        end
        
        STATE_WAITING: begin
            out_reset_prox = 1'b1;
            out_clk_enb = 1'b0;
            tx_start = 1'b0;
            clk_counter_prox = 1'b0;
            mux_sel_prox = {NB_SELECT{1'b0}};
            rd_addr = {NB_mem{1'b0}};
            wea_prog = 1'b0;
            mem_sel_prox = 1'b0;
            out_reg_prox = {NB_data{1'b0}};
            halt_flag_next = 1'b1;


            if(in_rx_done) begin
              if (in_rx_reg == step_by) begin
                out_reset_prox = 1'b0;
                estado_proximo = STATE_STEP;
                end
              else if (in_rx_reg == continuous) begin
                estado_proximo = STATE_COTINUOUS;
                out_reset_prox = 1'b0;
                end
              else if (in_rx_reg == reprogramar)
                estado_proximo = STATE_IDLE;
              else
                estado_proximo = estado_actual;
            end
        end
        STATE_COTINUOUS: begin
            out_reset_prox = 1'b0;
            clk_counter_prox = clk_counter + 1'b1;
            out_reg_prox = {NB_data{1'b0}};
            mem_sel_prox = 1'b0;
            tx_start = 1'b0;
            // mux_sel_prox = 0;
            out_clk_enb = 1'b1;          
            if (in_halt == 1'b1) begin
                estado_proximo = STATE_SEND_DATA;
                // tx_reg = mux_out;
                tx_start = 1'b1;
            end

        end

        STATE_SEND_DATA: begin
            out_clk_enb = 1'b0;
            // out_reset_prox =1'b1;
            halt_flag_next = 1'b0;
            clk_counter_prox = clk_counter;
            out_reg_prox = {NB_data{1'b0}};
            // mux_select = 0;
            // tx_reg = mux_out;
            tx_start = 1'b1;

            if(in_tx_done)begin
                /* Estoy en el ultimo canal ? */ 
                if((mux_select >> 2) == N_CHAN - 1) begin
                    //Cambio el byte a enviar
                    mux_sel_prox[1:0] = mux_select[1:0] + 1'b1;

                    //Deteco si llego al final de lectura de la memoria
                    // mem_select = mem_select ^ (rd_addr[5] & !(&mux_select[1:0]));
                    if (out_rd_addr == (NB_data - 1) && (&mux_select[1:0]) ) begin
                    //reseteo la direccion
                        if (mem_select) begin        
                            tx_start = 1'b0;
                            if (in_halt)
                                estado_proximo = STATE_WAITING;
                            else
                                estado_proximo = STATE_STEP;
                        end else begin
                          mem_sel_prox = 1'b1;
                        end
                        rd_addr = {NB_mem{1'b0}};
                    end else begin
                    //Aca incremento la direccion de lectura de las memorias
                        rd_addr = out_rd_addr + (&mux_select[1:0]);
                    end            
                end else 
                    mux_sel_prox = mux_select + 1'b1;          
                
                // tx_reg = mux_out;
                // tx_start = 1'b1;
            end 
            else 
                tx_start = 1'b0;   

        end 

        STATE_STEP: begin
            out_reset_prox = 1'b0;
            mem_sel_prox = 1'b0;
            out_reg_prox = {NB_data{1'b0}};
            rd_addr = {NB_data{1'b0}};
            tx_start = 1'b0;
            halt_flag_next = 1'b0;
            mux_sel_prox = {NB_SELECT{1'b0}};
            if(in_rx_done) begin
                if (in_rx_reg == step) begin
                    estado_proximo = STATE_SEND_DATA;    
                    clk_counter_prox = clk_counter + 1'b1;
                    mux_sel_prox = {NB_SELECT{1'b0}};
                    tx_start = 1'b1;
                    out_clk_enb = 1'b1;
                end 
            end
        end
    endcase
end

//--------------------------------------------------------------------------
//Asignacion de salidas segun el estado
//--------------------------------------------------------------------------
always @(posedge clk or negedge reset) begin
    halt_flag <= in_halt;
    if (reset) begin  
      estado_actual <= STATE_IDLE;
      estado_actual_prog <= BYTE_1;
      out_addr <= {NB_data{1'b0}};
      out_data <= {NB_data{1'b0}};
      out_rd_addr <= {NB_mem{1'b0}};
      halt_flag <= 1'b1;
    //   out_tx_reg <= {NB_UART{1'b0}};
      out_tx_start <= 1'b0;
    //   out_wea_prog <= 1'b0;
      clk_counter <= 1'b0;
      rx_ant <= 1'b1;
      addr_tmp <= 32'd0;
      mux_select <=  {NB_SELECT{1'b0}};
      mem_select <= 1'b0;
      out_reg  <= {NB_data{1'b0}};
      out_reset <= 1'b0;
    //    out_clk_enb <= 1'b1;
    end else begin
        estado_actual <= estado_proximo;
        estado_actual_prog <= estado_proximo_prog;
        out_addr <= addr_tmp;
        out_data <= out_reg;
        out_rd_addr <= rd_addr;
        // out_tx_reg <= tx_reg;
        out_tx_start <= tx_start;
        // out_wea_prog <= wea_prog;
        clk_counter <= clk_counter_prox;
        rx_ant <= in_rx_done;
        addr_tmp <= addr_tmp_prox;
        mux_select <= mux_sel_prox;
        mem_select <= mem_sel_prox;
        out_reg <= out_reg_prox;
        out_reset <= out_reset_prox;
        // out_clk_enb <= clk_enb;
    end
end


  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
endmodule