module mid1 ();

initial begin
   $display("%m");
end
generate;
   for (genvar i=0; i<3; ++i) begin :botgen1
      bot1 bot1 ();   
   end
endgenerate
endmodule