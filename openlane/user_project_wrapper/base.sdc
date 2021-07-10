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


set_units -time ns
set ::env(WBM_CLOCK_PERIOD) "10"
set ::env(WBM_CLOCK_PORT)   "wb_clk_i"
set ::env(WBM_CLOCK_NAME)   "wbm_clk_i"

set ::env(WBS_CLOCK_PERIOD) "10"
set ::env(WBS_CLOCK_PORT)   "u_wb_host*wbs_clk_out"
set ::env(WBS_CLOCK_NAME)   "wbs_clk_i"

set ::env(SDRAM_CLOCK_PERIOD) "20"
set ::env(SDRAM_CLOCK_PORT)   "u_wb_host*sdram_clk"
set ::env(SDRAM_CLOCK_NAME)   "sdram_clk"

set ::env(PAD_SDRAM_CLOCK_PERIOD) "20"
set ::env(PAD_SDRAM_CLOCK_PORT)   "u_skew_sd_ci*clk_in"
set ::env(PAD_SDRAM_CLOCK_NAME)   "sdram_pad_clk"

set ::env(CPU_CLOCK_PERIOD) "50"
set ::env(CPU_CLOCK_PORT)   "u_wb_host*cpu_clk"
set ::env(CPU_CLOCK_NAME)   "cpu_clk"

set ::env(RTC_CLOCK_PERIOD) "50"
set ::env(RTC_CLOCK_PORT)   "u_wb_host*rtc_clk"
set ::env(RTC_CLOCK_NAME)   "rtc_clk"

set ::env(UART_CLOCK_PERIOD) "100"
set ::env(UART_CLOCK_PORT)   "u_uart_core*u_lineclk_buf/X"
set ::env(UART_CLOCK_NAME)   "line_clk"

#Setting clock delay to center of the tap
set_case_analysis 1 [get_pins -hierarchical u_skew_wi*sel[3]]
set_case_analysis 0 [get_pins -hierarchical u_skew_wi*sel[2]] 
set_case_analysis 0 [get_pins -hierarchical u_skew_wi*sel[1]] 
set_case_analysis 0 [get_pins -hierarchical u_skew_wi*sel[0]] 

set_case_analysis 1 [get_pins -hierarchical u_skew_riscv*sel[3]]
set_case_analysis 0 [get_pins -hierarchical u_skew_riscv*sel[2]]
set_case_analysis 0 [get_pins -hierarchical u_skew_riscv*sel[1]]
set_case_analysis 0 [get_pins -hierarchical u_skew_riscv*sel[0]]

set_case_analysis 1 [get_pins -hierarchical u_skew_uart*sel[3]]
set_case_analysis 0 [get_pins -hierarchical u_skew_uart*sel[2]]
set_case_analysis 0 [get_pins -hierarchical u_skew_uart*sel[1]]
set_case_analysis 0 [get_pins -hierarchical u_skew_uart*sel[0]]

set_case_analysis 1 [get_pins -hierarchical u_skew_spi*sel[3]]
set_case_analysis 0 [get_pins -hierarchical u_skew_spi*sel[2]]
set_case_analysis 0 [get_pins -hierarchical u_skew_spi*sel[1]]
set_case_analysis 0 [get_pins -hierarchical u_skew_spi*sel[0]]

set_case_analysis 0 [get_pins -hierarchical u_skew_glbl*sel[3]]
set_case_analysis 1 [get_pins -hierarchical u_skew_glbl*sel[2]]
set_case_analysis 1 [get_pins -hierarchical u_skew_glbl*sel[1]]
set_case_analysis 1 [get_pins -hierarchical u_skew_glbl*sel[0]]

set_case_analysis 1 [get_pins -hierarchical u_skew_wh*sel[3]]
set_case_analysis 0 [get_pins -hierarchical u_skew_wh*sel[2]]
set_case_analysis 0 [get_pins -hierarchical u_skew_wh*sel[1]]
set_case_analysis 0 [get_pins -hierarchical u_skew_wh*sel[0]]

# Set the interface logic to 0
set_case_analysis 0 [get_pins -hierarchical u_skew_sd_co*sel[3]]
set_case_analysis 0 [get_pins -hierarchical u_skew_sd_co*sel[2]]
set_case_analysis 0 [get_pins -hierarchical u_skew_sd_co*sel[1]]
set_case_analysis 0 [get_pins -hierarchical u_skew_sd_co*sel[0]]

set_case_analysis 0 [get_pins -hierarchical u_skew_sd_ci*sel[3]]
set_case_analysis 0 [get_pins -hierarchical u_skew_sd_ci*sel[2]]
set_case_analysis 0 [get_pins -hierarchical u_skew_sd_ci*sel[1]]
set_case_analysis 1 [get_pins -hierarchical u_skew_sd_ci*sel[0]]

set_case_analysis 0 [get_pins -hierarchical u_skew_sp_co*sel[3]]
set_case_analysis 0 [get_pins -hierarchical u_skew_sp_co*sel[2]]
set_case_analysis 0 [get_pins -hierarchical u_skew_sp_co*sel[1]]
set_case_analysis 0 [get_pins -hierarchical u_skew_sp_co*sel[0]]

