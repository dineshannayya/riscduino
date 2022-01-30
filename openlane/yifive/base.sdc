###############################################################################
# Timing Constraints
###############################################################################
create_clock -name core_clk -period 20.0000 [get_ports {core_clk}]
create_clock -name rtc_clk -period 40.0000 [get_ports {rtc_clk}]
create_clock -name wb_clk -period 10.0000 [get_ports {wb_clk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.2500 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]


set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {core_clk}]\
 -group [get_clocks {rtc_clk}]\
 -group [get_clocks {wb_clk}] -comment {Async Clock group}

### ClkSkew Adjust
set_case_analysis 0 [get_ports {cfg_cska_riscv[0]}]
set_case_analysis 0 [get_ports {cfg_cska_riscv[1]}]
set_case_analysis 0 [get_ports {cfg_cska_riscv[2]}]
set_case_analysis 0 [get_ports {cfg_cska_riscv[3]}]


set_max_delay   3.5 -from [get_ports {wbd_clk_int}]
set_max_delay   2 -to   [get_ports {wbd_clk_riscv}]
set_max_delay 3.5 -from wbd_clk_int -to wbd_clk_riscv

set_input_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {sram_dout0[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {sram_dout1[*]}]

set_input_delay -min 3.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {sram_dout0[*]}]
set_input_delay -min 3.0000 -clock [get_clocks {core_clk}] -add_delay [get_ports {sram_dout1[*]}]

set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_addr0[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_addr1[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_csb0}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_csb1}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_din0[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_web0}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_wmask0[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_addr0[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_addr1[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_csb0}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_csb1}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_din0[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_web0}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {sram_wmask0[*]}]


set_input_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wb_rst_n}]
set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_ack_i}]
set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_dat_i[*]}]
set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_err_i}]
set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_ack_i}]
set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_dat_i[*]}]
set_input_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_err_i}]

set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_err_i}]

set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_adr_o[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_dat_o[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_sel_o[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_stb_o}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_we_o}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_adr_o[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_dat_o[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_sel_o[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_stb_o}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_we_o}]

set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_sel_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_dmem_we_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_sel_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wbd_imem_we_o}]

set_false_path\
    -from [get_ports {soft_irq}]
set_false_path\
    -to [list [get_ports {riscv_debug[0]}]\
           [get_ports {riscv_debug[10]}]\
           [get_ports {riscv_debug[11]}]\
           [get_ports {riscv_debug[12]}]\
           [get_ports {riscv_debug[13]}]\
           [get_ports {riscv_debug[14]}]\
           [get_ports {riscv_debug[15]}]\
           [get_ports {riscv_debug[16]}]\
           [get_ports {riscv_debug[17]}]\
           [get_ports {riscv_debug[18]}]\
           [get_ports {riscv_debug[19]}]\
           [get_ports {riscv_debug[1]}]\
           [get_ports {riscv_debug[20]}]\
           [get_ports {riscv_debug[21]}]\
           [get_ports {riscv_debug[22]}]\
           [get_ports {riscv_debug[23]}]\
           [get_ports {riscv_debug[24]}]\
           [get_ports {riscv_debug[25]}]\
           [get_ports {riscv_debug[26]}]\
           [get_ports {riscv_debug[27]}]\
           [get_ports {riscv_debug[28]}]\
           [get_ports {riscv_debug[29]}]\
           [get_ports {riscv_debug[2]}]\
           [get_ports {riscv_debug[30]}]\
           [get_ports {riscv_debug[31]}]\
           [get_ports {riscv_debug[32]}]\
           [get_ports {riscv_debug[33]}]\
           [get_ports {riscv_debug[34]}]\
           [get_ports {riscv_debug[35]}]\
           [get_ports {riscv_debug[36]}]\
           [get_ports {riscv_debug[37]}]\
           [get_ports {riscv_debug[38]}]\
           [get_ports {riscv_debug[39]}]\
           [get_ports {riscv_debug[3]}]\
           [get_ports {riscv_debug[40]}]\
           [get_ports {riscv_debug[41]}]\
           [get_ports {riscv_debug[42]}]\
           [get_ports {riscv_debug[43]}]\
           [get_ports {riscv_debug[44]}]\
           [get_ports {riscv_debug[45]}]\
           [get_ports {riscv_debug[46]}]\
           [get_ports {riscv_debug[47]}]\
           [get_ports {riscv_debug[48]}]\
           [get_ports {riscv_debug[49]}]\
           [get_ports {riscv_debug[4]}]\
           [get_ports {riscv_debug[50]}]\
           [get_ports {riscv_debug[51]}]\
           [get_ports {riscv_debug[52]}]\
           [get_ports {riscv_debug[53]}]\
           [get_ports {riscv_debug[54]}]\
           [get_ports {riscv_debug[55]}]\
           [get_ports {riscv_debug[56]}]\
           [get_ports {riscv_debug[57]}]\
           [get_ports {riscv_debug[58]}]\
           [get_ports {riscv_debug[59]}]\
           [get_ports {riscv_debug[5]}]\
           [get_ports {riscv_debug[60]}]\
           [get_ports {riscv_debug[61]}]\
           [get_ports {riscv_debug[62]}]\
           [get_ports {riscv_debug[63]}]\
           [get_ports {riscv_debug[6]}]\
           [get_ports {riscv_debug[7]}]\
           [get_ports {riscv_debug[8]}]\
           [get_ports {riscv_debug[9]}]]

