
        set ::env(USER_ROOT)    ".."
        set ::env(CARAVEL_ROOT) "/home/dinesha/workarea/efabless/MPW-5/caravel"
        set ::env(CARAVEL_PDK_ROOT)     "/opt/pdk_mpw5"

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

	# User project netlist
        read_verilog $::env(USER_ROOT)/verilog/gl/ycr_core_top.v


	link_design ycr_core_top


	## User Project Spef
        read_spef  $::env(USER_ROOT)/spef/ycr_core_top.spef


	read_sdc -echo ./sdc/ycr_core_top.sdc	
	set_propagated_clock [all_clocks]

	check_setup  -verbose >  unconstraints.rpt
	report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50	
	report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 50	
	report_worst_slack -max 	
	report_worst_slack -min 	
	report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -slack_max 0.18 -group_count 10	
	report_check_types -max_slew -max_capacitance -max_fanout -violators  > slew.cap.fanout.vio.rpt


	#Delay check around imem
	echo "imem Interface Min Timing.................." > imem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2imem_cmd_o             >> imem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2imem_req_o             >> imem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through imem2core_req_ack_i         >> imem.min.rpt 
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2imem_addr_o[*]         >> imem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2imem_bl_o[*]           >> imem.min.rpt 
        report_checks -path_delay min -fields {slew cap input nets fanout} -through imem2core_rdata_i[*]        >> imem.min.rpt 
	
	echo "imem Interface max Timing.................." > imem.max.rpt
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2imem_cmd_o             >> imem.max.rpt
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2imem_req_o             >> imem.max.rpt
        report_checks -path_delay max -fields {slew cap input nets fanout} -through imem2core_req_ack_i         >> imem.max.rpt 
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2imem_addr_o[*]         >> imem.max.rpt
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2imem_bl_o[*]           >> imem.max.rpt 
        report_checks -path_delay max -fields {slew cap input nets fanout} -through imem2core_rdata_i[*]        >> imem.max.rpt 

	#Delay check around imem
	echo "dmem Interface Min Timing.................." > dmem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2dmem_cmd_o             >> dmem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2dmem_req_o             >> dmem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through dmem2core_req_ack_i         >> dmem.min.rpt 
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2dmem_addr_o[*]         >> dmem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2dmem_wdata_o[*]        >> dmem.min.rpt
        report_checks -path_delay min -fields {slew cap input nets fanout} -through core2dmem_width_o[*]        >> dmem.min.rpt 
        report_checks -path_delay min -fields {slew cap input nets fanout} -through dmem2core_rdata_i[*]        >> dmem.min.rpt 
	
	echo "imem Interface max Timing.................." > imem.max.rpt
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2dmem_cmd_o             >> dmem.max.rpt
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2dmem_req_o             >> dmem.max.rpt
        report_checks -path_delay max -fields {slew cap input nets fanout} -through dmem2core_req_ack_i         >> dmem.max.rpt 
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2dmem_addr_o[*]         >> dmem.max.rpt
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2dmem_wdata_o[*]        >> dmem.max.rpt 
        report_checks -path_delay max -fields {slew cap input nets fanout} -through core2dmem_width_o[*]        >> dmem.max.rpt 
        report_checks -path_delay max -fields {slew cap input nets fanout} -through dmem2core_rdata_i[*]        >> dmem.max.rpt 

