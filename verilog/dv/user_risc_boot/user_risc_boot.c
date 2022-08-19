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

#define reg_mprj_globl_reg0  (*(volatile uint32_t*)0x10020000) // Chip ID
#define reg_mprj_globl_reg1  (*(volatile uint32_t*)0x10020004) // Global Config-0
#define reg_mprj_globl_reg2  (*(volatile uint32_t*)0x10020008) // Global Config-1
#define reg_mprj_globl_reg3  (*(volatile uint32_t*)0x1002000C) // Global Interrupt Mask
#define reg_mprj_globl_reg4  (*(volatile uint32_t*)0x10020010) // Global Interrupt
#define reg_mprj_globl_reg5  (*(volatile uint32_t*)0x10020014) // Multi functional sel
#define reg_mprj_globl_soft0  (*(volatile uint32_t*)0x10020018) // Sof Register-0
#define reg_mprj_globl_soft1  (*(volatile uint32_t*)0x1002001C) // Sof Register-1
#define reg_mprj_globl_soft2  (*(volatile uint32_t*)0x10020020) // Sof Register-2
#define reg_mprj_globl_soft3  (*(volatile uint32_t*)0x10020024) // Sof Register-3
#define reg_mprj_globl_soft4 (*(volatile uint32_t*)0x10020028) // Sof Register-4
#define reg_mprj_globl_soft5 (*(volatile uint32_t*)0x1002002C) // Sof Register-5

int main()
{

    //volatile long *out_ptr = (volatile long*)SC_SIM_OUTPORT;
    //*out_ptr = 0xAABBCCDD;
    //*out_ptr = 0xBBCCDDEE;
    //*out_ptr = 0xCCDDEEFF;
    //*out_ptr = 0xDDEEFF00;

    // Write software Write & Read Register
    reg_mprj_globl_soft0  = 0x11223344; 
    reg_mprj_globl_soft1  = 0x22334455; 
    reg_mprj_globl_soft2  = 0x33445566; 
    reg_mprj_globl_soft3  = 0x44556677; 
    reg_mprj_globl_soft4 = 0x55667788; 
    reg_mprj_globl_soft5 = 0x66778899; 
    //reg_mprj_globl_reg12 = 0x778899AA; 
    //reg_mprj_globl_reg13 = 0x8899AABB; 
    //reg_mprj_globl_reg14 = 0x99AABBCC; 
    //reg_mprj_globl_reg15 = 0xAABBCCDD; 

    while(1) {}
    return 0;
}
