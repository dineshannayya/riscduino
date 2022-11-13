set ::env(SYNTH_TIMING_DERATE) 0.01
set ::env(SYNTH_CLOCK_SETUP_UNCERTAINITY) 0.25
set ::env(SYNTH_CLOCK_HOLD_UNCERTAINITY) 0.25
set ::env(SYNTH_CLOCK_TRANSITION) 0.15

## MASTER CLOCKS
create_clock -name clk -period 25 [get_ports {clock}] 

create_clock -name hkspi_clk -period 100 [get_pins {housekeeping/mgmt_gpio_in[4]} ] 
create_clock -name hk_serial_clk -period 50 [get_pins {housekeeping/serial_clock}]
create_clock -name hk_serial_load -period 1000 [get_pins {housekeeping/serial_load}]


### User Project Clocks
create_generated_clock -name wb_clk -add -source [get_ports {clock}] -master_clock [get_clocks clk] -divide_by 1 -comment {Wishbone User Clock} [get_pins mprj/wb_clk_i]
create_clock -name int_pll_clock -period 5.0000  [get_pins {mprj/u_pinmux/int_pll_clock}]

create_clock -name wbs_ref_clk -period 5.0000   [get_pins {mprj/u_wb_host/u_reg.u_wbs_ref_clkbuf.u_buf/X}]
create_clock -name wbs_clk_i   -period 10.0000  [get_pins {mprj/u_wb_host/wbs_clk_out}]

create_clock -name cpu_ref_clk -period 5.0000   [get_pins {mprj/u_wb_host/u_reg.u_cpu_ref_clkbuf.u_buf/X}]
create_clock -name cpu_clk     -period 10.0000  [get_pins {mprj/u_wb_host/cpu_clk}]

create_clock -name rtc_ref_clk -period 50.0000  [get_pins {mprj/u_pinmux/u_glbl_reg.u_rtc_ref_clkbuf.u_buf/X}]
create_clock -name rtc_clk     -period 50.0000  [get_pins {mprj/u_pinmux/u_glbl_reg.u_clkbuf_rtc.u_buf/X}]

create_clock -name pll_ref_clk -period 20.0000  [get_pins {mprj/u_pinmux/pll_ref_clk}]
create_clock -name pll_clk_0   -period 5.0000   [get_pins {mprj/u_pll/ringosc.ibufp01/Y}]

create_clock -name usb_ref_clk -period 5.0000   [get_pins {mprj/u_pinmux/u_glbl_reg.u_usb_ref_clkbuf.u_buf/X}]
create_clock -name usb_clk     -period 20.0000  [get_pins {mprj/u_pinmux/u_glbl_reg.u_clkbuf_usb.u_buf/X}]
create_clock -name uarts0_clk  -period 100.0000 [get_pins {mprj/u_uart_i2c_usb_spi/u_uart0_core.u_lineclk_buf.genblk1.u_mux/X}]
create_clock -name uarts1_clk  -period 100.0000 [get_pins {mprj/u_uart_i2c_usb_spi/u_uart1_core.u_lineclk_buf.genblk1.u_mux/X}]
create_clock -name uartm_clk   -period 100.0000 [get_pins {mprj/u_wb_host/u_uart2wb.u_core.u_uart_clk.genblk1.u_mux/X}]
create_clock -name dbg_ref_clk -period 10.0000 [get_pins {mprj/u_pinmux/clkbuf_0_u_glbl_reg.dbg_clk_ref/X}]


set_clock_groups \
   -name clock_group \
   -logically_exclusive \
   -group [get_clocks {wb_clk clk}]\
   -group [get_clocks {hk_serial_clk} ]\
   -group [get_clocks {hk_serial_load} ]\
   -group [get_clocks {hkspi_clk} ]\
   -group [get_clocks {int_pll_clock}]\
   -group [get_clocks {wbs_clk_i}]\
   -group [get_clocks {wbs_ref_clk}]\
   -group [get_clocks {cpu_clk}]\
   -group [get_clocks {cpu_ref_clk}]\
   -group [get_clocks {rtc_clk}]\
   -group [get_clocks {usb_ref_clk}]\
   -group [get_clocks {pll_ref_clk}]\
   -group [get_clocks {pll_clk_0}]\
   -group [get_clocks {usb_clk}]\
   -group [get_clocks {uarts0_clk}]\
   -group [get_clocks {uarts1_clk}]\
   -group [get_clocks {uartm_clk}]\
   -group [get_clocks {dbg_ref_clk}]\
   -group [get_clocks {rtc_ref_clk}]\
   -comment {Async Clock group}

set_propagated_clock [all_clocks]

set_max_fanout 12 [current_design]
# synthesis max fanout should be less than 12 (7 maybe)


