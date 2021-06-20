#------------------------------------------------------------------------------
# Makefile for Synthesis
#------------------------------------------------------------------------------

# Paths
export ROOT_DIR := $(shell pwd)
export REPORT_DIR  := $(ROOT_DIR)/reports
export NETLIST_DIR  := $(ROOT_DIR)/netlist
export TMP_DIR  := $(ROOT_DIR)/tmp


# Targets
.PHONY: clean create synth

default: clean create synth

synth: clean create 
	yosys -g -c synth.tcl -l synth.log

create:
	mkdir -p ./tmp/synthesis; 
	mkdir -p ./reports; 
	mkdir -p ./netlist;
	$(OPENLANE_ROOT)/scripts/libtrim.pl $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib $(PDK_ROOT)/sky130A/libs.tech/openlane/sky130_fd_sc_hd/no_synth.cells > ./tmp/trimmed.lib



clean:
	$(RM) -R synth.log
	$(RM) -R $(REPORT_DIR)
	$(RM) -R $(NETLIST_DIR)
	$(RM) -R $(TMP_DIR)