######################################
# WB MASTER Clock domain input output
######################################
create_clock [get_ports $::env(WBM_CLOCK_PORT)]  -name $::env(WBM_CLOCK_NAME)  -period $::env(WBM_CLOCK_PERIOD)
set wb_input_delay_value [expr $::env(WBM_CLOCK_PERIOD) * 0.54]
set wb_output_delay_value [expr $::env(WBM_CLOCK_PERIOD) * 0.54]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"


set_input_delay 2.0 -clock [get_clocks $::env(WBM_CLOCK_NAME)] {wb_rst_i}

set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_stb_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_cyc_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_we_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_sel_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_dat_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_adr_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wb_cti_i*]

set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_dat_o*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_ack_o*]

######################################
# WishBone Slave Port
#######################################
create_clock [get_pins -hierarchical $::env(WBS_CLOCK_PORT)]  -name $::env(WBS_CLOCK_NAME)  -period $::env(WBS_CLOCK_PERIOD)
######################################
# SDRAM Clock domain input output
######################################
create_clock [get_pins -hierarchical $::env(SDRAM_CLOCK_PORT)]  -name $::env(SDRAM_CLOCK_NAME)  -period $::env(SDRAM_CLOCK_PERIOD)
create_clock [get_pins -hierarchical $::env(PAD_SDRAM_CLOCK_PORT)]  -name $::env(PAD_SDRAM_CLOCK_NAME)  -period $::env(PAD_SDRAM_CLOCK_PERIOD)
create_clock [get_pins -hierarchical $::env(CPU_CLOCK_PORT)] -name $::env(CPU_CLOCK_NAME)  -period $::env(CPU_CLOCK_PERIOD)
create_clock [get_pins -hierarchical $::env(RTC_CLOCK_PORT)] -name $::env(RTC_CLOCK_NAME)  -period $::env(RTC_CLOCK_PERIOD)
create_clock [get_pins -hierarchical $::env(UART_CLOCK_PORT)]  -name $::env(UART_CLOCK_NAME)  -period $::env(UART_CLOCK_PERIOD)

set_clock_groups -name async_clock -asynchronous -comment "Async Clock group" -group [get_clocks $::env(WBM_CLOCK_NAME)] -group [get_clocks $::env(WBS_CLOCK_NAME)] -group [get_clocks $::env(SDRAM_CLOCK_NAME)] -group [get_clocks $::env(CPU_CLOCK_NAME)] -group [get_clocks $::env(RTC_CLOCK_NAME)] -group [get_clocks $::env(UART_CLOCK_NAME)] 


## Add clock uncertainty
#Note: We have PAD_SDRAM_CLOCK_NAME => SDRAM_CLOCK_NAME path only

set_clock_uncertainty -from $::env(WBM_CLOCK_NAME)          -to $::env(WBM_CLOCK_NAME)    -setup 0.200
set_clock_uncertainty -from $::env(WBS_CLOCK_NAME)          -to $::env(WBS_CLOCK_NAME)    -setup 0.200
set_clock_uncertainty -from $::env(SDRAM_CLOCK_NAME)        -to $::env(SDRAM_CLOCK_NAME)  -setup 0.200
set_clock_uncertainty -from $::env(PAD_SDRAM_CLOCK_NAME)    -to $::env(SDRAM_CLOCK_NAME)  -setup 0.200
set_clock_uncertainty -from $::env(CPU_CLOCK_NAME)          -to $::env(CPU_CLOCK_NAME)    -setup 0.200
set_clock_uncertainty -from $::env(RTC_CLOCK_NAME)          -to $::env(RTC_CLOCK_NAME)    -setup 0.200
set_clock_uncertainty -from $::env(UART_CLOCK_NAME)         -to $::env(UART_CLOCK_NAME)   -setup 0.200

set_clock_uncertainty -from $::env(WBM_CLOCK_NAME)          -to $::env(WBM_CLOCK_NAME)    -hold 0.050
set_clock_uncertainty -from $::env(WBS_CLOCK_NAME)          -to $::env(WBS_CLOCK_NAME)    -hold 0.050
set_clock_uncertainty -from $::env(SDRAM_CLOCK_NAME)        -to $::env(SDRAM_CLOCK_NAME)  -hold 0.050
set_clock_uncertainty -from $::env(PAD_SDRAM_CLOCK_NAME)    -to $::env(SDRAM_CLOCK_NAME)  -hold 0.050
set_clock_uncertainty -from $::env(CPU_CLOCK_NAME)          -to $::env(CPU_CLOCK_NAME)    -hold 0.050
set_clock_uncertainty -from $::env(RTC_CLOCK_NAME)          -to $::env(RTC_CLOCK_NAME)    -hold 0.050
set_clock_uncertainty -from $::env(UART_CLOCK_NAME)         -to $::env(UART_CLOCK_NAME)   -hold 0.050

# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

## 2 Multi-cycle setup and 0 hold
set_multicycle_path -setup -from wbs_adr_i* 2
set_multicycle_path -hold -from wbs_adr_i* 2

set_multicycle_path -setup -from wbs_we_i* 2
set_multicycle_path -hold -from wbs_we_i* 2
