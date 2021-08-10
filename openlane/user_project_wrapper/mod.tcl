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

# Removing the decap and diode
read_verilog ../../verilog/gl/clk_buf.v  
link_design  clk_buf
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/clk_buf.v
# Removing the decap and diode
read_verilog  ../../verilog/gl/clk_skew_adjust.v  
link_design  clk_skew_adjust
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/clk_skew_adjust.v

# Removing the decap and diode
read_verilog  ../../verilog/gl/glbl_cfg.v  
link_design  glbl_cfg
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/glbl_cfg.v

read_verilog  ../../verilog/gl/sdram.v  
link_design  sdrc_top
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/sdram.v

read_verilog  ../../verilog/gl/spi_master.v 
link_design  spim_top 
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/spi_master.v

read_verilog  ../../verilog/gl/syntacore.v  
link_design  scr1_top_wb
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/syntacore.v

read_verilog  ../../verilog/gl/uart_i2cm_usb.v  
link_design  uart_i2c_usb_top
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/uart_i2cm_usb.v

read_verilog  ../../verilog/gl/wb_host.v  
link_design  wb_host
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/wb_host.v

read_verilog  ../../verilog/gl/wb_interconnect.v
link_design  wb_interconnect
write_verilog -remove_cells [get_lib_cells {sky130_fd_sc_hd__decap* sky130_fd_sc_hd__fill* sky130_fd_sc_hd__diode_* sky130_ef_sc_hd__fakediode* sky130_fd_sc_hd__tapvpwrvgnd*}] netlist/wb_interconnect.v


exit
