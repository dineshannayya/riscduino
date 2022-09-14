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
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  strap control                                               ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      Manages all the strap related func                      ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 29th Aug 2022, Dinesh A                             ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

/*************************************************************************
  This block control the system/soft/sticky strap generation

expected Reset removal sequence
   
               _________                 __________________________________________________
                        |                |
e_reset_n               |________________|
               
               ________                           ________________________________________
               XXXXXXXXX                          |
p_reset_n      XXXXXXXXX__________________________|
               
                                                                     ____________
              XXXXXXXXX                                             |
clk_enb       XXXXXXXXX_____________________________________________|

                                                                                ____________
               XXXXXXXXX                                                        |
s_reset_n      XXXXXXXXX________________________________________________________|

pad_strap_in decoding
     bit[1:0] - System Clock Source Selection for wbs/riscv
                 00 - User clock1  (Default)
                 01 - User clock2 
                 10 - Internal PLL
                 11 - Xtal
     bit[3:2] - Clock Division for wbs/riscv
                 00 - 0 Div (Default)
                 01 - 2 Div
                 10 - 4 Div
                 11 - 8 Div
     bit [4]   - Reserved
     bit [5]   - QSPI SRAM Mode Selection
                 1'b0 - Single 
                 1'b1 - Quad   (Default)
     bit [7:6] - QSPI Fash Mode Selection
                 2'b00 - Single 
                 2'b01 - Double
                 2'b10 - Quad   (Default)
                 2'b11 - QDDR
     bit [8]   - Riscv Reset control
                 0 - Keep Riscv on Reset
                 1 - Removed Riscv on Power On Reset (Default)
     bit [9]   - Riscv Cache Bypass
                 0 - Cache Enable
                 1 - Bypass cache (Default
     bit [10]  - Riscv SRAM clock edge selection
                 0 - Normal
                 1 - Invert (Default)
     bit [12:11] - Skew selection
                 2'b00 - Default value (Default
                 2'b01 - Default value + 2               
                 2'b10 - Default value + 4               
                 2'b11 - Default value - 4 
     bit [4:13]   - uart master config control
                 2'b00   - Auto Detect (Default)
                 2'b01   - constant value based on system clock-50Mhz
                 2'b10   - constant value based on system clock-4Mhz 
                 2'b11   - load from LA
     bit [14:13] - Reserved
     bit [15]    - Strap Mode
                   0 - Normal
                   1 - Pick Default Value

system strap decoding
     bit[1:0] - System Clock Source Selection for wbs
                 00 - User clock1 
                 01 - User clock2 
                 10 - Internal PLL
                 11 - Xtal
     bit[3:2] - Clock Division for wbs
                 00 - 0 Div
                 01 - 2 Div
                 10 - 4 Div
                 11 - 8 Div
     bit[5:4] - System Clock Source Selection for riscv
                 00 - User clock1 
                 01 - User clock2 
                 10 - Internal PLL
                 11 - Xtal
     bit[7:6] - Clock Division for riscv
                 00 - 0 Div
                 01 - 2 Div
                 10 - 4 Div
                 11 - 8 Div
     bit [8]   - uart master config control
                 0   - load from LA
                 1   - constant value based on system clock selection
     bit [9]   - QSPI SRAM Mode Selection CS#2
                 1'b0 - Single
                 1'b1 - Quad
     bit [11:10] - QSPI FLASH Mode Selection CS#0
                 2'b00 - Single
                 2'b01 - Double
                 2'b10 - Quad
                 2'b11 - QDDR
     bit [12]  - Riscv Reset control
                 0 - Keep Riscv on Reset
                 1 - Removed Riscv on Power On Reset
     bit [13]   - Riscv Cache Bypass
                 1 - Cache Enable
                 0 - Bypass cache
     bit [14]  - Riscv SRAM clock edge selection
                 0 - Normal
                 1 - Invert

     bit [15]    -  Soft Reboot Request
     bit [17:16] -  cfg_cska_wi Skew selection      
     bit [19:18] -  cfg_cska_wh Skew selection        
     bit [21:20] -  cfg_cska_riscv Skew selection      
     bit [23:22] -  cfg_cska_qspi  Skew selection      
     bit [25:24] -  cfg_cska_uart  Skew selection       
     bit [27:26] -  cfg_cska_pinmux Skew selection     
     bit [29:28] -  cfg_cska_qspi_co Skew selection    

**************************************************************************/
module strap_ctrl (

	         input logic        clk                 ,
	         input logic        e_reset_n           ,  // external reset
	         input logic        p_reset_n           ,  // power-on reset
	         input logic        s_reset_n           ,  // soft reset

             input logic [15:0] pad_strap_in        , // strap from pad
	         //List of Inputs
	         input logic        cs                  ,
	         input logic [3:0]  we                  ,		 
	         input logic [31:0] data_in             ,
	         
	         //List of Outs
             output logic [15:0] strap_latch         ,
	         output logic [31:0] strap_sticky        ,
             output logic [1:0]  strap_uartm           // Uart Master Strap Config

         );


