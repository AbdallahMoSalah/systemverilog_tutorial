# SystemVerilog Classes & OOP Complete Reference & Tutorial
*Based on IEEE Std 1800™-2023, Clause 8 ("Classes")*

---

## 1. Introduction: What is a Class in SystemVerilog? (Clause 8.1 & 8.2, Page 179)
Traditional Verilog is purely **static** (modules, gates, nets) synthesized or elaborated once before simulation starts. 

SystemVerilog introduced **Object-Oriented Programming (OOP)** through **classes**:
- **Dynamic Lifetime**: Objects are created dynamically on the heap during simulation using `new()` and reclaimed automatically when no longer referenced (garbage collection).
- **Separation of Structure vs. Behavior**: Hardware (DUT) is modeled using static modules/interfaces, while verification testbenches (stimulus, checkers, scoreboards) are modeled using dynamic OOP classes.
- **Safe Pointers**: Class variables store **handles** (safe reference pointers), preventing raw pointer bugs.

---

## 2. Class Definitions, Objects & Handles (Clause 8.3 & 8.4, Pages 180–182)

### A. Syntax (Clause 8.3, Page 180)
```systemverilog
[ virtual ] class [ final ] class_identifier [ #( parameter_list ) ]
    [ extends base_class_identifier ]
    [ implements interface_class_1, ... ];
    
    // Class properties (data variables)
    // Class methods (tasks and functions)
    // Constraints (for randomization)
    // Covergroups (for functional coverage)
endclass [ : class_identifier ]
```

### B. Handle vs. Object (Clause 8.4, Page 181)
- **Handle**: A variable that holds the memory address of an object. Default value before instantiation is `null`.
- **Object**: The actual allocated data structure residing in heap memory, created via `new()`.

```systemverilog
Packet pkt;       // Handle declared; currently pkt == null (NO memory allocated)
pkt = new();      // Object created on the heap; 'pkt' now holds its handle
```

> [!WARNING]
> Attempting to read or write class properties using a `null` handle results in a fatal simulation runtime error (Null Pointer Dereference).

---

## 3. Constructors: `new()` (Clause 8.7 & 8.8, Pages 184–185)

The `new` constructor is a special built-in function that allocates memory on the heap and initializes properties:
```systemverilog
class Packet;
    bit [31:0] addr;
    bit [31:0] data;

    // Custom constructor with default arguments
    function new(bit [31:0] a = 32'h0, bit [31:0] d = 32'h0);
        this.addr = a;
        this.data = d;
    endfunction
endclass

// Instantiation:
Packet p1 = new();                   // addr = 0, data = 0
Packet p2 = new(32'h1000, 32'hDEAD); // addr = 0x1000, data = 0xDEAD
```

> [!NOTE]
> `new()` is strictly a **function**, never a **task**. Therefore, it can **never consume simulation time** (it cannot contain timing controls like `#delay`, `@(posedge clk)`, or `wait`).

---

## 4. `this` and `super` Keywords (Clause 8.11 & 8.15, Pages 187 & 191)

1. **`this` (Clause 8.11, Page 187)**:
   A predefined handle pointing to the current instance. Used to disambiguate class properties from method arguments with identical names:
   ```systemverilog
   function void set_addr(bit [31:0] addr);
       this.addr = addr; // this.addr is property; addr is argument
   endfunction
   ```

2. **`super` (Clause 8.15, Page 191)**:
   Refers to member properties or methods of the immediate base (parent) class. Used in derived classes to invoke overridden methods or parent constructors:
   ```systemverilog
   function new(bit [31:0] a, bit [31:0] d);
       super.new(a, d); // Call parent constructor (Constructor Chaining)
   endfunction
   ```

---

## 5. Static Members & Scope Resolution `::` (Clause 8.9, 8.10, & 8.23, Pages 186 & 200)

By default, class properties and methods belong to individual instances. The `static` keyword shares members across all instances:

```systemverilog
class Packet;
    static int pkt_count = 0; // Shared across ALL instances of Packet
    int id;                   // Unique per instance

    function new();
        pkt_count++;
        this.id = pkt_count;
    endfunction

    // Static method: can be called even without an object instance
    static function void print_total();
        $display("Total packets created: %0d", pkt_count);
        // Note: Static methods CANNOT access non-static properties like 'id'
        // because there is no 'this' instance context!
    endfunction
endclass

module top;
    initial begin
        Packet p1 = new();
        Packet p2 = new();
        
        // Calling static method using scope resolution operator ::
        Packet::print_total(); // Prints: 2
    end
endmodule
```

---

## 6. Object Copying: Shallow vs. Deep Copy (Clause 8.12, Pages 187–189)

