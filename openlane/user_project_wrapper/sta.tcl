# SPDX-FileCopyrightText:  2021 , Dinesh Annayya
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>


set ::env(LIB_FASTEST) "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib"
set ::env(LIB_SLOWEST) "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib"
set ::env(DESIGN_NAME) "user_project_wrapper"
set ::env(BASE_SDC_FILE) "base.sdc"
set ::env(SYNTH_DRIVING_CELL) "sky130_fd_sc_hd__inv_8"
set ::env(SYNTH_DRIVING_CELL_PIN) "Y"
set ::env(SYNTH_CAP_LOAD) "17.65"
set ::env(WIRE_RC_LAYER) "met1"

#To disable empty filler cell black box get created
#set link_make_black_boxes 0


set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um
define_corners wc bc
read_liberty -corner bc $::env(LIB_FASTEST)
read_liberty -corner wc $::env(LIB_SLOWEST)
read_verilog netlist/clk_skew_adjust.v  
read_verilog netlist/glbl_cfg.v  
read_verilog netlist/sdram.v  
read_verilog netlist/spi_master.v 
read_verilog netlist/syntacore.v  
read_verilog netlist/uart.v  
read_verilog netlist/wb_host.v  
read_verilog netlist/wb_interconnect.v
read_verilog netlist/user_project_wrapper.v  
link_design  $::env(DESIGN_NAME)


read_spef -path u_skew_wi    ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_riscv ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_uart  ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_spi   ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_sdram ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_glbl  ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_wh    ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_sd_co ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_sd_ci ../../spef/clk_skew_adjust.spef  
read_spef -path u_skew_sp_co ../../spef/clk_skew_adjust.spef  
read_spef -path u_glbl_cfg   ../../spef/glbl_cfg.spef  
read_spef -path u_riscv_top  ../../spef/scr1_top_wb.spef  
read_spef -path u_sdram_ctrl ../../spef/sdrc_top.spef  
read_spef -path u_spi_master ../../spef/spim_top.spef  
read_spef -path u_uart_core  ../../spef/uart_core.spef  
read_spef -path u_wb_host    ../../spef/wb_host.spef  
read_spef -path u_intercon   ../../spef/wb_interconnect.spef
read_spef ../..//spef/user_project_wrapper.spef  


read_sdc -echo $::env(BASE_SDC_FILE)

# check for missing constraints
#check_setup  -verbose > unconstraints.rpt

set_operating_conditions -analysis_type single
# Propgate the clock
set_propagated_clock [all_clocks]

report_tns
report_wns
#report_power 
echo "################ CORNER : WC (SLOW) TIMING Report ###################" > timing_max.rpt
report_checks -unique -path_delay max -slack_max -0.0 -group_count 100 -corner wc >> timing_max.rpt
report_checks -group_count 100 -path_delay max  -slack_max -0.01 -path_group $::env(WBM_CLOCK_NAME)       -corner wc  > timing_max.rpt
report_checks -group_count 100 -path_delay max  -slack_max -0.01 -path_group $::env(WBS_CLOCK_NAME)       -corner wc  > timing_max.rpt
report_checks -group_count 100 -path_delay max  -slack_max -0.01 -path_group $::env(SDRAM_CLOCK_NAME)     -corner wc  > timing_max.rpt
report_checks -group_count 100 -path_delay max  -slack_max -0.01 -path_group $::env(PAD_SDRAM_CLOCK_NAME) -corner wc  > timing_max.rpt
report_checks -group_count 100 -path_delay max  -slack_max -0.01 -path_group $::env(CPU_CLOCK_NAME)       -corner wc  > timing_max.rpt
report_checks -group_count 100 -path_delay max  -slack_max -0.01 -path_group $::env(RTC_CLOCK_NAME)       -corner wc  > timing_max.rpt

echo "################ CORNER : BC (SLOW) TIMING Report ###################" > timing_min.rpt
report_checks -unique -path_delay min -slack_min -0.0 -group_count 100 -corner bc >> timing_min.rpt
report_checks -group_count 100  -path_delay min -slack_min -0.01 -path_group $::env(WBM_CLOCK_NAME)        -corner bc  > timing_min.rpt
report_checks -group_count 100  -path_delay min -slack_min -0.01 -path_group $::env(WBS_CLOCK_NAME)        -corner bc  > timing_min.rpt
report_checks -group_count 100  -path_delay min -slack_min -0.01 -path_group $::env(SDRAM_CLOCK_NAME)      -corner bc  > timing_min.rpt
report_checks -group_count 100  -path_delay min -slack_min -0.01 -path_group $::env(PAD_SDRAM_CLOCK_NAME)  -corner bc  > timing_min.rpt
report_checks -group_count 100  -path_delay min -slack_min -0.01 -path_group $::env(CPU_CLOCK_NAME)        -corner bc  > timing_min.rpt
report_checks -group_count 100  -path_delay min -slack_min -0.01 -path_group $::env(RTC_CLOCK_NAME)        -corner bc  > timing_min.rpt

report_checks -path_delay min_max 

exit
