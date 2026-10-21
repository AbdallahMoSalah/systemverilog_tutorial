class test_class;
   virtual mem_intf.tb tb;

   function new(virtual mem_intf.tb tb);
      this.tb = tb;
   endfunction //new()
   
   bit [31:0] data[int] = '{default: 32'h0};

   task run();
      reset();
      
      writeAwait(32'hDEAD_BEEF, 4'b101);
      writeAwait(32'hCAFE_F00D, 4'b010);
      
      readandcheck(4'b101);
      readandcheck(4'b010);
      readandcheck(4'b111); // Test unwritten location (expected 0)
   endtask //run()

   task reset();
      tb.cb.Data_in <= 32'b0;
      tb.cb.WE      <= 1'b0;
      tb.cb.EN      <= 1'b0;
      tb.cb.Address <= 4'b0;
      tb.rst_n       = 1'b0;
      repeat(2) @(tb.cb);
      tb.rst_n       = 1'b1;
      @(tb.cb);
   endtask //reset()

   task writeAwait(input [31:0] data, input [3:0] addr);
      tb.cb.EN      <= 1'b1;
      tb.cb.WE      <= 1'b1;
      tb.cb.Data_in <= data;
      tb.cb.Address <= addr;
      @(tb.cb);
      this.data[addr] = data;
      tb.cb.WE      <= 1'b0;
      tb.cb.EN      <= 1'b0;
      tb.cb.Address <= 4'b0;
      tb.cb.Data_in <= 32'b0;
      @(tb.cb);
   endtask //writeAwait()
   
   task readandcheck(input [3:0] addr);
      bit [31:0] exp_data;
      // drive read 
      tb.cb.EN      <= 1'b1;
      tb.cb.WE      <= 1'b0;
      tb.cb.Address <= addr;
      @(tb.cb);
      // output is ready & drive idle 
      tb.cb.EN      <= 1'b0;
      tb.cb.WE      <= 1'b0;
      tb.cb.Address <= 4'b0;
      @(tb.cb); // any DUT_output is sampled just before posedge clk 
      exp_data = this.data[addr];

      if (!tb.cb.Valid_out) begin
         $display("ERROR: Valid_out is low at addr 0x%0h!", addr);
      end

      if (tb.cb.Data_out !== exp_data) begin
         $display("ERROR: Read mismatch at addr 0x%0h | Expected: 0x%08h, Got: 0x%08h", 
                  addr, exp_data, tb.cb.Data_out);
      end
      else if (tb.cb.Valid_out) begin
         $display("SUCCESS: Read match at addr 0x%0h | Data: 0x%08h (Valid_out=1)", 
                  addr, tb.cb.Data_out);
      end
   endtask //readandcheck()
   
endclass 