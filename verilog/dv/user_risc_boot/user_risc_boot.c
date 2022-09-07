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
#include "int_reg_map.h"
#include "common_misc.h"
#include "common_bthread.h"


int main()
{

   // GLBL_CFG_MAIL_BOX used as mail box, each core update boot up handshake at 8 bit
   // bit[7:0]   - core-0
   // bit[15:8]  - core-1
   // bit[23:16] - core-2
   // bit[31:24] - core-3

   reg_glbl_mail_box = 0x1 << (bthread_get_core_id() * 8); // Start of Main 

    // Write software Write & Read Register
    reg_glbl_soft_reg_0  = 0x11223344; 
    reg_glbl_soft_reg_1  = 0x22334455; 
    reg_glbl_soft_reg_2  = 0x33445566; 
    reg_glbl_soft_reg_3  = 0x44556677; 
    reg_glbl_soft_reg_4 = 0x55667788; 
    reg_glbl_soft_reg_5 = 0x66778899; 
    //reg_mprj_globl_reg12 = 0x778899AA; 
    //reg_mprj_globl_reg13 = 0x8899AABB; 
    //reg_mprj_globl_reg14 = 0x99AABBCC; 
    //reg_mprj_globl_reg15 = 0xAABBCCDD; 

    while(1) {}
    return 0;
}
