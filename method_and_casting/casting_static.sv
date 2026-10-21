//=============================================================================

module casting_static;

  // Q1 Variables
  byte b_var;
  int  i_var;

  // Q2 Enum definition of type integer
   enum integer {
    IDLE  = 10,
    START = 50,
    DONE  = 100
  } state_var;

  time    time_var;

  initial begin


    // Q1: Static cast from byte to int

    b_var = 8'd25;
    i_var = int'(b_var); // static cast

    $display("Original byte value : %0d", b_var);
    $display("Cast to int value   : %0d", i_var);

    // ----------------------------------------------------
    // Q2: Static cast from enum element to time
    // ----------------------------------------------------
    state_var = START;
    time_var  = time'(state_var); // static cast of enum element to time

    $display("Enum element        : %s (value = %0d)", state_var.name(), START);
    $display("Cast to time value  : %0t", time_var);

  end

endmodule
