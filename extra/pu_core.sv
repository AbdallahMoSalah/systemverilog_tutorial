module pu_core (
    input logic clk,
    input logic rst_n,
    input logic [31:0] instruction_in,
    output logic [31:0] result_out
);
    logic [3:0] alu_op;
    logic mem_we, mem_re;
    logic [4:0] reg_rd, reg_rs1, reg_rs2;
    logic [31:0] imm_val;
    logic use_imm;
    
    logic [31:0] alu_result;
    logic alu_zero;
    logic [31:0] mem_rdata;

    // Dummy registers for ALU inputs
    logic [31:0] reg_file [0:31];
    logic [31:0] rs1_data, rs2_data;
    
    // Read from registers (simplified for testing)
    assign rs1_data = reg_file[reg_rs1];
    assign rs2_data = use_imm ? imm_val : reg_file[reg_rs2];

    // Instantiate Control Unit
    ctrl_unit u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction_in),
        .alu_op(alu_op),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .reg_rd_addr(reg_rd),
        .reg_rs1_addr(reg_rs1),
        .reg_rs2_addr(reg_rs2),
        .imm_val(imm_val),
        .use_imm(use_imm)
    );

    // Instantiate ALU
    alu u_alu (
        .opcode(alu_op),
        .a(rs1_data),
        .b(rs2_data),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Instantiate Memory
    memory u_mem (
        .clk(clk),
        .we(mem_we),
        .re(mem_re),
        .addr(alu_result[7:0]), // Use ALU result as memory address
        .wdata(rs2_data),
        .rdata(mem_rdata)
    );

    // Write-back stage
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_out <= 32'd0;
            for (int i = 0; i < 32; i++) begin
                reg_file[i] <= 32'd0;
            end
        end else begin
            if (mem_re) begin
                reg_file[reg_rd] <= mem_rdata;
                result_out <= mem_rdata;
            end else begin
                reg_file[reg_rd] <= alu_result;
                result_out <= alu_result;
            end
        end
    end

endmodule
