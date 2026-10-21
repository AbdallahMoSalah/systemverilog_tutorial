

// Packed struct of elements: logic, int, and time (Total = 1 + 32 + 64 = 97 bits)
typedef struct packed {
  logic l;
  int   i;
  time  t;
} my_packed_struct_t;
// the simulator put that struct in an package and all modules can see it through compilation unit scope ($unit)

module sub_module #(
  parameter type T   = my_packed_struct_t, // Type parameter default: packed struct
  parameter T    VAL = '0                  // Value parameter whose type is T
) ();

  initial begin
    $display("[%m] Type bit-width = %0d  (%s)| Parameter VAL = %0d", $bits(T), $typename(T), VAL); // 64+32+1=97
  end

endmodule


module top_module_params;

  sub_module u_default();

  sub_module #(
    .T(int),
    .VAL(50)
  ) u_q2();

  genvar i;
  generate
    for (i = 5; i > 2; i--) begin : gen_instances
      sub_module #(
        .T(int),
        .VAL(i)
      ) u_gen();
    end
  endgenerate

endmodule
