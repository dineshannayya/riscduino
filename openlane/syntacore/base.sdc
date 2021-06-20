set_units -time ns
#Wishbone Clock
set ::env(WB_CLOCK_PERIOD)    "10"
set ::env(WB_CLOCK_PORT)      "wb_clk"

#Risc Core Clock
set ::env(CORE_CLOCK_PERIOD) "50"
set ::env(CORE_CLOCK_PORT)   "core_clk"

######################################
# CORE Clock domain input output
######################################
create_clock [get_ports $::env(CORE_CLOCK_PORT)]  -name $::env(CORE_CLOCK_PORT)  -period $::env(CORE_CLOCK_PERIOD)
set core_input_delay_value [expr $::env(CORE_CLOCK_PERIOD) * 0.6]
set core_output_delay_value [expr $::env(CORE_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting core output delay to: $core_output_delay_value"
puts "\[INFO\]: Setting core input delay to: $core_input_delay_value"
set core_clk_indx [lsearch [all_inputs] [get_port $::env(CORE_CLOCK_PORT)]]
set core_rst_indx [lsearch [all_inputs] [get_port cpu_rst_n]]
set all_inputs_wo_core_clk_rst [lreplace [all_inputs] $core_clk_indx $core_rst_indx]
set all_outputs_core [all_outputs] 

set_input_delay $core_input_delay_value  -clock [get_clocks $::env(CORE_CLOCK_PORT)] $all_inputs_wo_core_clk_rst
set_input_delay 5.0 -clock [get_clocks $::env(CORE_CLOCK_PORT)] {cpu_rst_n}
set_output_delay $core_output_delay_value  -clock [get_clocks $::env(CORE_CLOCK_PORT)] $all_outputs_core

######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(WB_CLOCK_PORT)]  -name $::env(WB_CLOCK_PORT)  -period $::env(WB_CLOCK_PERIOD)
set wb_input_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
set wb_output_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"
set wb_clk_indx [lsearch [all_inputs] [get_port $::env(WB_CLOCK_PORT)]]
set wb_rst_indx [lsearch [all_inputs] [get_port wb_rst_n]]
set all_inputs_wo_wb_clk_rst [lreplace [all_inputs] $wb_clk_indx $wb_rst_indx]
set all_outputs_wb [all_outputs]

set_input_delay $wb_input_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] $all_inputs_wo_wb_clk_rst
set_input_delay 5.0 -clock [get_clocks $::env(WB_CLOCK_PORT)] {wb_rst_n}
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] $all_outputs_wb


# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]