######################################################
#  Caravel Case Analysis
#######################################################
#assign core_ext_clk = (use_pll_first) ? ext_clk_syncd : ext_clk;
#assign core_clk = (use_pll_second) ? pll_clk_divided : core_ext_clk;
#assign user_clk = (use_pll_second) ? pll_clk90_divided : core_ext_clk;

set_case_analysis  0 clock_ctrl/_205_/S
set_case_analysis  0 clock_ctrl/_206_/S
set_case_analysis  0 clock_ctrl/_208_/S

## Set system monitoring mux select to zero so that the clock/user_clk monitoring is disabled 
set_case_analysis 0 [get_pins housekeeping/_3936_/S]
set_case_analysis 0 [get_pins housekeeping/_3937_/S]

# Add case analysis for pads DM[2]==1'b1 & DM[1]==1'b1 & DM[0]==1'b0

set_case_analysis 1 [get_pins padframe/*_pad/DM[2]]
set_case_analysis 1 [get_pins padframe/*_pad/DM[1]]
set_case_analysis 0 [get_pins padframe/*_pad/DM[0]]
set_case_analysis 0 [get_pins padframe/*_pad/SLOW]
set_case_analysis 0 [get_pins padframe/*_pad/ANALOG_EN]

set_case_analysis 1 [get_pins padframe/*_io_pad*/DM[2]]
set_case_analysis 1 [get_pins padframe/*_io_pad*/DM[1]]
set_case_analysis 0 [get_pins padframe/*_io_pad*/DM[0]]
set_case_analysis 0 [get_pins padframe/*_io_pad*/SLOW]
set_case_analysis 0 [get_pins padframe/*_io_pad*/ANALOG_EN]

