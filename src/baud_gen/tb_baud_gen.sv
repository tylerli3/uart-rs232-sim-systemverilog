`timescale 1ns/1ps

module tb_baud_gen;

    // params
    localparam DIVIDER = 10;     // tick every 10 clock cycles
    localparam CLK_PERIOD = 10;  // clock = 100 MHz

    // tb io
    logic clk;
    logic rst_n;
    logic tick;

    // init dut
    baud_gen #(.DIVIDER(DIVIDER)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick)
    );

    // clk gen
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        // init rst signal
        rst_n = 0;

        // hold reset first
        #(CLK_PERIOD*20);
        rst_n = 1;

        // let baud run
        #(CLK_PERIOD*105);

		  // reset at async interval
		  rst_n = 0;
        #(CLK_PERIOD*25); 
		  
		  //test baud again from rst
		  rst_n = 1;
        #(CLK_PERIOD*100);
		 
        // End simulation
        $finish;
    end

    // Monitor output
    initial begin
        $display("Time\tTick");
        $monitor("%0t\t%b", $time, tick);
    end

endmodule
