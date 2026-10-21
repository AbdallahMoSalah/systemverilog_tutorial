//=============================================================================
// Question 3: Dynamic Casting ($cast) in SystemVerilog
//
// Q3: Convert the static casting in Q1 and Q2 to dynamic casting
//     - Dynamic cast byte to int
//     - Dynamic cast enum element to time
//=============================================================================

module casting_dynamic;

  // Variables for Q1 converted to dynamic cast
  byte b_var;
  int  i_var;

  // Enum definition of type integer (from Q2)
   enum integer {
    IDLE  = 10,
    START = 50,
    DONE  = 100
  } state_var;

  time    time_var;

  initial begin

    // Dynamic cast from byte to int
    b_var = 8'd25;

    if ($cast(i_var, b_var)) begin
      $display("Dynamic cast succeeded!");
      $display("Original byte value : %0d", b_var);
      $display("Cast to int value   : %0d", i_var);
    end else begin
      $display("Dynamic cast failed!");
    end

    // ----------------------------------------------------
    // Converting Q2: Dynamic cast from enum element to time
    // ----------------------------------------------------
    state_var = START;

    $display("\n--- Q3 [Part 2]: Dynamic Cast (enum element to time) ---");
    if ($cast(time_var, state_var)) begin
      $display("Dynamic cast succeeded!");
      $display("Enum element        : %s (value = %0d)", state_var.name(), START);
      $display("Cast to time value  : %0t", time_var);
    end else begin
      $fatal("Dynamic cast failed!");
    end

    $display("==================================================");
  end

endmodule
