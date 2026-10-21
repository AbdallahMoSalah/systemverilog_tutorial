vlib work
vlog pipeline_reg.sv alu.sv ctrl_unit.sv memory.sv pu_core.sv pu_top.sv tb_pu_top.sv
vsim -voptargs=+acc work.tb_pu_top
add wave -position insertpoint sim:/tb_pu_top/*
add wave -position insertpoint sim:/tb_pu_top/dut/u_pu_core/*
run -all