Understanding how objects duplicate is critical in verification when cloning transactions:

### A. Handle Assignment (No Copy)
```systemverilog
p2 = p1; // Both p1 and p2 point to the EXACT SAME object in memory.
```

### B. Shallow Copy (`new id_or_handle`) (Clause 8.12, Page 188)
Copies all immediate primitive properties, but nested object handles are **shared** (not duplicated):
```systemverilog
p2 = new p1; // Creates new Packet object for p2, but sub-objects remain shared!
```

### C. Deep Copy (Custom Method)
Creates a completely independent copy, including all nested child objects:
```systemverilog
class Header;
    bit [7:0] len;
endclass

class Packet;
    Header hdr;
    bit [31:0] data;

    function new();
        hdr = new();
    endfunction

    // Deep copy implementation
    function Packet copy();
        copy = new();
        copy.data = this.data;
        copy.hdr.len = this.hdr.len; // New sub-object duplicated
    endfunction
endclass
```

---

## 7. The 4 Pillars of OOP in SystemVerilog

### Pillar 1: Encapsulation & Data Hiding (Clause 8.18, Page 194)
Controls visibility and protects internal state:
- **`public` (default)**: Accessible by anyone with an object handle.
- **`protected`**: Accessible only within the class and its derived subclasses (`extends`).
- **`local`**: Accessible strictly inside the declaring class itself (hidden even from child classes).

```systemverilog
class Account;
    local int secret_key;       // Strictly private to Account
    protected int balance;      // Available to Account and derived classes
    string user_name;           // Public: accessible to all
endclass
```

---

### Pillar 2: Inheritance (`extends`) (Clause 8.13 & 8.17, Pages 189 & 192)
Allows child classes to inherit properties and methods from a parent class:

```systemverilog
// Base class
class Packet;
    bit [31:0] addr;
    function new(bit [31:0] addr);
        this.addr = addr;
    endfunction
endclass

// Derived class
class EthPacket extends Packet;
    bit [47:0] mac_dest;

    function new(bit [31:0] addr, bit [47:0] mac);
        super.new(addr); // Mandatory constructor chaining
        this.mac_dest = mac;
    endfunction
endclass
```

---

### Pillar 3: Polymorphism & `virtual` Methods (Clause 8.20 & 8.22, Pages 195–200)

**Polymorphism** allows a parent handle to refer to a child object and execute the child's specialized implementation.

> [!IMPORTANT]
> In SystemVerilog, methods are **non-virtual by default**. If a method is not marked `virtual`, method calls are resolved statically based on the **handle type**, NOT the underlying object type!

```systemverilog
class BasePacket;
    virtual function void display();
        $display("Base Packet");
    endfunction
endclass

class ErrorPacket extends BasePacket;
    virtual function void display(); // Overridden
        $display("Error Packet with Corrupted CRC");
    endfunction
endclass

module top;
    initial begin
        BasePacket b_handle;
        ErrorPacket e_obj = new();

        b_handle = e_obj; // Upcasting (legal): parent handle points to child object
        
        // Polymorphic call: executes ErrorPacket::display() because 'display' is virtual!
        b_handle.display(); // Output: "Error Packet with Corrupted CRC"
    end
endmodule
```

#### Upcasting & Downcasting (`$cast`) (Clause 8.16, Page 191)

Class handles are **viewing lenses** pointing to objects in memory:
- **Upcasting (`parent_handle = child_handle;`)**:
  - Always legal, implicit, and checked at compile time.
  - The parent handle now points to the child object in memory. However, through the parent handle, the compiler only permits access to base-class members (`speed`). Child-specific members (`battery`) are hidden.
- **Downcasting (`$cast(child_handle, parent_handle);`)**:
  - Direct assignment (`child_handle = parent_handle;`) is **strictly illegal** at compile time (Clause 8.16). The compiler cannot know what type of object `parent_handle` will hold during execution.
  - `$cast` performs a dynamic runtime check: it verifies whether the object in heap memory is actually an instance of the destination subclass (or one of its descendants).

##### The Practical Verification Pattern:
> [!NOTE]
> If you create an object with `cc = new(); cp = cc; $cast(cc, cp);` in a single local block, `$cast` seems redundant because `cc` already pointed to that object!
> In actual verification environments, **the receiver never had the child handle (`cc`)**. The receiver only receives the generic base handle (`cp`) and uses `$cast` to access specialized child features.

