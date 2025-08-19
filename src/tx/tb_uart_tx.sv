`timescale 1ns/1ps

module tb_uart_tx;

    // in
    logic clk;
    logic rst_n;
    logic baud_tick;
    logic [7:0] tx_data;
    logic tx_start;
	 // out
    logic tx_busy;
    logic tx_out;

    // instantiate tx
    uart_tx uut (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_out(tx_out)
    );

	// clk gen
	always #5 clk = ~clk;

	// sim baud ticks (div = 10)
	always begin
   #45 baud_tick = 0;
   #5 baud_tick = 1;
	end

    // task to send byte
    task send_byte(input [7:0] data);
        begin
            wait (!tx_busy);
            tx_data = data;
            tx_start = 1;
            @(posedge clk);
            tx_start = 0;

            wait (tx_busy == 1);
            wait (tx_busy == 0);
            $display("[%0t ns] Sent byte: 0x%0h", $time, data);
        end
    endtask

    // main test
    initial begin
        $display("starting tx test");
        clk = 0;
        rst_n = 0;
        tx_start = 0;
        tx_data = 8'h00;

        // rst
        #100;
        rst_n = 1;

        // wait before starting
        #500;

        // test 1: single byte
        send_byte(8'hA5);  // 10100101

        // test 2: more bytes
        send_byte(8'h00);  // all zeros
        send_byte(8'hFF);  // All ones
        send_byte(8'h3C);  // 00111100

        // test 3: signal during busy
        tx_data = 8'h77;
        tx_start = 1;
        @(posedge clk);  // attempt to start while idle
        tx_start = 0;

        // mid transmission, trigger another start (should not affect current tx)
        #5000;
        tx_data = 8'hB2;
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        // wait for all transmissions to finish
        wait (!tx_busy);
        #2000;

        $display("tx test completed");
        $finish;
    end

    // tx out monitor
    initial begin
        $display("Time\tTX_OUT");
        $monitor("%0t\t%b", $time, tx_out);
    end

endmodule
