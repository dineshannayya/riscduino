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


# ---- Include Partitioned Makefiles ----

CONFIG = caravel_user_project
 
#######################################################################
## Caravel Verilog for Integration Tests
#######################################################################

DESIGNS?=../../..
TOOLS?=/opt/riscv32i/

export USER_PROJECT_VERILOG ?=  $(DESIGNS)/verilog
## YIFIVE FIRMWARE
YIFIVE_FIRMWARE_PATH = $(USER_PROJECT_VERILOG)/dv/common/firmware
GCC_PREFIX?=riscv32-unknown-elf


## Simulation mode: RTL/GL
SIM?=RTL
DUMP?=OFF
RISC_CORE?=0

### To Enable IVERILOG FST DUMP
export IVERILOG_DUMPER = fst


.SUFFIXES:

PATTERN = user_aes_core

all:  ${PATTERN:=.vcd}


vvp:  ${PATTERN:=.vvp}

%.vvp: %_tb.v
	${GCC_PREFIX}-gcc -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las  -D__RVC_EXT -static -std=gnu99 -fno-common -fno-builtin-printf -DTCM=0 -Wa,-march=rv32imc -march=rv32imc -mabi=ilp32 -DFLAGS_STR=\""-O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las "\"  -c -I./ -I$(YIFIVE_FIRMWARE_PATH)  ${PATTERN}.c -o ${PATTERN}.o
	${GCC_PREFIX}-gcc -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las  -D__RVC_EXT -static -std=gnu99 -fno-common -fno-builtin-printf -DTCM=0 -Wa,-march=rv32imc -march=rv32imc -mabi=ilp32 -DFLAGS_STR=\""-O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las "\"  -c -I./ -I$(YIFIVE_FIRMWARE_PATH)  $(YIFIVE_FIRMWARE_PATH)/sc_print.c -o sc_print.o
	${GCC_PREFIX}-gcc -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las  -D__RVC_EXT -static -std=gnu99 -fno-common -fno-builtin-printf -DTCM=0 -Wa,-march=rv32imc -march=rv32imc -mabi=ilp32 -DFLAGS_STR=\""-O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las "\"  -D__ASSEMBLY__=1 -c -I./ -I$(YIFIVE_FIRMWARE_PATH)  $(YIFIVE_FIRMWARE_PATH)/crt.S -o crt.o
	${GCC_PREFIX}-gcc -o ${PATTERN}.elf -T $(YIFIVE_FIRMWARE_PATH)/link.ld ${PATTERN}.o sc_print.o crt.o -nostartfiles -lc -lgcc -march=rv32imc -mabi=ilp32 -N
	${GCC_PREFIX}-objcopy -O verilog ${PATTERN}.elf ${PATTERN}.hex
	${GCC_PREFIX}-objdump -D ${PATTERN}.elf > ${PATTERN}.dump
	rm crt.o ${PATTERN}.o
ifeq ($(SIM),RTL)
   ifeq ($(DUMP),OFF)
	iverilog -g2012 -DFUNCTIONAL -DSIM -DRISC_BOOT -I $(PDK_PATH) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.rtl.$(CONFIG) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.rtl.lib  \
	$< -o $@ 
    else  
	iverilog -g2012 -DWFDUMP -DFUNCTIONAL -DRISC_BOOT -DSIM -I $(PDK_PATH) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.rtl.$(CONFIG) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.rtl.lib  \
	$< -o $@ 
   endif
else  
   ifeq ($(DUMP),OFF)
	iverilog -g2012 -DFUNCTIONAL -DUSE_POWER_PINS -DGL -DRISC_BOOT -I $(PDK_PATH) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.gl.lib \
	$< -o $@ 
    else  
	iverilog -g2012 -DWFDUMP -DFUNCTIONAL -DUSE_POWER_PINS -DGL -DRISC_BOOT -I $(PDK_PATH) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.gl.lib \
	$< -o $@ 
   endif
endif

%.vcd: %.vvp
	vvp $< +risc_core_id=$(RISC_CORE)


# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.log *.dump *.o

.PHONY: clean hex all
