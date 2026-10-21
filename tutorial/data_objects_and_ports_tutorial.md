# SystemVerilog Data Objects (Nets & Variables) and Port Declarations Complete Reference & Tutorial
*Based on IEEE Std 1800™-2023, Clause 6 ("Data Types and Data Objects") & Clause 23 ("Modules and Hierarchy - Port Declarations")*

---

## 1. Introduction: Data Objects in SystemVerilog (Clause 6.5, Page 91)

In SystemVerilog, a **data object** is a named entity that has a data type and holds a value. 

### The Beginner Mental Model: Copper Wire vs. Post-it Note
Before memorizing LRM rules, visualize how they behave in the physical world:
- **Net = A piece of copper wire**:
  A wire has no brain and no memory. It cannot "remember" what voltage was on it a microsecond ago. If you connect a power source, it conducts; if you disconnect the source, it instantly floats to **high-impedance (`'z`)**. It can connect multiple physical outputs together (which fight each other if their values conflict).
- **Variable = A Post-it note / Storage box**:
  A variable is a memory location. If you write the number `5` on it, it will stay `5` forever until someone comes back and writes a new number over it. It cannot have multiple people writing on it at the exact same instant (no multi-driver contention).

---

All SystemVerilog data objects belong to one of these **two fundamental groups**:
1. **Nets** (e.g., `wire`, `tri`, `tri0`, `wand`, `supply0`)
2. **Variables** (e.g., `var`, `logic`, `bit`, `byte`, `int`, `reg`)

```
                       ┌───────────────────────────────┐
                       │     Data Objects (Clause 6.5) │
                       └───────────────┬───────────────┘
                                       │
                ┌──────────────────────┴──────────────────────┐
                ▼                                             ▼
     ┌──────────────────────┐                      ┌──────────────────────┐
     │   Nets (Clause 6.6)  │                      │ Variables (Clause 6.7│
     ├──────────────────────┤                      ├──────────────────────┤
     │ • Copper wire analogy│                      │ • Memory box analogy │
     │ • Does NOT store val │                      │ • Stores its value   │
     │ • Continuously driven│                      │ • Procedural / single│
     │ • Multi-driver OK    │                      │   continuous assign  │
     │ • Default: 'z        │                      │ • NO multi-drivers   │
     │ • Continuous only    │                      │ • Default: 'x or 0   │
     └──────────────────────┘                      └──────────────────────┘
```

---

## 2. Nets (Clause 6.5.1 & 6.6, Pages 91–98)

A **net** represents physical structural wiring between hardware components. 
- A net **does not store a value** in memory.
- Its value is determined continuously by the drivers connected to it. If all drivers disconnect, it floats to high-impedance (`'z`), unless it has pullup/pulldown properties.
- **Assignment rules**: Nets can **only** be driven by:
  - Continuous assignments (`assign net_out = in;`)
  - Gate primitive outputs (`and g1 (out_net, in1, in2);`)
  - Module instance output/inout ports.
- **Illegal**: A net **cannot** be written procedurally inside `initial` or `always` blocks.

### Built-in Net Types (Table 6-1, Page 92)

