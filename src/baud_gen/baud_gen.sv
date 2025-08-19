module baud_gen #(parameter DIVIDER = 10) // set div param for timing, needs to be >1
( // io
	input logic clk, // external clk
	input logic rst_n, // reset signal (inverted)
	output logic tick // baud tick out
);
	logic [$clog2(DIVIDER)-1:0] counter; // counter for tick out
	
	always_ff @(posedge clk or negedge rst_n) begin // start logic (async reset)
		if (!rst_n) begin // if reset on (rst_n = 0), no ticks
			counter <= 0;
			tick <=0; 
		end else begin // if counter reached div, out a tick
			if (counter == DIVIDER-1) begin // reached threshold, out tick
				counter <= 0;
				tick <= 1;
			end else begin // not time to tick yet
				counter <= counter+1;
				tick <= 0;
			end
		end
	end
endmodule