```systemverilog
class car;
    int speed = 60;
endclass

class Ecar extends car;
    int battery = 100; // Specialized child property
endclass

// Component that handles cars generically
class ServiceStation;
    task service_vehicle(car cp); // Receives generic base handle
        Ecar ec; // Local child handle (initially null)

        // ❌ ILLEGAL (Compile-time error):
        // ec = cp; 

        // ✅ LEGAL: Dynamic runtime check with $cast
        if ($cast(ec, cp)) begin
            $display("Electric car detected! Battery level: %0d%%", ec.battery);
            ec.battery = 100; // Safely access specialized property
        end else begin
            $display("Standard gas vehicle. Speed: %0d", cp.speed);
        end
    endtask
endclass

module tb;
    initial begin
        ServiceStation station = new();
        Ecar tesla = new();
        car  toyota = new();

        // Upcast happens implicitly when passing 'tesla' into 'car cp':
        station.service_vehicle(tesla);  // $cast SUCCEEDS inside task!

        station.service_vehicle(toyota); // $cast FAILS safely inside task!
    end
endmodule
```

##### `$cast` Success vs Failure Rules:
1. **Succeeds**: If the object in memory was originally created as an `Ecar` (or subclass of `Ecar`).
2. **Fails**: If the object in memory was created as a base `car` (cannot invent a `battery` out of thin air) or if the handle is `null`.
3. **Syntax**:
   - **Task form**: `$cast(dest, src);` $\rightarrow$ Throws a fatal run-time error if cast fails.
   - **Function form (Best Practice)**: `if ($cast(dest, src)) ... else ...` $\rightarrow$ Returns 1 on success, 0 on failure without crashing simulation.

---

### Pillar 4: Abstraction (Clause 8.21 & 8.26, Pages 198 & 206)

#### A. Abstract Classes (`virtual class`) & `pure virtual` Methods (Clause 8.21, Page 198)
- A `virtual class` cannot be directly instantiated (`new()` is illegal on it).
- It serves as a base blueprint. Subclasses must implement all `pure virtual` methods:

```systemverilog
virtual class DriverBase;
    pure virtual task drive_packet(); // Must be implemented by child classes
endclass

class AXI_Driver extends DriverBase;
    virtual task drive_packet();
        // Specific AXI driving logic
    endtask
endclass
```

#### B. Interface Classes (`interface class` & `implements`) (Clause 8.26, Page 206)
SystemVerilog does not support multiple inheritance for standard classes (`extends A, B` is illegal). However, it supports multiple inheritance of interface specifications using `interface class`:

```systemverilog
interface class ResetCapable;
    pure virtual function void do_reset();
endinterface

interface class LogCapable;
    pure virtual function void dump_log();
endinterface

// A class can implement multiple interface classes:
class Agent extends uvm_agent implements ResetCapable, LogCapable;
    virtual function void do_reset(); /* ... */ endfunction
    virtual function void dump_log(); /* ... */ endfunction
endclass
```

---

## 8. Parameterized Classes (Clause 8.25, Pages 203–205)

Classes can accept parameters (data types or values), making them reusable:

```systemverilog
class Mailbox #(type T = int, int DEPTH = 16);
    local T queue[$];

    function void put(T item);
        if (queue.size() < DEPTH) queue.push_back(item);
    endfunction

    function T get();
        return queue.pop_front();
    endfunction
endclass

// Usage:
Mailbox #(string, 32) str_box = new();
Mailbox #(bit [63:0]) data_box = new();
```

---

## 9. Forward Class Declarations: `typedef class` (Clause 8.27, Pages 215–216)

### A. The Circular Dependency Problem
SystemVerilog compilers read source files linearly from top to bottom. If two classes reference each other (e.g. `Parent` needs a handle to `Child`, and `Child` needs a handle to `Parent`):
- If you declare `Parent` first, the compiler complains that `Child` is an unknown type.
- If you declare `Child` first, the compiler complains that `Parent` is an unknown type.

This mutual dependency is impossible to compile without a **forward declaration**.

### B. Syntax & Solution (Clause 8.27, Page 216)
You inform the compiler ahead of time that an identifier will be defined as a class later:

```systemverilog
typedef class Child; // Forward declaration: tells compiler "Child is a class, trust me!"
// Note: 'typedef Child;' is also legal and equivalent

class Parent;
    Child child_h; // LEGAL: Compiler knows Child is a class handle

    function void set_child(Child c);
        this.child_h = c;
    endfunction
endclass

class Child;
    Parent parent_h; // LEGAL: Parent is already fully defined above

    function new(Parent p);
        this.parent_h = p;
    endfunction
endclass
```

### C. Rules & Compiler Resolution (Clause 8.27 & Clause 6.18, Page 119):
1. **Handles & Arguments**: Declaring handles (`Child c;`), method arguments, and return types is immediately valid upon forward declaration.
2. **Two-Pass Method Body Resolution**:
   - Modern simulators (QuestaSim, VCS) resolve procedural method bodies in a second pass. Therefore, accessing members (`b_h.data = 100;`) inside a function or task **compiles cleanly** as long as the class definition appears later in the compilation unit.
   - If the class definition is missing or if the accessed member does not exist in the target class, Pass 2 flags an error: `Could not find field/method name`.
