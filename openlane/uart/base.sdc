set_units -time ns
set ::env(CORE_CLOCK_PERIOD) "10"
set ::env(CORE_CLOCK_PORT)   "app_clk"

######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(CORE_CLOCK_PORT)]  -name $::env(CORE_CLOCK_PORT)  -period $::env(CORE_CLOCK_PERIOD)
set core_input_delay_value [expr $::env(CORE_CLOCK_PERIOD) * 0.6]
set core_output_delay_value [expr $::env(CORE_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$core_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $core_input_delay_value"


set_input_delay 2.0 -clock [get_clocks $::env(CORE_CLOCK_PORT)] {arst_n}

set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_cs*]
set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_addr*]
set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_wr*]
set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_be*]
set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_wdata*]


set_output_delay $core_output_delay_value  -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_rdata*]
set_output_delay $core_output_delay_value  -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_ack*]



# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

