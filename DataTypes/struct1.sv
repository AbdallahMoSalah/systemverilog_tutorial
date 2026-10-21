module struct1;

  // Define an unpacked struct with the required elements
  struct {
    string  str;
    integer i;
    byte    b;
    // Packed struct of size 6 bits (3 bits + 3 bits = 6 bits)
    struct packed {
      bit [2:0] p1;
      bit [2:0] p2;
    } p_struct;
    // Unpacked struct of elements (event, real variable)
    struct {
      event e;
      real  r;
    } unp_struct;
  } my_struct;

  event ev;

  initial begin
    // Assign the data in the real variable in the nested struct using dot operator
    my_struct.unp_struct.r = 3.14159;
    $display("1. Assigned real via dot operator: %0f", my_struct.unp_struct.r);

    // Use named assignment pattern to assign the whole unpacked structure
    my_struct = '{
      str:        "Verification Lab",
      i:          100,
      b:          8'hA5,
      p_struct:   '{p1: 3'b101, p2: 3'b011},
      unp_struct: '{e: ev, r: 2.71828}
    };

    $display("\n2. Structure elements after named assignment pattern:");
    $display("String: %s", my_struct.str);
    $display("Integer: %0d", my_struct.i);
    $display("Byte: 8'h%0h", my_struct.b);
    $display("Packed struct (6 bits): %0b (p1=%0b, p2=%0b)", my_struct.p_struct, my_struct.p_struct.p1, my_struct.p_struct.p2);
    $display("Nested real: %0f", my_struct.unp_struct.r);
    $display("Was event triggered? %0b", my_struct.unp_struct.e.triggered);

  end

endmodule
