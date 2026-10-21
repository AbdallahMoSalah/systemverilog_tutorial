// =============================================================================
// Experiment: Accessing members of a class declared later in the same file
// =============================================================================

// STEP 1: Forward declaration
// Tells the compiler: "ClassB is a class type that will be defined later"
typedef class ClassB; 

class ClassA;
    ClassB b_h; // LEGAL: Compiler knows b_h is a handle to a class

    function void test();
        // ---------------------------------------------------------------------
        // EXPERIMENT 1: Accessing a valid member of ClassB
        // Because ClassB is defined below in the same file, QuestaSim performs
        // a 2-pass resolution: it parses the types first, then resolves members!
        // ---------------------------------------------------------------------
        b_h.data = 100; // Compiles successfully!

        // ---------------------------------------------------------------------
        // EXPERIMENT 2: Uncomment the line below to see the compiler FAIL!
        // The compiler checks members against ClassB once ClassB is parsed.
        // ---------------------------------------------------------------------
        // b_h.non_existent_member = 50; 
        // --> Error: Could not find field/method name (non_existent_member) in 'b_h'
    endfunction
endclass

// ClassB is defined here, later in the same file:
class ClassB;
    int data;
endclass

module top();
    initial begin
        automatic ClassA a = new();
        automatic ClassB b = new();
        a.b_h = b;
        a.test();
        $display("SUCCESS: b_h.data resolved to %0d", b.data);
    end
endmodule
