`timescale 1ns/1ps

module tb_rs232_phy;

    // in
    logic uart_tx;
    logic rs232_rx;

    // out
    logic rs232_tx;
    logic uart_rx;

    // instantiate
    rs232_phy dut (
        .uart_tx(uart_tx),
        .rs232_tx(rs232_tx),
        .rs232_rx(rs232_rx),
        .uart_rx(uart_rx)
    );

    // test uart to rs232
    task test_uart_to_rs232(input logic uart_val, input integer expected_voltage);
        begin
            uart_tx = uart_val;
            #1;  // small delay to propagate
            if (rs232_tx !== expected_voltage) begin
                $error("UART->RS232 FAILED: uart_tx=%b expected rs232_tx=%0d, got %0d",
                       uart_val, expected_voltage, rs232_tx);
            end else begin
                $display("UART->RS232 PASSED: uart_tx=%b -> rs232_tx=%0d", uart_val, rs232_tx);
            end
        end
    endtask

    // test rs232 to uart
    task test_rs232_to_uart(input integer rs232_val, input logic expected_uart);
        begin
            rs232_rx = rs232_val;
            #1;
            if (uart_rx !== expected_uart) begin
                $error("RS232->UART FAILED: rs232_rx=%0d expected uart_rx=%b, got %b",
                       rs232_val, expected_uart, uart_rx);
            end else begin
                $display("RS232->UART PASSED: rs232_rx=%0d -> uart_rx=%b", rs232_val, uart_rx);
            end
        end
    endtask

    // test begin
    initial begin
        $display("Starting RS-232 PHY test...");

        // === UART to RS-232 Tests ===
        test_uart_to_rs232(1'b1, -12);  // uart high 
        test_uart_to_rs232(1'b0, +12);  // uart low

        // === RS-232 to UART Tests ===
        test_rs232_to_uart(-12, 1'b1);  // rs232 low
        test_rs232_to_uart(-3, 1'b0);   // threshold (edge case)
        test_rs232_to_uart(+12, 1'b0);  // rs232 high
        test_rs232_to_uart(0, 1'b0);    // in the undefined region, should map to 0

        // invalid voltage
        uart_tx = 1'bx;  // undefined input
        #1;

        $display("tests complete");
        $finish;
    end

endmodule