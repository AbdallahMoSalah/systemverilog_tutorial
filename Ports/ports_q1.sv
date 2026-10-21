
module du_tri0_q1 (
   input tri0 logic [3:0] in_bus,
   output tri0 logic [3:0] out_bus
    );

    assign out_bus = in_bus;

    always @(in_bus) begin
        $display("[%m @ %0t] in_bus = %b (%0d) | out_bus = %b", 
                 $time, in_bus, in_bus,out_bus);
    end

endmodule

/* in an ANSI style port list:
 If the direction is omitted, it shall default to inout*/