3. **Incomplete Type Restrictions (Clause 6.18, Page 119)**:
   - Prior to its full definition, a forward class is an **incomplete type**.
   - Directly resolving scoped types for variable declarations (`ClassB::my_type var;`) is **strictly illegal** prior to the full definition.
   - The forward declaration **must** be resolved within the same local scope or file; otherwise, the compiler flags: `Forward declaration for type was not defined`.

---

## 10. Out-of-Block Method Declarations: `extern` (Clause 8.24, Pages 202–203)

In professional verification (and especially UVM), class declarations can become hundreds of lines long. To keep the class definition clean, readable, and structured like an API, methods can be prototyped inside the class with `extern` and defined outside using the class scope operator `::`:

```systemverilog
class Packet;
    bit [31:0] addr;
    bit [31:0] data;

    // 1. Prototype declarations inside class with 'extern'
    extern function new(bit [31:0] addr, bit [31:0] data);
    extern virtual function void print();
    extern task send();
endclass

// 2. Full method implementations outside class using ClassName::
function Packet::new(bit [31:0] addr, bit [31:0] data);
    this.addr = addr;
    this.data = data;
endfunction

function void Packet::print();
    $display("Addr: 0x%0h, Data: 0x%0h", addr, data);
endfunction

task Packet::send();
    // Timing and protocol drive logic
endtask
```

> [!TIP]
> Qualifiers like `virtual`, `protected`, and `local` are specified **only in the prototype inside the class**, not repeated in the out-of-block implementation.

---

## 11. Constant Class Properties: `const` (Clause 8.19, Page 195)

SystemVerilog classes support two distinct forms of read-only constants:

### A. Global Constants
Initialized at declaration. Every instance of the class shares the exact same constant value:
```systemverilog
class Frame;
    const int MAX_PAYLOAD = 1500; // Global constant (identical for all Frames)
endclass
```

### B. Instance Constants
Declared without an initial value, and assigned **once during object construction inside `new()`**. Once assigned in `new()`, they become strictly read-only for that specific object instance:
```systemverilog
class Transaction;
    const int transaction_id; // Instance constant: unique per object!

    function new(int id);
        this.transaction_id = id; // Assigned once in new()
    endfunction

    function void modify();
        // ❌ COMPILE ERROR: Cannot write to a const property outside new()!
        // this.transaction_id = 99; 
    endfunction
endclass
```

---

## 12. Memory Management & Object Lifetime (Clause 8.29 & 8.30, Pages 216–218)

### A. Automatic Garbage Collection (Clause 8.29, Page 216)
Unlike C/C++ (`malloc` and `free` / `delete`), **SystemVerilog has no manual deallocation keyword**.
- Memory is automatically allocated when `new()` is called.
- The simulator tracks the number of active handles pointing to each object (Reference Counting / Reachability).
- When the last handle pointing to an object is reassigned or set to `null`, the object becomes orphaned and is **automatically reclaimed** by the garbage collector:

```systemverilog
Packet p1 = new(); // Object A allocated in memory (1 reference)
Packet p2 = p1;    // Object A now has 2 references

p1 = null;         // Object A still exists (p2 points to it)
p2 = null;         // Object A has 0 references -> Automatically freed by Garbage Collector!
```

### B. Weak References: `std::weak_reference` (Clause 8.30, Pages 217–218)
Introduced in IEEE Std 1800-2023:
When two objects hold normal (strong) handles to each other (circular reference: A points to B, B points to A), neither object's reference count drops to zero, causing a simulation memory leak!
`std::weak_reference` allows referencing an object without preventing the garbage collector from reclaiming it when no strong references remain.

---

## 13. Classes in Verification Architecture Summary

| Verification Component | SV / UVM Class Role | Why OOP is Essential |
| :--- | :--- | :--- |
| **Transaction / Sequence Item** | `class my_seq_item extends uvm_sequence_item` | Dynamic generation, randomization (`rand`), cloning, deep copying. |
| **Driver / Monitor** | `class my_driver extends uvm_driver` | Modular, polymorphic execution, connecting to hardware via `virtual interface`. |
| **Scoreboard / Predictor** | `class my_scoreboard extends uvm_scoreboard` | Abstract reference models, transaction queues, dynamically tracking state. |
| **Environment / Test** | `class my_env extends uvm_env` | Hierarchical composition and reuse across multiple chip projects. |
