`include "Baud_rate_gen.sv"
`include "Transmitter.sv"
`include "Receiver.sv"

module uart_protocol #(parameter data_len,clk_freq,baud_rate,parity_type) 
  (input logic clk,		//common  system clk  eg:50mhz;-->20ns
  input logic rst,
  input logic tx_start,
  input logic [data_len-1:0] tx_data,
  output logic baud_tick_tx,
  output logic tx_out,	//tx pin
  output logic tx_done,
  
  output logic rx_done,
  output logic [data_len-1:0] rx_data_out
   
);
  
  
  
  //logic baud_tick_tx;
  logic baud_tick_rx;
  //baud_generator;
  baud_gen #(clk_freq,baud_rate) gen (.clk(clk),
                 .rst(rst),
                 .baud_tick_tx(baud_tick_tx),
                 .baud_tick_rx(baud_tick_rx));
  
  
  //transamitter module;
  tx #(data_len,parity_type) dut_tx (.clk(clk),.rst(rst),
                         .tx_start(tx_start),
                         .tx_data(tx_data),
                         .baud_tick_tx(baud_tick_tx),
                         .tx_done(tx_done),
                         .tx_out(tx_out));
  //receiver module
  rx #(data_len,parity_type) dut_rx  (.clk(clk),.rst(rst),
                          .tx_in(tx_out),
                          .baud_tick_rx(baud_tick_rx),
                          .rx_done(rx_done),
                          .rx_out(rx_data_out));
  
  
endmodule
                          
                         
                         
                
  
                 
