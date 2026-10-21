# QuestaSim / ModelSim DO-script for Compiler Directives Q1
# Usage: vsim -c -do run.do

# Create and map work library
if [file exists work] {
    vdel -lib work -all
}
vlib work
vmap work work

echo ""
echo "=============================================================="
echo " Compiling and Simulating Compiler Directives Q1"
echo "=============================================================="
vlog -sv compiler_directives_q1.sv
vsim -c top
run -all

quit -f
