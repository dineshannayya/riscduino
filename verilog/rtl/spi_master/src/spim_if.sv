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
////  SPI WishBone I/F Module                                     ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////     SPI WishBone I/F module                                  ////
////     This block support following functionality               ////
////        1. This block Response to Direct Memory Read and      ////
////           Register Write and Read Command                    ////
////        2. In case of Direct Memory Read, It check send the   ////
////           SPI Read command to SPI Ctrl logic and wait for    ////
////           Read data through Response                         ////
////                                                              ////
////  To Do:                                                      ////
////    1. Add 4 Word Memory Fetch for better Through Put         ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////     V.0  -  June 30, 2021                                    //// 
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


module spim_if #( parameter WB_WIDTH = 32) (
    input  logic                         mclk,
    input  logic                         rst_n,

    input  logic                         wbd_stb_i, // strobe/request
    input  logic   [WB_WIDTH-1:0]        wbd_adr_i, // address
    input  logic                         wbd_we_i,  // write
    input  logic   [WB_WIDTH-1:0]        wbd_dat_i, // data output
    input  logic   [3:0]                 wbd_sel_i, // byte enable
    output logic   [WB_WIDTH-1:0]        wbd_dat_o, // data input
    output logic                         wbd_ack_o, // acknowlegement
    output logic                         wbd_err_o,  // error


    // Configuration
    input logic                          cfg_fsm_reset,
    input logic [3:0]                    cfg_mem_seq,    // SPI MEM SEQUENCE
    input logic [1:0]                    cfg_addr_cnt,   // SPI Addr Count
    input logic [1:0]                    cfg_dummy_cnt,  // SPI Dummy Count
    input logic [7:0]                    cfg_data_cnt,   // SPI Read Count
    input logic [7:0]                    cfg_cmd_reg,    // SPI MEM COMMAND
    input logic [7:0]                    cfg_mode_reg,   // SPI MODE REG
    input logic                          spi_init_done,  // SPI internal Init completed

    // Towards Reg I/F
    output logic                         spim_reg_req,     // Reg Request
    output logic [3:0]                   spim_reg_addr,    // Reg Address
    output logic                         spim_reg_we,      // Reg Write/Read Command
    output logic [3:0]                   spim_reg_be,      // Reg Byte Enable
    output logic [31:0]                  spim_reg_wdata,    // Reg Write Data
    input  logic                         spim_reg_ack,     // Read Ack
    input  logic [31:0]                  spim_reg_rdata,    // Read Read Data

    // Towards Command FIFO
    input  logic                         cmd_fifo_empty,   // Command FIFO empty
    output logic                         cmd_fifo_wr,      // Command FIFO Write
    output logic [33:0]                  cmd_fifo_wdata,   // Command FIFO WData
    
    // Towards Response FIFO
    input  logic                         res_fifo_empty,   // Response FIFO Empty
    output logic                         res_fifo_rd,      // Response FIFO Read
    input  logic [31:0]                  res_fifo_rdata,    // Response FIFO Data

    output  logic [3:0]                  state         
    );

//------------------------------------------------
// Parameter Decleration
// -----------------------------------------------
parameter SOC = 1'b1;    // START of COMMAND
parameter EOC = 1'b1;    // END of COMMAND
parameter NOC = 1'b0;    // NORMAL COMMAND

// State Machine state
parameter IDLE       = 4'b000;
parameter ADR_PHASE  = 4'b001;
parameter CMD_WAIT   = 4'b010;
parameter READ_DATA  = 4'b011;

