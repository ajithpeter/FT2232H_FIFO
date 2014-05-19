/*

	An attempt to test the Asynchronous FIFO Operation of FT2232H by generating a triangular waveform whose 
	period can be varied by the rotary encoder on the Spartan 3E Starter Kit.
	
	Ajith Peter
	Standard Process / Center for Computational Engineering and Networking, Amrita Vishwa Vidyapeetham
	ajith dot peter at gmail dot com
	
	May 2014
	
*/

module top(
    input wire clk,					// Input Clock at 50MHz
    input wire rot_a,					// Rotary Encoder Quadrature Out A
    input wire rot_b,					// Rotary Encoder Quadrature Out B
    input wire rot_center,				// Rotary Encoder Push Button Switch
    output wire [7:0] d,				// FIFO Data Bus
    output reg wr = 1'b1,				// FIFO Write Strobe
    input wire txe,					// FIFO TX Buffer is Full - Donot write to FIFO when this signal is high
    output wire [7:0] leds				// LEDs for Indication
    );

wire [31:0] clock_divisor = 32'd5;			// Set this value to divide the input clock for setting the data rate
wire [23:0] out_max = 24'd65024;			// Output counter 24-bit wide maximum
wire [23:0] out_min = 24'd256;				// Output counter 24-bit wide minimum
wire [7:0] increment;					// Increment for every step - A crude/dirty measure of frequency

reg [31:0] clock_counter = 32'd0;			// Clock divide counter
reg count_direction = 1'b1;				// Triangular Waveform Ramp Direction
reg [23:0] out_counter = 24'd256;			// 24-bit wide counter for 8-bit data bus (to check for overflows, I know - DIRTY

assign leds = out_counter[15:8];			// Show the Current Value on the LED Display
assign d = out_counter[15:8];				// Select the mid 8 bits of the output counter as the FIFO data bus

// Rotary Encoder Initiation
RotaryEncoder encoder(.clock(clk), .a(rot_a), .b(rot_b), .button(rot_center), .count(increment));

always @ (posedge clk)
	begin
		if (clock_counter < clock_divisor - 3)		// Clock Divider Logic
			begin
				clock_counter <= clock_counter + 32'd1;
				out_counter <= out_counter;
				wr <= wr;
				count_direction <= count_direction;
			end
		else
			begin			
				if (clock_counter == clock_divisor - 3)
					begin
						clock_counter <= clock_counter + 32'd1;
						wr <= wr;
						if (count_direction) 
							out_counter <= out_counter + {8'd0, increment, 8'd0}; 
						else 
							out_counter <= out_counter - {8'd0, increment, 8'd0};
						
						if (out_counter >= out_max)
							begin
								count_direction <= 1'b0;
							end
						else
							begin
								if (out_counter <= out_min)
									begin
										count_direction <= 1'b1;
									end
								else
									begin
										count_direction <= count_direction;
									end
							end
					end
				else
					begin
						if (clock_counter == clock_divisor - 2)
							begin
								clock_counter <= clock_counter + 32'd1;
								out_counter <= out_counter;
								count_direction <= count_direction;
								wr <= 1'b1;
							end
						else
							begin
								if (clock_counter < clock_divisor)
									begin
										clock_counter <= clock_counter + 32'd1;
										out_counter <= out_counter;
										wr <= wr;
										count_direction <= count_direction;
									end
								else
									begin
										clock_counter <= 32'd0;
										out_counter <= out_counter;
										if (txe == 1'b0)
											wr <= 1'b0;
										else
											wr <= wr;
										count_direction <= count_direction;
									end
							end
					end
			end
	end

endmodule
