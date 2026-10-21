# SystemVerilog Ports Lab

This folder contains the complete solutions for the **Ports** assignment, covering:
1. **Net type ports (`tri0`) with 4-state data types** and allowable directions.
2. **Variable ports (`var`) with 2-state data types** and allowable directions.
3. **Application across different DUs (Design Units)** with interconnect verification.

> **Note**: For our standard search & verification workflow agreement, see [SV_STANDARD_RULES.md](file:///media/abdallah-salah/eng/Verification/SV_STANDARD_RULES.md).

---

## Question 1: Net Type `tri0` and 4-State Data Type

### Port Definition
```systemverilog
module du_tri0_q1 (
    input  tri0 logic [3:0] in_bus,    // input direction
    output tri0 logic [3:0] out_bus,   // output direction
    inout  tri0 logic [3:0] bidir_bus  // inout direction (bidirectional)
);
    assign out_bus = in_bus;
endmodule
```

### What are the available directions for net type `tri0`?
According to the **IEEE Std 1800 SystemVerilog LRM (Section 23.2.2)**:
- **`input`**: Supported. The net is driven externally; if left undriven / floating (`'z`), a `tri0` net automatically resolves to logic `'0'` (resistive pulldown).
- **`output`**: Supported. The net is driven internally via continuous assignment (`assign`) or module instance output.
- **`inout`**: Supported. Net types are **required** for bidirectional ports to allow multiple drivers and resolution.
- **`ref`**: **NOT supported / ILLEGAL for nets**. The LRM states: *"A ref port shall be a variable type and an equivalent type to the actual variable."*

> **Answer:** The valid directions for net type `tri0` are **`input`**, **`output`**, and **`inout`**.

---

## Question 2: Variable (`var`) Port and 2-State Data Type

### Port Definition
```systemverilog
module du_var_q2 (
    input  var bit [7:0] in_data,    // input direction
    output var bit [7:0] out_data,   // output direction
    ref    var bit [7:0] ref_data    // ref direction (pass-by-reference)
);
    always_comb begin
        out_data = in_data + 8'd10;
    end
endmodule
```

### What is the list of available directions for variable (`var`) ports?
According to the **IEEE Std 1800 SystemVerilog LRM (Section 23.2.2.3 & 23.2.2.4)**:
- **`input`**: Supported. The variable is read-only inside the module.
- **`output`**: Supported. The variable is written procedurally (`always`/`initial`) or continuously.
- **`ref`** (and **`const ref`**): Supported. The variable is passed by reference (shared variable), allowing direct in-place modification without copying.
- **`inout`**: **NOT supported / ILLEGAL for variables**. The LRM explicitly states: *"An inout port shall be a net type; it cannot be a variable type."*

> **Answer:** The list of available directions for `var` ports is: **`input`**, **`output`**, and **`ref`** (including `const ref`).

---

## Question 3: Applying Q1 and Q2 Ports on Different DUs

In [ports_q3.sv](file:///media/abdallah-salah/eng/Verification/Ports/ports_q3.sv):
1. **DUs for Q1 Ports (`tri0` 4-state nets):**
   - `du_tri0_driver`: Controls when to drive or float (`4'bz`) the `tri0` bus.
   - `du_tri0_receiver`: Connects to `in_bus`, `out_bus`, and `bidir_bus`. Demonstrates that whenever the driver floats the bus to `4'bz`, the `tri0` net automatically resolves to `0000` (pulldown).
2. **DUs for Q2 Ports (`var` 2-state bits):**
   - `du_var_sender`: Drives `output var bit [7:0]` and directly mutates the shared `ref var bit [7:0]`.
   - `du_var_receiver`: Accepts `input var bit [7:0]` and observes live changes to the shared `ref var bit [7:0]`.
3. **Top module (`top_ports`):**
   - Integrates and connects both pairs of DUs, running verification stimuli and printing output logs.

---

## How to Run Simulation

From this directory (`/media/abdallah-salah/eng/Verification/Ports`), execute:
```bash
vsim -c -do run.do
```
All modules compile with **0 Errors, 0 Warnings** and complete the simulation run.
