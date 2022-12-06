set std_cell_library        "sky130_fd_sc_hd"
set special_voltage_library "sky130_fd_sc_hvl"
set io_library              "sky130_fd_io"
set primitives_library      "sky130_fd_pr"
set ef_io_library           "sky130_ef_io"
set ef_cell_library           "sky130_ef_sc_hd"

set signal_layer            "met2"
set clock_layer             "met5"

set extra_lefs "
[glob $::env(CARAVEL_ROOT)/lef/*.lef]
[glob $::env(MCW_ROOT)/lef/*.lef]
[glob $::env(CUP_ROOT)/lef/*.lef]"

set tech_lef $::env(PDK_REF_PATH)/$std_cell_library/techlef/${std_cell_library}__$::env(RCX_CORNER).tlef
set cells_lef $::env(PDK_REF_PATH)/$std_cell_library/lef/$std_cell_library.lef
set io_lef $::env(PDK_REF_PATH)/$io_library/lef/$io_library.lef
set ef_io_lef $::env(PDK_REF_PATH)/$io_library/lef/$ef_io_library.lef
set ef_cells_lef $::env(PDK_REF_PATH)/$std_cell_library/lef/$ef_cell_library.lef

set lefs [list \
    $tech_lef \
    $cells_lef \
    $io_lef \
    $ef_cells_lef \
    $ef_io_lef
]
# search order:
# cup -> mcw -> caravel

# file mkdir $::env(CUP_ROOT)/spef/
# file mkdir $::env(CARAVEL_ROOT)/spef/
# file mkdir $::env(MCW_ROOT)/spef/

set def $::env(CUP_ROOT)/def/$::env(BLOCK).def
set spef $::env(CUP_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/spef/$::env(BLOCK).$::env(RCX_CORNER).spef
set sdc $::env(CUP_ROOT)/sdc/$::env(BLOCK).sdc
set sdf $::env(CUP_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/sdf/$::env(RCX_CORNER)/$::env(BLOCK).$::env(LIB_CORNER)$::env(LIB_CORNER).$::env(RCX_CORNER).sdf
if { ![file exists $def] } {
    set def $::env(MCW_ROOT)/def/$::env(BLOCK).def
    set spef $::env(MCW_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/spef/$::env(BLOCK).$::env(RCX_CORNER).spef
    set sdc $::env(MCW_ROOT)/sdc/$::env(BLOCK).sdc
    set sdf $::env(MCW_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/sdf/$::env(RCX_CORNER)/$::env(BLOCK).$::env(LIB_CORNER)$::env(LIB_CORNER).$::env(RCX_CORNER).sdf
}
if { ![file exists $def] } {
    set def $::env(CARAVEL_ROOT)/def/$::env(BLOCK).def
    set spef $::env(CARAVEL_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/spef/$::env(BLOCK).$::env(RCX_CORNER).spef
    set sdc $::env(CARAVEL_ROOT)/sdc/$::env(BLOCK).sdc
    set sdf $::env(CARAVEL_ROOT)/signoff/$::env(BLOCK)/openlane-signoff/sdf/$::env(RCX_CORNER)/$::env(BLOCK).$::env(LIB_CORNER)$::env(LIB_CORNER).$::env(RCX_CORNER).sdf
}

file mkdir [file dirname $spef]
file mkdir [file dirname $sdf]
set block $::env(BLOCK)
if { $::env(PDK) == "sky130A" } {
    set rcx_rules_file $::env(PDK_TECH_PATH)/openlane/rules.openrcx.$::env(PDK).$::env(RCX_CORNER).calibre
} elseif { $::env(PDK) == "sky130B" } {
    set rcx_rules_file $::env(PDK_TECH_PATH)/openlane/rules.openrcx.$::env(PDK).$::env(RCX_CORNER).spef_extractor
} else {
    puts "no extraction rules file set for $::env(PDK) exiting.."
    exit 1
}
set merged_lef $::env(CARAVEL_ROOT)/tmp/merged_lef-$::env(RCX_CORNER).lef

set sram_lef $::env(PDK_REF_PATH)/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef

# order matter
set verilogs "
[glob $::env(MCW_ROOT)/verilog/gl/*]
[glob $::env(CARAVEL_ROOT)/verilog/gl/*]
[glob $::env(CUP_ROOT)/verilog/gl/*]
"

set verilog_exceptions [list \
    "[exec realpath $::env(CARAVEL_ROOT)/verilog/gl/__user_analog_project_wrapper.v]" \
    "[exec realpath $::env(CARAVEL_ROOT)/verilog/gl/caravel-signoff.v]" \
    "[exec realpath $::env(CARAVEL_ROOT)/verilog/gl/caravan-signoff.v]" \
    "[exec realpath $::env(CARAVEL_ROOT)/verilog/gl/__user_project_wrapper.v]" \
    ]

foreach verilog_exception $verilog_exceptions {
    #puts $verilog_exception
    set verilogs [regsub "$verilog_exception" "$verilogs" " "]
}

proc puts_list {arg} {
    foreach element $arg {
        puts $element
    }
}

proc read_libs {arg} {
    set libs [split [regexp -all -inline {\S+} $arg]]
    foreach liberty $libs {
        puts $liberty
        read_liberty $liberty
    }
}

proc read_verilogs {arg} {
    set verilogs [split [regexp -all -inline {\S+} $arg]]
    foreach verilog $verilogs {
        puts $verilog
        read_verilog $verilog
    }
}

proc read_spefs {} {
    global spef_mapping
    foreach key [array names spef_mapping] {
        puts "read_spef -path $key $spef_mapping($key)"
        read_spef -path $key $spef_mapping($key)
    }
}

proc run_puts {arg} {
    puts "exec> $arg"
    eval "{*}$arg"
}

proc run_puts_logs {arg log} {
    set output [open "$log" w+]    
    puts $output "exec> $arg"
    puts $output "design: $::env(BLOCK)"
    set timestr [exec date]
    puts $output "time: $timestr\n"
    close $output
    puts "exec> $arg >> $log"
    eval "{*}$arg >> $log"
}
