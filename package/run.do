# QuestaSim / ModelSim DO-script for Package Q1
# Usage: vsim -c -do run.do

# Create and map work library
if [file exists work] {
    vdel -lib work -all
}
vlib work
vmap work work

echo ""
echo "=============================================================="
echo " CASE 1: Solution 1 (Direct Import 'import pack1::*' in top)"
echo "=============================================================="
vlog -sv static_vs_dynamic_demo.sv
vsim -c static_vs_dynamic_demo
run -all

quit -f
