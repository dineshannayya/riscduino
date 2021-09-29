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
set ::env(WBM_CLOCK_PORT)   "mclk"
set ::env(WBM_CLOCK_NAME)   "mclk"


######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(WBM_CLOCK_PORT)]  -name $::env(WBM_CLOCK_PORT)  -period $::env(WBM_CLOCK_PERIOD)


set wb_input_delay_value [expr $::env(WBM_CLOCK_PERIOD) * 0.6]
set wb_output_delay_value [expr $::env(WBM_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"


set_input_delay 2.0 -clock [get_clocks $::env(WBM_CLOCK_PORT)] {h_reset_n}

set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_PORT)] [get_port reg_cs]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_PORT)] [get_port reg_wr]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_PORT)] [get_port reg_addr*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_PORT)] [get_port reg_wdata*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_PORT)] [get_port reg_be*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WBM_CLOCK_PORT)] [get_port wbm_err_o*]

set_output_delay 4.5   -clock [get_clocks $::env(WBM_CLOCK_PORT)] [get_port reg_rdata*]
set_output_delay 4.5   -clock [get_clocks $::env(WBM_CLOCK_PORT)] [get_port reg_ack]


set_clock_uncertainty -from $::env(WBM_CLOCK_NAME)          -to $::env(WBM_CLOCK_NAME)    -setup 0.400


# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

