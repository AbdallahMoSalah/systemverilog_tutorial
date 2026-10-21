//=============================================================================
// Question 1: SystemVerilog Function with Arguments and String Return
// 
// Requirements:
// 1. Define a function that accepts two arguments (integer and byte) and returns a string.
// 2. The method displays both variables and adds them.
// 3. If sum > 10, returns "hello"; otherwise displays "hi" (and returns "hi").
// 4. Called from an initial block with values satisfying both conditions.
//=============================================================================

module q1_function;

  // Function definition
  function string check_sum(integer a, byte b);
    integer sum;
    sum = a + b;

    if (sum > 10) begin
      return "hello";
    end else begin
      $display("hi");
      return "hi";
    end
  endfunction

  // initail block and testing 
  initial begin
  string res;
  integer val_int;
  byte val_byte;

  val_int = 7;
  val_byte = 8;

  // function call 1 (method call)

  res = check_sum(val_int, val_byte);

  $display("result  :%s", res);


  val_int = 2;
  val_byte = 5;

  // function call 2 (method call)

  res = check_sum(val_int, val_byte);

  $display("result 2 :%s", res);

  $display("==================================================");
  end
endmodule
