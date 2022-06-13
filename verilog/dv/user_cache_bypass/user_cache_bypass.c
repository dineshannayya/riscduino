//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021, Dinesh Annayya
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>
// //////////////////////////////////////////////////////////////////////////
#define SC_SIM_OUTPORT (0xf0000000)
#define uint32_t  long
#define uint16_t  int

#define reg_mprj_globl_reg0  (*(volatile uint32_t*)0x10020000)
#define reg_mprj_globl_reg1  (*(volatile uint32_t*)0x10020004)
#define reg_mprj_globl_reg2  (*(volatile uint32_t*)0x10020008)
#define reg_mprj_globl_reg3  (*(volatile uint32_t*)0x1002000C)
#define reg_mprj_globl_reg4  (*(volatile uint32_t*)0x10020010)
#define reg_mprj_globl_reg5  (*(volatile uint32_t*)0x10020014)
#define reg_mprj_globl_reg6  (*(volatile uint32_t*)0x10020018)
#define reg_mprj_globl_reg7  (*(volatile uint32_t*)0x1002001C)
#define reg_mprj_globl_reg8  (*(volatile uint32_t*)0x10020020)
#define reg_mprj_globl_reg9  (*(volatile uint32_t*)0x10020024)
#define reg_mprj_globl_reg10 (*(volatile uint32_t*)0x10020028)
#define reg_mprj_globl_reg11 (*(volatile uint32_t*)0x1002002C)
#define reg_mprj_globl_reg12 (*(volatile uint32_t*)0x10020030)
#define reg_mprj_globl_reg13 (*(volatile uint32_t*)0x10020034)
#define reg_mprj_globl_reg14 (*(volatile uint32_t*)0x10020038)
#define reg_mprj_globl_reg15 (*(volatile uint32_t*)0x1002003C)
#define reg_mprj_globl_reg16 (*(volatile uint32_t*)0x10020040)
#define reg_mprj_globl_reg17 (*(volatile uint32_t*)0x10020044)
#define reg_mprj_globl_reg18 (*(volatile uint32_t*)0x10020048)
#define reg_mprj_globl_reg19 (*(volatile uint32_t*)0x1002004C)
#define reg_mprj_globl_reg20 (*(volatile uint32_t*)0x10020050)
#define reg_mprj_globl_reg21 (*(volatile uint32_t*)0x10020054)
#define reg_mprj_globl_reg22 (*(volatile uint32_t*)0x10020058)
#define reg_mprj_globl_reg23 (*(volatile uint32_t*)0x1002005C)
#define reg_mprj_globl_reg24 (*(volatile uint32_t*)0x10020060)
#define reg_mprj_globl_reg25 (*(volatile uint32_t*)0x10020064)
#define reg_mprj_globl_reg26 (*(volatile uint32_t*)0x10020068)
#define reg_mprj_globl_reg27 (*(volatile uint32_t*)0x1002006C)
// -------------------------------------------------------------------------
// Test copying code into SRAM and running it from there.
// -------------------------------------------------------------------------

void test_function()
{
    reg_mprj_globl_reg24  = 0x33445566;  // Sig-3
    reg_mprj_globl_reg25  = 0x44556677;  // Sig-4

    return;
}

void main()
{
    uint16_t func[&main - &test_function];
    uint16_t *src_ptr;
    uint16_t *dst_ptr;


    src_ptr = &test_function;
    dst_ptr = func;

    reg_mprj_globl_reg22  = 0x11223344;  // Sig-1
    while (src_ptr < &main) {
	*(dst_ptr++) = *(src_ptr++);
    }

    // Call the routine in SRAM
    reg_mprj_globl_reg23  = 0x22334455;  // Sig-2
    
    ((void(*)())func)();

    reg_mprj_globl_reg26 = 0x55667788; 
    reg_mprj_globl_reg27 = 0x66778899; 

    // Signal end of test
}

