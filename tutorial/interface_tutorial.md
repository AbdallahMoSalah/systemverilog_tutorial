# SystemVerilog Interfaces Complete Reference & Tutorial
*Based on IEEE Std 1800™-2023, Clause 25 ("Interfaces")*

---

## 1. What is an Interface? (Clause 25.1 & 25.2, Page 781)
In traditional Verilog, connecting modules required declaring individual wires for every single signal and connecting each port by port. As design complexity grew, this led to bulky headers, connection errors, and tight coupling.

An **interface** encapsulates the communication between blocks:
- **Bundling**: Groups nets, variables, constants, user-defined types, clocking blocks, and assertions.
- **Protocol Encapsulation**: Houses subroutines (`tasks` and `functions`) that drive and sample the bus protocol directly within the interface.
- **Direction View**: Controls signal direction per connected block using `modport`.
- **Bridge to Verification Classes**: Uses `virtual interface` to allow dynamic class-based testbenches (OOP/UVM drivers, monitors) to access physical hardware signals.

---

## 2. Syntax & Declaration (Clause 25.3 & 25.4, Pages 782–786)

```systemverilog
interface interface_identifier [ parameter_port_list ] [ ( [ list_of_ports ] ) ];
    // Signal declarations (nets, variables)
    // Clocking blocks
    // Modport declarations
    // Tasks and functions
    // Concurrent assertions
endinterface [ : interface_identifier ]
```

### Key Rules:
1. **Ports in Interfaces (Clause 25.4, Page 786)**:
   - An interface can have its own port list, typically used to receive global signals from the environment (e.g. `clk`, `rst_n`).
   - Example:
     ```systemverilog
     interface mem_intf (input logic clk, input logic rst_n);
         logic [31:0] Data_in;
         logic [31:0] Data_out;
         logic [3:0]  Address;
         logic        WE;
         logic        EN;
         logic        Valid_out;
     endinterface : mem_intf
     ```
2. **Nets vs. Variables in Interfaces**:
   - Variables (`logic`, `bit`) or nets (`wire`, `tri`) can be declared inside interfaces. If signals are driven by procedural code (like tasks in testbenches), `logic` (variable) is standard.

---

## 3. Connecting Interfaces to Modules (Clause 25.3.2 & 25.3.3, Pages 784–786)

There are two primary ways to declare an interface port in a module:

### A. Named (Explicit) Interface Port (Clause 25.3.2, Page 784)
The module explicitly specifies the interface type. Only an instance of this specific interface type can be connected.
```systemverilog
module Memory16x32 (
    mem_intf.DUT_mp bus // Bound to mem_intf and specifically DUT_mp modport
);
    // Access signals via: bus.Data_in, bus.WE, etc.
endmodule
```

### B. Generic Interface Port (Clause 25.3.3, Page 785)
The module uses the generic keyword `interface`. Any interface can be connected; types and port members are checked during elaboration.
```systemverilog
module Memory16x32 (
    interface bus // Generic interface port
);
    // Access: bus.Data_in
endmodule
```

---

## 4. Modports (Module Ports) (Clause 25.5, Pages 787–793)

A `modport` defines direction perspectives for signals declared in the interface. Different modules (e.g., Master vs. Slave or DUT vs. Testbench) see different pin directions.

```systemverilog
interface mem_intf (input logic clk, input logic rst_n);
    logic [31:0] Data_in;
    logic [31:0] Data_out;
    logic [3:0]  Address;
    logic        WE;
    logic        EN;
    logic        Valid_out;

    // DUT view: Inputs to DUT are outputs from Testbench
    modport DUT_mp (
        input  clk, rst_n, Data_in, Address, WE, EN,
        output Data_out, Valid_out
    );

    // Testbench Driver view:
    modport DRV_mp (
        input  clk, rst_n, Data_out, Valid_out,
        output Data_in, Address, WE, EN
    );

    // Monitor view (Passive observer: everything is input):
    modport MON_mp (
        input  clk, rst_n, Data_in, Data_out, Address, WE, EN, Valid_out
    );
endinterface : mem_intf
```