set_case_analysis 0 [get_pins padframe/*area1_io_pad[4]/DM[2]]
set_case_analysis 0 [get_pins padframe/*area1_io_pad[4]/DM[1]]
set_case_analysis 1 [get_pins padframe/*area1_io_pad[4]/DM[0]]

set_case_analysis 0 [get_pins padframe/*area1_io_pad[2]/DM[2]]
set_case_analysis 0 [get_pins padframe/*area1_io_pad[2]/DM[1]]
set_case_analysis 1 [get_pins padframe/*area1_io_pad[2]/DM[0]]

set_case_analysis 0 [get_pins padframe/clock_pad/DM[2]]
set_case_analysis 0 [get_pins padframe/clock_pad/DM[1]]
set_case_analysis 1 [get_pins padframe/clock_pad/DM[0]]

#################################################################
## User Case analysis
#################################################################

set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_sp_co[3]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_sp_co[2]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_sp_co[1]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_sp_co[0]}]

set_case_analysis 1 [get_pins {mprj/u_pinmux/cfg_cska_pinmux[3]}]
set_case_analysis 0 [get_pins {mprj/u_pinmux/cfg_cska_pinmux[2]}]
set_case_analysis 0 [get_pins {mprj/u_pinmux/cfg_cska_pinmux[1]}]
set_case_analysis 0 [get_pins {mprj/u_pinmux/cfg_cska_pinmux[0]}]

set_case_analysis 0 [get_pins {mprj/u_uart_i2c_usb_spi/cfg_cska_uart[3]}]
set_case_analysis 1 [get_pins {mprj/u_uart_i2c_usb_spi/cfg_cska_uart[2]}]
set_case_analysis 1 [get_pins {mprj/u_uart_i2c_usb_spi/cfg_cska_uart[1]}]
set_case_analysis 1 [get_pins {mprj/u_uart_i2c_usb_spi/cfg_cska_uart[0]}]

set_case_analysis 1 [get_pins {mprj/u_qspi_master/cfg_cska_spi[3]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_spi[2]}]
set_case_analysis 0 [get_pins {mprj/u_qspi_master/cfg_cska_spi[1]}]
set_case_analysis 1 [get_pins {mprj/u_qspi_master/cfg_cska_spi[0]}]

set_case_analysis 1 [get_pins {mprj/u_riscv_top.u_intf/cfg_wcska[3]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_wcska[2]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_wcska[1]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_wcska[0]}]

set_case_analysis 1 [get_pins {mprj/u_wb_host/cfg_cska_wh[3]}]
set_case_analysis 0 [get_pins {mprj/u_wb_host/cfg_cska_wh[2]}]
set_case_analysis 0 [get_pins {mprj/u_wb_host/cfg_cska_wh[1]}]
set_case_analysis 1 [get_pins {mprj/u_wb_host/cfg_cska_wh[0]}]

set_case_analysis 0 [get_pins {mprj/u_intercon/cfg_cska_wi[3]}]
set_case_analysis 0 [get_pins {mprj/u_intercon/cfg_cska_wi[2]}]
set_case_analysis 1 [get_pins {mprj/u_intercon/cfg_cska_wi[0]}]
set_case_analysis 1 [get_pins {mprj/u_intercon/cfg_cska_wi[1]}]

# clock skew cntrl-2
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_ccska[3]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_ccska[2]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_ccska[1]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_ccska[0]}]

set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_connect/cfg_ccska[3]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_connect/cfg_ccska[2]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_connect/cfg_ccska[1]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_connect/cfg_ccska[0]}]

set_case_analysis 0 [get_pins {mprj/u_riscv_top.i_core_top_0/cfg_ccska[3]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.i_core_top_0/cfg_ccska[2]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.i_core_top_0/cfg_ccska[1]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.i_core_top_0/cfg_ccska[0]}]

#Keept the SRAM clock driving edge at pos edge
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_sram_lphase[0]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_intf/cfg_sram_lphase[1]}]

set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_connect/cfg_sram_lphase[0]}]
set_case_analysis 0 [get_pins {mprj/u_riscv_top.u_connect/cfg_sram_lphase[1]}]

set_case_analysis 0 [get_pins {mprj/u_aes/cfg_ccska[3]}]
set_case_analysis 0 [get_pins {mprj/u_aes/cfg_ccska[2]}]
set_case_analysis 0 [get_pins {mprj/u_aes/cfg_ccska[1]}]
set_case_analysis 0 [get_pins {mprj/u_aes/cfg_ccska[0]}]

set_case_analysis 0 [get_pins {mprj/u_fpu/cfg_ccska[3]}]
set_case_analysis 0 [get_pins {mprj/u_fpu/cfg_ccska[2]}]
set_case_analysis 0 [get_pins {mprj/u_fpu/cfg_ccska[1]}]
set_case_analysis 0 [get_pins {mprj/u_fpu/cfg_ccska[0]}]
############## Caravel False Path ########################################################
## FALSE PATHS (ASYNCHRONOUS INPUTS)
set_false_path -from [get_ports {resetb}]

set_false_path -from [get_ports mprj_io[0]] -through [get_pins housekeeping/mgmt_gpio_in[0]]
set_false_path -from [get_ports mprj_io[1]] -through [get_pins housekeeping/mgmt_gpio_in[1]]
set_false_path -from [get_ports mprj_io[3]] -through [get_pins housekeeping/mgmt_gpio_in[3]]
set_false_path -from [get_ports mprj_io[5]] -through [get_pins housekeeping/mgmt_gpio_in[5]]
set_false_path -from [get_ports mprj_io[6]] -through [get_pins housekeeping/mgmt_gpio_in[6]]
set_false_path -from [get_ports mprj_io[7]] -through [get_pins housekeeping/mgmt_gpio_in[7]]
set_false_path -from [get_ports mprj_io[8]] -through [get_pins housekeeping/mgmt_gpio_in[8]]
set_false_path -from [get_ports mprj_io[9]] -through [get_pins housekeeping/mgmt_gpio_in[9]]
set_false_path -from [get_ports mprj_io[10]] -through [get_pins housekeeping/mgmt_gpio_in[10]]
set_false_path -from [get_ports mprj_io[11]] -through [get_pins housekeeping/mgmt_gpio_in[11]]
set_false_path -from [get_ports mprj_io[12]] -through [get_pins housekeeping/mgmt_gpio_in[12]]
set_false_path -from [get_ports mprj_io[13]] -through [get_pins housekeeping/mgmt_gpio_in[13]]
set_false_path -from [get_ports mprj_io[14]] -through [get_pins housekeeping/mgmt_gpio_in[14]]
set_false_path -from [get_ports mprj_io[15]] -through [get_pins housekeeping/mgmt_gpio_in[15]]
set_false_path -from [get_ports mprj_io[16]] -through [get_pins housekeeping/mgmt_gpio_in[16]]
set_false_path -from [get_ports mprj_io[17]] -through [get_pins housekeeping/mgmt_gpio_in[17]]
set_false_path -from [get_ports mprj_io[18]] -through [get_pins housekeeping/mgmt_gpio_in[18]]
set_false_path -from [get_ports mprj_io[19]] -through [get_pins housekeeping/mgmt_gpio_in[19]]
set_false_path -from [get_ports mprj_io[20]] -through [get_pins housekeeping/mgmt_gpio_in[20]]
set_false_path -from [get_ports mprj_io[21]] -through [get_pins housekeeping/mgmt_gpio_in[21]]
set_false_path -from [get_ports mprj_io[22]] -through [get_pins housekeeping/mgmt_gpio_in[22]]
set_false_path -from [get_ports mprj_io[23]] -through [get_pins housekeeping/mgmt_gpio_in[23]]
set_false_path -from [get_ports mprj_io[24]] -through [get_pins housekeeping/mgmt_gpio_in[24]]
set_false_path -from [get_ports mprj_io[25]] -through [get_pins housekeeping/mgmt_gpio_in[25]]
set_false_path -from [get_ports mprj_io[26]] -through [get_pins housekeeping/mgmt_gpio_in[26]]
set_false_path -from [get_ports mprj_io[27]] -through [get_pins housekeeping/mgmt_gpio_in[27]]
set_false_path -from [get_ports mprj_io[28]] -through [get_pins housekeeping/mgmt_gpio_in[28]]
set_false_path -from [get_ports mprj_io[29]] -through [get_pins housekeeping/mgmt_gpio_in[29]]
set_false_path -from [get_ports mprj_io[30]] -through [get_pins housekeeping/mgmt_gpio_in[30]]
set_false_path -from [get_ports mprj_io[31]] -through [get_pins housekeeping/mgmt_gpio_in[31]]
set_false_path -from [get_ports mprj_io[32]] -through [get_pins housekeeping/mgmt_gpio_in[32]]
set_false_path -from [get_ports mprj_io[33]] -through [get_pins housekeeping/mgmt_gpio_in[33]]
set_false_path -from [get_ports mprj_io[34]] -through [get_pins housekeeping/mgmt_gpio_in[34]]
set_false_path -from [get_ports mprj_io[35]] -through [get_pins housekeeping/mgmt_gpio_in[35]]
set_false_path -from [get_ports mprj_io[36]] -through [get_pins housekeeping/mgmt_gpio_in[36]]
set_false_path -from [get_ports mprj_io[37]] -through [get_pins housekeeping/mgmt_gpio_in[37]]

set_false_path -from [get_ports mprj_io[*]] -through [get_pins housekeeping/mgmt_gpio_out[*]]
set_false_path -from [get_ports mprj_io[*]] -through [get_pins housekeeping/mgmt_gpio_oeb[*]]


################ Caravel Timing Constraints ##########################################################


set input_delay_value 4
set output_delay_value 4
puts "\[INFO\]: Setting output delay to: $output_delay_value"
puts "\[INFO\]: Setting input delay to: $input_delay_value"

set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {gpio}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[0]}]

#set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[1]}]

set_input_delay $input_delay_value  -clock [get_clocks {hkspi_clk}] -add_delay [get_ports {mprj_io[2]}]
set_input_delay $input_delay_value  -clock [get_clocks {hkspi_clk}] -add_delay [get_ports {mprj_io[3]}]

#set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[4]}]

set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[5]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[6]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[7]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[8]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[9]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[10]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[11]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[12]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[13]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[14]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[15]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[16]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[17]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[18]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[19]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[20]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[21]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[22]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[23]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[24]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[25]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[26]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[27]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[28]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[29]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[30]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[31]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[32]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[33]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[34]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[35]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[36]}]
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[37]}]

set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {flash_csb}]
set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {flash_clk}]
set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {flash_io0}]
set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {flash_io1}]


####################################################################################################





# TODO set this as parameter
set cap_load 10
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

#add input transition for the inputs pins
set_input_transition 2 [all_inputs]

puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

puts "\[INFO\]: Setting clock setup uncertainity to: $::env(SYNTH_CLOCK_SETUP_UNCERTAINITY)"
puts "\[INFO\]: Setting clock hold uncertainity to: $::env(SYNTH_CLOCK_HOLD_UNCERTAINITY)"
set_clock_uncertainty -setup $::env(SYNTH_CLOCK_SETUP_UNCERTAINITY) [all_clocks]
set_clock_uncertainty -hold $::env(SYNTH_CLOCK_HOLD_UNCERTAINITY) [all_clocks]


#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_adr_i[*]}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_cyc_i}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_i[*]}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_sel_i[*]}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_stb_i}]
#set_output_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_we_i}]
#
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_adr_i[*]}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_cyc_i}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_i[*]}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_sel_i[*]}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_stb_i}]
#set_output_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_we_i}]
#
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_ack_o}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[0]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[10]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[11]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[12]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[13]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[14]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[15]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[16]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[17]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[18]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[19]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[1]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[20]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[21]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[22]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[23]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[24]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[25]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[26]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[27]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[28]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[29]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[2]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[30]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[31]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[3]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[4]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[5]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[6]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[7]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[8]}]
#set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[9]}]
#
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_ack_o}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[0]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[10]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[11]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[12]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[13]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[14]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[15]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[16]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[17]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[18]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[19]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[1]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[20]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[21]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[22]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[23]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[24]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[25]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[26]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[27]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[28]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[29]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[2]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[30]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[31]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[3]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[4]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[5]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[6]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[7]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[8]}]
#set_input_delay -min 1.0000 -clock [get_clocks {wb_clk}] -add_delay [get_pins {mprj/wbs_dat_o[9]}]

