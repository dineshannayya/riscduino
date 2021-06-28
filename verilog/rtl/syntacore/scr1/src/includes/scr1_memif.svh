//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: Syntacore LLC © 2016-2021
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
// SPDX-FileContributor: Syntacore LLC
// //////////////////////////////////////////////////////////////////////////
/// @file       <scr1_memif.svh>
/// @brief      Memory interface definitions file
///

`ifndef SCR1_MEMIF_SVH
`define SCR1_MEMIF_SVH

`include "scr1_arch_description.svh"

//-------------------------------------------------------------------------------
// Memory command enum
//-------------------------------------------------------------------------------
//typedef enum logic {
parameter    SCR1_MEM_CMD_RD     = 1'b0;
parameter    SCR1_MEM_CMD_WR     = 1'b1;
//`ifdef SCR1_XPROP_EN
//    ,
parameter     SCR1_MEM_CMD_ERROR  = 'x;
//`endif // SCR1_XPROP_EN
//} type_scr1_mem_cmd_e;

//-------------------------------------------------------------------------------
// Memory data width enum
//-------------------------------------------------------------------------------
//typedef enum logic[1:0] {
parameter    SCR1_MEM_WIDTH_BYTE     = 2'b00;
parameter    SCR1_MEM_WIDTH_HWORD    = 2'b01;
parameter    SCR1_MEM_WIDTH_WORD     = 2'b10;
//`ifdef SCR1_XPROP_EN
//    ,
parameter    SCR1_MEM_WIDTH_ERROR    = 'x;
//`endif // SCR1_XPROP_EN
//} type_scr1_mem_width_e;

//-------------------------------------------------------------------------------
// Memory response enum
//-------------------------------------------------------------------------------
//typedef enum logic[1:0] {
parameter    SCR1_MEM_RESP_NOTRDY    = 2'b00;
parameter    SCR1_MEM_RESP_RDY_OK    = 2'b01;
parameter    SCR1_MEM_RESP_RDY_ER    = 2'b10;
//`ifdef SCR1_XPROP_EN
//    ,
parameter    SCR1_MEM_RESP_ERROR     = 'x;
//`endif // SCR1_XPROP_EN
//} type_scr1_mem_resp_e;

`endif // SCR1_MEMIF_SVH
