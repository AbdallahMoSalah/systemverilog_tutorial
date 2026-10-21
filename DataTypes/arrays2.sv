module arrays2;

  // Unpacked structure of: String, event, real, packed array (size 3 bits)
  typedef struct {
    string    s;
    event     e;
    real      r;
    bit [2:0] p_data;
  } item_struct_t;

  event dummy_event;

  // =========================================================================
  // Q1: Associative array with string index (indices: "hi", "hello", "hey")
  // =========================================================================
  item_struct_t assoc_arr [string];

  // =========================================================================
  // Q2: Associative array with wildcard index [*]
  // =========================================================================
  item_struct_t wildcard_arr [*];

  // =========================================================================
  // Q3: Queue of type string
  // =========================================================================
  string str_queue [$];

  initial begin
    // -----------------------------------------------------------------------
    // Q1 Execution
    // -----------------------------------------------------------------------
    $display("=== Q1: Associative Array (String Index) ===");
    assoc_arr["hi"]    = '{s: "Message_Hi",    e: dummy_event, r: 1.11, p_data: 3'b001};
    assoc_arr["hello"] = '{s: "Message_Hello", e: dummy_event, r: 2.22, p_data: 3'b010};
    assoc_arr["hey"]   = '{s: "Message_Hey",   e: dummy_event, r: 3.33, p_data: 3'b011};

    // Reading elements using dot operator
    $display("assoc_arr[\"hi\"].s    = %s, r = %0.2f, p_data = %3b", assoc_arr["hi"].s, assoc_arr["hi"].r, assoc_arr["hi"].p_data);
    $display("assoc_arr[\"hello\"].s = %s, r = %0.2f, p_data = %3b", assoc_arr["hello"].s, assoc_arr["hello"].r, assoc_arr["hello"].p_data);
    $display("assoc_arr[\"hey\"].s   = %s, r = %0.2f, p_data = %3b", assoc_arr["hey"].s, assoc_arr["hey"].r, assoc_arr["hey"].p_data);

    // -----------------------------------------------------------------------
    // Q2 Execution
    // -----------------------------------------------------------------------
    $display("\n=== Q2: Associative Array (Wildcard [*] Index) ===");
    wildcard_arr["hi"]    = '{s: "Wildcard_Hi",    e: dummy_event, r: 4.44, p_data: 3'b100};
    wildcard_arr["hello"] = '{s: "Wildcard_Hello", e: dummy_event, r: 5.55, p_data: 3'b101};
    wildcard_arr["hey"]   = '{s: "Wildcard_Hey",   e: dummy_event, r: 6.66, p_data: 3'b110};

    // Reading elements using dot operator
    $display("wildcard_arr[\"hi\"].s    = %s, r = %0.2f, p_data = %3b", wildcard_arr["hi"].s, wildcard_arr["hi"].r, wildcard_arr["hi"].p_data);
    $display("wildcard_arr[\"hello\"].s = %s, r = %0.2f, p_data = %3b", wildcard_arr["hello"].s, wildcard_arr["hello"].r, wildcard_arr["hello"].p_data);
    $display("wildcard_arr[\"hey\"].s   = %s, r = %0.2f, p_data = %3b", wildcard_arr["hey"].s, wildcard_arr["hey"].r, wildcard_arr["hey"].p_data);

    // -----------------------------------------------------------------------
    // Q3 Execution
    // -----------------------------------------------------------------------
    $display("\n=== Q3: Queue of Strings ===");
    // Push elements in front
    str_queue.push_front("First_Pushed");
    str_queue.push_front("Second_Pushed");
    str_queue.push_front("Third_Pushed");

    $display("Queue size after push_front: %0d", str_queue.size());

    // Pop elements from the back
    while (str_queue.size() > 0) begin
      $display("Popped from back: %s", str_queue.pop_back());
    end
  end

endmodule
