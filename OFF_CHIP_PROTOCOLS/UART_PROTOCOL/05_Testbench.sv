module uart_tb();
  
  parameter data_len=8;          //data_bits length;
  parameter clk_freq=50000000;	 //50 mhz
  parameter baud_rate=9600;
  parameter parity_type=1; 	     //1--->even ,0-->odd parity type
  
  
   logic clk;		                 //common  system clk  eg:50mhz;-->10ns
   logic rst;
   logic tx_start;
   logic [data_len-1:0] tx_data;
  
   logic tx_out;	//tx pin
   logic tx_done;
   logic baud_tick_tx;
   logic rx_done;
   logic [data_len-1:0] rx_data_out;
  
  //dut 
  uart_protocol  #(data_len,clk_freq,baud_rate,parity_type) dut (clk,rst,tx_start,tx_data,baud_tick_tx,tx_out,tx_done,rx_done,rx_data_out);
  
  //common system clk generation here for both tx and rx
  initial begin
    clk=0;
    forever #10 clk=~clk;   //clk_period=20   -->50mhz clk;
  end
  
  
  initial begin  
    $monitor("time=%0t| tx_start=%b | tx_data=%0d| tx_out=%b| tx_done=%b| rx_done=%b| rx_data_out=(%d)%b |tx_state=%s ",$time,tx_start,tx_data,tx_out,tx_done,rx_done,rx_data_out,rx_data_out,dut.dut_tx.state);
    $dumpfile("wave.vcd");
    $dumpvars();
  end
  
initial begin
  rst = 1;
  tx_start = 0;
  tx_data = 0;
  #20 rst = 0;
  
  repeat (3) begin
    //tx_data=$random;
    send_byte();
  end
end

  
  task send_byte();
    logic [7:1] data;
begin
  data=$random;
  @(posedge baud_tick_tx);
  tx_data  <= data;
  tx_start <= 1;
  @(posedge clk);
  tx_start <= 0;   
  @(posedge tx_done);
  //@(posedge baud_tick_tx);  //for go to idle 
end
endtask
  
endmodule

  
  
  
  
    
    
      
      
      
      
      
    
    
  
  
  
  
  
  
  

  
 
  
  
  
  

  
  
  
    
    
      
      
      
      
      
    
    
  
  
  
  
  
  
  

  
 
  
  
  
  
