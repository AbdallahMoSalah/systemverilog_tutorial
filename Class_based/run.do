# ==============================================================================
# Simulation run script for Class-based Memory Verification in Questa / ModelSim
# ==============================================================================

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# Compile DUT, Interface, Test Class, and Top module in a single compilation unit
vlog -sv -mfcu +acc ../LAB1_Ver_plan/Memory16x32.sv mem_intf.sv test_class.sv top.sv

# Elaborate and simulate top module with full visibility
vsim -voptargs="+acc" work.top

# Add waveforms for GUI mode
add wave -position insertpoint sim:/top/clk
add wave -group "Interface" -position insertpoint sim:/top/intf/*
add wave -group "DUT Internal" -position insertpoint sim:/top/dut/*

# Run full test
run -all
