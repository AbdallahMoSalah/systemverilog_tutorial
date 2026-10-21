module ctrl_unit (
    input logic clk,
    input logic rst_n,
    input logic [31:0] instruction,
    output logic [3:0] alu_op,
    output logic mem_we,
    output logic mem_re,
    output logic [4:0] reg_rd_addr,
    output logic [4:0] reg_rs1_addr,
    output logic [4:0] reg_rs2_addr,
    output logic [31:0] imm_val,
    output logic use_imm
);
    // Simple decoding logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_op <= 4'b0000;
            mem_we <= 1'b0;
            mem_re <= 1'b0;
            use_imm <= 1'b0;
            reg_rd_addr <= 5'd0;
            reg_rs1_addr <= 5'd0;
            reg_rs2_addr <= 5'd0;
            imm_val <= 32'd0;
        end else begin
            // Simplified decode fields for testing
            alu_op <= instruction[29:26];
            mem_we <= instruction[25];
            mem_re <= instruction[24];
            use_imm <= instruction[23];
            reg_rd_addr <= instruction[22:18];
            reg_rs1_addr <= instruction[17:13];
            reg_rs2_addr <= instruction[12:8];
            imm_val <= {{24{instruction[7]}}, instruction[7:0]}; // Sign extended
        end
    end
endmodule
