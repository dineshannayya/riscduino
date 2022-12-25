
    set ::env(USER_ROOT)    ".."
    set ::env(CARAVEL_ROOT) "/home/dinesha/workarea/efabless/MPW-7/caravel"
    set ::env(CARAVEL_PDK_ROOT)     "/opt/pdk_mpw6"

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

    source scripts/statistic.tcl
    set c_seq_cnt 0
    set c_comb_cnt 0
    set c_total_cnt 0

    read_verilog $::env(USER_ROOT)/verilog/gl/qspim_top.v
	link_design qspim_top 
	puts "IP   :: Total Cell :: Total Combo :: Total Sequential"
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "qspim_top :: $tcell :: $tregs "
    lassign [get_statistic qspim_top] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/ycr_iconnect.v  
	link_design ycr_iconnect
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "ycr_iconnect :: $tcell :: $tregs "
    lassign [get_statistic ycr_iconnect] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/ycr_intf.v
	link_design ycr_intf
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "ycr_intf :: $tcell :: $tregs "
    lassign [get_statistic ycr_intf] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/ycr_core_top.v
	link_design ycr_core_top
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "ycr_intf :: $tcell :: $tregs "
    lassign [get_statistic ycr_core_top] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]
    
    read_verilog $::env(USER_ROOT)/verilog/gl/uart_i2c_usb_spi_top.v
	link_design uart_i2c_usb_spi_top
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "ycr_intf :: $tcell :: $tregs "
    lassign [get_statistic uart_i2c_usb_spi_top] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]
    
    read_verilog $::env(USER_ROOT)/verilog/gl/wb_host.v
	link_design wb_host
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "ycr_intf :: $tcell :: $tregs "
    lassign [get_statistic wb_host] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]
    
    read_verilog $::env(USER_ROOT)/verilog/gl/wb_interconnect.v
	link_design wb_interconnect
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "ycr_intf :: $tcell :: $tregs "
    lassign [get_statistic wb_interconnect] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]
    
    read_verilog $::env(USER_ROOT)/verilog/gl/pinmux_top.v
	link_design pinmux_top
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "pinmux_top :: $tcell :: $tregs "
    lassign [get_statistic pinmux] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/peri_top.v
	link_design peri_top
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "peri_top :: $tcell :: $tregs "
    lassign [get_statistic peri_top] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/fpu_wrapper.v
	link_design fpu_wrapper
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "fpu_wrapper :: $tcell :: $tregs "
    lassign [get_statistic fpu_wrapper] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/aes_top.v
	link_design aes_top
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "aes_top :: $tcell :: $tregs "
    lassign [get_statistic aes_top] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/bus_rep_north.v
	link_design bus_rep_north
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "bus_rep_east :: $tcell :: $tregs "
    lassign [get_statistic bus_rep_north] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/bus_rep_south.v
	link_design bus_rep_south
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "bus_rep_south :: $tcell :: $tregs "
    lassign [get_statistic bus_rep_south] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/bus_rep_east.v
	link_design bus_rep_east
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "bus_rep_east :: $tcell :: $tregs "
    lassign [get_statistic bus_rep_east] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

    read_verilog $::env(USER_ROOT)/verilog/gl/bus_rep_west.v
	link_design bus_rep_west
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "bus_rep_west :: $tcell :: $tregs "
    lassign [get_statistic bus_rep_west] a b c
    set c_total_cnt [expr {$c_total_cnt + $a }]
    set c_comb_cnt  [expr {$c_comb_cnt + $b }]
    set c_seq_cnt   [expr {$c_seq_cnt + $c }]

   puts "digital_top :: $c_total_cnt ::  $c_comb_cnt ::  $c_seq_cnt"
    #    read_verilog $::env(USER_ROOT)/verilog/gl/user_project_wrapper.v  
    #    read_verilog $::env(USER_ROOT)/verilog/gl/qspim.v
    #    read_verilog $::env(USER_ROOT)/verilog/gl/DFFRAM.v
    #    read_verilog $::env(USER_ROOT)/verilog/gl/pinmux.v
    #    read_verilog $::env(USER_ROOT)/verilog/gl/wb_interconnect.v
    #    read_verilog $::env(USER_ROOT)/verilog/gl/wb_host.v  
    #    read_verilog $::env(USER_ROOT)/verilog/gl/uart_i2cm_usb_spi.v
    #    read_verilog $::env(USER_ROOT)/verilog/gl/qspim.v
    #    read_verilog $::env(USER_ROOT)/verilog/gl/yifive.v  

	#link_design user_project_wrapper
	#set tcell [llength [get_cell -hier *]]
	#set tregs [llength [all_registers]]
	#puts "user_project_wrapper :: $tcell :: $tregs "





