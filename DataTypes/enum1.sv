module enum1;

  enum integer {
    S0 = 0,
    S5 = 5,
    S7 = 7,
    S9 = 9
  } my_state;

  initial begin
    my_state = my_state.first();
    $display("First element: %-4s | Value: %0d", my_state.name(), my_state);

    $display("Enum size (num): %0d", my_state.num());
  end

endmodule
