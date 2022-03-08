
        set ::env(USER_ROOT)    "/home/dinesha/workarea/opencore/git/riscduino"
        #set ::env(CARAVEL_ROOT) "/home/dinesha/workarea/efabless/MPW-4/caravel_openframe"
        #set ::env(CARAVEL_PDK_ROOT)  "/opt/pdk_mpw4"
        set ::env(CARAVEL_ROOT) "/home/dinesha/workarea/efabless/MPW-5/caravel"
        set ::env(CARAVEL_PDK_ROOT)  "/opt/pdk_mpw4"

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

	puts "IP   :: Total Cell :: Total register"
        read_verilog $::env(USER_ROOT)/verilog/gl/qspim.v
	link_design qspim_top
	set tcell [llength [get_cell -hier *]]
	set tregs [llength [all_registers]]
	puts "qspim :: $tcell :: $tregs "

        read_verilog $::env(USER_ROOT)/verilog/gl/yifive.v  
	link_design ycr1_top_wb
	set tcell [llength [get_cell -hier *]]
	set tregs [llength [all_registers]]
	puts "yifive :: $tcell :: $tregs "

        read_verilog $::env(USER_ROOT)/verilog/gl/uart_i2cm_usb_spi.v
	link_design uart_i2c_usb_spi_top
	set tcell [llength [get_cell -hier *]]
	set tregs [llength [all_registers]]
	puts "uart_i2cm_usb_spi :: $tcell :: $tregs "

        read_verilog $::env(USER_ROOT)/verilog/gl/wb_host.v  
	link_design wb_host
	set tcell [llength [get_cell -hier *]]
	set tregs [llength [all_registers]]
	puts "wb_host :: $tcell :: $tregs "

        read_verilog $::env(USER_ROOT)/verilog/gl/wb_interconnect.v
	link_design wb_interconnect
	set tcell [llength [get_cell -hier *]]
	set tregs [llength [all_registers]]
	puts "wb_interconnect :: $tcell :: $tregs "

        read_verilog $::env(USER_ROOT)/verilog/gl/pinmux.v
	link_design pinmux
	set tcell [llength [get_cell -hier *]]
	set tregs [llength [all_registers]]
	puts "pinmux :: $tcell :: $tregs "

        read_verilog $::env(USER_ROOT)/verilog/gl/DFFRAM.v
	link_design DFFRAM
	set tcell [llength [get_cell -hier *]]
	set tregs [llength [all_registers]]
	puts "DFFRAM :: $tcell :: $tregs "

        read_verilog $::env(USER_ROOT)/verilog/gl/user_project_wrapper.v  
        read_verilog $::env(USER_ROOT)/verilog/gl/qspim.v
        read_verilog $::env(USER_ROOT)/verilog/gl/DFFRAM.v
        read_verilog $::env(USER_ROOT)/verilog/gl/pinmux.v
        read_verilog $::env(USER_ROOT)/verilog/gl/wb_interconnect.v
        read_verilog $::env(USER_ROOT)/verilog/gl/wb_host.v  
        read_verilog $::env(USER_ROOT)/verilog/gl/uart_i2cm_usb_spi.v
        read_verilog $::env(USER_ROOT)/verilog/gl/qspim.v
        read_verilog $::env(USER_ROOT)/verilog/gl/yifive.v  

	link_design user_project_wrapper
	set tcell [llength [get_cell -hier *]]
	set tregs [llength [all_registers]]
	puts "user_project_wrapper :: $tcell :: $tregs "