| Net Type | Resolution Behavior when Multiple Drivers Conflict | Floating Value (No Driver) | Practical Use Case |
| :--- | :--- | :---: | :--- |
| **`wire`** / **`tri`** | Equal-strength conflicts resolve to **`'x`** (unknown). `wire` and `tri` are syntactically identical. | `'z` | Standard point-to-point or shared tristate buses. |
| **`uwire`** | **Unresolved net**: strictly forbids multiple drivers. Compiler flags an error if driven by >1 source! | `'z` | Safety-critical point-to-point buses to prevent unintentional shorts. |
| **`wand`** / **`triand`** | **Wired-AND**: Conflict resolves with bitwise AND. `0` dominates over `1`. | `'z` | Open-collector / wired-AND buses (e.g., I2C bus modeling). |
| **`wor`** / **`trior`** | **Wired-OR**: Conflict resolves with bitwise OR. `1` dominates over `0`. | `'z` | Open-emitter / wired-OR emitter-coupled logic (ECL). |
| **`tri0`** | Conflicts resolve like `wire`. Undriven bits automatically resolve to **`0`** (resistive pulldown). | **`0`** | Pull-down termination lines. |
| **`tri1`** | Conflicts resolve like `wire`. Undriven bits automatically resolve to **`1`** (resistive pullup). | **`1`** | Pull-up termination lines (e.g., active-low interrupt lines). |
| **`supply0`** / **`supply1`** | Represents constant **Ground (0)** and **Power VDD (1)** rails with maximum `supply` drive strength. | N/A | Hardware power/ground distribution modeling. |
| **`trireg`** | **Capacitive storage net**: when all drivers float (`'z`), it holds its last driven charge before decaying. | Holds last value | Dynamic CMOS circuits, pass-transistor logic, charge decay modeling. |

#### Wire / Tri Resolution Truth Table (Table 6-2, Page 92)
Equal-strength driver resolution:
```
  wire/tri │  0  │  1  │  x  │  z  
 ──────────┼─────┼─────┼─────┼─────
     0     │  0  │  x  │  x  │  0  
     1     │  x  │  1  │  x  │  1  
     x     │  x  │  x  │  x  │  x  
     z     │  0  │  1  │  x  │  z  
```

---

## 3. Variables (Clause 6.5.2 & 6.7, Pages 91 & 107–108)

A **variable** is an abstract storage element:
- It **holds its value** from one assignment until the next assignment executes.
- **Assignment rules**:
  - Can be written procedurally inside `initial`, `always`, `always_ff`, `always_comb`, `tasks`, and `functions`.
  - Can also be driven by **a single continuous assignment** (`assign var_out = a & b;`).
  - **Illegal**: Multiple continuous assignments or combining continuous and procedural assignments to the same variable is illegal.
- Variables can be declared with the optional explicit keyword **`var`** (e.g. `var int count;`, `var logic [7:0] bus;`).

### 2-State vs. 4-State Variables & Defaults (Table 6-7, Page 108)

| Data Type | State Model | Signedness | Uninitialized Default Value |
| :--- | :---: | :---: | :---: |
| **`logic`** / **`reg`** | 4-state (`0, 1, x, z`) | Unsigned | **`'x`** |
| **`integer`** | 4-state (`0, 1, x, z`) | Signed (32-bit) | **`'x`** |
| **`time`** | 4-state (`0, 1, x, z`) | Unsigned (64-bit) | **`'x`** |
| **`bit`** | 2-state (`0, 1`) | Unsigned | **`'0`** |
| **`byte`** | 2-state (`0, 1`) | Signed (8-bit) | **`'0`** |
| **`shortint`** | 2-state (`0, 1`) | Signed (16-bit) | **`'0`** |
| **`int`** | 2-state (`0, 1`) | Signed (32-bit) | **`'0`** |
| **`longint`** | 2-state (`0, 1`) | Signed (64-bit) | **`'0`** |
| **`real`** / **`shortreal`** | 2-state | Signed (Floating-point) | **`0.0`** |
| **`string`** | Dynamic | Unsigned | **`""`** (empty string) |
| **`class` handle** | Dynamic handle | N/A | **`null`** |

> [!TIP]
> Use **4-state (`logic`)** for RTL design and interface signals to detect uninitialized states (`'x`) and floating buses (`'z`).
> Use **2-state (`bit`, `int`)** for high-performance OOP testbenches, transaction items, packet counters, and mathematical models to consume less simulation memory and run faster.

### Debunking the Classic Myth: `wire` vs. `reg` vs. `logic`
In traditional Verilog:
- Engineers were taught: *"Use `wire` for continuous `assign`, and `reg` for `always` blocks."*
- **The Myth**: Many beginners wrongly assumed `reg` meant a hardware flip-flop register!
- **The Reality**: In Verilog, `reg` only meant a variable. An `always @(*)` block with a `reg` synthesizes into pure combinational logic (wires/gates), NOT a flip-flop!

