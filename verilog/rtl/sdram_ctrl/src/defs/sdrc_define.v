//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
///////////////////////////////////////////////////////////////////////////

`define SDR_REQ_ID_W       4

`define SDR_RFSH_TIMER_W    12
`define SDR_RFSH_ROW_CNT_W   3

// B2X Command

`define OP_PRE           2'b00
`define OP_ACT           2'b01
`define OP_RD            2'b10
`define OP_WR            2'b11

// SDRAM Commands (CS_N, RAS_N, CAS_N, WE_N)

`define SDR_DESEL        4'b1111
`define SDR_NOOP         4'b0111
`define SDR_ACTIVATE     4'b0011
`define SDR_READ         4'b0101
`define SDR_WRITE        4'b0100
`define SDR_BT           4'b0110
`define SDR_PRECHARGE    4'b0010
`define SDR_REFRESH      4'b0001
`define SDR_MODE         4'b0000

`define  ASIC            1'b1
`define  FPGA            1'b0
`define  TARGET_DESIGN   `FPGA
// 12 bit subtractor is not feasibile for FPGA, so changed to 6 bits
`define  REQ_BW    (`TARGET_DESIGN == `FPGA) ? 6 : 12   //  Request Width

