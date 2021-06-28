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
set ::env(WB_CLOCK_PERIOD) "10"
set ::env(WB_CLOCK_PORT) "mclk"

######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(WB_CLOCK_PORT)]  -name $::env(WB_CLOCK_PORT)  -period $::env(WB_CLOCK_PERIOD)
set wb_input_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
set wb_output_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"


set_input_delay 2.0 -clock [get_clocks $::env(WB_CLOCK_PORT)] {reset_n}

set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port reg_cs*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port reg_wr*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port reg_addr*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port reg_wdata*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port reg_be*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port sdr_init_done*]

set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port device_idcode*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port reg_rdata*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port reg_ack*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port fuse_mhartid*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port irq_lines*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port soft_irq*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port user_irq*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_width*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_colbits*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_tras_d*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_trp_d*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_trcd_d*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_en*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_req_depth*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_mode_reg*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_cas*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_trcar_d*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_twr_d*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_rfsh*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_cas*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_trcar_d*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_twr_d*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_rfsh*]


# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

## These are generated clock, only max delay added
set_false_path -to [get_port sdram_clk] 
set_false_path -to [get_port cpu_clk] 
set_false_path -to [get_port rtc_clk] 

#set_max_delay 2.0 [get_port sdram_clk]
#set_max_delay 2.0 [get_port cpu_clk]
#set_max_delay 2.0 [get_port rtc_clk]
