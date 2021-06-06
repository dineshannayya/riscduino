# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name
set ::env(DESIGN_NAME) scr1_top_axi

# This is macro
set ::env(DESIGN_IS_CORE) 0

# Diode insertion
	#  Spray
set ::env(DIODE_INSERTION_STRATEGY) 0

	# Smart-"ish"
#set ::env(DIODE_INSERTION_STRATEGY) 3
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"


# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_top.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/scr1_core_top.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/scr1_dm.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/scr1_tapc_synchronizer.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/scr1_clk_ctrl.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/scr1_scu.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/scr1_tapc.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/scr1_tapc_shift_reg.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/scr1_dmi.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/primitives/scr1_reset_cells.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_ifu.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_idu.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_exu.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_mprf.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_csr.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_ialu.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_lsu.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_hdu.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_pipe_tdu.sv  \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/core/pipeline/scr1_ipic.sv   \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/top/scr1_dmem_router.sv   \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/top/scr1_imem_router.sv   \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/top/scr1_tcm.sv   \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/top/scr1_timer.sv   \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/top/scr1_top_axi.sv   \
	$script_dir/../../verilog/rtl/syntacore_scr1/src/top/scr1_mem_axi.sv "

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore_scr1/src/includes ]

#set ::env(SYNTH_DEFINES) [list SCR1_DBG_EN ]


# Need blackbox for cells
set ::env(SYNTH_READ_BLACKBOX_LIB) 0


# Floorplanning
# -------------

# Fixed area and pin position
set ::env(FP_SIZING) "absolute"
#actual die area is 0 0 2920 3520, given 500 micron extra margin
set ::env(DIE_AREA) [list 0.0 0.0 2000.0 1200.0]
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

# Halo around the Macros
set ::env(FP_HORIZONTAL_HALO) 25
set ::env(FP_VERTICAL_HALO) 20

#set ::env(PDN_CFG) $::env(DESIGN_DIR)/pdn.tcl



# Placement
# ---------

set ::env(PL_TARGET_DENSITY) 0.40

#set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro_placement.cfg


# Routing
# -------

#| `ROUTING_CORES` | Specifies the number of threads to be used in TritonRoute. <br> (Default: `4`) |
set ::env(ROUTING_CORES) 4

#| `GLB_RT_ALLOW_CONGESTION` | Allow congestion in the resultign guides. 0 = false, 1 = true <br> (Default: `0`) |
set ::env(GLB_RT_ALLOW_CONGESTION) 0

# | `GLB_RT_MINLAYER` | The number of lowest layer to be used in routing. <br> (Default: `1`)|
set ::env(GLB_RT_MINLAYER) 1

# | `GLB_RT_MAXLAYER` | The number of highest layer to be used in routing. <br> (Default: `6`)|
set ::env(GLB_RT_MAXLAYER) 6

# Obstructions
    # li1 over the SRAM areas
	# met5 over the whole design
#set ::env(GLB_RT_OBS) "li1 0.00 22.68 1748.00 486.24, li1 0.00 851.08 1748.00 486.24, met5 0.0 0.0 1748.0 1360.0"

#| `ROUTING_OPT_ITERS` | Specifies the maximum number of optimization iterations during Detailed Routing in TritonRoute. <br> (Default: `64`) |
set ::env(ROUTING_OPT_ITERS) "64"

#| `GLOBAL_ROUTER` | Specifies which global router to use. Values: `fastroute` or `cugr`. <br> (Default: `fastroute`) |
set ::env(GLOBAL_ROUTER) "fastroute"

#| `DETAILED_ROUTER` | Specifies which detailed router to use. Values: `tritonroute`, `tritonroute_or`, or `drcu`. <br> (Default: `tritonroute`) |
set ::env(DETAILED_ROUTER) "tritonroute"

# DRC
# ---


set ::env(MAGIC_DRC_USE_GDS) 1


# Tape Out
# --------

set ::env(MAGIC_ZEROIZE_ORIGIN) 0


# Cell library specific config
# ----------------------------

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
