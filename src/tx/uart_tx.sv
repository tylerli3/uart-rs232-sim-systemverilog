module uart_tx (
    input  logic clk,
    input  logic rst_n,
    input  logic baud_tick,
    input  logic [7:0] tx_data,
    input  logic tx_start,
    output logic tx_busy,
    output logic tx_out
);

typedef enum logic [2:0] { // states
        IDLE,
        START,
        DATA,
        STOP
    } state_t;
	 
	 state_t state; // for fsm
	 logic [7:0] shift_reg; // data
	 logic [2:0] bit_count; // track how much data sent out
	 
	 always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin // reset
			// set to defaults
			state <= IDLE;
			tx_out <= 1'b1; // idle high
			tx_busy <= 1'b0;
			shift_reg <= '0;
			bit_count <= '0;
		end else if (baud_tick) begin
			case (state)
				IDLE: begin
					tx_out <= 1'b1;
					if (tx_start) begin // send data
						state <= START;
						shift_reg <= tx_data;
						tx_busy <= 1'b1;
					end
				end
				
				START: begin
					state <= DATA;
					bit_count <= '0;
					tx_out <= 1'b0; // start bit, held for 1 baud
				end
				
				DATA: begin
					tx_out <= shift_reg[0]; // lsb first
					shift_reg <= shift_reg >> 1; // right shift 1
					if (bit_count == 3'd7) begin // sent all 8 bits
						state <= STOP;
					end
					bit_count <= bit_count + 1;
				end
				
				STOP: begin
					state <= IDLE; 
					tx_out <= 1'b1; // stop bit
					tx_busy <= 1'b0;
				end
			endcase
		end
	 end

endmodule