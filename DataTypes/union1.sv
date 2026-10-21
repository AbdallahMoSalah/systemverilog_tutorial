module union1;

  // Unpacked union (without the 'packed' keyword)
  union {
    // Packed struct of 3 elements divided equally on size (30 bits)
    // 30 / 3 = 10 bits each
    struct packed {
      bit [9:0] elem1;
      bit [9:0] elem2;
      bit [9:0] elem3;
    } p_struct;

    // Packed array of size 30 bits
    bit [29:0] p_arr;
  } my_union;

  initial begin
    // 1. Assign the data using the dot operator using the packed array of size 30 bits
    my_union.p_arr = 30'b1010101010_1100110011_1111100000;
    $display("1. Assigned 30-bit packed array via dot operator:");
    $display("my_union.p_arr = 30'b%30b ", my_union.p_arr, my_union.p_arr);

    // 2. Read the data using dot operator accessing the struct elements
    $display("\n2. Reading through struct elements via dot operator:");
    $display("my_union.p_struct.elem1 = 10'b%10b", my_union.p_struct.elem1);
    $display("my_union.p_struct.elem2 = 10'b%10b", my_union.p_struct.elem2);
    $display("my_union.p_struct.elem3 = 10'b%10b", my_union.p_struct.elem3);
  end

endmodule
