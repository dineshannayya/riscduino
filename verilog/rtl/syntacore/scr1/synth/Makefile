#------------------------------------------------------------------------------
# Makefile for Synthesis
#------------------------------------------------------------------------------

# Paths
export ROOT_DIR := $(shell pwd)
export DESIGN_FILE  := $(ROOT_DIR)/syntacore.sv
export SYNTH_LOG    := $(ROOT_DIR)/synth.log
export REPORT_DIR  := $(ROOT_DIR)/reports
export NETLIST_DIR  := $(ROOT_DIR)/netlist
export TMP_DIR  := $(ROOT_DIR)/tmp


# Targets
.PHONY: clean create merge synth

default: clean create merge synth

synth: clean create merge 
	yosys -g -c synth.tcl -l synth.log

create:
	mkdir -p ./tmp/synthesis; 
	mkdir -p ./reports; 
	mkdir -p ./netlist;
	$(OPENLANE_ROOT)/scripts/libtrim.pl $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib $(PDK_ROOT)/sky130A/libs.tech/openlane/sky130_fd_sc_hd/no_synth.cells > ./tmp/trimmed.lib

merge: 
	################################################ 
	# yosys has issue in propgating the golbal parameter from one file to other file 
	# to fix this issue, we have concatinated all the rtl file into single file before starting synthesis 
	# only memory are exclded from this list 
	# ################################################
	cat ../src/core/pipeline/scr1_pipe_top.sv > syntacore.sv; 
	cat ../src/core/scr1_core_top.sv >> syntacore.sv; 
	cat ../src/core/scr1_dm.sv >> syntacore.sv; 
	cat ../src/core/scr1_tapc_synchronizer.sv >> syntacore.sv; 
	cat ../src/core/scr1_clk_ctrl.sv >> syntacore.sv; 
	cat ../src/core/scr1_scu.sv >> syntacore.sv; 
	cat ../src/core/scr1_tapc.sv >> syntacore.sv; 
	cat ../src/core/scr1_tapc_shift_reg.sv >> syntacore.sv; 
	cat ../src/core/scr1_dmi.sv >> syntacore.sv; 
	cat ../src/core/primitives/scr1_reset_cells.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_ifu.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_idu.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_exu.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_mprf.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_csr.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_ialu.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_lsu.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_hdu.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_pipe_tdu.sv >> syntacore.sv; 
	cat ../src/core/pipeline/scr1_ipic.sv >> syntacore.sv; 
	cat ../src/top/scr1_dmem_router.sv >> syntacore.sv; 
	cat ../src/top/scr1_imem_router.sv >> syntacore.sv; 
	#cat ../src/top/scr1_dp_memory.sv >> syntacore.sv; 
	cat ../src/top/scr1_tcm.sv >> syntacore.sv; 
	cat ../src/top/scr1_timer.sv >> syntacore.sv; 
	#cat ../src/top/scr1_dmem_ahb.sv >> syntacore.sv; 
	#cat ../src/top/scr1_imem_ahb.sv >> syntacore.sv; 
	cat ../src/top/scr1_top_axi.sv >> syntacore.sv; 
	cat ../src/top/scr1_mem_axi.sv>> syntacore.sv;



clean:
	$(RM) $(DESIGN_FILE)
	$(RM) $(SYNTH_LOG)
	$(RM) -R $(REPORT_DIR)
	$(RM) -R $(NETLIST_DIR)
	$(RM) -R $(TMP_DIR)
