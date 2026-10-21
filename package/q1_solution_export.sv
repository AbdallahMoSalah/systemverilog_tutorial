// Package Question 1: Solution 2 (Export Chaining: pack1 -> pack2 -> pack3 -> top)
// Solves visibility by exporting imported declarations across packages.
// Reference: IEEE Std 1800-2023 Clause 26.6 (Exporting imported names from packages)

package pack1;
  // 2 static variables of type integer and byte
  static integer sv_int  = 32'd1000;
  static byte    sv_byte = 8'h5A;

  // 2 value parameters of any values
  parameter int PARAM_A = 10;
  parameter int PARAM_B = 20;
endpackage : pack1

package pack2;
  // Import from pack1
  import pack1::sv_byte;
  import pack1::PARAM_A;
  import pack1::sv_int;
  import pack1::PARAM_B;

export *::*;
endpackage : pack2

package pack3;
  // Import everything exported by pack2
  import pack2::sv_byte;
  import pack2::sv_int;
  import pack2::PARAM_A;
  import pack2::PARAM_B;

export *::*;
endpackage : pack3

module top;
  // Top ONLY imports pack3, yet has full direct access to all exported symbols!
  import pack3::*;

  initial begin
    $display("=== Solution 2: Chained Package Exports ===");
    $display("PARAM_A = %0d", PARAM_A);
    $display("PARAM_B = %0d", PARAM_B);
    $display("sv_int  = %0d", sv_int);
    $display("sv_byte = 8'h%0h", sv_byte);
  end
endmodule : top
