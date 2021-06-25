# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name
set ::env(DESIGN_NAME) wb_interconnect

#set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk_i"

set ::env(SYNTH_MAX_FANOUT) 4

# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
        $script_dir/../../verilog/rtl/lib/wb_stagging.sv                \
        $script_dir/../../verilog/rtl/wb_interconnect/src/wb_arb.sv     \
        $script_dir/../../verilog/rtl/wb_interconnect/src/wb_interconnect.sv  \
	"

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore/scr1/src/includes $script_dir/../../verilog/rtl/sdram_ctrl/src/defs ]

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

set ::env(LEC_ENABLE) 0

# Floorplanning
# -------------

#set ::env(PL_BASIC_PLACEMENT) 1
#set ::env(FP_DEF_TEMPLATE) $script_dir/floorplan.def
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2000 200"



set ::env(FP_PDN_VPITCH) 50
set ::env(PDN_CFG) $script_dir/pdn.tcl

set ::env(FP_VERTICAL_HALO) 6
set ::env(PL_TARGET_DENSITY) 0.32
set ::env(PL_TARGET_DENSITY_CELLS) 0.2
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 1
set ::env(CELL_PAD) 4

set ::env(GLB_RT_ADJUSTMENT) 0
set ::env(GLB_RT_L2_ADJUSTMENT) 0.2
set ::env(GLB_RT_L3_ADJUSTMENT) 0.25
set ::env(GLB_RT_L4_ADJUSTMENT) 0.2
set ::env(GLB_RT_L5_ADJUSTMENT) 0.1
set ::env(GLB_RT_L6_ADJUSTMENT) 0.1
set ::env(GLB_RT_TILES) 14
set ::env(GLB_RT_MAXLAYER) 5

set ::env(DIODE_INSERTION_STRATEGY) 4


