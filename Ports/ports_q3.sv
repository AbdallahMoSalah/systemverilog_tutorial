// ==============================================================================
// Question 3:
// - Apply the same ports in Q1 and Q2 on different DUs (Design Units)
//
// Demonstrates:
// 1. DUs using Q1 ports (Net type: tri0, 4-state: logic [3:0])
//    - du_tri0_driver: Drives signals onto tri0 nets or floats them (z)
//    - du_tri0_receiver: Monitors tri0 nets and verifies pulldown to 0 when floating
//    - Connected via shared tri0 wires to illustrate inout and pulldown behavior
//
// 2. DUs using Q2 ports (Kind: var, 2-state: bit [7:0])
//    - du_var_sender: Drives output var and manipulates ref var
//    - du_var_receiver: Reads input var and monitors ref var modifications
//    - Shows how variable reference (ref) passes data directly between DUs
// ==============================================================================

// ==============================================================================
// Top-Level Module to test and verify all DUs
// ==============================================================================
module top_ports;
    logic [3:0] tria,trib;
    logic [7:0] var1,var2;
du_tri0_q1 u_du_tri0_q1 (
    .in_bus(tria), 
    .out_bus(trib)
);
du_var_q2 u_du_var_q2 (
    .in_data(var1), 
    .out_data(var2)
);
initial begin
	tria = 4'b1010;
	var1 = 8'd10;
    #10;
	tria = 4'b0100;
    var1 = 8'd20;
	#10;
	$finish;
end


endmodule
