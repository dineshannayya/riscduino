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

## Caravel Pointers
CARAVEL_ROOT ?= ../../../caravel
CARAVEL_PATH ?= $(CARAVEL_ROOT)
CARAVEL_FIRMWARE_PATH = $(CARAVEL_PATH)/verilog/dv/caravel
CARAVEL_VERILOG_PATH  = $(CARAVEL_PATH)/verilog
CARAVEL_RTL_PATH = $(CARAVEL_VERILOG_PATH)/rtl
CARAVEL_BEHAVIOURAL_MODELS = $(CARAVEL_VERILOG_PATH)/dv/caravel


## User Project Pointers
UPRJ_VERILOG_PATH ?= ../../../verilog
UPRJ_RTL_PATH = $(UPRJ_VERILOG_PATH)/rtl
UPRJ_GL_PATH = $(UPRJ_VERILOG_PATH)/gl
UPRJ_BEHAVIOURAL_MODELS = ../model
UPRJ_BEHAVIOURAL_AGENTS = ../agents
UPRJ_INCLUDE_PATH1 = $(UPRJ_RTL_PATH)/yifive/ycr1c/src/includes
UPRJ_INCLUDE_PATH2 = $(UPRJ_RTL_PATH)/sdram_ctrl/src/defs
UPRJ_INCLUDE_PATH3 = $(UPRJ_RTL_PATH)/i2cm/src/includes
UPRJ_INCLUDE_PATH4 = $(UPRJ_RTL_PATH)/usb1_host/src/includes
UPRJ_INCLUDE_PATH5 = $(UPRJ_RTL_PATH)/mbist/include

## YIFIVE FIRMWARE
YIFIVE_FIRMWARE_PATH = $(UPRJ_VERILOG_PATH)/dv/firmware
GCC64_PREFIX?=riscv64-unknown-elf

## RISCV GCC 
GCC_PATH?=/ef/apps/bin
GCC_PREFIX?=riscv32-unknown-elf
PDK_PATH?=/ef/tech/SW/sky130A

## Simulation mode: RTL/GL
SIM?=RTL
DUMP?=OFF

.SUFFIXES:

PATTERN = user_uart

all:  ${PATTERN:=.vcd}

hex:  ${PATTERN:=.hex}

vvp:  ${PATTERN:=.vvp}

%.vvp: %_tb.v
	${GCC64_PREFIX}-gcc -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las  -D__RVC_EXT -static -std=gnu99 -fno-common -fno-builtin-printf -DTCM=0 -Wa,-march=rv32imc -march=rv32imc -mabi=ilp32 -DFLAGS_STR=\""-O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las "\"  -c -I./ -I$(YIFIVE_FIRMWARE_PATH) user_uart.c -o user_uart.o
	${GCC64_PREFIX}-gcc -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las  -D__RVC_EXT -static -std=gnu99 -fno-common -fno-builtin-printf -DTCM=0 -Wa,-march=rv32imc -march=rv32imc -mabi=ilp32 -DFLAGS_STR=\""-O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las "\"  -D__ASSEMBLY__=1 -c -I./ -I$(YIFIVE_FIRMWARE_PATH)  $(YIFIVE_FIRMWARE_PATH)/crt.S -o crt.o
	${GCC64_PREFIX}-gcc -o user_uart.elf -T $(YIFIVE_FIRMWARE_PATH)/link.ld user_uart.o crt.o -nostartfiles -nostdlib -lc -lgcc -march=rv32imc -mabi=ilp32 -N
	${GCC64_PREFIX}-objcopy -O verilog user_uart.elf user_uart.hex
	${GCC64_PREFIX}-objdump -D user_uart.elf > user_uart.dump
	rm crt.o user_uart.o
ifeq ($(SIM),RTL)
   ifeq ($(DUMP),OFF)
	iverilog -g2005-sv -DFUNCTIONAL -DSIM -I $(PDK_PATH) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS)    -I $(UPRJ_RTL_PATH) -I $(UPRJ_VERILOG_PATH) \
	-I $(UPRJ_BEHAVIOURAL_AGENTS)    \
	-I $(UPRJ_INCLUDE_PATH1)    -I $(UPRJ_INCLUDE_PATH2) -I $(UPRJ_INCLUDE_PATH3) \
	-I $(UPRJ_INCLUDE_PATH4) -I $(UPRJ_INCLUDE_PATH5) \
	$< -o $@ 
    else  
	iverilog -g2005-sv -DWFDUMP -DFUNCTIONAL -DSIM -I $(PDK_PATH) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS)    -I $(UPRJ_RTL_PATH) -I $(UPRJ_VERILOG_PATH) \
	-I $(UPRJ_BEHAVIOURAL_AGENTS)    \
	-I $(UPRJ_INCLUDE_PATH1)    -I $(UPRJ_INCLUDE_PATH2) -I $(UPRJ_INCLUDE_PATH3) \
	-I $(UPRJ_INCLUDE_PATH4) -I $(UPRJ_INCLUDE_PATH5) \
	$< -o $@ 
   endif
else  
	iverilog -g2005-sv -DFUNCTIONAL -DSIM -DGL -I $(PDK_PATH) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) -I $(CARAVEL_VERILOG_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS) -I $(UPRJ_GL_PATH) \
	-I $(UPRJ_BEHAVIOURAL_AGENTS)    \
	$< -o $@ 
endif

%.vcd: %.vvp
	vvp $<

%.elf: %.c $(CARAVEL_FIRMWARE_PATH)/sections.lds $(CARAVEL_FIRMWARE_PATH)/start.s
	${GCC64_PREFIX}-gcc -I $(CARAVEL_PATH) -march=rv32imc -mabi=ilp32 -Wl,-Bstatic,-T,$(CARAVEL_FIRMWARE_PATH)/sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ $(CARAVEL_FIRMWARE_PATH)/start.s $<

%.hex: 
	echo @"This is user boot test, noting to compile the mangment core code"

%.bin: %.elf
	${GCC64_PREFIX}-objcopy -O binary $< /dev/stdout | tail -c +1048577 > $@

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.log *.dump

.PHONY: clean hex all
