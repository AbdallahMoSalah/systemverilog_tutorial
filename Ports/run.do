# ==============================================================================
# Simulation run script for Ports lab in Questa / ModelSim
# ==============================================================================

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# Compile all SystemVerilog files in the Ports folder
vlog -sv ports_q1.sv ports_q2.sv ports_q3.sv

# Simulate top module testing Q1, Q2, and Q3
echo "==================== SIMULATING PORTS LAB ===================="
vsim -c work.top_ports -do "run -all; quit -sim"

quit -f
