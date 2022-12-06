set SPEF_MAPPING_POSTFIX ".$::env(RCX_CORNER).spef"
set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/gpio_control_block/openlane-signoff/spef/"
set spef_mapping(\gpio_control_bidir_1[0]) ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_bidir_1[1]) ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_bidir_2[0]) ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_bidir_2[1]) ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_bidir_2[2]) ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[0])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[10])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[1])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[2])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[3])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[4])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[5])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[6])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[7])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[8])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1[9])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1a[0])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1a[1])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1a[2])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1a[3])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1a[4])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_1a[5])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[0])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[10])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[11])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[12])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[13])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[14])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[15])   ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[1])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[2])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[3])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[4])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[5])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[6])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[7])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[8])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\gpio_control_in_2[9])    ${SPEF_MAPPING_PREFIX}gpio_control_block${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/spare_logic_block/openlane-signoff/spef/"
set spef_mapping(\spare_logic[0])          ${SPEF_MAPPING_PREFIX}spare_logic_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\spare_logic[1])          ${SPEF_MAPPING_PREFIX}spare_logic_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\spare_logic[2])          ${SPEF_MAPPING_PREFIX}spare_logic_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(\spare_logic[3])          ${SPEF_MAPPING_PREFIX}spare_logic_block${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/caravel_clocking/openlane-signoff/spef/"
set spef_mapping(clock_ctrl)               ${SPEF_MAPPING_PREFIX}caravel_clocking${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/buff_flash_clkrst/openlane-signoff/spef/"
set spef_mapping(flash_clkrst_buffers)     ${SPEF_MAPPING_PREFIX}buff_flash_clkrst${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/gpio_defaults_block/openlane-signoff/spef/"
set spef_mapping(gpio_defaults_block_0)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_1)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_2)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_3)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_4)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_5)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_6)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_7)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_8)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_9)    ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_10)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_11)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_12)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_13)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_14)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_15)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_16)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_17)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_18)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_19)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_20)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_21)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_22)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_23)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_24)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_25)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_26)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_27)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_28)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_29)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_30)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_31)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_32)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_33)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_34)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_35)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_36)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(gpio_defaults_block_37)   ${SPEF_MAPPING_PREFIX}gpio_defaults_block${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/housekeeping/openlane-signoff/spef/"
set spef_mapping(housekeeping)             ${SPEF_MAPPING_PREFIX}housekeeping${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/mgmt_protect/openlane-signoff/spef/"
set spef_mapping(mgmt_buffers)             ${SPEF_MAPPING_PREFIX}mgmt_protect${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CUP_ROOT)/signoff/user_project_wrapper/openlane-signoff/spef/"
set spef_mapping(mprj)                     ${SPEF_MAPPING_PREFIX}user_project_wrapper${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/chip_io/openlane-signoff/spef/"
set spef_mapping(padframe)                 ${SPEF_MAPPING_PREFIX}chip_io${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/digital_pll/openlane-signoff/spef/"
set spef_mapping(pll)                      ${SPEF_MAPPING_PREFIX}digital_pll${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/simple_por/openlane-signoff/spef/"
set spef_mapping(por)                      ${SPEF_MAPPING_PREFIX}simple_por${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/xres_buf/openlane-signoff/spef/"
set spef_mapping(rstb_level)               ${SPEF_MAPPING_PREFIX}xres_buf${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/gpio_signal_buffering/openlane-signoff/spef/"
set spef_mapping(sigbuf)                   ${SPEF_MAPPING_PREFIX}gpio_signal_buffering${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/user_id_programming/openlane-signoff/spef/"
set spef_mapping(user_id_value)            ${SPEF_MAPPING_PREFIX}user_id_programming${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(MCW_ROOT)/signoff/mgmt_core_wrapper/openlane-signoff/spef/"
set spef_mapping(soc)                      ${SPEF_MAPPING_PREFIX}mgmt_core_wrapper${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/constant_block/openlane-signoff/spef/"
set spef_mapping(padframe/\constant_value_inst[0])         ${SPEF_MAPPING_PREFIX}constant_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(padframe/\constant_value_inst[1])         ${SPEF_MAPPING_PREFIX}constant_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(padframe/\constant_value_inst[2])         ${SPEF_MAPPING_PREFIX}constant_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(padframe/\constant_value_inst[3])         ${SPEF_MAPPING_PREFIX}constant_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(padframe/\constant_value_inst[4])         ${SPEF_MAPPING_PREFIX}constant_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(padframe/\constant_value_inst[5])         ${SPEF_MAPPING_PREFIX}constant_block${SPEF_MAPPING_POSTFIX}
set spef_mapping(padframe/\constant_value_inst[6])         ${SPEF_MAPPING_PREFIX}constant_block${SPEF_MAPPING_POSTFIX}

set SPEF_MAPPING_PREFIX "$::env(MCW_ROOT)/signoff/RAM256/openlane-signoff/spef/"
set spef_mapping(soc/\core.RAM256)                         ${SPEF_MAPPING_PREFIX}RAM256${SPEF_MAPPING_POSTFIX}
set SPEF_MAPPING_PREFIX "$::env(MCW_ROOT)/signoff/RAM128/openlane-signoff/spef/"
set spef_mapping(soc/\core.RAM128)                         ${SPEF_MAPPING_PREFIX}RAM128${SPEF_MAPPING_POSTFIX}
