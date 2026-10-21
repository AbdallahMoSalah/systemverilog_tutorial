module pipeline_reg #(
    parameter WIDTH = 32
) (
    input logic clk,
    input logic rst_n,
    input logic enable,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= '0;
        end else if (enable) begin
            q <= d;
        end
    end
endmodule
