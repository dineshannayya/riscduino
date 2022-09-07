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
#include <defs.h>
#include <stub.c>

// User Project Slaves (0x3000_0000)


#define GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP   0x1C00

#define SC_SIM_OUTPORT (0xf0000000)

/*
         RiscV Hello World test.
	        - Wake up the Risc V
		- Boot from SPI Flash
		- Riscv Write Hello World to SDRAM,
		- External Wishbone read back validation the data
*/
int i = 0; 
int clk = 0;
int uart_cfg = 0;
void main()
{

	//int bFail = 0;
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

	Input: 0000_0001_0000_1111 (0x1800) = GPIO_MODE_USER_STD_BIDIRECTIONAL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 0     | 0       |
	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

    //reg_spi_enable = 1;
    //reg_wb_enable = 1;
	// reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

    //reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    //reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

    // /* Apply configuration */
    //reg_mprj_xfer = 1;
    //while (reg_mprj_xfer == 1);

    reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF;    // [31:0]

    // Flag start of the test
	reg_mprj_datal = 0xAB600000;

    //-----------------------------------------------------
    // Start of User Functionality and take over the GPIO Pins
    // --------------------------------------------------------------------
    // User block decide on the GPIO function
    // io[6] to 37 are set to default bio-direction using user_define.h file
    //---------------------------------------------------------------------

    //reg_mprj_io_37 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_36 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_35 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_34 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_33 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_32 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_31 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_30 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_29 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_28 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_27 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_26 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_25 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_24 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_23 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_22 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_21 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_20 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_19 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_18 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_17 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_16 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_15 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_14 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_13 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_12 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_11 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_10 = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_9  = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_8  = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_7  = GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_6 =  GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_5 =  GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_4 =  GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_3 =  GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_2 =  GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_1 =  GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;
    //reg_mprj_io_0 =  GPIO_MODE_USER_STD_BIDIRECTIONAL_PULLUP;

    // /* Apply configuration */
    //reg_mprj_xfer = 1;
    //while (reg_mprj_xfer == 1);

    reg_la0_data = 0x000;
    //reg_la0_data = 0x000;
    //reg_la0_data |= 0x1; // bit[0] - Remove Software Reset
    //reg_la0_data |= 0x1; // bit[1] - Enable Transmit Path
    //reg_la0_data |= 0x2; // bit[2] - Enable Receive Path
    //reg_la0_data |= 0x4; // bit[3] - Set 2 Stop Bit
    //reg_la0_data |= 0x0; // bit[15:4] - 16x Baud Clock
    //reg_la0_data |= 0x0; // bit[17:16] - Priority mode = 0
    reg_la0_data = 0x001;
    reg_la0_data = 0x00F;



}
