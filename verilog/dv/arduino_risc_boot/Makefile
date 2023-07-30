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
export RISCDUINO_BOARD ?=  $(USER_PROJECT_VERILOG)/dv/common/riscduino_firmware/custom_board/riscduino
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

PATTERN = arduino_risc_boot

all:  ${PATTERN:=.vcd}


vvp:  ${PATTERN:=.vvp}

%.vvp: %_tb.v
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${PATTERN}.ino.cpp -o ${PATTERN}.ino.cpp.o
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/Print.cpp -o Print.cpp.o
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/WMath.cpp -o WMath.cpp.o
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/WString.cpp -o WString.cpp.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/WInterrupts.c -o WInterrupts.c.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/drivers/fe300prci/fe300prci_driver.c -o fe300prci_driver.c.o
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/abi.cpp -o abi.cpp.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/drivers/plic/plic_driver.c -o plic_driver.c.o
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/UARTClass.cpp -o UARTClass.cpp.o
	${GCC_PREFIX}-gcc -c -march=rv32imac -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/entry.S -o entry.S.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/hooks.c -o hooks.c.o
	${GCC_PREFIX}-gcc -c -march=rv32imac -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/init.S -o init.S.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/itoa.c -o itoa.c.o
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/main.cpp -o main.cpp.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/malloc.c -o malloc.c.o
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/new.cpp -o new.cpp.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/sbrk.c -o sbrk.c.o
	${GCC_PREFIX}-gcc -c -march=rv32imac -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/start.S -o start.S.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/wiring.c -o wiring.c.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/wiring_analog.c -o wiring_analog.c.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/wiring_digital.c -o wiring_digital.c.o
	${GCC_PREFIX}-g++ -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -fpermissive -Wall -fno-rtti -fno-exceptions -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/wiring_pulse.cpp -o wiring_pulse.cpp.o
	${GCC_PREFIX}-gcc -c -O2 -march=rv32imac -fpeel-loops -ffreestanding -ffunction-sections -fdata-sections -Wall -I${RISCDUINO_BOARD}/system/include -I${RISCDUINO_BOARD}/sdk/bsp/include -I${RISCDUINO_BOARD}/sdk/bsp/env -I${RISCDUINO_BOARD}/sdk/bsp/drivers -I${RISCDUINO_BOARD}/sdk/bsp/env/uncache -include sys/cdefs.h -g -DARDUINO=10607 -DF_CPU=50000000LL -DRISCDUINO_SOC=122023 -I${RISCDUINO_BOARD}/cores/riscduino -I${RISCDUINO_BOARD}/variants/standard ${RISCDUINO_BOARD}/cores/riscduino/wiring_shift.c -o wiring_shift.c.o
	${GCC_PREFIX}-ar rcs core.a Print.cpp.o
	${GCC_PREFIX}-ar rcs core.a UARTClass.cpp.o
	${GCC_PREFIX}-ar rcs core.a WInterrupts.c.o
	${GCC_PREFIX}-ar rcs core.a WMath.cpp.o
	${GCC_PREFIX}-ar rcs core.a WString.cpp.o
	${GCC_PREFIX}-ar rcs core.a abi.cpp.o
	${GCC_PREFIX}-ar rcs core.a fe300prci_driver.c.o
	${GCC_PREFIX}-ar rcs core.a plic_driver.c.o
	${GCC_PREFIX}-ar rcs core.a entry.S.o
	${GCC_PREFIX}-ar rcs core.a hooks.c.o
	${GCC_PREFIX}-ar rcs core.a init.S.o
	${GCC_PREFIX}-ar rcs core.a itoa.c.o
	${GCC_PREFIX}-ar rcs core.a main.cpp.o
	${GCC_PREFIX}-ar rcs core.a malloc.c.o
	${GCC_PREFIX}-ar rcs core.a new.cpp.o
	${GCC_PREFIX}-ar rcs core.a sbrk.c.o
	${GCC_PREFIX}-ar rcs core.a start.S.o
	${GCC_PREFIX}-ar rcs core.a wiring.c.o
	${GCC_PREFIX}-ar rcs core.a wiring_analog.c.o
	${GCC_PREFIX}-ar rcs core.a wiring_digital.c.o
	${GCC_PREFIX}-ar rcs core.a wiring_pulse.cpp.o
	${GCC_PREFIX}-ar rcs core.a wiring_shift.c.o
	${GCC_PREFIX}-g++ -T ${RISCDUINO_BOARD}/sdk/bsp/env/uncache/link.lds -nostartfiles -Wl,-N -Wl,--gc-sections -Wl,--wrap=malloc -Wl,--wrap=free -Wl,--wrap=sbrk ${PATTERN}.ino.cpp.o -nostdlib -Wl,--start-group core.a -lm -lstdc++ -lc -lgloss -Wl,--end-group -lgcc -o ${PATTERN}.elf
	${GCC_PREFIX}-objcopy -R .rel.dyn -O binary ${PATTERN}.elf ${PATTERN}.bin
	${GCC_PREFIX}-objcopy -R .rel.dyn -O verilog ${PATTERN}.elf ${PATTERN}.hex
	${GCC_PREFIX}-objdump -D  ${PATTERN}.elf >   ${PATTERN}.dump
	rm *.o *.a
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
	iverilog -g2012 -DFUNCTIONAL -DUSE_POWER_PINS -DRISC_BOOT -DGL -I $(PDK_PATH) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.gl.lib \
	$< -o $@ 
    else  
	iverilog -g2012 -DWFDUMP -DFUNCTIONAL -DUSE_POWER_PINS -DRISC_BOOT -DGL -I $(PDK_PATH) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.gl.$(CONFIG) \
	-f$(USER_PROJECT_VERILOG)/includes/includes.gl.lib \
	$< -o $@ 
   endif
endif

%.vcd: %.vvp
	vvp $< +risc_core_id=$(RISC_CORE)


# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.log *.dump *.a *.o

.PHONY: clean hex all
