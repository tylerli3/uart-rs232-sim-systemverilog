module uart_top #(
    parameter CLK_FREQ  = 10_000_000, // 10 MHz
    parameter BAUD_RATE = 1_000_000, // 1 Mbps
    parameter DIVIDER   = CLK_FREQ / BAUD_RATE // 10 for this sim
) (
    input  logic clk,
    input  logic rst_n,
    // UART interface
    input  logic [7:0] tx_data,
    input  logic tx_start,
    output logic tx_busy,
    output logic [7:0] rx_data,
    output logic rx_ready,
    // RS-232 physical interface
    output logic rs232_tx,
    input  logic rs232_rx
);

    // internal signals
    logic baud_tick;
    logic uart_tx_out;
    logic uart_rx_in;
    logic [7:0] rx_shift_reg;
    
    // baud gen
    baud_gen #(.DIVIDER(DIVIDER)) u_baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .tick(baud_tick)
    );
    
    // UART transmitter
    uart_tx u_tx (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_out(uart_tx_out)
    );
    
    // UART receiver
    uart_rx #(.DIVIDER(DIVIDER)) u_rx (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .rx_in(uart_rx_in),
        .shift_reg(rx_shift_reg),
        .rx_ready(rx_ready)
    );
    
    assign rx_data = rx_shift_reg; // connect rx shift register to rx output
    
    // rs232 phy layer voltage conversion
    rs232_phy u_rs232_phy (
        .uart_tx(uart_tx_out),
        .rs232_tx(rs232_tx),
        .rs232_rx(rs232_rx),
        .uart_rx(uart_rx_in)
    );
    
endmodule