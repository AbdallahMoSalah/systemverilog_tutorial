module pu_top (
    input logic clk,
    input logic rst_n,
    input logic enable,
    input logic [31:0] instruction,
    output logic [31:0] pu_out,
    output logic valid_out
);
    logic [31:0] internal_instr;
    logic [31:0] core_out;
    
    // Input pipeline register
    pipeline_reg #(
        .WIDTH(32)
    ) u_in_reg (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .d(instruction),
        .q(internal_instr)
    );

    // Core Instantiation
    pu_core u_pu_core (
        .clk(clk),
        .rst_n(rst_n),
        .instruction_in(internal_instr),
        .result_out(core_out)
    );
    
    // Output pipeline registers
    pipeline_reg #(
        .WIDTH(32)
    ) u_out_reg (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1), // Always capture core output
        .d(core_out),
        .q(pu_out)
    );
    
    // 4-stage pipeline register for valid_out to match the 4-cycle datapath latency:
    // (input reg -> ctrl decode -> core writeback -> output reg)
    logic v_stage1, v_stage2, v_stage3;
    pipeline_reg #(.WIDTH(1)) u_vreg1 (.clk(clk), .rst_n(rst_n), .enable(1'b1), .d(enable),   .q(v_stage1));
    pipeline_reg #(.WIDTH(1)) u_vreg2 (.clk(clk), .rst_n(rst_n), .enable(1'b1), .d(v_stage1), .q(v_stage2));
    pipeline_reg #(.WIDTH(1)) u_vreg3 (.clk(clk), .rst_n(rst_n), .enable(1'b1), .d(v_stage2), .q(v_stage3));
    pipeline_reg #(.WIDTH(1)) u_vreg4 (.clk(clk), .rst_n(rst_n), .enable(1'b1), .d(v_stage3), .q(valid_out));

endmodule
