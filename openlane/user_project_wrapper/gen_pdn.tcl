read_lef $::env(MERGED_LEF_UNPADDED)
read_def $::env(CURRENT_DEF)

set ::env(_SPACING) 1.7
set ::env(_WIDTH) 3

set power_domains [list {vccd1 vssd1 1} {vccd2 vssd2 0} {vdda1 vssa1 0} {vdda2 vssa2 0}]

set ::env(_VDD_NET_NAME) vccd1
set ::env(_GND_NET_NAME) vssd1
set ::env(_WITH_STRAPS) 1
set ::env(_V_OFFSET) 14
set ::env(_H_OFFSET) $::env(_V_OFFSET)
set ::env(_V_PITCH) 80
set ::env(_H_PITCH) 80
set ::env(_V_PDN_OFFSET) 0
set ::env(_H_PDN_OFFSET) 0

foreach domain $power_domains {
	set ::env(_VDD_NET_NAME) [lindex $domain 0]
	set ::env(_GND_NET_NAME) [lindex $domain 1]
	set ::env(_WITH_STRAPS)  [lindex $domain 2]

	pdngen $::env(PDN_CFG) -verbose

	set ::env(_V_OFFSET) \
		[expr $::env(_V_OFFSET) + 2*($::env(_WIDTH)+$::env(_SPACING))]
	set ::env(_H_OFFSET) \
		[expr $::env(_H_OFFSET) + 2*($::env(_WIDTH)+$::env(_SPACING))]
	set ::env(_V_PDN_OFFSET) [expr $::env(_V_PDN_OFFSET)+6*$::env(_WIDTH)]
	set ::env(_H_PDN_OFFSET) [expr $::env(_H_PDN_OFFSET)+6*$::env(_WIDTH)]
}

write_def $::env(SAVE_DEF)
