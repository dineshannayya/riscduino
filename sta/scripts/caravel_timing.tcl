
        set ::env(USER_ROOT)    "/home/dinesha/workarea/opencore/git/riscduino"
        set ::env(CARAVEL_ROOT) "/home/dinesha/workarea/efabless/MPW-4/caravel_openframe"
        set ::env(CARAVEL_PDK_ROOT)     "/opt/pdk_mpw4"

        read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.lib
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hvl/lib/sky130_fd_sc_hvl__tt_025C_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hvl/lib/sky130_fd_sc_hvl__tt_025C_3v30_lv1v80.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_fd_io__top_gpiov2_tt_tt_025C_1v80_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_fd_io__top_ground_hvc_wpad_tt_025C_1v80_3v30_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_fd_io__top_ground_lvc_wpad_tt_025C_1v80_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_fd_io__top_ground_lvc_wpad_tt_100C_1v80_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_fd_io__top_power_lvc_wpad_tt_025C_1v80_3v30_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_fd_io__top_xres4v2_tt_tt_025C_1v80_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_ef_io__gpiov2_pad_tt_tt_025C_1v80_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_ef_io__vccd_lvc_clamped_pad_tt_025C_1v80_3v30_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_ef_io__vdda_hvc_clamped_pad_tt_025C_1v80_3v30_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_ef_io__vssa_hvc_clamped_pad_tt_025C_1v80_3v30_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_ef_io__vssd_lvc_clamped3_pad_tt_025C_1v80_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_ef_io__vccd_lvc_clamped3_pad_tt_025C_1v80_3v30_3v30.lib	
	read_liberty $::env(CARAVEL_PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lib/sky130_ef_io__vssd_lvc_clamped_pad_tt_025C_1v80_3v30.lib	
	read_verilog $::env(CARAVEL_ROOT)/mgmt_core_wrapper/verilog/gl/mgmt_core.v	
	read_verilog $::env(CARAVEL_ROOT)/mgmt_core_wrapper/verilog/gl/DFFRAM.v	
	read_verilog $::env(CARAVEL_ROOT)/mgmt_core_wrapper/verilog/gl/mgmt_core_wrapper.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/caravel_clocking.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/digital_pll.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/housekeeping.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/gpio_logic_high.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/gpio_control_block.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block_0403.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block_1803.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/mgmt_protect_hv.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/mprj_logic_high.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/mprj2_logic_high.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/mgmt_protect.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/user_id_programming.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/xres_buf.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/spare_logic_block.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/chip_io.v	
	read_verilog $::env(CARAVEL_ROOT)/verilog/gl/caravel.v	

	# User project netlist
        read_verilog $::env(USER_ROOT)/verilog/gl/qspim.v
        read_verilog $::env(USER_ROOT)/verilog/gl/yifive.v  
        read_verilog $::env(USER_ROOT)/verilog/gl/uart_i2cm_usb_spi.v
        read_verilog $::env(USER_ROOT)/verilog/gl/wb_host.v  
        read_verilog $::env(USER_ROOT)/verilog/gl/wb_interconnect.v
        read_verilog $::env(USER_ROOT)/verilog/gl/pinmux.v
        read_verilog $::env(USER_ROOT)/verilog/gl/mbist_wrapper.v
        read_verilog $::env(USER_ROOT)/verilog/gl/user_project_wrapper.v  


	link_design caravel	

	read_spef -path soc/DFFRAM_0                        $::env(CARAVEL_ROOT)/mgmt_core_wrapper/spef/DFFRAM.spef	
	read_spef -path soc/core                            $::env(CARAVEL_ROOT)/mgmt_core_wrapper/spef/mgmt_core.spef	
	read_spef -path soc                                 $::env(CARAVEL_ROOT)/mgmt_core_wrapper/spef/mgmt_core_wrapper.spef	
	read_spef -path padframe                            $::env(CARAVEL_ROOT)/spef/chip_io.spef	
	read_spef -path rstb_level                          $::env(CARAVEL_ROOT)/spef/xres_buf.spef	
	read_spef -path pll                                 $::env(CARAVEL_ROOT)/spef/digital_pll.spef	
	read_spef -path housekeeping                        $::env(CARAVEL_ROOT)/spef/housekeeping.spef	
	read_spef -path mgmt_buffers/powergood_check        $::env(CARAVEL_ROOT)/spef/mgmt_protect_hv.spef	
	read_spef -path mgmt_buffers/mprj_logic_high_inst   $::env(CARAVEL_ROOT)/spef/mprj_logic_high.spef	
	read_spef -path mgmt_buffers/mprj2_logic_high_inst  $::env(CARAVEL_ROOT)/spef/mprj2_logic_high.spef	
	read_spef -path clocking                            $::env(CARAVEL_ROOT)/spef/caravel_clocking.spef
	read_spef -path mgmt_buffers                        $::env(CARAVEL_ROOT)/spef/mgmt_protect.spef	
	read_spef -path \gpio_control_bidir_1[0]            $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_bidir_1[1]            $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_bidir_2[1]            $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_bidir_2[2]            $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[0]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[10]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[1]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[2]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[3]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[4]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[5]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[6]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[7]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[8]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1[9]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1a[0]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1a[1]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1a[2]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1a[3]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1a[4]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_1a[5]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[0]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[10]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[11]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[12]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[13]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[14]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[15]              $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[1]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[2]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[3]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[4]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[5]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[6]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[7]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[8]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path \gpio_control_in_2[9]               $::env(CARAVEL_ROOT)/spef/gpio_control_block.spef	
	read_spef -path gpio_defaults_block_0               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block_1803.spef	
	read_spef -path gpio_defaults_block_1               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block_1803.spef	
	read_spef -path gpio_defaults_block_2               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block_0403.spef	
	read_spef -path gpio_defaults_block_3               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block_0403.spef	
	read_spef -path gpio_defaults_block_4               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block_0403.spef	
	read_spef -path gpio_defaults_block_5               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_6               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_7               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_8               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_9               $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_10              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_11              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_12              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_13              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_14              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_15              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_16              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_17              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_18              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_19              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_20              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_21              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_22              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_23              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_24              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_25              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_26              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_27              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_28              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_29              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_30              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_31              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_32              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_33              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_34              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_35              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_36              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	
	read_spef -path gpio_defaults_block_37              $::env(CARAVEL_ROOT)/spef/gpio_defaults_block.spef	

	## User Project Spef
        read_spef -path mprj/u_mbist                       $::env(USER_ROOT)/spef/mbist_wrapper.spef

        read_spef -path mprj/u_riscv_top         $::env(USER_ROOT)/spef/ycr1_top_wb.spef
        read_spef -path mprj/u_pinmux            $::env(USER_ROOT)/spef/pinmux.spef
        read_spef -path mprj/u_qspi_master       $::env(USER_ROOT)/spef/qspim_top.spef
        read_spef -path mprj/u_uart_i2c_usb_spi  $::env(USER_ROOT)/spef/uart_i2c_usb_spi_top.spef
        read_spef -path mprj/u_wb_host           $::env(USER_ROOT)/spef/wb_host.spef
        read_spef -path mprj/u_intercon          $::env(USER_ROOT)/spef/wb_interconnect.spef
        read_spef -path mprj                     $::env(USER_ROOT)/spef/user_project_wrapper.spef  


	read_sdc -echo ./sdc/caravel.sdc	
	check_setup  -verbose >  unconstraints.rpt
	report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50	
	report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50	
	report_worst_slack -max 	
	report_worst_slack -min 	
	report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -slack_max 0.18 -group_count 10	
	report_check_types -max_slew -max_capacitance -max_fanout -violators  > slew.cap.fanout.vio.rpt

	echo "Wishbone Interface Timing.................." > wb.max.rpt
	echo "Wishbone Interface Timing.................." > wb.min.rpt
	set wb_port [get_pins {mprj/wbs_adr_i[*]}]
	set wb_port [concat $wb_port [get_pins {mprj/wbs_cyc_i}]]
	set wb_port [concat $wb_port [get_pins {mprj/wbs_dat_i[*]}]]
	set wb_port [concat $wb_port [get_pins {mprj/wbs_sel_i[*]}]]
	set wb_port [concat $wb_port [get_pins {mprj/wbs_stb_i}]]
	set wb_port [concat $wb_port [get_pins {mprj/wbs_we_i}]]
	set wb_port [concat $wb_port [get_pins {mprj/wbs_ack_o}]]
	set wb_port [concat $wb_port [get_pins {mprj/wbs_dat_o[*]}]]
	foreach pin $wb_port {
	   echo "Wishbone Interface Timing for : [get_full_name $pin]"  >> wb.max.rpt
           report_checks -path_delay max -fields {slew cap input nets fanout} -through $pin  >> wb.max.rpt 
        }
	foreach pin $wb_port {
	   echo "Wishbone Interface Timing for [get_full_name $pin]" >> wb.min.rpt
           report_checks -path_delay min -fields {slew cap input nets fanout} -through $pin  >> wb.min.rpt
        }
        
