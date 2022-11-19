###############################################################################
# Timing Constraints
###############################################################################
create_clock -name core_clk -period 10.0000 [get_ports {core_clk}]

create_generated_clock -name sram0_clk0 -add -source [get_ports {core_clk}] -master_clock [get_clocks core_clk] -divide_by 1 -comment {tcm clock0} [get_ports sram0_clk0]
create_generated_clock -name sram0_clk1 -add -source [get_ports {core_clk}] -master_clock [get_clocks core_clk] -divide_by 1 -comment {tcm clock1} [get_ports sram0_clk1]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]

set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

set_case_analysis 0 [get_ports {cfg_sram_lphase[0]}]
set_case_analysis 0 [get_ports {cfg_sram_lphase[1]}]

#CORE-0 IMEM Constraints
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_cmd}]
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_req}]
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_addr[*]}]
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_bl[*]}]

set_input_delay -min 1.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_cmd}]
set_input_delay -min 1.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_req}]
set_input_delay -min 1.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_addr[*]}]
set_input_delay -min 1.0000  -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_bl[*]}]

set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_req_ack}]
set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_rdata[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_imem_rdata[*]}]

#CORE-0 DMEM Constraints
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_cmd}]
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_req}]
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_addr[*]}]
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_wdata[*]}]
set_input_delay -max 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_width[*]}]

set_input_delay -min 1.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_cmd}]
set_input_delay -min 1.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_req}]
set_input_delay -min 1.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_addr[*]}]
set_input_delay -min 1.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_wdata[*]}]
set_input_delay -min 1.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_width[*]}]

set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_req_ack}]
set_output_delay -max 4.5000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_rdata[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {core0_dmem_rdata[*]}]

## PORT-0 TCM I/F
set_output_delay -min -1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_csb0}]
set_output_delay -min -1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_web0}]
set_output_delay -min -1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_addr0[*]}]
set_output_delay -min -1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_wmask0[*]}]
set_output_delay -min -1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_din0[*]}]

set_output_delay -max 1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_csb0}]
set_output_delay -max 1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_web0}]
set_output_delay -max 1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_addr0[*]}]
set_output_delay -max 1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_wmask0[*]}]
set_output_delay -max 1.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_din0[*]}]

set_input_delay  -min 2.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_dout0[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {sram0_clk0}] -add_delay  [get_ports {sram0_dout0[*]}]


## PORT-1 TCM1 I/F
set_output_delay -min -1.0000 -clock [get_clocks {sram0_clk1}] -add_delay  [get_ports {sram0_csb1}]
set_output_delay -min -1.0000 -clock [get_clocks {sram0_clk1}] -add_delay  [get_ports {sram0_addr1[*]}]

set_output_delay -max 1.000 -clock [get_clocks {sram0_clk1}] -add_delay  [get_ports {sram0_csb1}]
set_output_delay -max 1.000 -clock [get_clocks {sram0_clk1}] -add_delay  [get_ports {sram0_addr1[*]}]

set_input_delay  -min 2.0000 -clock [get_clocks {sram0_clk1}] -add_delay  [get_ports {sram0_dout1[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {sram0_clk1}] -add_delay  [get_ports {sram0_dout1[*]}]


set_max_delay 5 -to [get_ports core_icache_req]
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
