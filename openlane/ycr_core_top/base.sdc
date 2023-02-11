###############################################################################
# Timing Constraints
###############################################################################
create_clock -name core_clk -period 10.0000 [get_ports {clk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold  0.2500 [all_clocks]

set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

set_dont_touch { u_skew_core_clk.* }


#IMEM Constraints
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_cmd_o}]
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_req_o}]
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_addr_o[*]}]
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_bl_o[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_cmd_o}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_req_o}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_addr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2imem_bl_o[*]}]

set_input_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_req_ack_i}]
set_input_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_rdata_i[*]}]
set_input_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_resp_i[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_req_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_rdata_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {imem2core_resp_i[*]}]

#DMEM Constraints
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_cmd_o}]
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_req_o}]
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_addr_o[*]}]
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_wdata_o[*]}]
set_output_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_width_o[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_cmd_o}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_req_o}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_addr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_wdata_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core2dmem_width_o[*]}]

set_input_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_req_ack_i}]
set_input_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_rdata_i[*]}]
set_input_delay -max 7.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_resp_i[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_req_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_rdata_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {dmem2core_resp_i[*]}]

###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} [all_inputs]
set cap_load 0.0334
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

set_max_transition 1.00 [current_design]
set_max_capacitance 0.2 [current_design]
set_max_fanout 10 [current_design]
###############################################################################
# Design Rules
###############################################################################
