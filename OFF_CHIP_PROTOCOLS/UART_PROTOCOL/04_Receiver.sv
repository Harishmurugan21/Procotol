//receiver module

module rx #(parameter data_len,parity_type) (
  input logic clk,
  input logic rst,
  input logic tx_in,     //tx to rx bus line;
  input logic baud_tick_rx,
  output logic rx_done,
  output logic [data_len-1:0] rx_out);
  
  
  typedef  enum {idle,start,data,parity,stop} states;
  

  logic [$clog2(data_len)-1:0] data_state_counter;
  logic [3:0] counter; //for oversampling;
  logic [data_len-1:0] shift_reg;   //according to frame length parameter;
  
  //for checking
  logic parity_bit;

  
  states  state,ns_state;
  always_ff @(posedge clk or posedge rst)begin
    if (rst)begin
      state<=idle;
      data_state_counter<=0;
      counter<=0;
      shift_reg<=0;  
    end
    else begin
      if(baud_tick_rx) begin
      state<=ns_state;
        
        if(state!=ns_state)
          counter<='0;
        
        case(state)  
          idle:begin
            data_state_counter<='0;
            counter<='0;
          end
          
          start:begin
            if(counter==7)
              counter<='0;
            else
              counter<=counter+1;
          end
          
          data:begin
            if (counter==15)begin
              data_state_counter<=data_state_counter+1;
              shift_reg<={tx_in, shift_reg[data_len-1:1]};
              counter<='0;
            end
            else
              counter++;
          end
          
          parity:begin
            if (counter==15)begin
              parity_bit<=(parity_type)?(tx_in==(^shift_reg)):(tx_in==(~^shift_reg));
            end
            else counter<=counter+1;
          end
          
          stop:begin
              counter<=counter+1;
          end
          
        endcase
      end
    end
  end
            

          
 //combination logic to select ns_state depending on the input; 
  always_comb begin
    ns_state=state;
    rx_done=0;
    case(state)
      
      idle:begin
        if(!tx_in)
          ns_state=start;
        else begin
          ns_state=idle;
          //rx_done=0;
        end
      end
      
      
        
      start:begin	//upto 8 count to reach mid bit sampling of start bit;
        if (counter==7)begin
          if (!tx_in)begin
            ns_state=data;
          	//reload the counter to zero;
          end
           else begin
              ns_state=idle;  //if tx_in start bit !=0 at mid bit sapling of start bit.
            end
          end
        else begin  	
          ns_state=start;
        end
      end
           
   
        //data state;
        data:begin
          if (counter == 15 && data_state_counter == data_len-1)begin
            ns_state=parity;
            //reload the data state counting counter;
          end   
          else
            ns_state=data;
        end
           
        
        parity:begin
          if (counter==15)begin
            ns_state=stop;        
          end
          else
              ns_state=parity; 
        end
        
        stop:begin
          if (counter==15) begin
            if (tx_in) begin
              ns_state=idle;
              rx_done=1;
            end
            else begin
              ns_state=idle;		//invalid stop bid -->framing error;
            end
          end
          else
            ns_state=stop;
        end     
    endcase
    
  end
  
 
 // assign rx_out=(rx_done&&parity_bit)?shift_reg:'0;
  always_ff @(posedge clk) begin
  if (rx_done && parity_bit)
    rx_out <= shift_reg;
end
endmodule















