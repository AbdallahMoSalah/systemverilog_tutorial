# ==============================================================================
# Simulation run script for Ports lab in Questa / ModelSim
# ==============================================================================

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# Compile all SystemVerilog files in folder
vlog -sv *.sv

# Simulate top module testing Q1, Q2, and Q3
echo "==================== SIMULATING LAB ===================="
vsim -c work.top -do "run -all; quit -sim"

quit -f
