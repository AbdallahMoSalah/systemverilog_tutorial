module struct2;


  struct packed {
    bit [7:0] data_byte;
    bit [4:0] tag;
  } my_packed_struct;

  initial begin
    my_packed_struct = 13'b10110011_01101;
    $display("1. Whole packed struct: 13'b%13b ", my_packed_struct, my_packed_struct);

    $display("\n2. Reading element by element:");
    $display("Element 1 (data_byte): 8'b%8b ", my_packed_struct.data_byte);
    $display("Element 2 (tag)      : 5'b%5b ", my_packed_struct.tag);
  end

endmodule
