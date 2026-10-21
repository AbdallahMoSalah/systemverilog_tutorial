
`define DISPLAY_TWO_VARS(arg1, arg2) \
initial begin \
    $display("[MACRO $display 1] First  Argument: %0d", arg1); \
    $display("[MACRO $display 2] Second Argument: %0d", arg2); \
end

module top;
    // Two variables x & y
    int x = 42;
    int y = 100;

    // Expand the initial block by invoking the macro with arguments x and y
    `DISPLAY_TWO_VARS(x, y)
// $display ("%m [MACRO $display 1] First  Argument: %0d", x); 
// $display ("%m [MACRO $display 2] Second Argument: %0d", y); 
endmodule
