# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0


 
PWDD := $(shell pwd)
BLOCKS := $(shell basename $(PWDD))

# ---- Include Partitioned Makefiles ----

DESIGNS?=../../..
CONFIG = caravel_user_project
TOOLS?=/opt/riscv32i/

########################################################
#include $(MCW_ROOT)/verilog/dv/make/env.makefile
########################################################
#######################################################################
## Global Environment Variables for local repo  
#######################################################################

export PDK_PATH =      $(PDK_ROOT)/sky130A
export VIP_PATH =      $(CORE_VERILOG_PATH)/dv/vip
export FIRMWARE_PATH = $(CORE_VERILOG_PATH)/dv/firmware

#######################################################################
## Caravel Verilog for Integration Tests
#######################################################################

export CARAVEL_VERILOG_PATH ?=  $(CARAVEL_ROOT)/verilog
export CORE_VERILOG_PATH    ?=  $(CARAVEL_ROOT)/mgmt_core_wrapper/verilog
export USER_PROJECT_VERILOG ?=  $(DESIGNS)/verilog

export CARAVEL_PATH = $(CARAVEL_VERILOG_PATH)
export VERILOG_PATH = $(CORE_VERILOG_PATH)

#######################################################################
## Compiler Information 
#######################################################################

export TOOLS     ?=  /opt/riscv32i 
export GCC_PATH  ?=  $(TOOLS)/bin
GCC_PREFIX?=riscv32-unknown-elf


############## USER SPECIFIC DEFINE ##################

YIFIVE_FIRMWARE_PATH = $(USER_PROJECT_VERILOG)/dv/common/firmware

######################################################





########################################################
#include $(MCW_ROOT)/verilog/dv/make/var.makefile
########################################################

CPU=vexriscv
CPUFAMILY=riscv
CPUFLAGS=-march=rv32i      -mabi=ilp32 -D__vexriscv__
CPUENDIANNESS=little
CLANG=0


######################################################
# include $(MCW_ROOT)/verilog/dv/make/cpu.makefile
######################################################

ifeq ($(CPU),picorv32)
	LINKER_SCRIPT=$(FIRMWARE_PATH)/sections.lds
	SOURCE_FILES=$(FIRMWARE_PATH)/start.s 
	VERILOG_FILES=
endif

ifeq ($(CPU),ibex)
	LINKER_SCRIPT=$(FIRMWARE_PATH)/link_ibex.ld
	SOURCE_FILES=$(FIRMWARE_PATH)/crt0_ibex.S $(FIRMWARE_PATH)/simple_system_common.c
# 	VERILOG_FILES=../ibex/*
	VERILOG_FILES=
endif

ifeq ($(CPU),vexriscv)
# 	LINKER_SCRIPT=$(FIRMWARE_PATH)/sections_vexriscv.lds
# 	SOURCE_FILES=$(FIRMWARE_PATH)/start_caravel_vexriscv.s
	LINKER_SCRIPT=$(FIRMWARE_PATH)/sections.lds
	SOURCE_FILES=$(FIRMWARE_PATH)/crt0_vex.S $(FIRMWARE_PATH)/isr.c
	VERILOG_FILES=
endif



#####################################################
#include $(MCW_ROOT)/verilog/dv/make/sim.makefile
######################################################

export IVERILOG_DUMPER = fst

# RTL/GL/GL_SDF
SIM?=RTL
DUMP?=OFF
RISC_CORE?=0


.SUFFIXES:


all:  ${BLOCKS:=.vcd} ${BLOCKS:=.lst}

hex:  ${BLOCKS:=.hex}

#.SUFFIXES:

##############################################################################
# Comiple firmeware
##############################################################################
%.elf: %.c $(LINKER_SCRIPT) $(SOURCE_FILES)
	${GCC_PREFIX}-gcc -g \
	-I$(FIRMWARE_PATH) \
	-I$(VERILOG_PATH)/dv/generated \
	-I$(VERILOG_PATH)/dv/ \
	-I$(VERILOG_PATH)/common \
	  $(CPUFLAGS) \
	-Wl,-Bstatic,-T,$(LINKER_SCRIPT),--strip-debug \
	-ffreestanding -nostdlib -o $@ $(SOURCE_FILES) $<

%.lst: %.elf
	${GCC_PREFIX}-objdump -d -S $< > $@

%.hex: %.elf %.lst
	${GCC_PREFIX}-objcopy -O verilog $< $@ 
	# to fix flash base address
	sed -ie 's/@10/@00/g' $@

%.bin: %.elf
	${GCC_PREFIX}-objcopy -O binary $< /dev/stdout | tail -c +1048577 > $@
	
	
##############################################################################
# Runing the simulations
##############################################################################

