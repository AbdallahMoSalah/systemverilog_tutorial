# SystemVerilog Clocking Blocks: From Root Cause to Complete Solution
*Based on IEEE Std 1800™-2023, Clause 4 ("Scheduling Semantics") and Clause 14 ("Clocking Blocks")*

---

## 1. The Root Cause: Testbench vs. Design Race Conditions

### The Fundamental Problem
In traditional Verilog, hardware designs (RTL) and testbenches (TB) execute inside the same active simulation queue. When a clock event occurs (`@(posedge clk)`):
1. **The Sampling Race (TB reading DUT outputs)**:
   - If the DUT updates an output at `posedge clk` using nonblocking assignments (`<=`), and the testbench attempts to read that same output at `posedge clk`, who wins?
   - If the TB reads first, it sees the **old** value. If the DUT's NBA executes first, the TB sees the **new** value.
   - This creates simulator-dependent, non-deterministic race conditions.
2. **The Driving Race (TB writing DUT inputs)**:
   - If the testbench drives inputs using blocking assignments (`=`), the DUT might register the updated input on the *current* cycle or the *next* cycle depending on simulator scheduling order.
3. **The Flawed Historical Workaround**:
   - Engineers added artificial delays (e.g., `#1`, `#2ns`, `@(negedge clk)`).
   - This brittle approach breaks when clock frequencies change, causes timing glitches, and adds maintenance overhead.

---

## 2. The Architectural Foundation: Stratified Event Scheduler (Clause 4, Page 63–70)

IEEE Std 1800 solved this at the simulator engine level by dividing every simulation time slot into dedicated regions:

```
+-----------------------------------------------------------------------------+
|                            SIMULATION TIME SLOT                             |
+-------------------+--------------------+------------------+-----------------+
|  PREPONED REGION  |   ACTIVE REGION    | OBSERVED REGION  | REACTIVE REGION |
|  (Clause 4.4.2.1) |   (Clause 4.4.2.2) | (Clause 4.4.2.5) |(Clause 4.4.2.6) |
|                   |   NBA (4.4.2.4)    |                  |Re-NBA (4.4.2.8) |
|                   |                    |                  |                 |
| Samples steady    | RTL design code    | SystemVerilog    | Testbench drives|
| state BEFORE edge | evaluates & updates| Assertions (SVA) | & clocking block|
| (Input #1step)    | (DUT logic)        | evaluate here    | drives execute  |
+-------------------+--------------------+------------------+-----------------+
```

- **Preponed Region (Clause 4.4.2.1, Page 65)**: Captures values right before any clock edge events occur.
- **Active / NBA Region (Clause 4.4.2.2 & 4.4.2.4, Page 65)**: Design flip-flops and combinational logic update here.
- **Reactive / Re-NBA Region (Clause 4.4.2.6 & 4.4.2.8, Page 66)**: Testbench programs and clocking block synchronous drives execute here.

---

## 3. The Solution: Clocking Blocks (Clause 14, Page 355–372)

A **clocking block** automates race-free synchronization, sampling, and driving between the testbench and the DUT.

### A. Clocking Block Declaration & Syntax (Clause 14.3, Page 355)
```systemverilog
clocking cb_name @(posedge clk);
    default input #1step output #0;
    input  Data_out, Valid_out;
    output Data_in, Address, WE, EN;
endclocking
```

### B. Input Skew & Sampling Mechanics (Clause 14.4 & 14.13, Pages 357, 364)
- **Input Skew**: Determines how much time *prior* to the clock edge the input signal is sampled.
- **`default input #1step` (Clause 14.4, Page 357)**:
  - `#1step` indicates that the signal is sampled in the **Preponed region** of the current time step.
  - This guarantees that the testbench samples the clean, stable value of DUT outputs **before any flip-flop has begun transitioning**.
  - Off-by-one cycle bugs and race conditions are eliminated.

### C. Output Skew & Synchronous Drives (Clause 14.4 & 14.16, Pages 357, 369–371)
- **Output Skew**: Determines when the driven signal is updated relative to the clock event.
- **`default output #0` (Clause 14.16.1, Page 370)**:
  - Synchronous drives (`cb.sig <= val;`) are scheduled in the **Re-NBA (Reactive Nonblocking Assignment)** region.
  - The DUT inputs are cleanly updated *after* the current clock edge evaluation has settled, ready to be sampled by the DUT on the *next* clock edge (mimicking real physical setup times).

### D. Cycle Delay Operator `##` (Clause 14.11, Page 362)
- Replaces wall-clock delays (`#10ns`) with clock-cycle accurate delays tied directly to the clocking event:
  ```systemverilog
  ##1;   // Wait for 1 clocking block cycle
  ##5;   // Wait for 5 clocking block cycles
  ```

---

## 4. Practical Implementation: Interface with Clocking Block

Applying clocking blocks to the [`Memory16x32`](file:///media/abdallah-salah/eng/Verification/LAB1_Ver_plan/Memory16x32.sv) DUT:

```systemverilog
interface mem_intf (input logic clk, input logic rst_n);
    logic [31:0] Data_in;
    logic [31:0] Data_out;
    logic [3:0]  Address;
    logic        WE;
    logic        EN;
    logic        Valid_out;

    // 1. Clocking block for Testbench Driver
    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output Data_in, Address, WE, EN;
        input  Data_out, Valid_out;
    endclocking

    // 2. Clocking block for Testbench Monitor (sampling only)
    clocking mon_cb @(posedge clk);
        default input #1step;
        input Data_in, Address, WE, EN, Data_out, Valid_out;
    endclocking

    // 3. Modports exposing clocking blocks (Clause 14.9 & 25.5.5)
    modport DRV_mp (
        clocking drv_cb,
        input    rst_n
    );

    modport MON_mp (
        clocking mon_cb,
        input    rst_n
    );

    modport DUT_mp (
        input  clk, rst_n, Data_in, Address, WE, EN,
        output Data_out, Valid_out
    );
endinterface
```

---

## 5. Usage in Dynamic Verification Classes (UVM / OOP Driver)

```systemverilog
class mem_driver;
    virtual mem_intf.DRV_mp vif;

    function new(virtual mem_intf.DRV_mp vif);
        this.vif = vif;
    endfunction

    task write_mem(input logic [3:0] addr, input logic [31:0] data);
        // Synchronous drive using clocking block handle
        @(vif.drv_cb);
        vif.drv_cb.Address <= addr;
        vif.drv_cb.Data_in <= data;
        vif.drv_cb.WE      <= 1'b1;
        vif.drv_cb.EN      <= 1'b1;

        @(vif.drv_cb);
        vif.drv_cb.WE      <= 1'b0;
        vif.drv_cb.EN      <= 1'b0;
    endtask
endclass
```

---

## 6. Summary Comparison: With vs. Without Clocking Blocks

| Feature | Without Clocking Blocks | With Clocking Blocks |
| :--- | :--- | :--- |
| **Sampling Region** | Active region (races with RTL assignments) | **Preponed region** (`#1step`, perfectly stable) |
| **Driving Region** | Active or NBA region (potential setup violations) | **Re-NBA region** (scheduled cleanly after active edge) |
| **Delays** | Hardcoded `#10ns`, `#1` (breaks on frequency changes) | Cycle-accurate `##1`, `##5` (clock-frequency independent) |
| **Simulator Independence** | Behavior can differ between simulators | Guaranteed deterministic by IEEE Std 1800 scheduler |
