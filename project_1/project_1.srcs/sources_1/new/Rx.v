`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:39:38 10/09/2016 
// Design Name: 
// Module Name:    Rxv2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Rx(
		input                                         reset,
		input                                         clk,
		input	                                      rx,
		output    reg [7:0]                           d_out,
		output    reg                                 rx_done_tick
    );
    
	reg [4:0] estado;
	reg [3:0] tick_counter;
	reg [2:0] cant_recv;
	
	always @(posedge clk)
	begin
		if(reset)
		begin
            estado <= 5'b00001;
            d_out <= 0;
            rx_done_tick <= 0;
		end
        case(estado)
            5'b00001 :  //Espero a que el rx tome el valor de 0 para pasar al siguiente estado.
                begin
                    if (rx == 0)
                    begin
                        estado <= 5'b00010;
                        tick_counter <= 0;
                        d_out <= 0;
                    end
                    rx_done_tick <= 0;
                end
            5'b00010 : //Espero a que lleguen 7 ciclos de clock para avanzar al siguiente estado.
                begin
                if(tick_counter == 7)
                    begin
                        estado <= 5'b00100;
                        tick_counter <= 0;
                        cant_recv <= 0;
                    end
                else
                    tick_counter <= tick_counter +1;
                end
            5'b00100 : //Espero a que lleguen 15 ciclos de clock para tomar el valor de rx y guardarlo en d;
                begin 
                    if(tick_counter == 15)
                    begin
                        d_out[cant_recv] <= rx;
                        tick_counter <= 0;
                        if(cant_recv == 7)
                            begin
                                estado <= 5'b01000;
                            end
                        else
                            cant_recv <= cant_recv + 1;
                    end
                    else
                        tick_counter <= tick_counter +1;
                end
            5'b01000 : //bit de paridad
                begin
                    estado <= 5'b10000;
                end
            5'b10000 : //bit stop
                begin
                    if(tick_counter == 15)
                    begin
                        estado <= 5'b00001;
                        rx_done_tick <= 1;
                    end
                    else
                        tick_counter <= tick_counter +1;
                end
            default: estado <= 5'b00001;
        endcase
    end
endmodule
