###############################################################################
# Created by write_sdc
# Fri Nov 12 05:00:05 2021
###############################################################################
current_design wb_interconnect
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk_i    -period 10.0000 [get_ports {clk_i}]
create_clock -name mclk_raw -period 10.0000 [get_ports {mclk_raw}]

set_clock_groups \
   -name async_group \
   -logically_exclusive \
   -group [get_clocks {clk_i}]\
   -group [get_clocks {mclk_raw}]\
   -comment {Async Clock group}

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]

# check ocv table (not provided) -- maybe try 8% 
set derate 0.0375
puts "\[INFO\]: Setting derate factor to: [expr $derate * 100] %"
set_timing_derate -early [expr 1-$derate]
set_timing_derate -late [expr 1+$derate]

#Clock Skew adjustment
set_case_analysis 0 [get_ports {cfg_cska_wi[0]}]
set_case_analysis 0 [get_ports {cfg_cska_wi[1]}]
set_case_analysis 0 [get_ports {cfg_cska_wi[2]}]
set_case_analysis 0 [get_ports {cfg_cska_wi[3]}]


# Set max delay for clock skew
#set_max_delay 4.0 -from [get_ports {wbd_clk_int}]
#set_max_delay   2 -to   [get_ports {wbd_clk_wi}]
#set_max_delay 4.0 -from wbd_clk_int -to wbd_clk_wi

## Don't touch delay cells
set_dont_touch { u_skew_wi.* }
##
set_input_delay -max 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {rst_n}]

set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_adr_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_dat_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_adr_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_adr_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_ack_i}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_dat_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_ack_i}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_dat_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_ack_i}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_dat_i[*]}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_ack_i}]
set_input_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_dat_i[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_adr_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_sel_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_adr_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_sel_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_adr_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_sel_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_dat_i[*]}]

set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_ack_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_dat_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_err_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_ack_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_dat_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_err_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_ack_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_dat_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_err_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_adr_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_cyc_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_dat_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_sel_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_stb_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_we_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_adr_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_cyc_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_dat_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_sel_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_stb_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_we_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_adr_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_cyc_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_dat_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_sel_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_stb_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_we_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_adr_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_cyc_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_dat_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_sel_o[*]}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_stb_o}]
set_output_delay -max 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_we_o}]

set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_ack_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m0_wbd_err_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_ack_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m1_wbd_err_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_ack_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {m2_wbd_err_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_cyc_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_sel_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s0_wbd_we_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_cyc_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_sel_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s1_wbd_we_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_cyc_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_sel_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s2_wbd_we_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_cyc_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_sel_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {s3_wbd_we_o}]

###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

set_max_transition 1.00 [current_design]
set_max_capacitance 0.2 [current_design]
set_max_fanout 10 [current_design]

###############################################################################
set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]
###############################################################################
# Design Rules
###############################################################################
