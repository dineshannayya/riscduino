# Global
# ------

set script_dir [file dirname [file normalize [info script]]]
# Name
set ::env(DESIGN_NAME) spim_top
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

#set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Timing configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "mclk"


# Sources
# -------

# Local sources + no2usb sources
set ::env(VERILOG_FILES) "\
        $script_dir/../../verilog/rtl/spi_master/src/spim_top.sv \
        $script_dir/../../verilog/rtl/spi_master/src/spim_regs.sv \
        $script_dir/../../verilog/rtl/spi_master/src/spim_clkgen.sv \
        $script_dir/../../verilog/rtl/spi_master/src/spim_ctrl.sv \
        $script_dir/../../verilog/rtl/spi_master/src/spim_rx.sv \
        $script_dir/../../verilog/rtl/spi_master/src/spim_tx.sv "

#set ::env(VERILOG_INCLUDE_DIRS) [glob $script_dir/../../verilog/rtl/syntacore/scr1/src/includes ]

#set ::env(SYNTH_DEFINES) [list SCR1_DBG_EN ]


# Need blackbox for cells
set ::env(SYNTH_READ_BLACKBOX_LIB) 0


# Floorplanning
# -------------

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(CELL_PAD) 0

set ::env(GLB_RT_MAXLAYER) 5

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 600 500"
set ::env(PL_TARGET_DENSITY) 0.4
set ::env(BOTTOM_MARGIN_MULT) 2
set ::env(TOP_MARGIN_MULT) 2
set ::env(LEFT_MARGIN_MULT) 15
set ::env(RIGHT_MARGIN_MULT) 15
