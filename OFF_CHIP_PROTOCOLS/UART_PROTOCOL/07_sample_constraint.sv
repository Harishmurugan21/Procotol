//class and constraint layering method for verification;:
class uart_configuration;
  
  rand int baud_rate;
  rand int data_bits;
  rand bit parity;		//0-->odd  |  1-->even parity
  
  
  constraint baud_c{
    baud_rate inside {9600,19200,57600};
  }
  constraint bit_count{
    data_bits inside {6,7,8};
  }
  
  constraint limit_c{
    baud_rate==57600->data_bits==6;
  }
endclass

class uart_transaction;
  rand byte data;
  int data_bits;
  
  function new (uart_configuration cfg);
    data_bits=cfg.data_bits;
  endfunction

  
  constraint data_config{
    data_bits==6->data inside {[0:63]};
    data_bits==7->data inside {[0:127]};
    data_bits==8->data inside {[0:255]};
  }
  
endclass

module uart_v;
  uart_configuration cfg;
  uart_transaction tr;
  initial begin
    repeat (3)begin
      cfg=new();
      cfg.randomize();
      $display("config:%p:",cfg);
      repeat (10)begin
        tr=new(cfg);
        tr.randomize();
        $display(" uart_data:%b",tr.data);
      end
    end
  end
endmodule
    
        
      
  
  
                     
  
