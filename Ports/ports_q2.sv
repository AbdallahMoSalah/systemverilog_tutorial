
module du_var_q2 (
    input  var bit [7:0] in_data,    // input direction
    output var bit [7:0] out_data//,   // output direction
   // ref    var bit [7:0] ref_data    // ref direction (pass-by-reference)
);

    // Procedural drive onto output port
    always_comb begin
        out_data = in_data + 8'd10;
    end


    initial begin
        #1;
        $display("[%m @ %0t] Initial: in_data = %0d | out_data = %0d ",
                 $time, in_data, out_data);
    end

endmodule
