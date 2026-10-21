module memory (
    input logic clk,
    input logic we,
    input logic re,
    input logic [7:0] addr,
    input logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:255];

    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= wdata;
        end
        if (re) begin
            rdata <= mem[addr];
        end
    end
endmodule
