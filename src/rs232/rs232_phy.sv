// RS-232 voltage levels (+3V to +15V for '0', -3V to -15V for '1')
module rs232_phy (
    input  logic uart_tx,      // UART output (1=high, 0=low)
    output logic rs232_tx,     // RS-232 output
    input  logic rs232_rx,     // RS-232 input
    output logic uart_rx       // UART input
);
    // tx path (UART to RS-232)
    assign rs232_tx = uart_tx ? -12 : +12;  // sim voltages (within threshold)
    
    // rx path (RS-232 to UART)
    assign uart_rx = (rs232_rx < -3);  // threshold detection
    
    // sim assertions
    always @(*) begin
        if (rs232_tx !== 12 && rs232_tx !== -12) 
            $warning("Invalid RS-232 TX voltage: %0d", rs232_tx);
    end
endmodule