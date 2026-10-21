module top #(
    parameter p1 = 10
) ();
initial begin
   $display("%m");
   
end

generate;
   if (p1==20) begin :midgen1
      mid1 mid1_1 ();   
   end
   else if (p1==10) begin :midgen2
      mid2 mid2_1 ();
   end
      
endgenerate

endmodule