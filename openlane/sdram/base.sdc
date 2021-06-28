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
set ::env(WB_CLOCK_PORT)   "wb_clk_i"

set ::env(SDRAM_CLOCK_PERIOD) "20"
set ::env(SDRAM_CLOCK_PORT)   "sdram_clk"

set ::env(PAD_SDRAM_CLOCK_PERIOD) "20"
set ::env(PAD_SDRAM_CLOCK_PORT)   "io_in\[29\]"
######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(WB_CLOCK_PORT)]  -name $::env(WB_CLOCK_PORT)  -period $::env(WB_CLOCK_PERIOD)
set wb_input_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
set wb_output_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"


set_input_delay 2.0 -clock [get_clocks $::env(WB_CLOCK_PORT)] {wb_rst_n}

set_input_delay  3.0                     -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_stb_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_addr_i*]
set_input_delay  5.0                     -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_we_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_dat_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_sel_i*]
set_input_delay  3.0                     -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_cyc_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_cti_i*]

set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_tras_d*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_trp_d*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_trcd_d*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_en*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_req_depth*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_mode_reg*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_cas*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_trcar_d*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_twr_d*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_rfsh*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port cfg_sdr_rfmax*]

set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_dat_o*]
set_output_delay 3.0                     -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wb_ack_o*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port sdr_init_done*]

######################################
# SDRAM Clock domain input output
######################################
create_clock [get_ports $::env(SDRAM_CLOCK_PORT)]  -name $::env(SDRAM_CLOCK_PORT)  -period $::env(SDRAM_CLOCK_PERIOD)
set sdram_input_delay_value [expr $::env(SDRAM_CLOCK_PERIOD) * 0.6]
set sdram_output_delay_value [expr $::env(SDRAM_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"

set_output_delay $sdram_output_delay_value  -clock [get_clocks $::env(SDRAM_CLOCK_PORT)] [get_port io_out*]
set_output_delay $sdram_output_delay_value  -clock [get_clocks $::env(SDRAM_CLOCK_PORT)] [get_port io_oeb*]

################################################
# PAD SDRAM Clock domain input output
# Note: PAD SDRAM clock is same as SDRAM clock
#       it's a feedback clock through pads
################################################

create_clock [get_ports $::env(PAD_SDRAM_CLOCK_PORT)]  -name $::env(PAD_SDRAM_CLOCK_PORT)  -period $::env(SDRAM_CLOCK_PERIOD)
set_input_delay  $sdram_input_delay_value   -clock [get_clocks $::env(PAD_SDRAM_CLOCK_PORT)] [get_port io_in*]


set_clock_groups -name async_clock -asynchronous -comment "Async Clock group" -group [get_clocks $::env(WB_CLOCK_PORT)] -group [get_clocks $::env(SDRAM_CLOCK_PORT)]


# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

