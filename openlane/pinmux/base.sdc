###############################################################################
# Created by write_sdc
# Thu Nov 11 05:33:42 2021
###############################################################################
current_design pinmux
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name mclk -period 10.0000 [get_ports {mclk}]
set_propagated_clock [get_clocks {mclk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]

set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

### ClkSkew Adjust
set_case_analysis 0 [get_ports {cfg_cska_pinmux[0]}]
set_case_analysis 0 [get_ports {cfg_cska_pinmux[1]}]
set_case_analysis 0 [get_ports {cfg_cska_pinmux[2]}]
set_case_analysis 0 [get_ports {cfg_cska_pinmux[3]}]


set_max_delay   3.5 -from [get_ports {wbd_clk_int}]
set_max_delay   2 -to   [get_ports {wbd_clk_pinmux}]
set_max_delay 3.5 -from wbd_clk_int -to wbd_clk_pinmux

set_input_delay 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {h_reset_n}]

set_input_delay -max 4.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_addr[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_be[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_cs}]
set_input_delay -max 4.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_wdata[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_wr}]

set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_addr[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_be[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_cs}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_wdata[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_wr}]


set_output_delay -max 1.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_ack}]
set_output_delay -max 1.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_rdata[*]}]

set_output_delay -min -3.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_ack}]
set_output_delay -min -3.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_rdata[*]}]


set_output_delay -max 1.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {qspim_rst_n}]
set_output_delay -min -3.000 -clock [get_clocks {mclk}] -add_delay [get_ports {qspim_rst_n}]

###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]
###############################################################################
# Design Rules
###############################################################################
