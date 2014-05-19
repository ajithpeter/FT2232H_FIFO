/*
	Implements a rotary encoder interface with detent correction and push button debounce
	
	Copied mercilessly from the Xilinx Spartan 3E Starter Kit Reference Design for Rotary Encoder
	and the debouncer logic from fpga4fun
	
	Ajith Peter
	Standard Process / Center for Computational Engineering and Networking, Amrita Vishwa Vidyapeetham
	ajith dot peter at gmail dot com
	
	May 2014
	
*/

module RotaryEncoder(
    input wire clock,
    input wire a,
    input wire b,
    input wire button,
    output reg [7:0] count = 8'd1
    );

wire button_d;
wire [1:0] rotary_in = {a, b};

reg delay_button_d;
reg rotary_q1;
reg rotary_q2;
reg delay_rotary_q1;
reg rotate_event;
reg rotate_left;

Debouncer db_rot_center(.clk(clock), .signal_in(button), .signal_out(button_d));

always @ (posedge clock)
	begin
			case (rotary_in)
				2'b00:
					begin
						rotary_q1 <= 0;
						rotary_q2 <= rotary_q2;
					end
				2'b01:
					begin
						rotary_q1 <= rotary_q1;
						rotary_q2 <= 0;
					end
				2'b10:
					begin
						rotary_q1 <= rotary_q1;
						rotary_q2 <= 1;
					end
				2'b11:
					begin
						rotary_q1 <= 1;
						rotary_q2 <= rotary_q2;
					end
				default:
					begin
						rotary_q1 <= rotary_q1;
						rotary_q2 <= rotary_q2;
					end
			endcase
			
			if (rotary_q1 == 1'b1 && delay_rotary_q1 == 1'b0)
				begin
					rotate_event <= 1;
					rotate_left <= rotary_q2;
				end
			else
				begin
					rotate_event <= 0;
					rotate_left <= rotate_left;
				end

			if (button_d == 1'b1 && delay_button_d == 1'b0)
				begin
					count <= 8'd0;
				end
			else
				begin
					if (rotate_event) if (rotate_left) count <= count + 8'd1; else count <= count - 8'd1;
				end
				
			
			delay_rotary_q1 <= rotary_q1;
			delay_button_d <= button_d;
	end
	
endmodule
