# SPDX-FileCopyrightText: 2020 Efabless Corporation
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

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) digital_core

set verilog_root $script_dir/../../verilog/
set lef_root $script_dir/../../lef/
set gds_root $script_dir/../../gds/


set ::env(VERILOG_FILES) "\
        $script_dir/../../verilog/rtl/digital_core/src/digital_core.sv \
	"
set ::env(SYNTH_READ_BLACKBOX_LIB) "1"
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_PERIOD) "50"
set ::env(SYNTH_STRATEGY) "AREA 0"
set ::env(SYNTH_MAX_FANOUT) 4

set ::env(FP_PDN_VPITCH) 50
set ::env(PDN_CFG) $script_dir/pdn.tcl

set ::env(PL_BASIC_PLACEMENT) 1

set ::env(FP_VERTICAL_HALO) 6
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg


set ::env(DESIGN_IS_CORE) "0"



set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore/scr1/src/includes $script_dir/../../verilog/rtl/sdram_ctrl/src/defs ]

set ::env(EXTRA_LEFS) "\
	$lef_root/spi_master.lef \
	$lef_root/glbl_cfg.lef \
	$lef_root/wb_interconnect.lef \
	$lef_root/sdram.lef \
	$lef_root/syntacore.lef \
	"

set ::env(EXTRA_GDS_FILES) "\
	$gds_root/spi_master.gds \
	$gds_root/glbl_cfg.gds \
	$gds_root/wb_interconnect.gds \
	$gds_root/sdram.gds \
	$gds_root/syntacore.gds \
        "

set ::env(VERILOG_FILES_BLACKBOX) "\
        $script_dir/../../verilog/rtl/spi_master/src/spim_top.sv \
        $script_dir/../../verilog/rtl/wb_interconnect/src/wb_interconnect.sv  \
        $script_dir/../../verilog/rtl/digital_core/src/glbl_cfg.sv     \
	$script_dir/macro/bb/sdram.v \
	$script_dir/macro/bb/syntacore.v \
	"


set ::env(FP_SIZING) relative
set ::env(DIE_AREA) "0 0 3000 3000"



set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg
set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.20
set ::env(PL_TARGET_DENSITY_CELLS) 0.20
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0
set ::env(CELL_PAD) 4

set ::env(GLB_RT_ADJUSTMENT) 0
set ::env(GLB_RT_L2_ADJUSTMENT) 0.2
set ::env(GLB_RT_L3_ADJUSTMENT) 0.25
set ::env(GLB_RT_L4_ADJUSTMENT) 0.2
set ::env(GLB_RT_L5_ADJUSTMENT) 0.1
set ::env(GLB_RT_L6_ADJUSTMENT) 0.1
set ::env(GLB_RT_TILES) 14
set ::env(GLB_RT_MAXLAYER) 4
set ::env(PL_DIAMOND_SEARCH_HEIGHT) "400"

set ::env(DIODE_INSERTION_STRATEGY) 4




