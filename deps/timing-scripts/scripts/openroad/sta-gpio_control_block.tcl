source $::env(TIMING_ROOT)/env/common.tcl
source $::env(TIMING_ROOT)/env/$::env(LIB_CORNER).tcl

set libs [split [regexp -all -inline {\S+} $libs]]

foreach liberty $libs {
    read_liberty $liberty
}


set verilogs [list \
    $::env(CARAVEL_ROOT)/verilog/gl/gpio_logic_high.v \
    $::env(CARAVEL_ROOT)/verilog/gl/gpio_control_block.v \
]
foreach verilog $verilogs {
    puts "read_verilog $verilog"
    read_verilog $verilog
}

link_design $block

set spef $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef
puts "read_spef $spef"
read_spef $spef

puts "read_spef -path gpio_logic_high $::env(CARAVEL_ROOT)/spef/gpio_logic_high.spef"
read_spef -path gpio_logic_high $::env(CARAVEL_ROOT)/spef/gpio_logic_high.spef

read_sdc -echo $sdc

report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50

report_worst_slack -max 
report_worst_slack -min 

puts "block: $block"
puts "spef: $spef"
puts "verilog: $verilog"
puts "sdf: $sdf"
puts "sdc: $sdc"
puts "rcx-corner: $::env(RCX_CORNER)"
puts "lib-corner: $::env(TIMING_ROOT)/env/$::env(LIB_CORNER).tcl"