**In SystemVerilog (The Solution)**:
- `logic` is introduced as a universal 4-state data type that replaces `reg`.
- In SystemVerilog, `wire` is a **Port/Object Kind (net)**, while `logic` is a **Data Type**.
- Therefore, you can declare:
  - `wire logic a;` $\rightarrow$ A net with 4-state data type.
  - `var logic b;` (or simply `logic b;`) $\rightarrow$ A variable with 4-state data type.
- SystemVerilog allows `logic` to be driven by `always` blocks OR by a single continuous `assign` statement!

---

### The Dangerous Implicit Wire Trap & `` `default_nettype none `` (Clause 22.8, Page 714)
By default in Verilog and SystemVerilog, if you use an undeclared signal name in a continuous assignment or port connection, the compiler **silently creates an implicit 1-bit wire**!

```systemverilog
// DANGEROUS DEFAULT BEHAVIOR:
logic [31:0] data_bus;
assign data_buss = data_bus; // Typo: 'data_buss' with two 's'!
// Simulator silently creates: wire data_buss; (1-bit!)
// Your 32-bit bus is silently truncated to 1 bit with NO compilation error!
```

**The Industry Standard Best Practice**:
Put this directive at the top of your design files:
```systemverilog
`default_nettype none // Turns off automatic implicit wire creation!
```
Now, any misspelled or undeclared signal name immediately produces a **fatal compile-time error**, saving days of debugging!

---

## 4. Port Declarations: The Full Anatomy (Clause 23.2.2, Pages 731–737)

A port declaration consists of four optional tokens:
```systemverilog
[ port_direction ] [ port_kind ] [ data_type ] [ packed_dimensions ] port_name [ unpacked_dimensions ]
```

1. **`port_direction`**: `input`, `output`, `inout`, or `ref`.
2. **`port_kind`**: 
   - A net keyword: `wire`, `tri`, `tri0`, `tri1`, `wand`, `wor`, `uwire`, `supply0`, `supply1`.
   - OR the variable keyword: `var`.
   - OR an `interface` keyword.
3. **`data_type`**: `logic`, `bit`, `byte`, `int`, `integer`, or a user-defined `typedef`.
4. **`dimensions`**: Packed (`[7:0]`) and unpacked (`[0:15]`).

---

## 5. The Golden Rules for Port Defaults (Clause 23.2.2.3, Pages 735–737)

When designers omit keywords (e.g. writing `output logic [7:0] out`), SystemVerilog applies strict standardized rules to determine the **direction**, **kind (net vs var)**, and **data type**:

### A. Rules for the FIRST Port in an ANSI List:
1. **Direction**: If direction is omitted, it defaults to **`inout`**.
2. **Data Type**: If data type is omitted, it defaults to **`logic`**.
3. **Port Kind (Net vs. Variable)**:
   - For **`input`** and **`inout`**: Defaults to a **net** (of type `wire`, or the directive set by `` `default_nettype ``).
   - For **`output`**:
     - If data type is **implicit** (e.g., `output [7:0] x` or `output x`), kind defaults to a **net** (`wire`).
     - If data type is **explicit** (e.g., `output logic [7:0] x` or `output int x`), kind defaults to a **variable** (`var`)!
   - For **`ref`**: Always defaults to a **variable** (`var`). A net can **never** be a `ref` port!

### B. Rules for SUBSEQUENT Ports in an ANSI List:
- If direction, kind, and data type are all omitted, they are **inherited from the preceding port**:
  ```systemverilog
  module du (input [7:0] a, b); // 'b' inherits: input wire logic [7:0]
  ```
- If a new direction is given without kind/type:
  ```systemverilog
  module du (input wire [7:0] a, output b); // 'b' is output wire logic (kind=net)
  ```

### Standard LRM Examples Decoded (Page 736)

