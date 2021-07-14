# Power nets
set ::power_nets $::env(_VDD_NET_NAME)
set ::ground_nets $::env(_GND_NET_NAME)

set stdcell {
    name grid
	core_ring {
		met5 {width $::env(_WIDTH) spacing $::env(_SPACING) core_offset $::env(_H_OFFSET)}
		met4 {width $::env(_WIDTH) spacing $::env(_SPACING) core_offset $::env(_V_OFFSET)}
	}
	rails {
	}
    connect {{met4 met5}}
}

if { $::env(_WITH_STRAPS) } {
	dict append stdcell straps {
	    met4 {width $::env(_WIDTH) pitch $::env(_V_PITCH) offset $::env(_V_PDN_OFFSET)}
	    met5 {width $::env(_WIDTH) pitch $::env(_H_PITCH) offset $::env(_H_PDN_OFFSET)}
    }
}

pdngen::specify_grid stdcell $stdcell

set macro {
    orient {R0 R180 MX MY R90 R270 MXR90 MYR90}
    power_pins "vccd1"
    ground_pins "vssd1"
    blockages "li1 met1 met2 met3 met4"
    straps { 
    } 
    connect {{met4_PIN_ver met5}}
}

pdngen::specify_grid macro [subst $macro]

set ::halo 10

# POWER or GROUND #Std. cell rails starting with power or ground rails at the bottom of the core area
set ::rails_start_with "POWER" ;

# POWER or GROUND #Upper metal stripes starting with power or ground rails at the left/bottom of the core area
set ::stripes_start_with "POWER" ;

