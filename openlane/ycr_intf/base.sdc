###############################################################################
# Timing Constraints
###############################################################################
create_clock -name core_clk -period 10.0000 [get_ports {core_clk}]
create_clock -name rtc_clk -period 40.0000 [get_ports {rtc_clk}]
create_clock -name wb_clk -period 10.0000 [get_ports {wb_clk}]

create_generated_clock -name dcache_mem_clk0 -add -source [get_ports {core_clk}] -master_clock [get_clocks core_clk] -divide_by 1 -comment {dcache mem clock0} [get_ports dcache_mem_clk0]
create_generated_clock -name dcache_mem_clk1 -add -source [get_ports {core_clk}] -master_clock [get_clocks core_clk] -divide_by 1 -comment {dcache mem clock1} [get_ports dcache_mem_clk1]
create_generated_clock -name icache_mem_clk0 -add -source [get_ports {core_clk}] -master_clock [get_clocks core_clk] -divide_by 1 -comment {icache mem clock0} [get_ports icache_mem_clk0]
create_generated_clock -name icache_mem_clk1 -add -source [get_ports {core_clk}] -master_clock [get_clocks core_clk] -divide_by 1 -comment {icache mem clock1} [get_ports icache_mem_clk1]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.5000 [all_clocks]
set_clock_uncertainty -hold 0.3000 [all_clocks]

set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

set_clock_groups -name async_clock -asynchronous \
 -group [get_clocks {core_clk dcache_mem_clk0 dcache_mem_clk1 icache_mem_clk0 icache_mem_clk1}]\
 -group [get_clocks {rtc_clk}]\
 -group [get_clocks {wb_clk}] -comment {Async Clock group}

set_dont_touch { u_skew_core_clk.* }
set_dont_touch { u_skew_wb_clk.* }

# Set case analysis
set_case_analysis  0 [get_ports {cfg_ccska[3]}]
set_case_analysis  0 [get_ports {cfg_ccska[2]}]
set_case_analysis  0 [get_ports {cfg_ccska[1]}]
set_case_analysis  0 [get_ports {cfg_ccska[0]}]

set_case_analysis  0 [get_ports {cfg_wcska[3]}]
set_case_analysis  0 [get_ports {cfg_wcska[2]}]
set_case_analysis  0 [get_ports {cfg_wcska[1]}]
set_case_analysis  0 [get_ports {cfg_wcska[0]}]

#Assumed config are static
set_false_path -from  [get_ports {cfg_dcache_force_flush}]
set_false_path -from  [get_ports {cfg_dcache_pfet_dis}]
set_false_path -from  [get_ports {cfg_icache_ntag_pfet_dis}]
set_false_path -from  [get_ports {cfg_icache_pfet_dis}]


set_false_path -from  [get_ports {cfg_sram_lphase[1]}]
set_false_path -from  [get_ports {cfg_sram_lphase[0]}]

#All reset has reset synchronization logic inside block ??
set_false_path -from  [get_ports {cpu_intf_rst_n}]
set_false_path -from  [get_ports {pwrup_rst_n}]
set_false_path -from  [get_ports {wb_rst_n}]

#CORE Instruction Memory Interface
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_rdata[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_resp[*]}]

set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_req_ack}]
set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_rdata[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_resp[*]}]


set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_req}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_cmd}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_req}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_addr[*]}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_bl[*]}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_width[*]}]

set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_req}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_cmd}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_req}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_addr[*]}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_bl[*]}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_icache_width[*]}]

#Wishbone ICACHE I/F
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_we_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_sel_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_bl_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_bry_o}]

set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_stb_o}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_adr_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_we_o}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_sel_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_bl_o[*]}]
set_output_delay -max 2.5000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_bry_o}]

set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_lack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_err_i}]

set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_dat_i[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_ack_i}]
set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_lack_i}]
set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_icache_err_i}]



# CORE Data Memory Interface

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_rdata[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_resp[*]}]

set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_req_ack}]
set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_rdata[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_resp[*]}]

set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_req}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_cmd}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_width[*]}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_addr[*]}]
set_input_delay -min 4.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_wdata[*]}]

set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_req}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_cmd}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_width[*]}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_addr[*]}]
set_input_delay -max 8.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dcache_wdata[*]}]


# Data memory interface from router to WB bridge

set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_req_ack}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_rdata[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_resp[*]}]

set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_req_ack}]
set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_rdata[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_resp[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_req}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_cmd}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_width[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_addr[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_wdata[*]}]