### Important Standard Rules on Modports:
- **No storage allocation**: A modport does NOT declare new signals; it only provides directions/views for signals already declared in the interface.
- **Access restriction**: If a module is connected via a modport, it cannot write to signals specified as `input` in that modport.

---

## 5. Tasks and Functions in Interfaces (Clause 25.7, Pages 794–800)

Interfaces can contain subroutines to encapsulate the bus protocol directly:

```systemverilog
interface mem_intf (input logic clk, input logic rst_n);
    // ... signals ...

    task automatic write_data(input logic [3:0] addr, input logic [31:0] data);
        @(posedge clk);
        Address <= addr;
        Data_in <= data;
        WE      <= 1'b1;
        EN      <= 1'b1;
        @(posedge clk);
        WE      <= 1'b0;
        EN      <= 1'b0;
    endtask

    // Modport can export or import tasks
    modport TB_mp (
        import task write_data(input logic [3:0] addr, input logic [31:0] data),
        input  clk, rst_n
    );
endinterface
```

- **`import` in modport (Clause 25.7.2, Page 795)**: The module connected to the modport can *call* the subroutine implemented inside the interface.
- **`export` in modport (Clause 25.7.3, Page 797)**: The module provides the task implementation and exports it through the interface for external modules to invoke.

---

## 6. Parameterized Interfaces (Clause 25.8, Pages 800–802)

Interfaces support parameters, allowing reusable and scalable bus architectures:

```systemverilog
interface custom_bus #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 4
)(
    input logic clk
);
    logic [DATA_WIDTH-1:0] data;
    logic [ADDR_WIDTH-1:0] addr;
endinterface
```

---

## 7. Virtual Interfaces (`virtual interface`) (Clause 25.9, Pages 802–807)

### Why Virtual Interfaces are Vital:
- SystemVerilog **modules and interfaces are static design elements** created at elaboration (compile/elaboration time).
- SystemVerilog **classes (OOP/UVM drivers, monitors, environments) are dynamic** entities created at runtime with `new()`.
- A class **cannot instantiate or directly hierarchically embed a physical interface instance**.
- **Solution**: A `virtual interface` is a variable that serves as a **handle (pointer)** referencing an actual, instantiated interface in the hardware design hierarchy.

### Syntax & Usage Pattern:
```systemverilog
// 1. In dynamic verification class (Driver)
class mem_driver;
    virtual mem_intf vif; // Virtual interface handle

    function new(virtual mem_intf vif);
        this.vif = vif;
    endfunction

    task run();
        vif.Data_in <= 32'hDEADBEEF;
        vif.WE      <= 1'b1;
        vif.EN      <= 1'b1;
        @(posedge vif.clk);
        // ...
    endtask
endclass

// 2. In static top-level testbench module
module top;
    logic clk, rst_n;

    // Physical interface instantiated in static hierarchy:
    mem_intf p_intf (.clk(clk), .rst_n(rst_n));

    // Connect physical interface to DUT:
    Memory16x32 dut (
        .clk(p_intf.clk),
        .rst_n(p_intf.rst_n),
        .Data_in(p_intf.Data_in),
        .WE(p_intf.WE),
        .EN(p_intf.EN),
        .Address(p_intf.Address),
        .Data_out(p_intf.Data_out),
        .Valid_out(p_intf.Valid_out)
    );

    mem_driver drv;

    initial begin
        // Pass physical interface handle to dynamic class object:
        drv = new(p_intf);
        drv.run();
    end
endmodule
```

### Standard Rules & Restrictions for Virtual Interfaces (Clause 25.9, Pages 802–807):

#### 1. Allowed Operations (Clause 25.9, Pages 802–803)
Only the following operations are legal on virtual interface variables:
- **Assignment (`=`)**:
  - Assigning an interface instance of matching type: `vif = top.p_intf;`
  - Assigning another virtual interface: `vif1 = vif2;`
  - Assigning the special constant `null`: `vif = null;`
- **Equality (`==`) and Inequality (`!=`)**:
  - Comparing with another virtual interface of the same type.
  - Comparing with an interface instance.
  - Checking against `null`: `if (vif == null) $fatal(1, "Virtual interface not connected!");`
