module tb_uart_rx;

  // signals
  logic clk;
  logic rst_n;
  logic baud_tick;
  logic rx_in;
  logic [7:0] shift_reg;
  logic rx_ready;

  // instantiate rx module
  uart_rx uut (
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick(baud_tick),
    .rx_in(rx_in),
    .shift_reg(shift_reg),
    .rx_ready(rx_ready)
  );

  // clk gen
  always #5 clk = ~clk;

  // input for rx
  initial begin
    // init signals
    clk = 0;
    rst_n = 0;
    baud_tick = 0;
    rx_in = 1; // idle state for UART

    // reset
    #10 rst_n = 1;
    
    // sim data transfer with 8 bits + start and stop
    // case 1: 0xA5 = 10100101
    #10 uart_receive(1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1);
    
    // case 2: all 0s
    #10 uart_receive(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
    
    // case 3: all 1s
    #10 uart_receive(1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1);
	 $finish;
  end
  
  // sim baud ticks (div = 10)
  always begin
    #45 baud_tick = 0;
    #5 baud_tick = 1;
  end
  
  // sim rx_in signal
  task uart_receive(input logic b7, b6, b5, b4, b3, b2, b1, b0);
    begin
      // start bit
      @(posedge baud_tick); rx_in = 0; // 1 baud cycle to simulate the start bit
      
      // data (lsb first)
      @(posedge baud_tick); rx_in = b0;
      @(posedge baud_tick); rx_in = b1;
      @(posedge baud_tick); rx_in = b2;
      @(posedge baud_tick); rx_in = b3; 
      @(posedge baud_tick); rx_in = b4;
      @(posedge baud_tick); rx_in = b5;
      @(posedge baud_tick); rx_in = b6;
      @(posedge baud_tick); rx_in = b7;
      
      // stop bit
      rx_in = 1; 
      #100; // hold for some time
    end
  endtask

  // monitor outputs
  initial begin
    $monitor("Time: %t | rx_in: %b | shift_reg: %h | rx_ready: %b", 
             $time, rx_in, shift_reg, rx_ready);
  end

endmodule