set_input_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_req}]
set_input_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_cmd}]
set_input_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_width[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_addr[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {core_clk}] -add_delay  [get_ports {core_dmem_wdata[*]}]

#WB Data Memory Interface
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_we_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_sel_o[*]}]

set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_stb_o}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_adr_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_we_o}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_dat_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_sel_o[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_err_i}]

set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_dat_i[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_ack_i}]
set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wbd_dmem_err_i}]


## ICACHE PORT-0 SRAM Memory I/F
set_output_delay -min -1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_csb0}]
set_output_delay -min -1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_web0}]
set_output_delay -min -1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_addr0[*]}]
set_output_delay -min -1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_wmask0[*]}]
set_output_delay -min -1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_din0[*]}]

set_output_delay -max 1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_csb0}]
set_output_delay -max 1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_web0}]
set_output_delay -max 1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_addr0[*]}]
set_output_delay -max 1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_wmask0[*]}]
set_output_delay -max 1.0000 -clock [get_clocks {icache_mem_clk0}] -add_delay  [get_ports {icache_mem_din0[*]}]

## ICACHE PORT-1 SRAM Memory I/F
set_output_delay -min -1.0000 -clock [get_clocks {icache_mem_clk1}] -add_delay  [get_ports {icache_mem_csb1}]
set_output_delay -min -1.0000 -clock [get_clocks {icache_mem_clk1}] -add_delay  [get_ports {icache_mem_addr1[*]}]
set_output_delay -max 3.5000 -clock [get_clocks {icache_mem_clk1}] -add_delay  [get_ports {icache_mem_csb1}]
set_output_delay -max 3.5000 -clock [get_clocks {icache_mem_clk1}] -add_delay  [get_ports {icache_mem_addr1[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {icache_mem_clk1}] -add_delay  [get_ports {icache_mem_dout1[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {icache_mem_clk1}] -add_delay  [get_ports {icache_mem_dout1[*]}]


# Wishbone DCACHE I/F
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_cyc_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_stb_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_adr_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_we_o}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_dat_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_bl_o[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_bry_o}]

set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_cyc_o}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_stb_o}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_adr_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_we_o}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_dat_o[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_bl_o[*]}]
set_output_delay -max 5.5000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_bry_o}]

set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_dat_i[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_ack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_lack_i}]
set_input_delay -min 2.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_err_i}]

set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_dat_i[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_ack_i}]
set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_lack_i}]
set_input_delay -max 6.0000 -clock [get_clocks {wb_clk}] -add_delay  [get_ports {wb_dcache_err_i}]

## DCACHE PORT-0 SRAM I/F
set_output_delay -min -1.2500 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_csb0}]
set_output_delay -min -1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_web0}]
set_output_delay -min -1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_addr0[*]}]
set_output_delay -min -1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_wmask0[*]}]
set_output_delay -min -1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_din0[*]}]

set_output_delay -max 1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_csb0}]
set_output_delay -max 1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_web0}]
set_output_delay -max 1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_addr0[*]}]
set_output_delay -max 1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_wmask0[*]}]
set_output_delay -max 1.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_din0[*]}]

set_input_delay  -min 2.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_dout0[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {dcache_mem_clk0}] -add_delay  [get_ports {dcache_mem_dout0[*]}]


## DCACHE PORT-1 SRAM I/F
set_output_delay -min -1.0000 -clock [get_clocks {dcache_mem_clk1}] -add_delay  [get_ports {dcache_mem_csb1}]
set_output_delay -min -1.0000 -clock [get_clocks {dcache_mem_clk1}] -add_delay  [get_ports {dcache_mem_addr1[*]}]

set_output_delay -max 1.000 -clock [get_clocks {dcache_mem_clk1}] -add_delay  [get_ports {dcache_mem_csb1}]
set_output_delay -max 1.000 -clock [get_clocks {dcache_mem_clk1}] -add_delay  [get_ports {dcache_mem_addr1[*]}]

set_input_delay  -min 2.0000 -clock [get_clocks {dcache_mem_clk1}] -add_delay  [get_ports {dcache_mem_dout1[*]}]
set_input_delay  -max 6.0000 -clock [get_clocks {dcache_mem_clk1}] -add_delay  [get_ports {dcache_mem_dout1[*]}]


###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

set_max_transition 1.00 [current_design]
set_max_capacitance 0.2 [current_design]
set_max_fanout 10 [current_design]
###############################################################################
# Design Rules
###############################################################################
