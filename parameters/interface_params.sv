//=============================================================================
// Interface Parameters: Q1 and Q2
//
// Q1:
// - Define an interface with a local type parameter of type int
//   and a local value parameter of value = 20.
// - Instantiate the interface in top and try to override the two parameters
//   using parameter port list or defparam.
//
// Q2:
// - Change the local parameters in Q1 to non-local parameters (regular parameters).
// - Check if overriding works properly.
//=============================================================================

// ----------------------------------------------------------------------------
// Q1: Interface with local parameters
// ----------------------------------------------------------------------------
interface if_local_params;
  localparam type T = int;
  localparam VAL = 20;

  initial begin
    $display("[%m] (Localparam Interface) Type bits = %0d (%s), VAL = %0d", $bits(T),$typename(T), VAL);
  end
endinterface

// ----------------------------------------------------------------------------
// Q2: Interface with non-local parameters (can be overridden)
// ----------------------------------------------------------------------------
interface if_non_local_params ();
  parameter type T   = int;
  parameter      VAL = 20;

  initial begin
    $display("[%m] (Non-local Param Interface) Type bits = %0d (%s), VAL = %0d", $bits(T), $typename(T), VAL);
  end
endinterface

// ----------------------------------------------------------------------------
// Top Module demonstrating Q1 and Q2
// ----------------------------------------------------------------------------
module top_interface_params;

  if_local_params u_local_default();

  if_local_params #(.T(byte)) u_local_override(); // worked 
  // if_local_params #(.T(byte), .VAL(50)) u_local_override(); // didn't work
  // defparam u_local_default.VAL = 50; // compile errors
  // defparam u_local_default.T = byte; // you can't override type parameter with defparam


  if_non_local_params #(
    .T(byte),   // Override type parameter: int (32 bits) -> byte (8 bits)
    .VAL(100)   // Override value parameter: 20 -> 100
  ) u_non_local_override();

  // Overriding another instance with different values
  if_non_local_params #(
    .T(time),
    .VAL(500)
  ) u_non_local_override2();
  
  // using defparam
  // defparam u_non_local_override.T = shortint ; // can't override type parameter with defparam
  
  defparam u_non_local_override.VAL = 515; // defparam override the instant whatever it override already or not
  // the order is defparam > override > default

  if_non_local_params #()u_non_local_override_default(); // with default values from interface

  if_non_local_params #(.T(shortint), .VAL(520)) u_non_local_override_defparam2(); // with override

  
endmodule
