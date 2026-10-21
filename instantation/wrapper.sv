module wrapper #(
   parameter p1 = 20
) ();


initial begin
   $display("%m");
end
generate;
   if (p1 == 10) begin : botgen2
      bot2 bot2_1 ();
   end
   else if (p1 == 20) begin : botgen3
      bot3 bot3_1 ();
   end
endgenerate
      bind mid1 mid2 bind1 ();

endmodule