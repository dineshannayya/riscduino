# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name
set ::env(DESIGN_NAME) glbl_cfg
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

#set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "mclk"


# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
        $script_dir/../../verilog/rtl/lib/registers.v                  \
        $script_dir/../../verilog/rtl/lib/clk_ctl.v                    \
        $script_dir/../../verilog/rtl/digital_core/src/glbl_cfg.sv     \
	"


# Need blackbox for cells
set ::env(SYNTH_READ_BLACKBOX_LIB) 0


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(CELL_PAD) 0


set ::env(GLB_RT_MAXLAYER) 5

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 300 300"
set ::env(PL_TARGET_DENSITY) 0.3
