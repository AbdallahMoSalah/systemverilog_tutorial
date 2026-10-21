module Memory16x32(
   input  logic         clk,
   input  logic         rst_n,
   input  logic [31:0] Data_in,
   input  logic         WE,
   input  logic         EN,
   input  logic[3:0]    Address,
   output logic [31:0] Data_out,
   output logic   Valid_out
);

logic [31:0] memory[0:15];

always_ff @(posedge clk, negedge rst_n)
begin
    if(!rst_n)
    begin
        Data_out <= 32'b0;
        Valid_out <= 1'b0;
        memory <= '{default:0};
    end
    else if(EN)
    begin
        if(WE) 
        begin
            memory[Address] <= Data_in;
        end
        else 
        begin
            Valid_out <= 1'b1;
            Data_out <= memory[Address];
        end
    end
    else begin
        Valid_out <= 1'b0;
    end
end

endmodule
