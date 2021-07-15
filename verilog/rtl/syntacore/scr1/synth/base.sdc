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
#Wishbone Clock
set ::env(WB_CLOCK_PERIOD)    "10"
set ::env(WB_CLOCK_PORT)      "wb_clk"
set ::env(WB_CLOCK_NAME)      "wb_clk"

#Risc Core Clock
set ::env(CORE_CLOCK_PERIOD) "20"
set ::env(CORE_CLOCK_PORT)   "core_clk"
set ::env(CORE_CLOCK_NAME)   "core_clk"

#RTC Core Clock
set ::env(RTC_CLOCK_PERIOD) "40"
set ::env(RTC_CLOCK_PORT)   "rtc_clk"
set ::env(RTC_CLOCK_NAME)   "rtc_clk"

######################################
# CORE Clock domain input output
######################################
create_clock [get_ports $::env(CORE_CLOCK_PORT)]  -name $::env(CORE_CLOCK_NAME)  -period $::env(CORE_CLOCK_PERIOD)
set core_input_delay_value [expr $::env(CORE_CLOCK_PERIOD) * 0.6]
set core_output_delay_value [expr $::env(CORE_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting core output delay to: $core_output_delay_value"
puts "\[INFO\]: Setting core input delay to: $core_input_delay_value"
set core_clk_indx [lsearch [all_inputs] [get_port $::env(CORE_CLOCK_NAME)]]
set core_rst_indx [lsearch [all_inputs] [get_port cpu_rst_n]]
set all_inputs_wo_core_clk_rst [lreplace [all_inputs] $core_clk_indx $core_rst_indx]
set all_outputs_core [all_outputs] 

set_input_delay $core_input_delay_value  -clock [get_clocks $::env(CORE_CLOCK_NAME)] $all_inputs_wo_core_clk_rst
set_input_delay 5.0 -clock [get_clocks $::env(CORE_CLOCK_NAME)] {cpu_rst_n}
set_output_delay $core_output_delay_value  -clock [get_clocks $::env(CORE_CLOCK_NAME)] $all_outputs_core

create_clock [get_ports $::env(RTC_CLOCK_PORT)]  -name $::env(RTC_CLOCK_NAME)  -period $::env(RTC_CLOCK_PERIOD)

######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(WB_CLOCK_PORT)]  -name $::env(WB_CLOCK_NAME)  -period $::env(WB_CLOCK_PERIOD)
set wb_input_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
set wb_output_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"
set wb_clk_indx [lsearch [all_inputs] [get_port $::env(WB_CLOCK_NAME)]]
set wb_rst_indx [lsearch [all_inputs] [get_port wb_rst_n]]
set all_inputs_wo_wb_clk_rst [lreplace [all_inputs] $wb_clk_indx $wb_rst_indx]
set all_outputs_wb [all_outputs]

set_false_path -to riscv_debug*
set_false_path -from soft_irq

set_input_delay $wb_input_delay_value  -clock [get_clocks $::env(WB_CLOCK_NAME)] $all_inputs_wo_wb_clk_rst
set_input_delay 5.0 -clock [get_clocks $::env(WB_CLOCK_NAME)] {wb_rst_n}
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_NAME)] $all_outputs_wb

#### Clock Async Defination
set_clock_groups -name async_clock -asynchronous -comment "Async Clock group" -group [get_clocks $::env(WB_CLOCK_NAME)] -group [get_clocks $::env(CORE_CLOCK_NAME)] -group [get_clocks $::env(RTC_CLOCK_NAME)]

set_clock_uncertainty -from $::env(WB_CLOCK_NAME)    -to $::env(WB_CLOCK_NAME)    -setup 0.400
set_clock_uncertainty -from $::env(CORE_CLOCK_NAME)  -to $::env(CORE_CLOCK_NAME)   -setup 0.400
set_clock_uncertainty -from $::env(RTC_CLOCK_NAME)   -to $::env(RTC_CLOCK_NAME)   -setup 0.400

set_clock_uncertainty -from $::env(WB_CLOCK_NAME)    -to $::env(WB_CLOCK_NAME)    -hold 0.050
set_clock_uncertainty -from $::env(CORE_CLOCK_NAME)  -to $::env(CORE_CLOCK_NAME)   -hold 0.050
set_clock_uncertainty -from $::env(RTC_CLOCK_NAME)   -to $::env(RTC_CLOCK_NAME)   -hold 0.050


# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]
