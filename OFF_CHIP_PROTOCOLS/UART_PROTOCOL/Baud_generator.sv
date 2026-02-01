module baud_gen #(parameter clk_freq, baud_rate) (input logic clk,	//system clk ->50mhz->20 ns clkp
                 input logic rst,
                 output logic baud_tick_tx,   //one en_pulse;
                 output logic baud_tick_rx);  //for rx;
  
  
  //baude tick gen for -->tx
  integer count1=(clk_freq/baud_rate);
  integer counter_tx;
  
  always_ff @(posedge clk)begin
    if (rst)begin
      baud_tick_tx<=0;
      counter_tx<=0;
    end
    else begin
      if (counter_tx==count1-1)begin
        baud_tick_tx<=1;		//baud_tick signal enable for cycle of system clock;
        counter_tx<=0;
      end
      else begin
        counter_tx<=counter_tx+1;
        baud_tick_tx<=0;
      end
      
    end
  end	
  
  
  
  
  //for receiver  16 X oversampling baud_tick generation;
   
  integer count2=(clk_freq/(baud_rate*16));	//16xoversampling baud_tick generation to sampling at mid bit;
  integer counter_rx;
  
  always_ff @(posedge clk)begin
    if (rst)begin
      baud_tick_rx<=0;
      counter_rx<=0;
    end
    else begin
      if (counter_rx==count2-1)begin
        baud_tick_rx<=1;		//baud_tick signal enable for cycle of system clock;
        counter_rx<=0;
      end
      else begin
        counter_rx<=counter_rx+1;
        baud_tick_rx<=0;
      end
      
    end
  end	
    
    
    
    
endmodule
      
        
        
    
    
  
  
  
  
  
  
  
  
  
  
