###############################################################################
# Timing Constraints
###############################################################################
create_clock -name core_clk -period 8.0000 [get_ports {core_clk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.2500 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]

set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

#CORE-0 IMEM Constraints
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_cmd}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_req}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_addr[*]}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_bl[*]}]

set_input_delay -min 2.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_cmd}]
set_input_delay -min 2.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_req}]
set_input_delay -min 2.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_addr[*]}]
set_input_delay -min 2.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_bl[*]}]

set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_req_ack}]
set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_rdata[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_rdata[*]}]

#CORE-0 DMEM Constraints
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_cmd}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_req}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_addr[*]}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_wdata[*]}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_width[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_cmd}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_req}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_addr[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_wdata[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_width[*]}]

set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_req_ack}]
set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_rdata[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_rdata[*]}]

#CORE-1 IMEM Constraints
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_cmd}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_req}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_addr[*]}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_bl[*]}]

set_input_delay -min 2.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_cmd}]
set_input_delay -min 2.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_req}]
set_input_delay -min 2.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_addr[*]}]
set_input_delay -min 2.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_bl[*]}]

set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_req_ack}]
set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_rdata[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_imem_rdata[*]}]

#CORE-1 DMEM Constraints
set_input_delay  -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_cmd}]
set_input_delay  -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_req}]
set_input_delay  -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_addr[*]}]
set_input_delay  -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_wdata[*]}]
set_input_delay  -max 8.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_width[*]}]

set_input_delay  -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_cmd}]
set_input_delay  -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_req}]
set_input_delay  -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_addr[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_wdata[*]}]
set_input_delay  -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_width[*]}]

set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_req_ack}]
set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_rdata[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core1_dmem_rdata[*]}]

###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} [all_inputs]
set cap_load 0.0334
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

###############################################################################
# Design Rules
###############################################################################
