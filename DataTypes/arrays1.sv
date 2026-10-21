module arrays1;


bit [32:0] packed_arr; 

string unpacked_str_arr [10];

 typedef struct {
    string    s;
    event     e;
    real      r;
    bit [2:0] p_data;
  } item_struct_t;

  item_struct_t dyn_arr [];
  event dummy_event;

  initial begin
    $display("=== Q1: Static Packed Array (33 bits) ===");
    packed_arr = 33'd40;
    $display("Whole array (bin) : %33b", packed_arr);
    $display("Slice [3:0]       : %4b", packed_arr[3:0]);
    $display("Bit [9]           : %0b", packed_arr[9]);

    $display("\n=== Q2: Static Unpacked Array of 10 Strings ===");
    unpacked_str_arr = '{
      "Apple", "Banana", "Cherry", "Date", "Elderberry",
      "Fig", "Grape", "Honeydew", "Kiwi", "Lemon"
    };
    foreach (unpacked_str_arr[i]) begin
      $display("unpacked_str_arr[%0d] = %s", i, unpacked_str_arr[i]);
    end

    $display("\n=== Q3: Dynamic Array of 6 Struct Elements ===");
    dyn_arr = new[6];
    foreach (dyn_arr[i]) begin
      dyn_arr[i] = '{
        s:      $sformatf("Item_%0d", i),
        e:      dummy_event,
        r:      (i + 1) * 1.5,
        p_data: i[2:0]
      };
    end

    // Reading elements using dot operator
    foreach (dyn_arr[i]) begin
      $display("dyn_arr[%0d]: s=%-8s | r=%-4.2f | p_data=%3b | is event triggerd = %b ",
               i, dyn_arr[i].s, dyn_arr[i].r, dyn_arr[i].p_data, dyn_arr[i].e.triggered());
    end
  end

endmodule
