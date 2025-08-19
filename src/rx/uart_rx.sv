/* 
fsm:
idle @ high
start @ low
data, according to baud
(no parity)
stop @ high
*/

module uart_rx #(parameter DIVIDER = 10) // make sure this parameter is the same as in the baud gen
(
// io
input logic clk,
input logic rst_n, // reset signal
input logic baud_tick, // sync baud
input logic rx_in, // from tx
output logic [7:0] shift_reg, // holds data bits
output logic rx_ready // handshake w/ tx
);

	typedef enum logic [2:0] {
		IDLE,
		START,
		DATA,
		STOP
	} state_t; // define enum for fsm implementation
	
	state_t state; // for rx fsm
	logic [2:0] bit_count; // count when we have complete signal
	logic rx_sync; // synchronized output signal
	logic rx_in_meta; // for sync
	logic [$clog2(DIVIDER/2):0] start_counter; // counter for start, to check for start bit at middle of baud period
	
	// double flop synchronizer for sim
	always_ff @(posedge clk) begin
		{rx_sync, rx_in_meta} <= {rx_in_meta, rx_in}; // implement double flop with concatenation
	end
	
	always_ff @ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin // if reset
			state <= IDLE; // reset fsm and set signals to default
			rx_ready <= 1'b0;
			shift_reg <= 8'd0;
			bit_count <= 3'd0;
			start_counter <= '0;
		end else if (state == START) begin
			if (rx_sync) begin
				rx_ready <= 1'b0;
				state <= IDLE; // false start
			end else if (start_counter == DIVIDER/2) begin // we know start bit is still held
				rx_ready <= 1'b0; // about to recieve data
				bit_count <= 3'd0; // reset bit count
				state <= DATA;
			end
			start_counter <= start_counter + 1; // iter counter
		end else if (baud_tick) begin
			case (state) // define behavior based on fsm stage
				IDLE: begin
					rx_ready <= 1'b0; // not ready to output data now
					if (!rx_sync) begin // start bit detected
						start_counter <= '0;
						state <= START;
					end
				end
				DATA: begin
					shift_reg <= {rx_sync, shift_reg[7:1]}; // lsb first
					if (bit_count == 3'd7) begin // if gone thru all bits
						state <= STOP; // next state
					end
					bit_count <= bit_count+1; // iter bit count
				end
				STOP: begin
					if (rx_sync) begin // stop bit
						rx_ready <= 1'b1; // data ready to be read again
					end else begin
						rx_ready <= 1'b0; // framing error
					end
					state <= IDLE;
				end
			endcase
		end
	end
endmodule