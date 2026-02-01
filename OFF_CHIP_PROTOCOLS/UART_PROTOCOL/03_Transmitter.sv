module tx #(parameter data_len,parity_type ) (
  input logic clk,
  input logic rst,
  input logic tx_start,
  input logic [data_len-1:0] tx_data,
  input logic baud_tick_tx,
  output logic tx_done,
  output logic tx_out);

  
  typedef enum {idle,start,data,parity,stop} states;
  

  logic [$clog2(data_len)-1:0] data_state_counter;
  logic [data_len-1:0] shift_reg;
  logic parity_bit;
	 
  states state,ns_state;
  
  always_ff @(posedge clk or posedge rst)begin     //to make it work in synchronous to local clk system
    if (rst)begin
      state<=idle;
      data_state_counter<=0;    //to count the repeat stay in the same state according to data length;
      shift_reg<='0;
      
    end  
    else begin
      if (baud_tick_tx) begin
      state<=ns_state;
      
      case(state) 
        idle:begin
          if (tx_start) begin
            //shift_reg<=tx_data;
            data_state_counter<=0;  	//make the counter zere bsfore sending data frame;
            //parity_bit<=(parity_type) ? (^tx_data) : (~^tx_data);
          end
        end
          
        start:begin
          shift_reg<=tx_data;
          parity_bit<=(parity_type) ? (^tx_data) : (~^tx_data);
        end
        
        data:begin
         	data_state_counter<=data_state_counter+1; 
          	shift_reg <= {0, shift_reg[data_len-1:1]};	//left shift by 1;
          
        end
        
        stop:begin
          data_state_counter<='0;
        end
        
      endcase
      end
    end
  end

  //combinational logic to identify the next next:        
  always_comb begin
    tx_out=1;
    tx_done=0;
    ns_state=state;
    case(state)

        idle:begin
          tx_done=0;
          if(tx_start)begin
             ns_state=start;
             //shift_reg=tx_data; //load the tx_data parallely to shift reg ;      		 
          end
          else begin
             ns_state=idle;
          end   
        end
      
      	start:begin
          tx_out=0;
          ns_state=data;          
        end
      
        data:begin
           tx_out = shift_reg[0];   
          if (data_state_counter==data_len-1)begin
          ns_state=parity;       
          end 
          else         
            ns_state=data;       
        end

          parity:begin
            ns_state=stop;
            tx_out=parity_bit;
          end

          stop:begin
            ns_state=idle;
            tx_out=1;
            tx_done=1; 	//indicated that transaction completed;
            if(tx_start)
              ns_state=start;
          end    
    endcase
    
  end
endmodule
     
          




















































