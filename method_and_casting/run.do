# ==============================================================================
# Simulation run script for Questa / ModelSim
# ==============================================================================

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# Compile all SystemVerilog files in the folder
vlog -sv *.sv

# Simulate Methods (Function & Task)
echo "==================== SIMULATING Q1 FUNCTION ===================="
vsim -c work.q1_function -do "run -all; quit -sim"

echo "==================== SIMULATING Q2 TASK ===================="
vsim -c work.q2_task -do "run -all; quit -sim"

# Simulate Casting (Static & Dynamic)
echo "==================== SIMULATING STATIC CASTING ===================="
vsim -c work.casting_static -do "run -all; quit -sim"

echo "==================== SIMULATING DYNAMIC CASTING ===================="
vsim -c work.casting_dynamic -do "run -all; quit -sim"

quit -f