```systemverilog
module mh0 (wire x);                 // inout wire logic x
module mh1 (integer x);              // inout wire integer x
module mh3 ([5:0] x);                // inout wire logic [5:0] x
module mh4 (var x);                  // ❌ ERROR: direction defaults to inout, which CANNOT be var!
module mh5 (input x);                // input wire logic x
module mh6 (input var x);            // input var logic x
module mh7 (input var integer x);    // input var integer x
module mh8 (output x);               // output wire logic x  (implicit type -> net)
module mh9 (output var x);           // output var logic x
module mh10(output signed [5:0] x);  // output wire logic signed [5:0] x (implicit -> net)
module mh11(output integer x);       // output var integer x (explicit type -> variable!)
module mh12(ref [5:0] x);            // ref var logic [5:0] x (ref is always var)
```

---

## 6. Port Direction & Data Object Compatibility Matrix (Clause 23.2.2.3 & 23.3.3)

| Port Direction | Allowed as Net Type? (`wire`, `tri0`, etc.) | Allowed as Variable Type? (`var`, `logic`, `bit`, `int`) | Drive & Sampling Semantics |
| :---: | :---: | :---: | :--- |
| **`input`** | **YES** *(Default)* | **YES** (`input var ...`) | Read-only inside module. Continuously sampled from external driver. |
| **`output`** | **YES** | **YES** *(Default with explicit type)* | Driven from inside the module. If variable: single driver only. If net: multiple internal continuous drivers resolve. |
| **`inout`** | **YES** *(Mandatory)* | ❌ **STRICTLY ILLEGAL** | Bidirectional signal. Requires resolution between internal and external drivers. Variables cannot have multiple drivers, so variables can never be `inout`. |
| **`ref`** | ❌ **STRICTLY ILLEGAL** | **YES** *(Mandatory)* | Pass-by-reference. Directly points to the actual external variable in memory. Avoids copies and enables immediate in-place mutation. |
| **`const ref`** | ❌ **STRICTLY ILLEGAL** | **YES** *(Mandatory)* | Pass-by-reference, but marked read-only inside the module. Eliminates copy overhead while protecting against unintended writes. |

---

## 7. Connecting Ports: Design Unit Interconnection Rules (Clause 23.3.3)

When connecting internal module ports to external nets or variables:

```
          EXTERNAL WORLD                       INTERNAL MODULE
  ┌─────────────────────────────┐        ┌─────────────────────────────┐
  │ Variable or Net             │───────▶│ input (Net or Var)          │  (Read-only inside)
  │ Net (wire/tri0)             │◀───────│ output Net (wire/tri0)      │  (Continuous drive)
  │ Net or Variable             │◀───────│ output Var (procedural/cont)│  (Coerced drive)
  │ Net ONLY (wire/tri0)        │◀──────▶│ inout Net (wire/tri0)       │  (Bidir resolution)
  │ Variable ONLY (same type)   │◀══════▶│ ref Var                     │  (Direct memory ref)
  └─────────────────────────────┘        └─────────────────────────────┘
```

### Key Connection Rules:
1. **Connecting to `inout`**:
   - Both the internal port and the external connection **must be a net**.
   - You cannot connect a variable to an `inout` port.
2. **Connecting to `ref`**:
   - The actual external argument **must be a variable** (cannot be a net or an expression like `a + b`).
   - The data type of the actual variable must be **equivalent** to the `ref` port data type.
3. **Connecting `output var` to External `net`**:
   - Inside the module, you assign the variable procedurally (`always_ff`, `always_comb`).
   - The simulator continuously drives the external net with the current value of that internal variable.

### Module Port Connection Styles (Clause 23.3.2, Pages 738–741)
When instantiating a module, you connect signals to its ports using one of four styles:

1. **Positional Connection (`by order`)**:
   ```systemverilog
   Memory16x32 dut (clk, rst_n, data_in, data_out); // Risky: swapping two signals causes silent bugs!
   ```
2. **Explicit Named Connection (`by name`)**:
   ```systemverilog
   Memory16x32 dut (.clk(clk), .rst_n(rst_n), .Data_in(data_in)); // Industry standard: safe and clear
   ```