set_false_path -from [get_ports {fuse_mhartid[0]}]
set_false_path -from [get_ports {fuse_mhartid[10]}]
set_false_path -from [get_ports {fuse_mhartid[11]}]
set_false_path -from [get_ports {fuse_mhartid[12]}]
set_false_path -from [get_ports {fuse_mhartid[13]}]
set_false_path -from [get_ports {fuse_mhartid[14]}]
set_false_path -from [get_ports {fuse_mhartid[15]}]
set_false_path -from [get_ports {fuse_mhartid[16]}]
set_false_path -from [get_ports {fuse_mhartid[17]}]
set_false_path -from [get_ports {fuse_mhartid[18]}]
set_false_path -from [get_ports {fuse_mhartid[19]}]
set_false_path -from [get_ports {fuse_mhartid[1]}]
set_false_path -from [get_ports {fuse_mhartid[20]}]
set_false_path -from [get_ports {fuse_mhartid[21]}]
set_false_path -from [get_ports {fuse_mhartid[22]}]
set_false_path -from [get_ports {fuse_mhartid[23]}]
set_false_path -from [get_ports {fuse_mhartid[24]}]
set_false_path -from [get_ports {fuse_mhartid[25]}]
set_false_path -from [get_ports {fuse_mhartid[26]}]
set_false_path -from [get_ports {fuse_mhartid[27]}]
set_false_path -from [get_ports {fuse_mhartid[28]}]
set_false_path -from [get_ports {fuse_mhartid[29]}]
set_false_path -from [get_ports {fuse_mhartid[2]}]
set_false_path -from [get_ports {fuse_mhartid[30]}]
set_false_path -from [get_ports {fuse_mhartid[31]}]
set_false_path -from [get_ports {fuse_mhartid[3]}]
set_false_path -from [get_ports {fuse_mhartid[4]}]
set_false_path -from [get_ports {fuse_mhartid[5]}]
set_false_path -from [get_ports {fuse_mhartid[6]}]
set_false_path -from [get_ports {fuse_mhartid[7]}]
set_false_path -from [get_ports {fuse_mhartid[8]}]
set_false_path -from [get_ports {fuse_mhartid[9]}]
set_false_path -from [get_ports {irq_lines[0]}]
set_false_path -from [get_ports {irq_lines[10]}]
set_false_path -from [get_ports {irq_lines[11]}]
set_false_path -from [get_ports {irq_lines[12]}]
set_false_path -from [get_ports {irq_lines[13]}]
set_false_path -from [get_ports {irq_lines[14]}]
set_false_path -from [get_ports {irq_lines[15]}]
set_false_path -from [get_ports {irq_lines[1]}]
set_false_path -from [get_ports {irq_lines[2]}]
set_false_path -from [get_ports {irq_lines[3]}]
set_false_path -from [get_ports {irq_lines[4]}]
set_false_path -from [get_ports {irq_lines[5]}]
set_false_path -from [get_ports {irq_lines[6]}]
set_false_path -from [get_ports {irq_lines[7]}]
set_false_path -from [get_ports {irq_lines[8]}]
set_false_path -from [get_ports {irq_lines[9]}]
set_false_path -from [get_ports {pwrup_rst_n}]
set_false_path -from [get_ports {rst_n}]
set_false_path -from [get_ports {soft_irq}]
###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

###############################################################################
# Design Rules
###############################################################################