- **Dot notation (`.`)**: Accessing signals, clocking blocks, tasks, and functions.

#### 2. Strict Restrictions: Where Virtual Interfaces are FORBIDDEN (Clause 25.9, Page 803)
- **Not allowed as module ports**: Modules must use standard or generic interface ports (`mem_intf bus` or `interface bus`), never `virtual mem_intf`.
- **Not allowed as interface items**: An interface cannot declare a virtual interface inside itself.
- **Not allowed as union members**: Virtual interfaces cannot be members of packed or unpacked unions.
- **Procedural statements ONLY**:
  - Virtual interface signals **cannot** be used in continuous assignments (`assign w = vif.sig;` is **illegal**).
  - Virtual interface signals **cannot** appear in sensitivity lists (`always @(vif.sig)` is **illegal**).

#### 3. Driving Nets via Virtual Interface (Clause 25.9, Page 803)
Because virtual interfaces can only be driven procedurally, you **cannot procedurally drive a `wire` (net)** directly through a virtual interface (`vif.my_net = 1'b1;` is illegal).
To drive a net:
- **Approach A (Clocking Block)**: Drive synchronously via a clocking block (`vif.cb.my_net <= 1'b1;`).
- **Approach B (Internal Variable Driver)**: The interface declares an internal variable that continuously assigns to the net:
  ```systemverilog
  interface bus_intf;
      wire net_sig;
      logic var_driver;
      assign net_sig = var_driver; // Internal bridge
  endinterface
  // Driven in class via: vif.var_driver = 1'b1;
  ```

#### 4. Modport Assignment Rules (Clause 25.9, Page 804)
- **Full interface -> Modport interface**: **LEGAL**.
  An interface instance or virtual interface with *no* modport can be assigned to a virtual interface declared *with* a modport:
  ```systemverilog
  virtual mem_intf.DRV_mp vif_drv;
  vif_drv = p_intf; // LEGAL: restricts the handle to DRV_mp view
  ```
- **Modport interface -> Full interface**: **ILLEGAL**.
  You cannot cast a restricted modport handle back to an unrestricted interface.

#### 5. Parameter Matching Rule (Clause 25.9, Page 804)
For parameterized interfaces, the parameter values of the virtual interface declaration **must match exactly** with the physical instance:
```systemverilog
PBus #(16) p16();
virtual PBus #(16) v16;
virtual PBus #(32) v32;

v16 = p16; // LEGAL: parameter values match (16 == 16)
v32 = p16; // ILLEGAL: parameter mismatch (32 != 16) -> elaboration error
```

#### 6. Typedefs and Arrays of Virtual Interfaces (Clause 25.9.1, Page 805)
You can define convenient typedef aliases and instantiate arrays or queues of virtual interfaces for multi-channel testbenches:
```systemverilog
typedef virtual mem_intf.DRV_mp mem_vif_t;

mem_vif_t vifs[4]; // Array of 4 virtual interface handles

initial begin
    vifs[0] = top.mem_inst_0;
    vifs[1] = top.mem_inst_1;
end
```

---

## 8. Summary Checklist for SystemVerilog Interfaces

| Feature | Standard Clause | Page | Practical Purpose |
| :--- | :--- | :--- | :--- |
| **Interface Declaration** | Clause 25.3 | 782 | Bundle related bus signals into a single named construct. |
| **Interface Ports** | Clause 25.4 | 786 | Receive clocks/resets from outside into the interface. |
| **Modports** | Clause 25.5 | 787 | Specify signal directions per role (`DUT`, `Driver`, `Monitor`). |
| **Clocking Blocks** | Clause 25.5.5 | 792 | Eliminate simulation race conditions with synchronous sampling/driving. |
| **Tasks & Functions** | Clause 25.7 | 794 | Write clean protocol driver tasks directly inside the interface. |
| **Parameterized Interface**| Clause 25.8 | 800 | Parameterize bus widths and address depths. |
| **Virtual Interface** | Clause 25.9 | 802 | Provide dynamic verification classes with handles to static interfaces. |
