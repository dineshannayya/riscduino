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

set ::env(SPI_CLOCK_PORT)  "spiclk"
set ::env(SPI_CLOCK_PERIOD) "20"

######################################
# WB Clock domain input output
######################################
create_clock [get_ports $::env(WB_CLOCK_PORT)]  -name $::env(WB_CLOCK_PORT)  -period $::env(WB_CLOCK_PERIOD)

create_generated_clock -name $::env(SPI_CLOCK_PORT) -source [get_ports $::env(WB_CLOCK_PORT)] -master_clock $::env(WB_CLOCK_PORT) -divide_by 2  -add -comment "SPI Clock Out"  [get_port io_out[0]]

set wb_input_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
set wb_output_delay_value [expr $::env(WB_CLOCK_PERIOD) * 0.6]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"


set_input_delay 2.0 -clock [get_clocks $::env(WB_CLOCK_PORT)] {rst_n}

set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbd_stb_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbd_adr_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbd_we_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbd_dat_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbd_sel_i*]


set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbd_dat_o*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbd_ack_o*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port wbd_err_o*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WB_CLOCK_PORT)] [get_port spi_debug*]

### SPI I/F constaints
set spi_input_delay_value  [expr $::env(SPI_CLOCK_PERIOD) * 0.6]
set spi_output_delay_value [expr $::env(SPI_CLOCK_PERIOD) * 0.6]

set_input_delay  6   -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_in[3]]
set_input_delay  6   -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_in[2]]
set_input_delay  6   -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_in[1]]
set_input_delay  6   -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_in[0]]

set_input_delay  0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_in[3]]
set_input_delay  0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_in[2]]
set_input_delay  0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_in[1]]
set_input_delay  0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_in[0]]

#io_out[0] is spiclcok
#set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[0]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[5]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[4]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[3]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[2]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[1]]

set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[5]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[4]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[3]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[2]]
set_output_delay 6  -max -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[1]]

set_output_delay -0.5   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[5]]
set_output_delay -0.5   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[4]]
set_output_delay -0.5   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[3]]
set_output_delay -0.5   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[2]]
set_output_delay 0.0    -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[1]]

# Chip select asserted multiple cycle eariler than spi clock
set_output_delay 0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_out[1]]

set_output_delay 0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[5]]
set_output_delay 0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[4]]
set_output_delay 0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[3]]
set_output_delay 0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[2]]
set_output_delay 0   -min -clock [get_clocks $::env(SPI_CLOCK_PORT)] [get_port io_oeb[1]]

set_clock_uncertainty -from $::env(SPI_CLOCK_PORT)   -to $::env(SPI_CLOCK_PORT)   -setup 0.800
set_clock_uncertainty -from $::env(WB_CLOCK_PERIOD)  -to $::env(WB_CLOCK_PERIOD)  -setup 0.800
set_clock_uncertainty -from $::env(SPI_CLOCK_PORT)   -to $::env(SPI_CLOCK_PORT)   -hold 0.050
set_clock_uncertainty -from $::env(WB_CLOCK_PERIOD)  -to $::env(WB_CLOCK_PERIOD)  -hold 0.050

# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

