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


#include <stdio.h>
#include <string.h>
#include <stdint.h>

#include "int_reg_map.h"
#include "common_misc.h"
#include "common_bthread.h"

#define CMD_FPU_SP_ADD  0x1 // Single Precision (32 bit) Adder 
#define CMD_FPU_SP_MUL  0x2 // Single Precision (32 bit) Multipler
#define CMD_FPU_SP_DIV  0x3 // Single Precision (32 bit) Divider
#define CMD_FPU_SP_F2I  0x4 // Single Precision (32 bit) Float to Integer
#define CMD_FPU_SP_I2F  0x5 // Single Precision (32 bit) Integer to Float
#define CMD_FPU_DP_ADD  0x9 // Double Precision (64 bit) Adder
#define CMD_FPU_DP_MUL  0xA // Double Precision (64 bit) Multipler
#define CMD_FPU_DP_DIV  0xB // Double Precision (64 bit) Divider

int fpu_check(uint8_t Cmd, uint32_t Din1, uint32_t Din2, uint32_t Result);

int main(void)
{
    int exit;

   //printf("\nTesting FPU CORE LOGIC\n\n");

   reg_glbl_cfg0 |= 0x1F;       // Remove Reset for UART
   reg_glbl_multi_func &=0x7FFFFFFF; // Disable UART Master Bit[31] = 0
   reg_glbl_multi_func |=0x100; // Enable UART Multi func
   reg_gpio_dsel  =0xFF00; // Enable PORT B As output
   reg_uart0_ctrl = 0x07;       // Enable Uart Access {3'h0,2'b00,1'b1,1'b1,1'b1}

   //// GLBL_CFG_MAIL_BOX used as mail box, each core update boot up handshake at 8 bit
   //// bit[7:0]   - core-0
   //// bit[15:8]  - core-1
   //// bit[23:16] - core-2
   //// bit[31:24] - core-3

    reg_glbl_mail_box = 0x1 << (bthread_get_core_id() * 8); // Start of Main 

    reg_gpio_odata  = 0x00000100; 
    reg_glbl_soft_reg_0  = 0x00000000; 
    //--------------------------------------
    // Floating Point Addition
    //--------------------------------------

    // TEST-1: Addition: Din1: 0.500000 Din2: 1.500000 Res: 2.000000
    exit = fpu_check(CMD_FPU_SP_ADD,0x3f000000,0x3fc00000,0x40000000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-2: Addition: Din1: 0.500000 Din2: 1.250000 Res: 1.750000
    exit += fpu_check(CMD_FPU_SP_ADD,0x3f000000,0x3fa00000,0x3fe00000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-3: Addition: Din1: 0.500000 Din2: 0.250000 Res: 0.750000
    exit += fpu_check(CMD_FPU_SP_ADD,0x3f000000,0x3e800000,0x3f400000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-4: Addition: Din1: 2.000000 Din2: -2.000000 Res: 0.000000
    exit += fpu_check(CMD_FPU_SP_ADD,0x40000000,0xc0000000,0x00000000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-5: Addition: Din1: -0.000000 Din2: 0.000000 Res: 0.000000
    exit += fpu_check(CMD_FPU_SP_ADD,0x83e73d5c,0x1c800000,0x1c800000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-6: Addition: Din1: -1.211871 Din2: -2.889479 Res: -4.101350
    exit += fpu_check(CMD_FPU_SP_ADD,0xbf9b1e94,0xc038ed3a,0xc0833e42);
    reg_glbl_soft_reg_0  = exit;

    //--------------------------------------
    // Floating Point Multiplication
    //--------------------------------------
    // TEST-1: Multiplier: Din1: 0.500000 Din2: 1.500000 Res: 0.750000
    exit += fpu_check(CMD_FPU_SP_MUL,0x3f000000,0x3fc00000,0x3f400000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-2: Multiplier: Din1: 0.500000 Din2: 1.250000 Res: 0.625000
    exit += fpu_check(CMD_FPU_SP_MUL,0x3f000000,0x3fa00000,0x3f200000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-3: Multiplier: Din1: 0.500000 Din2: 0.250000 Res: 0.125000
    exit += fpu_check(CMD_FPU_SP_MUL,0x3f000000,0x3e800000,0x3e000000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-4: Multiplier: Din1: 0.000000 Din2: -0.000000 Res: -0.000000
    exit += fpu_check(CMD_FPU_SP_MUL,0x22cb525a,0xadd79efa,0x912b406d);
    reg_glbl_soft_reg_0  = exit;

    // TEST-5: Multiplier: Din1: 2.000000 Din2: -2.000000 Res: -4.000000
    exit += fpu_check(CMD_FPU_SP_MUL,0x40000000,0xc0000000,0xc0800000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-6: Multiplier: Din1: -1.211871 Din2: -2.889479 Res: 3.501675
    exit += fpu_check(CMD_FPU_SP_MUL,0xbf9b1e94,0xc038ed3a,0x40601b72);
    reg_glbl_soft_reg_0  = exit;

    //--------------------------------------
    // Floating Point Division
    //--------------------------------------
    // TEST-1: Division: Din1: 0.500000 Din2: 1.500000 Res: 0.750000
    exit += fpu_check(CMD_FPU_SP_DIV,0x3f000000,0x3fc00000,0x3eaaaaab);
    reg_glbl_soft_reg_0  = exit;

    // TEST-2: Division: Din1: 0.500000 Din2: 1.250000 Res: 0.400000
    exit += fpu_check(CMD_FPU_SP_DIV,0x3f000000,0x3fa00000,0x3ecccccd);
    reg_glbl_soft_reg_0  = exit;

    // TEST-3: Division: Din1: 0.500000 Din2: 0.250000 Res: 2.000000
    exit += fpu_check(CMD_FPU_SP_DIV,0x3f000000,0x3e800000,0x40000000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-4: Division: Din1: 0.000000 Din2: -0.000000 Res: 0.000000
    exit += fpu_check(CMD_FPU_SP_DIV,0x22cb525a,0xadd79efa,0xb47165bd);
    reg_glbl_soft_reg_0  = exit;

    // TEST-5: Division: Din1: 2.000000 Din2: -2.000000 Res: -1.000000
    exit += fpu_check(CMD_FPU_SP_DIV,0x40000000,0xc0000000,0xbf800000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-6: Division: Din1: -1.211871 Din2: -2.889479 Res: 0.419408
    exit += fpu_check(CMD_FPU_SP_DIV,0xbf9b1e94,0xc038ed3a,0x3ed6bca5);
    reg_glbl_soft_reg_0  = exit;

    //--------------------------------------
    // Intger To Floating Point 
    //--------------------------------------
    // TEST-1: I2F: Input: 1069547520 Result: 1069547520.000000
    exit += fpu_check(CMD_FPU_SP_I2F,0x3fc00000,0x0,0x4e7f0000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-2: I2F: Input: 1067450368 Result: 1067450368.000000
    exit += fpu_check(CMD_FPU_SP_I2F,0x3fa00000,0x0,0x4e7e8000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-3: I2F: Input: 1048576000 Result: 1048576000.000000
    exit += fpu_check(CMD_FPU_SP_I2F,0x3e800000,0x0,0x4e7a0000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-4: I2F: Input: 1075838976 Result: 1075838976.000000
    exit += fpu_check(CMD_FPU_SP_I2F,0x40200000,0x0,0x4e804000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-5: I2F: Input: 1084017869 Result: 1084017920.000000
    exit += fpu_check(CMD_FPU_SP_I2F,0x409ccccd,0x0,0x4e81399a);
    reg_glbl_soft_reg_0  = exit;

    // TEST-6: I2F: Input: -1071644672 Result: -1071644672.000000
    exit += fpu_check(CMD_FPU_SP_I2F,0xc0200000,0x0,0xce7f8000);
    reg_glbl_soft_reg_0  = exit;

    //--------------------------------------
    // Floating To Integer Point 
    //--------------------------------------
    // TEST-1: F2I: Input: 1.500000  Result: 1
    exit += fpu_check(CMD_FPU_SP_F2I,0x3fc00000,0x0,0x00000001);
    reg_glbl_soft_reg_0  = exit;

    // TEST-2: F2I: Input: 1.250000  Result: 1
    exit += fpu_check(CMD_FPU_SP_F2I,0x3fa00000,0x0,0x00000001);
    reg_glbl_soft_reg_0  = exit;

    // TEST-3: F2I: Input: 0.250000  Result: 0
    exit += fpu_check(CMD_FPU_SP_F2I,0x3e800000,0x0,0x00000000);
    reg_glbl_soft_reg_0  = exit;

    // TEST-4: F2I: Input: 2.500000  Result: 2
    exit += fpu_check(CMD_FPU_SP_F2I,0x40200000,0x0,0x00000002);
    reg_glbl_soft_reg_0  = exit;

    // TEST-5: F2I: Input: -2.500000  Result: -2
    exit += fpu_check(CMD_FPU_SP_F2I,0xc0200000,0x0,0xfffffffe);
    reg_glbl_soft_reg_0  = exit;

    // TEST-6: F2I: Input: -222.800003  Result: -222
    exit += fpu_check(CMD_FPU_SP_F2I,0xc35ecccd,0x0,0xffffff22);
    reg_glbl_soft_reg_0  = exit;

    if(exit == 0) {
        reg_gpio_odata  = 0x00001800; 
    } else {
        reg_gpio_odata  = 0x0000A800; 
    }

    return exit;
}

int fpu_check(uint8_t Cmd, uint32_t Din1, uint32_t Din2, uint32_t Result){


   reg_fpu_din1 = Din1;
   reg_fpu_din2 = Din2;
   reg_fpu_ctrl = Cmd | 0x80000000;

   while(reg_fpu_ctrl & 0x80000000); // Wait for FPU completion
  
    reg_glbl_soft_reg_1  = reg_fpu_res;
    reg_glbl_soft_reg_2  = Result;
   if(reg_fpu_res != Result) return 1;
   else return 0;
     
}