3. **Implicit Name Connection (`.name` shorthand, Clause 23.3.2.3)**:
   ```systemverilog
   Memory16x32 dut (.clk, .rst_n, .Data_in); // If port name matches signal name exactly!
   ```
4. **Wildcard Named Connection (`.*`, Clause 23.3.2.4)**:
   ```systemverilog
   Memory16x32 dut (.*, .WE(custom_we)); // Automatically connects all ports matching signal names!
   ```

---

## 8. Practical Code Verification Example

Below is a complete, compilable testbench demonstrating `tri0` nets, `var` variables, and all valid port directions across communicating design units:

```systemverilog
// 1. DESIGN UNIT 1: Net-based module with tri0 (PDI pulldown modeling)
module du_tri0_demo (
    input  tri0 logic [3:0] in_bus,   // Pulldown input
    output tri0 logic [3:0] out_bus,  // Pulldown output
    inout  tri0 logic [3:0] bidir_bus // Bidirectional net (MUST be net)
);
    // Continuous assignment to net output
    assign out_bus = in_bus;
    
    // Drive bidir_bus conditionally, else release to 'z (which resolves to 0 on tri0!)
    assign bidir_bus = (in_bus == 4'hA) ? 4'h5 : 4'bz;
endmodule

// 2. DESIGN UNIT 2: Variable-based module (Procedural & Reference mutation)
module du_var_demo (
    input  var bit [7:0] in_val,     // Read-only variable
    output var bit [7:0] out_val,    // Driven procedurally
    ref    var bit [7:0] shared_ref  // Pass-by-reference (in-place modification)
);
    always_comb begin
        out_val = in_val + 8'd10;
    end

    // Mutate the shared variable directly without copying
    task automatic increment_shared();
        shared_ref = shared_ref + 1;
    endtask
endmodule

// 3. TOP VERIFICATION MODULE
module top_ports_tb;
    // Interconnect signals
    tri0 logic [3:0] ext_in, ext_out, ext_bidir;
    bit [7:0] ext_var_in, ext_var_out, ext_shared;

    // Instantiate DU1 (Nets)
    du_tri0_demo du1 (
        .in_bus(ext_in),
        .out_bus(ext_out),
        .bidir_bus(ext_bidir)
    );

    // Instantiate DU2 (Variables)
    du_var_demo du2 (
        .in_val(ext_var_in),
        .out_val(ext_var_out),
        .shared_ref(ext_shared)
    );

    initial begin
        // Test tri0 automatic pulldown: float the bus to 'z
        ext_in = 4'bz;
        #1;
        $display("tri0 Floating Test: ext_out resolves to = %b (Expected: 0000)", ext_out);

        // Test pass-by-reference mutation
        ext_shared = 8'd50;
        du2.increment_shared();
        #1;
        $display("ref Var Test: ext_shared mutated in-place to = %0d (Expected: 51)", ext_shared);
    end
endmodule
```

---

## 9. Quick Decision Checklist for Verification & Design Engineers

```
Need a signal?
│
├── Is it an internal testbench storage, transaction item, or procedural variable?
│    └── USE: var / logic / bit / int (Variable)
│
├── Is it a physical bus with multiple drivers or tri-state lines ('z)?
│    └── USE: wire / tri / tri0 / tri1 (Net)
│
├── Is it a point-to-point connection that must NEVER have multiple drivers?
│    └── USE: uwire (Net) or logic (Variable with single driver)
│
├── Declaring a Port?
│    ├── Need Bidirectional communication?
│    │    └── Direction: inout | Kind: MUST be Net (wire/tri0)
│    │
│    ├── Need Pass-By-Reference for large arrays/objects without memory copying?
│    │    └── Direction: ref or const ref | Kind: MUST be Variable (var)
│    │
│    ├── Driving signal from inside always_ff / always_comb?
│    │    └── Direction: output | Kind: var logic
│    │
│    └── Receiving external clock or reset?
│         └── Direction: input | Kind: wire logic (or input logic)
```