//---------------------------------------------
// Strap Mapping
//----------------------------------------------
logic [31:0] strap_map;
logic [14:0] pstrap_select;

// Pad Strap selection based on strap mode
assign pstrap_select = (strap_latch[15] == 1'b1) ?  PSTRAP_DEFAULT_VALUE : strap_latch[14:0];

assign strap_map = {
                   1'b0               ,   // bit[31]      - Soft Reboot Request - Need to double sync to local clock
                   1'b0               ,   // bit[30]      - reserved
                   pstrap_select[12:11] , // bit[29:28]   - cfg_cska_qspi_co Skew selection
                   pstrap_select[12:11] , // bit[27:26]   - cfg_cska_pinmux Skew selection
                   pstrap_select[12:11] , // bit[25:24]   - cfg_cska_uart  Skew selection
                   pstrap_select[12:11] , // bit[23:22]   - cfg_cska_qspi  Skew selection
                   pstrap_select[12:11] , // bit[21:20]   - cfg_cska_riscv Skew selection
                   pstrap_select[12:11] , // bit[19:18]   - cfg_cska_wh Skew selection
                   pstrap_select[12:11] , // bit[17:16]   - cfg_cska_wi Skew selection
                   1'b0                 , // bit[15]      - Reserved
                   pstrap_select[10]    , // bit[14]      - Riscv SRAM clock edge selection
                   pstrap_select[9]     , // bit[13]      - Riscv Cache Bypass
                   pstrap_select[8]     , // bit[12]      - Riscv Reset control
                   pstrap_select[7:6]   , // bit[11:10]   - QSPI FLASH Mode Selection CS#0
                   pstrap_select[5]     , // bit[9]       - QSPI SRAM Mode Selection CS#2
                   pstrap_select[4]     , // bit[8]       - Reserved
                   pstrap_select[3:2]   , // bit[7:6]     - riscv clock div
                   pstrap_select[1:0]   , // bit[5:4]     - riscv clock source sel
                   pstrap_select[3:2]   , // bit[3:2]     - wbs clock division
                   pstrap_select[1:0]     // bit[1:0]     - wbs clock source sel
                   };


assign strap_uartm = strap_latch[`PSTRAP_UARTM_CFG];

//------------------------------------
// Generating strap latch
//------------------------------------
always_latch begin
  if ( ~e_reset_n )
  begin
    strap_latch =  pad_strap_in[15:0];
  end
end

//--------------------------------------------
// Software controller Strap Register
//--------------------------------------------


always @ (posedge clk or negedge e_reset_n) begin 
   if(e_reset_n == 1'b0) begin
       strap_sticky  <= 'h0 ;
   end else if (p_reset_n == 1'b0) begin
     strap_sticky  <= strap_map ;
   end else if(s_reset_n == 1'b0) begin
       strap_sticky[`STRAP_SOFT_REBOOT_REQ] <= 1'b0;
   end else begin
       if(cs && we[0]) strap_sticky[7:0]   <= data_in[7:0];
       if(cs && we[1]) strap_sticky[15:8]  <= data_in[15:8];
       if(cs && we[2]) strap_sticky[23:16] <= data_in[23:16];
       if(cs && we[3]) strap_sticky[31:24] <= data_in[31:24];
   end
end

endmodule
