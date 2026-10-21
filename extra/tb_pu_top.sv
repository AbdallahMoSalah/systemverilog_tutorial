module tb_pu_top();

    logic clk;
    logic rst_n;
    logic enable;
    logic [31:0] instruction;
    logic [31:0] pu_out;
    logic valid_out;

    // Instantiate DUT
    pu_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .instruction(instruction),
        .pu_out(pu_out),
        .valid_out(valid_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Self-checking logic
    int error_count = 0;
    int test_count = 0;
    logic [31:0] exp_queue[$];

    // Check outputs on posedge clk when valid_out is high
    always @(posedge clk) begin
        logic [31:0] expected_val;
        if (rst_n && valid_out) begin
            test_count++;
            if (exp_queue.size() > 0) begin
                expected_val = exp_queue.pop_front();
                if (pu_out === expected_val) begin
                    $display("[CHECK PASS] Time=%0t | Output Matched Expected: 0x%08h", $time, pu_out);
                end else begin
                    $error("[CHECK FAIL] Time=%0t | Expected: 0x%08h, Got: 0x%08h", $time, expected_val, pu_out);
                    error_count++;
                end
            end else begin
                $error("[CHECK FAIL] Time=%0t | Unexpected valid_out! Got: 0x%08h", $time, pu_out);
                error_count++;
            end
        end
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        enable = 0;
        instruction = 32'd0;

        // Reset for 2 clock cycles
        repeat (2) @(posedge clk);
        #1 rst_n = 1;
        
        @(negedge clk);
        // Instruction 1: ADD with immediate 5, destination rd=1 (0 + 5 = 5)
        enable = 1;
        instruction = 32'h00840005;
        exp_queue.push_back(32'd5);

        @(negedge clk);
        // Instruction 2: SUB with immediate 2, destination rd=2, source rs1=1 (5 - 2 = 3)
        enable = 1;
        instruction = 32'h04882002;
        exp_queue.push_back(32'd3);

        @(negedge clk);
        enable = 0;
        instruction = 32'd0;
        
        // Wait for results to propagate through the pipeline
        repeat (8) @(posedge clk);

        if (exp_queue.size() != 0) begin
            $error("[CHECK FAIL] Queue not empty! Missed %0d outputs.", exp_queue.size());
            error_count++;
        end

        $display("\n========================================");
        if (error_count == 0 && test_count > 0) begin
            $display(">>> ALL %0d TOP-LEVEL CHECKS PASSED! <<<", test_count);
        end else begin
            $display(">>> TOP-LEVEL CHECKS FAILED: %0d error(s) out of %0d test(s) <<<", error_count, test_count);
        end
        $display("========================================\n");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | rst_n=%b | en=%b | instr=%h | valid_out=%b | pu_out=%h",
                 $time, rst_n, enable, instruction, valid_out, pu_out);
    end
initial begin
    #39 force tb_pu_top.dut.u_pu_core.u_alu.a= 32'd5;
     force tb_pu_top.dut.u_pu_core.u_alu.b= 32'd5;
    force tb_pu_top.dut.u_pu_core.u_alu.opcode = 4'b0000; 
    
    #1 release tb_pu_top.dut.u_pu_core.u_alu.a;
    release tb_pu_top.dut.u_pu_core.u_alu.b;
    release tb_pu_top.dut.u_pu_core.u_alu.opcode;
end

bind alu testten test1(result);

endmodule
 
module testten (
    input logic [31:0] result
);
    initial begin
        #40
        if (result == 32'd10 ) begin
            $display("testten test PASS");
        end
        else begin
            $display("testten test FAIL");
        end
    end
endmodule