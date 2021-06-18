# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name
set ::env(DESIGN_NAME) wb_interconnect
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

#set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk_i"


# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
        $script_dir/../../verilog/rtl/wb_interconnect/src/wb_arb.sv     \
        $script_dir/../../verilog/rtl/wb_interconnect/src/wb_interconnect.sv  \
	"

set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore/scr1/src/includes $script_dir/../../verilog/rtl/sdram_ctrl/src/defs ]

# Need blackbox for cells
set ::env(SYNTH_READ_BLACKBOX_LIB) 0


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(CELL_PAD) 0

set ::env(FP_PDN_LOWER_LAYER) met2
set ::env(FP_PDN_UPPER_LAYER) met3
set ::env(FP_PDN_AUTO_ADJUST) 0
set ::env(FP_PDN_VWIDTH) 0.3
set ::env(FP_PDN_HWIDTH) 0.3
set ::env(FP_PDN_CORE_RING_VSPACING) 0.4
set ::env(FP_PDN_CORE_RING_HSPACING) 0.4
set ::env(FP_PDN_VOFFSET) 10
set ::env(FP_PDN_HOFFSET) 1
set ::env(FP_PDN_VWIDTH) 0.3
set ::env(FP_PDN_HWIDTH) 0.3
set ::env(FP_PDN_VPITCH) 80
set ::env(FP_PDN_HPITCH) 10.8

set ::env(GLB_RT_MAXLAYER) 4

set ::env(PL_RANDOM_INITIAL_PLACEMENT) 1
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2300 100"
set ::env(PL_TARGET_DENSITY) 0.9
set ::env(BOTTOM_MARGIN_MULT) 2
set ::env(TOP_MARGIN_MULT) 2
set ::env(LEFT_MARGIN_MULT) 15
set ::env(RIGHT_MARGIN_MULT) 15