%.vvp: %_tb.v %.hex
	${GCC_PREFIX}-gcc -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las  -D__RVC_EXT -static -std=gnu99 -fno-common -fno-builtin-printf -DTCM=0 -Wa,-march=rv32imc -march=rv32imc -mabi=ilp32 -DFLAGS_STR=\""-O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las "\"  -c -I./ -I$(YIFIVE_FIRMWARE_PATH)  user_uart.c -o user_uart.o
	${GCC_PREFIX}-gcc -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las  -D__RVC_EXT -static -std=gnu99 -fno-common -fno-builtin-printf -DTCM=0 -Wa,-march=rv32imc -march=rv32imc -mabi=ilp32 -DFLAGS_STR=\""-O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las "\"  -D__ASSEMBLY__=1 -c -I./ -I$(YIFIVE_FIRMWARE_PATH)  $(YIFIVE_FIRMWARE_PATH)/crt.S -o crt.o
	${GCC_PREFIX}-gcc -march=rv32imc -mabi=ilp32 -T $(YIFIVE_FIRMWARE_PATH)/link.ld user_uart.o crt.o -nostartfiles -nostdlib -lc -lgcc -o user_uart.elf -N
	${GCC_PREFIX}-objcopy -O verilog user_uart.elf user_uart.hex
	${GCC_PREFIX}-objdump -D user_uart.elf > user_uart.dump
	rm crt.o user_uart.o

## RTL
ifeq ($(SIM),RTL)
   ifeq ($(DUMP),OFF)
	iverilog -g2012 -Ttyp -DFUNCTIONAL -DSIM -DRISC_BOOT -DUSE_POWER_PINS -DUNIT_DELAY=#0.1 \
        -f$(VERILOG_PATH)/includes/includes.rtl.caravel \
        -f$(USER_PROJECT_VERILOG)/includes/includes.rtl.$(CONFIG) -o $@ $<
    else  
	iverilog -g2012 -DWFDUMP -Ttyp -DFUNCTIONAL -DRISC_BOOT -DSIM -DUSE_POWER_PINS -DUNIT_DELAY=#0.1 \
        -f$(VERILOG_PATH)/includes/includes.rtl.caravel \
        -f$(USER_PROJECT_VERILOG)/includes/includes.rtl.$(CONFIG) -o $@ $<
   endif
endif

##GL
ifeq ($(SIM),GL)
   ifeq ($(DUMP),OFF)
	iverilog -g2005-sv -Ttyp -DFUNCTIONAL -DGL -DRISC_BOOT -DUSE_POWER_PINS -DUNIT_DELAY=#0.1 \
        -f$(VERILOG_PATH)/includes/includes.gl.caravel \
        -f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) -o $@ $<
    else
	iverilog -g2005-sv -Ttyp -DWFDUMP -DFUNCTIONAL -DRISC_BOOT -DGL -DUSE_POWER_PINS -DUNIT_DELAY=#0.1 \
        -f$(VERILOG_PATH)/includes/includes.gl.caravel \
        -f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) -o $@ $<
    endif
endif 

## GL+SDF
ifeq ($(SIM),GL_SDF)
    ifeq ($(CONFIG),caravel_user_project)
		cvc64  +interp \
		+define+SIM +define+FUNCTIONAL +define+GL +define+USE_POWER_PINS +define+UNIT_DELAY +define+ENABLE_SDF \
		+change_port_type +dump2fst +fst+parallel2=on   +nointeractive +notimingchecks +mipdopt \
		-f $(VERILOG_PATH)/includes/includes.gl+sdf.caravel \
		-f $(USER_PROJECT_VERILOG)/includes/includes.gl+sdf.$(CONFIG) $<
	else
		cvc64  +interp \
		+define+SIM +define+FUNCTIONAL +define+GL +define+USE_POWER_PINS +define+UNIT_DELAY +define+ENABLE_SDF \
		+change_port_type +dump2fst +fst+parallel2=on   +nointeractive +notimingchecks +mipdopt \
		-f $(VERILOG_PATH)/includes/includes.gl+sdf.$(CONFIG) \
		-f $CARAVEL_PATH/gl/__user_project_wrapper.v $<
    endif
endif

%.vcd: %.vvp
	vvp  $< +risc_core_id=$(RISC_CORE)

# twinwave: RTL-%.vcd GL-%.vcd
#     twinwave RTL-$@ * + GL-$@ *

check-env:
ifndef PDK_ROOT
	$(error PDK_ROOT is undefined, please export it before running make)
endif
ifeq (,$(wildcard $(PDK_ROOT)/sky130A))
	$(error $(PDK_ROOT)/sky130A not found, please install pdk before running make)
endif
ifeq (,$(wildcard $(GCC_PREFIX)-gcc ))
	$(error $(GCC_PREFIX)-gcc is not found, please export GCC_PATH and GCC_PREFIX before running make)
endif
# check for efabless style installation
ifeq (,$(wildcard $(PDK_ROOT)/sky130A/libs.ref/*/verilog))
SIM_DEFINES := ${SIM_DEFINES} -DEF_STYLE
endif


# ---- Clean ----

clean:
	\rm  -f *.elf *.hex *.bin *.vvp *.log *.vcd *.lst *.hexe *.dump

.PHONY: clean hex all






