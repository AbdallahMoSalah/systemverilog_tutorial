module enum2;

  typedef time my_time_t;

  typedef enum my_time_t {
    T1 = 1032,
    T2 = 2003,
    T3 = 2004,
    T4 = 5000
  } time_enum_e;

  time_enum_e time_val;

  initial begin
    time_val = time_val.first();
    for (int i = 0; i < 4; i++) begin
      $display("Name: %-8s | Value: %0d", time_val.name(), time_val);
      time_val = time_val.next();
    end
  end

endmodule
