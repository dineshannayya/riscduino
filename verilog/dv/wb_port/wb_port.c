/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"

// User Project Slaves (0x3000_0000)
#define reg_mprj_slave (*(volatile uint32_t*)0x30000000)

#define reg_mprj_wbhost_reg0 (*(volatile uint32_t*)0x30800000)
#define reg_mprj_globl_reg0  (*(volatile uint32_t*)0x30020000)
#define reg_mprj_globl_reg1  (*(volatile uint32_t*)0x30020004)
#define reg_mprj_globl_reg2  (*(volatile uint32_t*)0x30020008)
#define reg_mprj_globl_reg3  (*(volatile uint32_t*)0x3002000C)
#define reg_mprj_globl_reg4  (*(volatile uint32_t*)0x30020010)
#define reg_mprj_globl_reg5  (*(volatile uint32_t*)0x30020014)
#define reg_mprj_globl_reg6  (*(volatile uint32_t*)0x30020018)
#define reg_mprj_globl_reg7  (*(volatile uint32_t*)0x3002001C)
#define reg_mprj_globl_reg8  (*(volatile uint32_t*)0x30020020)
#define reg_mprj_globl_reg9  (*(volatile uint32_t*)0x30020024)
#define reg_mprj_globl_reg10 (*(volatile uint32_t*)0x30020028)
#define reg_mprj_globl_reg11 (*(volatile uint32_t*)0x3002002C)
#define reg_mprj_globl_reg12 (*(volatile uint32_t*)0x30020030)
#define reg_mprj_globl_reg13 (*(volatile uint32_t*)0x30020034)
#define reg_mprj_globl_reg14 (*(volatile uint32_t*)0x30020038)
#define reg_mprj_globl_reg15 (*(volatile uint32_t*)0x3002003C)
#define reg_mprj_globl_reg16 (*(volatile uint32_t*)0x30020040)
#define reg_mprj_globl_reg17 (*(volatile uint32_t*)0x30020044)
#define reg_mprj_globl_reg18 (*(volatile uint32_t*)0x30020048)
#define reg_mprj_globl_reg19 (*(volatile uint32_t*)0x3002004C)
#define reg_mprj_globl_reg20 (*(volatile uint32_t*)0x30020050)
#define reg_mprj_globl_reg21 (*(volatile uint32_t*)0x30020054)
#define reg_mprj_globl_reg22 (*(volatile uint32_t*)0x30020058)
#define reg_mprj_globl_reg23 (*(volatile uint32_t*)0x3002005C)
#define reg_mprj_globl_reg24 (*(volatile uint32_t*)0x30020060)
#define reg_mprj_globl_reg25 (*(volatile uint32_t*)0x30020064)
#define reg_mprj_globl_reg26 (*(volatile uint32_t*)0x30020068)
#define reg_mprj_globl_reg27 (*(volatile uint32_t*)0x3002006C)


/*
	Wishbone Test:
		- Configures MPRJ lower 8-IO pins as outputs
		- Checks counter value through the wishbone port
*/
int i = 0; 
int clk = 0;

void main()
{

	int bFail = 0;
	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

     /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    reg_la2_oenb = reg_la2_iena = 0xFFFFFFFF;    // [95:64]
    reg_la0_data = 0x000;
    reg_la0_data = 0x001; // Remove Soft Reset

    // Flag start of the test
	reg_mprj_datal = 0xAB600000;

    // Remove Wishbone Reset
    reg_mprj_wbhost_reg0 = 0x1;

    if (reg_mprj_globl_reg0 != 0x89490201) bFail = 1;
    if (reg_mprj_globl_reg1 != 0xA55AA55A) bFail = 1;

    // Write software Write & Read Register
    reg_mprj_globl_reg22  = 0x11223344; 
    reg_mprj_globl_reg23  = 0x22334455; 
    reg_mprj_globl_reg24  = 0x33445566; 
    reg_mprj_globl_reg25  = 0x44556677; 
    reg_mprj_globl_reg26  = 0x55667788; 
    reg_mprj_globl_reg27  = 0x66778899; 


    if (reg_mprj_globl_reg22  != 0x11223344) bFail = 1;
    if (bFail == 1) reg_mprj_datal = 0xAB610000;
    if (reg_mprj_globl_reg23  != 0x22334455) bFail = 1;
    if (bFail == 1) reg_mprj_datal = 0xAB620000;
    if (reg_mprj_globl_reg24  != 0x33445566) bFail = 1;
    if (bFail == 1) reg_mprj_datal = 0xAB630000;
    if (reg_mprj_globl_reg25  != 0x44556677) bFail = 1;
    if (bFail == 1) reg_mprj_datal = 0xAB640000;
    if (reg_mprj_globl_reg26 != 0x55667788) bFail = 1;
    if (bFail == 1) reg_mprj_datal = 0xAB650000;
    if (reg_mprj_globl_reg27 != 0x66778899) bFail = 1;
    if (bFail == 1) reg_mprj_datal = 0xAB660000;

    if(bFail == 0) {
        reg_mprj_datal = 0xAB6A0000;
    } else {
        reg_mprj_datal = 0xAB600000;
    }
}
