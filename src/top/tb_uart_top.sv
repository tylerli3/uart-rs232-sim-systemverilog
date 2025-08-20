`timescale 1ns/1ps

module tb_uart_top;

    // signals
    logic clk;
    logic rst_n;

    // uart signals
    logic [7:0] tx_data;
    logic tx_start;
    logic tx_busy;
    logic [7:0] rx_data;
    logic rx_ready;

    // rs232 lines
    logic rs232_tx;
    logic rs232_rx;

    // clk gen
    always #50 clk = ~clk;  // 100 ns period = 10 MHz

    // DUT
    uart_top #(
        .CLK_FREQ(10_000_000),
        .BAUD_RATE(1_000_000)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .rs232_tx(rs232_tx),
        .rs232_rx(rs232_rx)
    );

    // test vars
    byte tx_test_data = 8'hA5;
    logic rx_received = 0;

    initial begin
        // init signals
        clk = 0;
        rst_n = 0;
        tx_data = 8'h00;
        tx_start = 0;

        // reset 
        #200;
        rst_n = 1;

        // loopback: connect TX to RX
        assign rs232_rx = rs232_tx;

        // wait for reset
        #500;

        // send byte
        $display("[%0t] Sending byte: 0x%02X", $time, tx_test_data);
        tx_data = tx_test_data;
        tx_start = 1;
        #100;           // 1 clock
        tx_start = 0;

        // wait for transmission + reception
        wait (rx_ready);
        rx_received = 1;

        // delay
        #100;

        if (rx_data == tx_test_data) begin
            $display("[%0t] PASS: Received byte matches: 0x%02X", $time, rx_data);
        end else begin
            $display("[%0t] FAIL: Expected 0x%02X, got 0x%02X", $time, tx_test_data, rx_data);
        end

        #200;
        $finish;
    end

endmodule