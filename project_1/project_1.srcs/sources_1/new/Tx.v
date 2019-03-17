`timescale 1ns / 1ps

module Tx(
		input reset,
		input clk,
		input tx_start,
		output reg tx,
		input [7:0] d_in,
		output reg tx_done_tick
    );
	reg [7:0] d_in_aux;
	reg [5:0] estado;
	reg [3:0] tick_counter;
	reg [3:0] cant_enviados;
	
	always @(posedge clk)
	begin
		d_in_aux <= d_in;
		if(reset)
		begin
			estado <= 5'b00001;
			tx_done_tick <= 0;
			tx <= 1;
		end
		case(estado)
			5'b00001 :  //Espero a que el tx_start tome el valor de 1 para pasar al siguiente estado.
				begin
				tx <= 1;
				tx_done_tick <= 0;
					if (tx_start == 1)
					begin
						estado <= 5'b00010;
						cant_enviados <= 0;
						tick_counter <= 0;
					end
				end
			5'b00010 ://Coloco el canal en 0 durante 15 ciclos de clock (bit de inicio);
				begin
				if(tick_counter == 15)
					begin
						estado <= 5'b00100;
						tick_counter <= 0;
						tx <= d_in_aux[cant_enviados];
					end
				else
					begin
                        tx <= 0;
						tick_counter <= tick_counter +1;
					end
				end
			5'b00100 ://Coloco el canal en funcion del bit que se envia durante 15 ciclos de clock;
				begin 
				if(cant_enviados == 8)
					begin
						estado <= 5'b01000;
						tick_counter <= 0;
						tx <= 1;
					end
				else
					begin
						tx <= d_in_aux[cant_enviados];
						if(tick_counter == 15)
							begin
								tick_counter <= 0;
								cant_enviados <= cant_enviados + 1;
							end
						else
							begin
								tick_counter <= tick_counter +1;
							end
					end
				end
			5'b01000 ://bit de paridad
				begin
					estado <= 5'b10000;
				end
			5'b10000 ://bit stop
				begin
					if(tick_counter == 15)
					begin
						estado <= 5'b00001;
						tx_done_tick <= 1;
						tx <= 1;
					end
					else
					tick_counter <= tick_counter +1;
				end
			default: estado <= 5'b00001;
		endcase
		
		
	end

endmodule
