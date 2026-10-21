// Demonstration of Static vs Dynamic (Automatic / Class Instances) in SystemVerilog
// References: IEEE Std 1800-2023 Clause 6.21, Clause 8.9, Clause 13.3.1, Clause 13.4.2

module static_vs_dynamic_demo;

  // =========================================================================
  // CASE 1: Subroutines (Tasks/Functions) - Counter Behavior
  // =========================================================================
  
  // Static function: local variable 'count' retains value between calls
  function int static_counter();
    static int count = 0; // or default in static scope
    count++;
    $display("%m   [static_counter] count = %0d" ,count);
    return count;
  endfunction

  // Automatic function: local variable 'count' is re-allocated and initialized every call
  function void automatic_counter();
    automatic int count = 0;
    count++;
    $display("%m  [automatic_counter] count = %0d", count);
  endfunction

  // =========================================================================
  // CASE 2: Recursion (Automatic is REQUIRED, Static corrupts data)
  // =========================================================================
  
  // Static factorial: Corrupts because all recursive frames share the SAME 'n' and local vars
  function int factorial_static(int n);
    if (n <= 1) return 1;
    else return n * factorial_static(n - 1);
  endfunction

  // Automatic factorial: Safe because each call allocates its own 'n' on the stack
  function automatic int factorial_auto(int n);
    if (n <= 1) return 1;
    else return n * factorial_auto(n - 1);
  endfunction

  // =========================================================================
  // CASE 3: Classes - Static Class Property vs Dynamic Instance Property
  // =========================================================================
  class Packet;
    // Static property: ONE copy shared by ALL packet instances
    static int global_packet_count = 0;

    // Dynamic (instance) property: Unique copy per object created with new()
    int packet_id;
    string payload;

    function new(string p);
      global_packet_count++;
      this.packet_id = global_packet_count;
      this.payload   = p;
    endfunction
  endclass

  // =========================================================================
  // CASE 4: Concurrency (fork..join_none loop index capture)
  // =========================================================================
  task test_fork_loop();
    $display("\n--- CASE 4: Thread Spawning in Loop ---");
    // BAD: Loop variable 'i' is static -> threads read final value (3)
    // GOOD: Copy into automatic variable for each thread
    for (int i = 0; i < 3; i++) begin
      automatic int thread_id = i; // dynamically created for this iteration
      fork
        $display("  [Thread] Launched for iteration ID = %0d", thread_id);
      join_none
    end
    #1; // allow spawned threads to execute
  endtask

  initial begin
    $display("==============================================================");
    $display(" DEMO 1: Subroutine Lifetime (Static vs Automatic)");
    $display("==============================================================");
    $display("Calling static_counter 3 times:");
    $display(static_counter());
    $display(static_counter());
    $display(static_counter());

    //static_counter();
    //static_counter();
    $display(static_counter.count);

    $display("\nCalling automatic_counter 3 times:");
    automatic_counter();
    automatic_counter();
    automatic_counter();
    
    //$display(automatic_counter.count);


    $display("\n==============================================================");
    $display(" DEMO 2: Recursion Factorial of 4");
    $display("==============================================================");
    $display("  factorial_auto(4) = %0d (Expected: 24)", factorial_auto(4));

    $display("\n==============================================================");
    $display(" DEMO 3: Classes (Static vs Dynamic Properties)");
    $display("==============================================================");
    begin
      automatic Packet p1 = new("Data_A");
      automatic Packet p2 = new("Data_B");
      automatic Packet p3 = new("Data_C");

      $display("  p1: id=%0d, payload=%s, shared_count=%0d", p1.packet_id, p1.payload, p1.global_packet_count);
      $display("  p2: id=%0d, payload=%s, shared_count=%0d", p2.packet_id, p2.payload, p2.global_packet_count);
      $display("  p3: id=%0d, payload=%s, shared_count=%0d", p3.packet_id, p3.payload, p3.global_packet_count);
      $display("  Direct class access: Packet::global_packet_count = %0d", Packet::global_packet_count);
    end

    test_fork_loop();
    $display("==============================================================");
  end

endmodule
