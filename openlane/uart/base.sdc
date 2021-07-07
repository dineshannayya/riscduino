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
set ::env(CORE_CLOCK_PERIOD) "10"
set ::env(CORE_CLOCK_PORT)   "app_clk"

set ::env(LINE_CLOCK_PERIOD) "100"
set ::env(LINE_CLOCK_PORT)   "line_clk"

######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(CORE_CLOCK_PORT)]  -name $::env(CORE_CLOCK_PORT)  -period $::env(CORE_CLOCK_PERIOD)
create_clock [get_pins  u_lineclk_buf/X ]  -name $::env(LINE_CLOCK_PORT)  -period $::env(LINE_CLOCK_PERIOD)


set_clock_groups -name sys_clk -asynchronous -group $::env(CORE_CLOCK_PORT) -group $::env(LINE_CLOCK_PORT)

set core_input_delay_value [expr $::env(CORE_CLOCK_PERIOD) * 0.6]
set core_output_delay_value [expr $::env(CORE_CLOCK_PERIOD) * 0.6]

set line_input_delay_value  [expr $::env(LINE_CLOCK_PERIOD) * 0.6]
set line_output_delay_value [expr $::env(LINE_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$core_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $core_input_delay_value"


set_input_delay 2.0 -clock [get_clocks $::env(CORE_CLOCK_PORT)] {arst_n}

set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_cs*]
set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_addr*]
set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_wr*]
set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_be*]
set_input_delay  $core_input_delay_value   -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_wdata*]


set_output_delay $core_output_delay_value  -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_rdata*]
set_output_delay $core_output_delay_value  -clock [get_clocks $::env(CORE_CLOCK_PORT)] [get_port reg_ack*]

set_input_delay  $line_input_delay_value   -clock [get_clocks $::env(LINE_CLOCK_PORT)] [get_port io_in*]
set_output_delay $line_input_delay_value   -clock [get_clocks $::env(LINE_CLOCK_PORT)] [get_port io_oeb*]
set_output_delay $line_output_delay_value  -clock [get_clocks $::env(LINE_CLOCK_PORT)] [get_port io_out*]


# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

