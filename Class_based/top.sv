`timescale 1ns/1ps

module top;
   logic clk;

   // Clock generation: 100MHz (10ns period, 5ns half-period)
   initial begin
      clk = 1'b0;
      forever #5 clk = ~clk;
   end

   // Instantiate interface
   mem_intf intf(clk);

   // Instantiate DUT
   Memory16x32 dut (
      .clk       (clk),
      .rst_n     (intf.rst_n),
      .Data_in   (intf.Data_in),
      .WE        (intf.WE),
      .EN        (intf.EN),
      .Address   (intf.Address),
      .Data_out  (intf.Data_out),
      .Valid_out (intf.Valid_out)
   );

   // Test execution
   initial begin
      test_class test;
      test = new(intf.tb);
      test.run();
      #20;
      $display("\n============================================");
      $display("     ALL TESTS COMPLETED SUCCESSFULLY");
      $display("============================================\n");
      $finish;
   end

endmodule
