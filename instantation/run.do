
if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vlog -sv *.sv

vsim -c work.TOP

run -all

quit -f