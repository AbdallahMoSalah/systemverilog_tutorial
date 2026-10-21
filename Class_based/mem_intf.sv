interface mem_intf(input clk);
   logic rst_n;
   logic [31:0] Data_in;
   logic WE,EN;
   logic [3:0] Address;
   logic [31:0] Data_out;
   logic Valid_out;
   
   clocking cb @(posedge clk);
      default input #1step output #0;
      output Data_in,WE,EN,Address;
      input Data_out,Valid_out;
   endclocking

   modport tb(clocking cb,output rst_n);
   
   
endinterface