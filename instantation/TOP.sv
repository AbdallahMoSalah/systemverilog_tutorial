module TOP();
initial begin
   $display("%m");
end

parameter p1 = 20;
wrapper #( 
   .p1 ( p1 ) 
) wrapper_1 ();
top #( 
   .p1 ( p1 ) 
) top_1 ();

endmodule


/*
 TOP


# TOP.wrapper_1

# TOP.wrapper_1.botgen2.bot2_1

# TOP.top_1

# TOP.top_1.||midgen1|| ||.mid1_1
# TOP.top_1.||midgen1|| ||.mid1_1||.botgen1[0].bot1
# TOP.top_1.||midgen1|| ||.mid1_1||.botgen1[1].bot1
# TOP.top_1.||midgen1|| ||.mid1_1||.botgen1[2].bot1

# TOP.top_1.||midgen1|| ||.mid1_1||.bind1
# TOP.top_1.||midgen1|| ||.mid1_1||.bind1.bot1_arr[0]
# TOP.top_1.||midgen1|| ||.mid1_1||.bind1.bot1_arr[1]
# TOP.top_1.||midgen1|| ||.mid1_1||.bind1.bot1_arr[2]

*/