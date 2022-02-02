# //////////////////////////////////////////////////////////////////////////////
# // SPDX-FileCopyrightText: 2021, Dinesh Annayya
# // 
# // Licensed under the Apache License, Version 2.0 (the "License");
# // you may not use this file except in compliance with the License.
# // You may obtain a copy of the License at
# //
# //      http://www.apache.org/licenses/LICENSE-2.0
# //
# // Unless required by applicable law or agreed to in writing, software
# // distributed under the License is distributed on an "AS IS" BASIS,
# // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# // See the License for the specific language governing permissions and
# // limitations under the License.
# // SPDX-License-Identifier: Apache-2.0
# // SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>
# // //////////////////////////////////////////////////////////////////////////

ADD_ASM_MACRO ?= -D__ASSEMBLY__=1

FLAGS = -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las $(ADD_FLAGS)
FLAGS_STR = "$(FLAGS)"

CFLAGS_COMMON = -static -std=gnu99 -fno-common -fno-builtin-printf -DTCM=$(TCM)
CFLAGS_ARCH = -Wa,-march=rv32$(ARCH) -march=rv32$(ARCH) -mabi=$(ABI)

CFLAGS := $(FLAGS) $(EXT_CFLAGS) \
$(CFLAGS_COMMON) \
$(CFLAGS_ARCH) \
-DFLAGS_STR=\"$(FLAGS_STR)\" \
$(ADD_CFLAGS)

LDFLAGS   ?= -nostartfiles -nostdlib -lc -lgcc -march=rv32$(ARCH) -mabi=$(ABI)

ifeq (,$(findstring 0,$(TCM)))
ld_script ?= $(inc_dir)/link_tcm.ld
asm_src   ?= crt_tcm.S
else
ld_script ?= $(inc_dir)/link.ld
asm_src   ?= crt.S
endif

VPATH += $(src_dir) $(inc_dir) $(ADD_VPATH)
incs  += -I$(src_dir) -I$(inc_dir) $(ADD_incs)

c_objs   := $(addprefix $(bld_dir)/,$(patsubst %.c, %.o, $(c_src)))
asm_objs := $(addprefix $(bld_dir)/,$(patsubst %.S, %.o, $(asm_src)))

$(bld_dir)/%.o: %.S
	$(RISCV_GCC) $(CFLAGS) $(ADD_ASM_MACRO) -c $(incs) $< -o $@

$(bld_dir)/%.o: %.c
	$(RISCV_GCC) $(CFLAGS) -c $(incs) $< -o $@

$(bld_dir)/%.elf: $(ld_script) $(c_objs) $(asm_objs)
	$(RISCV_GCC) -o $@ -T $^ $(LDFLAGS)

$(bld_dir)/%.hex: $(bld_dir)/%.elf
	$(RISCV_ROM_OBJCOPY) $^ $@
	$(RISCV_RAM_OBJCOPY) $^ $@.ram
	#assign 0x0800_0xxx  to 0x0000_0xxx to map to TCM Memory
	sed -i 's/@08000/@00000/g' $@.ram


$(bld_dir)/%.dump: $(bld_dir)/%.elf
	$(RISCV_OBJDUMP) $^ > $@
