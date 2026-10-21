# ==============================================================================
# Simulation run script for Parameters lab in Questa / ModelSim
# ==============================================================================

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# Compile all SystemVerilog files
vlog -sv module_params.sv interface_params.sv

# Simulate Part 1: Module Parameters (Q1, Q2, Q3)
 echo "==================== SIMULATING MODULE PARAMETERS ===================="
 vsim -c work.top_module_params -do "run -all; quit -sim"

# Simulate Part 2: Interface Parameters (Q1, Q2)
echo "==================== SIMULATING INTERFACE PARAMETERS ===================="
vsim -c work.top_interface_params -do "run -all; quit -sim"

quit -f
