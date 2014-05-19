/*
	Implements a signal debounce logic
	
	Copied mercilessly from debouncer logic at fpga4fun
	
	Ajith Peter
	Standard Process / Center for Computational Engineering and Networking, Amrita Vishwa Vidyapeetham
	ajith dot peter at gmail dot com
	
	May 2014
	
*/

module Debouncer(
    input wire clk,
    input wire signal_in,
    output reg signal_out = 1'b0
    );

reg old_signal_in = 1'b0;
reg [15:0] counter = 16'd0;

wire [15:0] counter_max = 16'd65535;

always @ (posedge clk)
	begin
		if (old_signal_in != signal_in)
			begin
				counter <= 16'd0;
			end
		else
			begin
				if (counter < counter_max)
					begin
						counter <= counter + 16'd1;
					end
				else
					begin
						signal_out <= signal_in;
					end
			end
		old_signal_in <= signal_in;
	end

endmodule