/*************************************************************
*  SPI FSM State Control
*
*   OPERATION   COMMAND                   SEQUENCE 
*
*    ERASE       P4E(0x20)           ->  COMMAND + ADDRESS
*    ERASE       P8E(0x40)           ->  COMMAND + ADDRESS
*    ERASE       SE(0xD8)            ->  COMMAND + ADDRESS
*    ERASE       BE(0x60)            ->  COMMAND + ADDRESS
*    ERASE       BE(0xC7)            ->  COMMAND 
*    PROGRAM     PP(0x02)            ->  COMMAND + ADDRESS + Write DATA
*    PROGRAM     QPP(0x32)           ->  COMMAND + ADDRESS + Write DATA
*    READ        READ(0x3)           ->  COMMAND + ADDRESS + READ DATA
*    READ        FAST_READ(0xB)      ->  COMMAND + ADDRESS + DUMMY + READ DATA
*    READ        DOR (0x3B)          ->  COMMAND + ADDRESS + DUMMY + READ DATA
*    READ        QOR (0x6B)          ->  COMMAND + ADDRESS + DUMMY + READ DATA
*    READ        DIOR (0xBB)         ->  COMMAND + ADDRESS + MODE  + READ DATA
*    READ        QIOR (0xEB)         ->  COMMAND + ADDRESS + MODE  + DUMMY + READ DATA
*    READ        RDID (0x9F)         ->  COMMAND + READ DATA
*    READ        READ_ID (0x90)      ->  COMMAND + ADDRESS + READ DATA
*    WRITE       WREN(0x6)           ->  COMMAND
*    WRITE       WRDI                ->  COMMAND
*    STATUS      RDSR(0x05)          ->  COMMAND + READ DATA
*    STATUS      RCR(0x35)           ->  COMMAND + READ DATA
*    CONFIG      WRR(0x01)           ->  COMMAND + WRITE DATA
*    CONFIG      CLSR(0x30)          ->  COMMAND
*    Power Saving DP(0xB9)           ->  COMMAND
*    Power Saving RES(0xAB)          ->  COMMAND + READ DATA
*    OTP          OTPP(0x42)         ->  COMMAND + ADDR+ WRITE DATA
*    OTP          OTPR(0x4B)         ->  COMMAND + ADDR + DUMMY + READ DATA
*    ********************************************************************/

parameter P_FSM_C      = 4'b0000; // Command Phase Only
parameter P_FSM_CA     = 4'b0001; // Command -> Address Phase Only

parameter P_FSM_CAR    = 4'b0010; // Command -> Address -> Read Data
parameter P_FSM_CADR   = 4'b0011; // Command -> Address -> Dummy -> Read Data
parameter P_FSM_CAMR   = 4'b0100; // Command -> Address -> Mode -> Read Data
parameter P_FSM_CAMDR  = 4'b0101; // Command -> Address -> Mode -> Dummy -> Read Data

parameter P_FSM_CAW    = 4'b0110; // Command -> Address ->Write Data
parameter P_FSM_CADW   = 4'b0111; // Command -> Address -> DUMMY + Write Data
//---------------------------------------------------------
// Variable declartion
// -------------------------------------------------------
logic                 spim_mem_req   ;  // Current Request is Direct Memory Read


logic                 spim_wb_req    ;
logic [WB_WIDTH-1:0]  spim_wb_wdata  ;
logic [WB_WIDTH-1:0]  spim_wb_addr   ;
logic                 spim_wb_ack    ;
logic                 spim_wb_we     ;
logic [3:0]           spim_wb_be     ;
logic [WB_WIDTH-1:0]  spi_mem_rdata  ;
logic [WB_WIDTH-1:0]  spim_wb_rdata  ;

logic                 spim_mem_ack   ;
logic [3:0]           next_state     ;

