//=============================================================================
// Question 2: SystemVerilog Task with Arguments and Display Statements
// 
// Requirements:
// 1. Convert the function from Q1 to a task.
// 2. Display "hello" or "hi" directly inside the task instead of returning them.
// 3. Called from an initial block with values satisfying both conditions.
//=============================================================================

module q2_task;

  // Task definition (converted from function)
  task check_sum_task(input integer a, input byte b);
    integer sum;
    sum = a + b;

    if (sum > 10) begin
      $display("hello");
    end else begin
      $display("hi");
    end
  endtask

  // initial block and testing 
  initial begin
    integer       val_int;
    byte          val_byte;


    // Test Case 1: Sum > 10 (Task displays "hello")
    
    val_int  = 9;
    val_byte = 4; // 9 + 4 = 13 (> 10)
    check_sum_task(val_int, val_byte);


    // Test Case 2: Sum <= 10 (Task displays "hi")
    
    val_int  = 2;
    val_byte = 5; // 2 + 5 = 7 (<= 10)
    check_sum_task(val_int, val_byte);

    $display("==================================================");
  end

endmodule