logic 	              NextPreDVal    ;
logic [7:0]	      NextPreDCnt    ;
logic [31:0]	      NextPreAddr    ;


  //---------------------------------------------------------------
  // Address Decoding
  // 0x0000_0000 - 0x0FFF_FFFF  - SPI FLASH MEMORY ACCESS - 256MB
  // 0x1000_0000 -              - SPI Register Access
  // 
  //
  // Note: Only Bit[28] is decoding done here, other Bit decoding 
  // will be done inside the wishbone inter-connect 
  // --------------------------------------------------------------

  assign spim_mem_req = ((spim_wb_req) && spim_wb_addr[28] == 1'b0);
  assign spim_reg_req = ((spim_wb_req) && spim_wb_addr[28] == 1'b1);

  assign spim_reg_addr = spim_wb_addr[5:2];
  assign spim_reg_wdata = spim_wb_wdata;
  assign spim_reg_we   = spim_wb_we;
  assign spim_reg_be   = spim_wb_be;

  assign wbd_dat_o  =  spim_wb_rdata;
  assign wbd_ack_o  =  spim_wb_ack;
  assign wbd_err_o  =  1'b0;

  // To reduce the load/Timing Wishbone I/F, all the variable are registered
always_ff @(negedge rst_n or posedge mclk) begin
    if ( rst_n == 1'b0 ) begin
        spim_wb_req   <= '0;
        spim_wb_wdata <= '0;
        spim_wb_rdata <= '0;
        spim_wb_addr  <= '0;
        spim_wb_be    <= '0;
        spim_wb_we    <= '0;
        spim_wb_ack   <= '0;
   end else begin
	if(spi_init_done) begin // Wait for internal SPI Init Done
            spim_wb_req   <= wbd_stb_i && ((spim_wb_ack == 0) && (spim_mem_ack ==0) && (spim_reg_ack == 0));
            spim_wb_wdata <= wbd_dat_i;
            spim_wb_addr  <= wbd_adr_i;
            spim_wb_be    <= wbd_sel_i;
            spim_wb_we    <= wbd_we_i;
    
    
    	    if(!spim_wb_we && spim_mem_req && spim_mem_ack) 
                   spim_wb_rdata <= spi_mem_rdata;
            else if (spim_reg_req && spim_reg_ack)
                   spim_wb_rdata <= spim_reg_rdata;
    
            spim_wb_ack   <= (spim_mem_req) ? spim_mem_ack :
		             (spim_reg_req) ? spim_reg_ack : 1'b0;
       end
   end
end


always_ff @(negedge rst_n or posedge mclk) begin
    if ( rst_n == 1'b0 ) begin
	state <= IDLE;
    end else begin
	if(cfg_fsm_reset) state <= IDLE;
	else state <= next_state;
    end
end

/***********************************************************************************
* This block interface with WishBone Request and Write Command & Read Response FIFO
* **********************************************************************************/

always_comb
begin
   cmd_fifo_wr    = '0;
   cmd_fifo_wdata = '0;
   res_fifo_rd    = 0;
   spi_mem_rdata = '0;

   spim_mem_ack   = 0;
   next_state     = state;
   case(state)
   IDLE:  begin
	// Check If any prefetch data available and if see it matched with WB
	// address, If yes, the move to data reading from response fifo, else 
	// generate command request
	if(spim_mem_req && NextPreDVal && (spim_wb_addr == NextPreAddr)) begin
          next_state = READ_DATA;
	end else if(spim_mem_req && cmd_fifo_empty) begin
	   cmd_fifo_wdata = {SOC,NOC,cfg_data_cnt[7:0],cfg_dummy_cnt[1:0],cfg_addr_cnt[1:0],cfg_mem_seq[3:0],cfg_mode_reg[7:0],cfg_cmd_reg[7:0]};
	   cmd_fifo_wr    = 1;
	   next_state = ADR_PHASE;
	end
   end
   ADR_PHASE: begin
          cmd_fifo_wdata = {NOC,EOC,spim_wb_addr[31:0]};
          cmd_fifo_wr      = 1;
          next_state = CMD_WAIT;
   end
   CMD_WAIT: begin
	  // Wait for Command Accepted, before reading data
	  // to take care of staled data being read due to pre-fetch logic
	  if(cmd_fifo_empty) next_state = READ_DATA;
    end


   READ_DATA: begin
	if(res_fifo_empty != 1) begin
           spi_mem_rdata = res_fifo_rdata;
	   res_fifo_rd   = 1;
           spim_mem_ack  = 1;
           next_state    = IDLE;
	end
   end
   endcase
end

/*****************************************************************
* This logic help to find any pre-fetch data available inside the response
* FIFO and if the next data read request address matches with NextPreAddr, The read
* the data from Response FIFO, else generate new request
* Note: Basic Assumption is cmd_fifo_wr & res_fifo_rd does not occur in same
* time as it's generation control through FSM
* **********************************************************/
    
always_ff @(negedge rst_n or posedge mclk) begin
    if ( rst_n == 1'b0 ) begin
	NextPreDVal       <= 1'b0;
	NextPreDCnt       <= 'h0;
	NextPreAddr       <= 'h0;
    end else if(cmd_fifo_wr) begin
       NextPreDVal    <= 1'b1;
       NextPreDCnt    <= cfg_data_cnt;
       NextPreAddr    <= spim_wb_addr;
    end else if (res_fifo_rd) begin
	if(NextPreDCnt == 4) begin
            NextPreDVal <= 1'b0;
        end else begin
           NextPreDCnt <= NextPreDCnt-4;
           NextPreAddr <= NextPreAddr+4;
        end
    end
end


endmodule
