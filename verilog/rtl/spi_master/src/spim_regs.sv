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
////  SPI WishBone Register I/F Module                            ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////     SPI WishBone I/F module                                  ////
////     This block support following functionality               ////
////        1. Direct SPI Read memory support for address rang    ////
////             0x0000 to 0x0FFF_FFFF - Use full for Instruction ////
////             Data Memory fetch                                ////
////        2. SPI Local Register Access                          ////
////        3. Indirect register way to access SPI Memory         ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////     V.0  -  June 8, 2021                                     //// 
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


module spim_regs #( parameter WB_WIDTH = 32) (
    input  logic                         mclk             ,
    input  logic                         rst_n            ,
    input logic                          fast_sim_mode    , // Set 1 for simulation

    output logic                   [7:0] spi_clk_div      ,
    output logic                         spi_init_done    , // SPI internal Init completed

    // Status Monitoring
    input logic                    [31:0] spi_debug       ,

    // Master 0 Configuration
    output logic                         cfg_m0_fsm_reset ,
    output logic [3:0]                   cfg_m0_cs_reg    ,  // Chip select
    output logic [1:0]                   cfg_m0_spi_mode  ,  // Final SPI Mode 
    output logic [1:0]                   cfg_m0_spi_switch,  // SPI Mode Switching Place
    output logic [3:0]                   cfg_m0_spi_seq   ,  // SPI SEQUENCE
    output logic [1:0]                   cfg_m0_addr_cnt  ,  // SPI Addr Count
    output logic [1:0]                   cfg_m0_dummy_cnt ,  // SPI Dummy Count
    output logic [7:0]                   cfg_m0_data_cnt  ,  // SPI Read Count
    output logic [7:0]                   cfg_m0_cmd_reg   ,  // SPI MEM COMMAND
    output logic [7:0]                   cfg_m0_mode_reg  ,  // SPI MODE REG

    output logic [3:0]                   cfg_m1_cs_reg    ,  // Chip select
    output logic [1:0]                   cfg_m1_spi_mode  ,  // Final SPI Mode 
    output logic [1:0]                   cfg_m1_spi_switch,  // SPI Mode Switching Place

    output logic [1:0]                   cfg_cs_early     ,  // Amount of cycle early CS asserted
    output logic [1:0]                   cfg_cs_late      ,  // Amount of cycle late CS de-asserted

    // Towards Reg I/F
    input  logic                         spim_reg_req     ,   // Reg Request
    input  logic [3:0]                   spim_reg_addr    ,   // Reg Address
    input  logic                         spim_reg_we      ,   // Reg Write/Read Command
    input  logic [3:0]                   spim_reg_be      ,   // Reg Byte Enable
    input  logic [31:0]                  spim_reg_wdata   ,   // Reg Write Data
    output  logic                        spim_reg_ack     ,   // Read Ack
    output  logic [31:0]                 spim_reg_rdata    ,   // Read Read Data

    // Towards Command FIFO
    input  logic                         cmd_fifo_full    ,   // Command FIFO full
    input  logic                         cmd_fifo_empty   ,   // Command FIFO empty
    output logic                         cmd_fifo_wr      ,   // Command FIFO Write
    output logic [33:0]                  cmd_fifo_wdata   ,   // Command FIFO WData
    
    // Towards Response FIFO
    input  logic                         res_fifo_full    ,   // Response FIFO Empty
    input  logic                         res_fifo_empty   ,   // Response FIFO Empty
    output logic                         res_fifo_rd      ,   // Response FIFO Read
    input  logic [31:0]                  res_fifo_rdata   ,   // Response FIFO Data

    output logic [3:0]                   state           
    );
//------------------------------------------------
// Parameter Decleration
// -----------------------------------------------
parameter SOC = 1'b1;    // START of COMMAND
parameter EOC = 1'b1;    // END of COMMAND
parameter NOC = 1'b0;    // NORMAL COMMAND

parameter BTYPE = 1'b0;  // Count is Byte Type
parameter WTYPE = 1'b1;  // Count is Word Type

parameter CNT1 = 2'b00; // BYTE/WORD Count1
parameter CNT2 = 2'b01; // BYTE/WORD Count2
parameter CNT3 = 2'b10; // BYTE/WORD Count3
parameter CNT4 = 2'b11; // BYTE/WORD Count4


// Type of command
parameter NWRITE = 2'b00; // Normal Write
parameter NREAD  = 2'b01; // Normal Read
parameter DWRITE = 2'b10; // Dummy Write
parameter DREAD  = 2'b11; // Dummy Read

// State Machine state
parameter FSM_IDLE        = 3'b000;
parameter FSM_ADR_PHASE   = 3'b001;
parameter FSM_WRITE_PHASE = 3'b010;
parameter FSM_READ_PHASE  = 3'b011;
parameter FSM_READ_BUSY   = 3'b100;
parameter FSM_WRITE_BUSY  = 3'b101;
parameter FSM_ACK_PHASE   = 3'b110;

//----------------------------
// Register Decoding
// ---------------------------
parameter GLBL_CTRL    = 4'b0000;
parameter DMEM_CTRL1   = 4'b0001;
parameter DMEM_CTRL2   = 4'b0010;
parameter IMEM_CTRL1   = 4'b0011;
parameter IMEM_CTRL2   = 4'b0100;
parameter IMEM_ADDR    = 4'b0101;
parameter IMEM_WDATA   = 4'b0110;
parameter IMEM_RDATA   = 4'b0111;
parameter SPI_STATUS   = 4'b1000;

// Init FSM
parameter SPI_INIT_PWUP      = 3'b000;
parameter SPI_INIT_IDLE      = 3'b001;
parameter SPI_INIT_CMD_WAIT  = 3'b010;
parameter SPI_INIT_WREN_CMD  = 3'b011;
parameter SPI_INIT_WREN_WAIT = 3'b100;
parameter SPI_INIT_WRR_CMD   = 3'b101;
parameter SPI_INIT_WRR_WAIT  = 3'b110;
parameter SPI_INIT_WAIT      = 3'b111;

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
parameter P_FSM_CW     = 4'b0001; // Command + Write DATA Phase Only
parameter P_FSM_CA     = 4'b0010; // Command -> Address Phase Only

parameter P_FSM_CAR    = 4'b0011; // Command -> Address -> Read Data
parameter P_FSM_CADR   = 4'b0100; // Command -> Address -> Dummy -> Read Data
parameter P_FSM_CAMR   = 4'b0101; // Command -> Address -> Mode -> Read Data
parameter P_FSM_CAMDR  = 4'b0110; // Command -> Address -> Mode -> Dummy -> Read Data

parameter P_FSM_CAW    = 4'b0111; // Command -> Address ->Write Data
parameter P_FSM_CADW   = 4'b1000; // Command -> Address -> DUMMY + Write Data

parameter P_FSM_CDR    = 4'b1001; // COMMAND -> DUMMY -> READ
parameter P_FSM_CDW    = 4'b1010; // COMMAND -> DUMMY -> WRITE
parameter P_FSM_CR     = 4'b1011;  // COMMAND -> READ
//---------------------------------------------------------
  parameter P_CS0 = 4'b0001;
  parameter P_CS1 = 4'b0010;
  parameter P_CS2 = 4'b0100;
  parameter P_CS3 = 4'b1000;

  parameter P_SINGLE = 2'b00;
  parameter P_DOUBLE = 2'b01;
  parameter P_QUAD   = 2'b10;

  parameter P_MODE_SWITCH_IDLE     = 2'b00;
  parameter P_MODE_SWITCH_AT_ADDR  = 2'b01;
  parameter P_MODE_SWITCH_AT_DATA  = 2'b10;

  parameter P_QOR = 8'h6B;
  parameter P_QIOR = 8'hEB;
  parameter P_RES = 8'hAB;
  parameter P_WEN = 8'h06;
  parameter P_WRR = 8'h01;

  parameter P_8BIT   = 2'b00;
  parameter P_16BIT  = 2'b01;
  parameter P_24BIT  = 2'b10;
  parameter P_32BIT  = 2'b11;
//---------------------------------------------------------
// Variable declartion
// -------------------------------------------------------
logic   [2:0]        spi_init_state ;
logic                spim_reg_req_f ; 

logic [1:0]          cfg_m1_fsm_reset ;
logic [3:0]          cfg_m1_spi_seq   ; // SPI SEQUENCE
logic [1:0]          cfg_m1_addr_cnt  ; // SPI Addr Count
logic [1:0]          cfg_m1_dummy_cnt ; // SPI Dummy Count
logic [7:0]          cfg_m1_data_cnt  ; // SPI Read Count
logic [7:0]          cfg_m1_cmd_reg   ; // SPI MEM COMMAND
logic [7:0]          cfg_m1_mode_reg  ; // SPI MODE REG
logic [31:0]         cfg_m1_addr      ;
logic [31:0]         cfg_m1_wdata     ;
logic [31:0]         cfg_m1_rdata     ;
logic                cfg_m1_wrdy      ;
logic                cfg_m1_req       ;

logic [31:0]         reg_rdata        ;


logic [5:0]           cur_cnt         ;
logic [5:0]           next_cnt        ;
logic [3:0]           next_state      ;


logic [31:0]          spim_m1_rdata   ;
logic                 spim_m1_ack     ;
logic                 spim_m1_rrdy    ;
logic                 spim_m1_wrdy    ;
logic  [9:0]          spi_delay_cnt  ;
logic                 spim_fifo_rdata_req  ;
logic                 spim_fifo_wdata_req  ;


//----------------------------------------------
// Consolidated Register Ack handling
//   1. Handles Normal Register Read
//   2. Indirect Memory Write
//   3. Indirect Memory Read
//----------------------------------------------
//
assign spim_fifo_rdata_req = spim_reg_req && spim_reg_we == 0 && (spim_reg_addr== IMEM_RDATA);
assign spim_fifo_wdata_req = spim_reg_req && spim_reg_we == 1 && (spim_reg_addr== IMEM_WDATA);

always_ff @(negedge rst_n or posedge mclk) begin
   if ( rst_n == 1'b0 ) begin
       spim_reg_ack  <= 1'b0;
       spim_reg_rdata <= 'h0;
   end else begin
      if(spi_init_done && spim_reg_ack == 0) begin
         if (spim_fifo_wdata_req && (spim_m1_wrdy == 1)) begin // Indirect Memory Write
	     // If FIFO Write DATA case, Make sure that there no previous pending
	     // need to processed
             spim_reg_ack  <= 1'b1;
	 end else if (spim_reg_req && spim_reg_we && (spim_reg_addr != IMEM_WDATA)) begin // Indirect memory Write
             spim_reg_ack  <= 1'b1;
	 end else if (spim_fifo_rdata_req && (spim_m1_rrdy == 1)) begin // Indirect mem Read
	     // If FIFO Read DATA case, Make sure that there Data is read from
             // External SPI Memory
             spim_reg_ack  <= 1'b1;
             spim_reg_rdata <= reg_rdata;
	end else if (spim_reg_req && spim_reg_we == 0 && (spim_reg_addr != IMEM_RDATA)) begin // Normal Read
	     // Read other than FIFO Read Data case
             spim_reg_ack  <= 1'b1;
             spim_reg_rdata <= reg_rdata;
	end
      end else begin
         spim_reg_ack <= 1'b0;
      end
   end
end

  //---------------------------------------------
  // Manges the initial Config Phase of SPI Memory
  // 1. Power Up Command -  RES(0xAB) 
  // 2. Write Enable Command - WEN (0x06)
  // 3. WRITE CONFIG Reg - WRR (0x01) - Set Qaud Mode
  // --------------------------------------------
  
  logic  [9:0]          cfg_exit_cnt  ;
  assign cfg_exit_cnt = (fast_sim_mode) ? 100: 1000;

  integer byte_index;
  always_ff @(negedge rst_n or posedge mclk) begin
    if ( rst_n == 1'b0 ) begin
      cfg_m0_fsm_reset      <= 'h0;
      cfg_m0_cs_reg         <= P_CS0;
      cfg_m0_spi_mode       <= P_QUAD;
      cfg_m0_spi_switch     <= P_MODE_SWITCH_AT_ADDR;
      cfg_m0_cmd_reg        <= P_QIOR;
      cfg_m0_mode_reg       <= 'h0;
      cfg_m0_spi_seq[3:0]   <= P_FSM_CAMDR;
      cfg_m0_addr_cnt[1:0]  <= P_24BIT;
      cfg_m0_dummy_cnt[1:0] <= P_16BIT;
      cfg_m0_data_cnt[7:0]  <= 8'h20; // 32 Byte

      cfg_m1_fsm_reset      <= 'h0;
      cfg_m1_cs_reg         <= P_CS0;
      cfg_m1_spi_mode       <= P_QUAD;
      cfg_m1_spi_switch     <= P_MODE_SWITCH_AT_DATA;
      cfg_m1_cmd_reg        <= P_QOR;
      cfg_m1_mode_reg       <= 'h0;
      cfg_m1_spi_seq[3:0]   <= P_FSM_CADR;
      cfg_m1_addr_cnt[1:0]  <= P_24BIT;
      cfg_m1_dummy_cnt[1:0] <= P_8BIT;
      cfg_m1_data_cnt[7:0]  <= 0;
      cfg_m1_req            <= 0; 
      cfg_m1_wrdy           <= 1'b0;
      cfg_m1_wdata          <= 'h0; // Not Used

      cfg_cs_early         <= 'h1;
      cfg_cs_late          <= 'h1;
      spi_clk_div          <= 'h2;

      spi_init_done         <=  'h0;
      spi_delay_cnt         <= 'h0;
      spim_reg_req_f        <= 1'b0;
      spi_init_state        <=  SPI_INIT_PWUP;
    end else begin 
        spim_reg_req_f        <= spim_reg_req; // Needed for finding Req Edge
        if (spi_init_done == 0) begin
          case(spi_init_state)

              //----------------------------------------------
              // SPI MEMORY Need minimum 5Us after power up
              // With 100Mhz, 10ns translated to 500 cycle
              // We are waiting 1000 cycle
              // ---------------------------------------------
              SPI_INIT_PWUP:begin
                   if(spi_delay_cnt == cfg_exit_cnt) begin
                       spi_init_state   <=  SPI_INIT_IDLE;
           	end else begin
           	    spi_delay_cnt <= spi_delay_cnt+1;
           	end
              end

              SPI_INIT_IDLE:
              begin
                 cfg_m1_cs_reg        <= P_CS0;
                 cfg_m1_spi_mode      <= P_SINGLE;
                 cfg_m1_spi_seq[3:0]  <= P_FSM_C;
                 cfg_m1_spi_switch    <= '0;
                 cfg_m1_cmd_reg       <= P_RES;
                 cfg_m1_mode_reg      <= 'h0; // Not Used
                 cfg_m1_addr_cnt[1:0] <= 'h0; // Not Used
                 cfg_m1_dummy_cnt[1:0]<= 'h0; // Not Used
                 cfg_m1_data_cnt[7:0] <= 'h0; // Not Used
                 cfg_m1_addr          <= 'h0; // Not Used
                 cfg_m1_wdata         <= 'h0; // Not Used
                 cfg_m1_req           <= 'h1;
                 spi_init_state       <=  SPI_INIT_CMD_WAIT;
              end
              SPI_INIT_CMD_WAIT:
              begin
                 if(spim_m1_ack)   begin
                    cfg_m1_req       <= 1'b0;
                    spi_init_state   <=  SPI_INIT_WREN_CMD;
                 end
              end
              SPI_INIT_WREN_CMD:
              begin
                 cfg_m1_cs_reg        <= P_CS0;
                 cfg_m1_spi_mode      <= P_SINGLE;
                 cfg_m1_spi_seq[3:0]  <= P_FSM_C;
                 cfg_m1_spi_switch    <= '0;
                 cfg_m1_cmd_reg       <= P_WEN;
                 cfg_m1_mode_reg      <= 'h0; // Not Used
                 cfg_m1_addr_cnt[1:0] <= 'h0; // Not Used
                 cfg_m1_dummy_cnt[1:0]<= 'h0; // Not Used
                 cfg_m1_data_cnt[7:0] <= 'h0; // Not Used
                 cfg_m1_addr          <= 'h0; // Not Used
                 cfg_m1_wdata         <= 'h0; // Not Used
                 cfg_m1_req           <= 'h1;
                 spi_init_state       <=  SPI_INIT_WREN_WAIT;
              end
              SPI_INIT_WREN_WAIT:
              begin
                 if(spim_m1_ack)   begin
                    cfg_m1_req      <= 1'b0;
                    spi_init_state    <=  SPI_INIT_WRR_CMD;
                 end
              end
              SPI_INIT_WRR_CMD:
              begin
                 cfg_m1_cs_reg        <= P_CS0;
                 cfg_m1_spi_mode      <= P_SINGLE;
                 cfg_m1_spi_seq[3:0]  <= P_FSM_CW;
                 cfg_m1_spi_switch    <= '0;
                 cfg_m1_cmd_reg       <= P_WRR;
                 cfg_m1_mode_reg      <= 'h0; 
                 cfg_m1_addr_cnt[1:0] <= 'h0; 
                 cfg_m1_dummy_cnt[1:0]<= 'h0; 
                 cfg_m1_data_cnt[7:0] <= 'h2; // 2 Bytes
                 cfg_m1_addr          <= 'h0; 
                 cfg_m1_wrdy          <= 1'b1;
                 cfg_m1_wdata         <= {16'h0,8'h2,8'h0}; // <<cr1[7:0]><sr1[7:0]>> cr1[1] = 1 indicate quad mode cr1[7:6]=3 
                 cfg_m1_req           <= 'h1;
                 spi_init_state       <=  SPI_INIT_WRR_WAIT;
              end
              SPI_INIT_WRR_WAIT:
              begin
                 if(spim_m1_ack)   begin
		    spi_delay_cnt    <= 'h0;
                    cfg_m1_wrdy      <= 1'b0;
                    cfg_m1_req       <= 1'b0;
                    spi_init_state   <=  SPI_INIT_WAIT;
                 end
              end
              SPI_INIT_WAIT:
              begin // SPI MEMORY need 5us after WRR Command
                   if(spi_delay_cnt == cfg_exit_cnt) begin
                       spi_init_done    <=  'h1;
           	end else begin
           	    spi_delay_cnt <= spi_delay_cnt+1;
           	end
              end
          endcase
       end else if (spim_reg_req && spim_reg_we && spi_init_done )
       begin
         case(spim_reg_addr)
         GLBL_CTRL: begin
             if ( spim_reg_be[0] == 1 ) begin
                cfg_cs_early  <= spim_reg_wdata[1:0];
                cfg_cs_late   <= spim_reg_wdata[3:2];
             end
             if ( spim_reg_be[1] == 1 ) begin
                spi_clk_div <= spim_reg_wdata[15:8];
             end
         end
        DMEM_CTRL1: begin // This register control Direct Memory Access Type
             if ( spim_reg_be[0] == 1 ) begin
               cfg_m0_cs_reg    <= spim_reg_wdata[3:0]; // Chip Select for Memory Interface
               cfg_m0_spi_mode  <= spim_reg_wdata[5:4]; // SPI Mode, 0 - Normal, 1- Double, 2 - Qard, 3 - QDDR
               cfg_m0_spi_switch<= spim_reg_wdata[7:6]; // Phase where to switch the SPI Mode
             end
             if ( spim_reg_be[1] == 1 ) begin
               cfg_m0_fsm_reset <= spim_reg_wdata[8];
             end
         end
         DMEM_CTRL2: begin // This register control Direct Memory Access Type
             if ( spim_reg_be[0] == 1 ) begin
                cfg_m0_cmd_reg <= spim_reg_wdata[7:0];
             end
             if ( spim_reg_be[1] == 1 ) begin
                cfg_m0_mode_reg <= spim_reg_wdata[15:8];
             end
             if ( spim_reg_be[2] == 1 ) begin
                cfg_m0_spi_seq[3:0]  <= spim_reg_wdata[19:16];
                cfg_m0_addr_cnt[1:0] <= spim_reg_wdata[21:20];
                cfg_m0_dummy_cnt[1:0]<= spim_reg_wdata[23:22];
             end
             if ( spim_reg_be[3] == 1 ) begin
               cfg_m0_data_cnt[7:0]  <= spim_reg_wdata[31:24];
             end
         end
         IMEM_CTRL1: begin
             if ( spim_reg_be[0] == 1 ) begin
               cfg_m1_cs_reg    <= spim_reg_wdata[3:0]; // Chip Select for Memory Interface
               cfg_m1_spi_mode  <= spim_reg_wdata[5:4]; // SPI Mode, 0 - Normal, 1- Double, 2 - Qard
               cfg_m1_spi_switch<= spim_reg_wdata[7:6]; // Phase where to switch the SPI Mode
             end
             if ( spim_reg_be[0] == 1 ) begin
               cfg_m1_fsm_reset <= spim_reg_wdata[8];
             end
         end
         IMEM_CTRL2: begin // This register control Direct Memory Access Type
             if ( spim_reg_be[0] == 1 ) begin
                cfg_m1_cmd_reg <= spim_reg_wdata[7:0];
             end
             if ( spim_reg_be[1] == 1 ) begin
                cfg_m1_mode_reg <= spim_reg_wdata[15:8];
             end
             if ( spim_reg_be[2] == 1 ) begin
                cfg_m1_spi_seq[3:0]  <= spim_reg_wdata[19:16];
                cfg_m1_addr_cnt[1:0] <= spim_reg_wdata[21:20];
                cfg_m1_dummy_cnt[1:0]<= spim_reg_wdata[23:22];
             end
             if ( spim_reg_be[3] == 1 ) begin
                cfg_m1_data_cnt[7:0]  <= spim_reg_wdata[31:24];
             end
         end
         IMEM_ADDR: begin
           for (byte_index = 0; byte_index < 4; byte_index = byte_index+1 )
               if ( spim_reg_be[byte_index] == 1 )
                 cfg_m1_addr[byte_index*8 +: 8] <= spim_reg_wdata[(byte_index*8) +: 8];
         end
         endcase
         end 
     end 
  end 



  // implement slave model register read mux
  always_comb
    begin
      reg_rdata = '0;
      if(spim_reg_req) begin
          case(spim_reg_addr)
            GLBL_CTRL:   reg_rdata[31:0] = {16'h0,spi_clk_div,4'h0,cfg_cs_late,cfg_cs_early};
	    DMEM_CTRL1:    reg_rdata[31:0] =  {23'h0,cfg_m0_fsm_reset,cfg_m0_spi_switch,cfg_m0_spi_mode,cfg_m0_cs_reg};
	    DMEM_CTRL2:    reg_rdata[31:0] =  {cfg_m0_data_cnt,cfg_m0_dummy_cnt,cfg_m0_addr_cnt,cfg_m0_spi_seq,cfg_m0_mode_reg,cfg_m0_cmd_reg};
            IMEM_CTRL1:    reg_rdata[31:0] =  {23'h0, cfg_m1_fsm_reset,cfg_m1_spi_switch,cfg_m1_spi_mode,cfg_m1_cs_reg};
	    IMEM_CTRL2:    reg_rdata[31:0] =  {cfg_m1_data_cnt,cfg_m1_dummy_cnt,cfg_m1_addr_cnt,cfg_m1_spi_seq,cfg_m1_mode_reg,cfg_m1_cmd_reg};
            IMEM_ADDR:   reg_rdata[31:0] = cfg_m1_addr;
            IMEM_WDATA: reg_rdata[31:0] = cfg_m1_wdata;
            IMEM_RDATA: reg_rdata[31:0] = cfg_m1_rdata;
            SPI_STATUS:   reg_rdata[31:0] = spi_debug;
          endcase
       end
    end 

// FSM

always_ff @(negedge rst_n or posedge mclk) begin
    if ( rst_n == 1'b0 ) begin
	cur_cnt <= 'h0;
	state    <= FSM_IDLE;
    end else begin
       if(cfg_m1_fsm_reset) begin
          cur_cnt <= 'h0;
	  state    <= FSM_IDLE;
       end else begin
           cur_cnt <= next_cnt;
       	   state <= next_state;
       end
    end
end

/***********************************************************************************
* This block interface with WishBone Request and Write Command & Read Response FIFO
* **********************************************************************************/

logic [7:0] cfg_data_cnt;
logic [31:0] spim_fifo_wdata;
logic       spim_fifo_req;
assign cfg_data_cnt = cfg_m1_data_cnt-1;

assign spim_fifo_req = cfg_m1_req || spim_fifo_rdata_req || spim_fifo_wdata_req;

assign spim_fifo_wdata = (cfg_m1_req) ?  cfg_m1_wdata :  spim_reg_wdata;

always_comb
begin
   cmd_fifo_wr    = '0;
   cmd_fifo_wdata = '0;

   res_fifo_rd    = 0;
   spim_m1_rdata   = '0;

   spim_m1_ack    = 0;
   spim_m1_rrdy   = 0;
   next_cnt      = cur_cnt;
   next_state    = state;
   spim_m1_rrdy  = 0;
   spim_m1_wrdy  = 0;
   cfg_m1_rdata  = 0;

   case(state)
   FSM_IDLE:  begin
        next_cnt      = 0;
	if(spim_fifo_req && cmd_fifo_empty) begin
	   case(cfg_m1_spi_seq)
	      P_FSM_C: begin
	              cmd_fifo_wdata = {SOC,EOC, cfg_m1_data_cnt[7:0],cfg_m1_dummy_cnt[1:0],
		                        cfg_m1_addr_cnt[1:0],cfg_m1_spi_seq[3:0],
					cfg_m1_mode_reg[7:0],cfg_m1_cmd_reg[7:0]};
	              spim_m1_wrdy = 1;
	              next_state = FSM_ACK_PHASE;
	      end
	      P_FSM_CW, 
	      P_FSM_CDW:
	      begin
	          cmd_fifo_wdata = {SOC,NOC, cfg_m1_data_cnt[7:0],cfg_m1_dummy_cnt[1:0],
			            cfg_m1_addr_cnt[1:0],cfg_m1_spi_seq[3:0],
				    cfg_m1_mode_reg[7:0],cfg_m1_cmd_reg[7:0]};
	          next_state = FSM_WRITE_PHASE;
	      end
	      P_FSM_CA, 
	      P_FSM_CAR, 
	      P_FSM_CADR,
	      P_FSM_CAMR, 
	      P_FSM_CAMDR, 
	      P_FSM_CAW, 
	      P_FSM_CADW: 
	      begin
	          cmd_fifo_wdata = {SOC,NOC, cfg_m1_data_cnt[7:0],cfg_m1_dummy_cnt[1:0],
			            cfg_m1_addr_cnt[1:0],cfg_m1_spi_seq[3:0],
				    cfg_m1_mode_reg[7:0],cfg_m1_cmd_reg[7:0]};
	          next_state = FSM_ADR_PHASE;
	      end
	       P_FSM_CDR,
	       P_FSM_CR: 
               begin
	          cmd_fifo_wdata = {SOC,EOC, cfg_m1_data_cnt[7:0],cfg_m1_dummy_cnt[1:0],
			            cfg_m1_addr_cnt[1:0],cfg_m1_spi_seq[3:0],
				    cfg_m1_mode_reg[7:0],cfg_m1_cmd_reg[7:0]};
	          next_state = FSM_READ_PHASE;
	       end


	   endcase
	   cmd_fifo_wr    = 1;
	end
   end
   // ADDRESS PHASE
   FSM_ADR_PHASE: begin
	  if(!cmd_fifo_full) begin
	      case(cfg_m1_spi_seq)
	         P_FSM_CA:   // COMMAND + ADDRESS PHASE
	         begin
                       cmd_fifo_wdata = {NOC,EOC,cfg_m1_addr[31:0]};
	               spim_m1_wrdy = 1;
	               next_state = FSM_ACK_PHASE;
	         end
	         P_FSM_CAR,  // COMMAND + ADDRESS + READ PHASE
                 P_FSM_CADR, // COMMAND + ADDRESS + DUMMY + READ PHASE
	         P_FSM_CAMR, // COMMAND + ADDRESS + MODE + READ PHASE
	         P_FSM_CAMDR: // COMMAND + ADDRESS + MODE + DUMMY + READ PHASE
		 begin
                    cmd_fifo_wdata = {NOC,EOC,cfg_m1_addr[31:0]};
	            next_cnt  = 'h0;
	            next_state = FSM_READ_PHASE;
	         end

		 P_FSM_CAW,
		 P_FSM_CADW: 
		 begin
                    cmd_fifo_wdata = {NOC,NOC,cfg_m1_addr[31:0]};
	            next_cnt  = 'h0;
	            next_state = FSM_WRITE_PHASE;
	         end
	      endcase
              cmd_fifo_wr      = 1;
	  end
   end

   //----------------------------------------------------------
   // Check Resonse FIFO is not empty then read the data from response fifo
   // ---------------------------------------------------------
   FSM_READ_PHASE: begin
	if(res_fifo_empty != 1 && spim_fifo_rdata_req) begin
	   spim_m1_rrdy = 1;
           cfg_m1_rdata = res_fifo_rdata;
	   res_fifo_rd  = 1;
	   if(cfg_data_cnt[7:2] == cur_cnt) begin
	      next_state = FSM_ACK_PHASE;
	   end else begin
	      next_state = FSM_READ_BUSY;
	      next_cnt  = cur_cnt+1;
	    end
	 end
   end
   //----------------------------------------------
   // Wait for Previous Read Data Read
   // ---------------------------------------------
   FSM_READ_BUSY: begin
        spim_m1_rrdy = 0;
	if(spim_fifo_rdata_req == 0) begin
           next_state    = FSM_READ_PHASE;
	end
   end

   //----------------------------------------------------------
   // Check command FIFO is not full and Write Data is available
   // ---------------------------------------------------------
   FSM_WRITE_PHASE: begin
        if(cmd_fifo_full != 1 && spim_fifo_req) begin
	   // If this a single word config cycle or 
           // in crrent spim_fifo_wr request
	   spim_m1_wrdy = 1;
	   if(cfg_data_cnt[7:2] == cur_cnt) begin
              cmd_fifo_wdata = {NOC,EOC,spim_fifo_wdata[31:0]};
	      next_state     = FSM_ACK_PHASE;
	   end else begin
              cmd_fifo_wdata = {NOC,NOC,spim_fifo_wdata[31:0]};
	      next_state     = FSM_WRITE_BUSY;
	      next_cnt      = cur_cnt+1;
	    end
	   cmd_fifo_wr  = 1;
	 end
   end
   //----------------------------------------------
   // Wait for NEXT Data Ready
   // ---------------------------------------------
   FSM_WRITE_BUSY: begin
	spim_m1_wrdy = 0;
	if(spim_fifo_wdata_req == 0) begin
           next_state    = FSM_WRITE_PHASE;
	end
   end

   FSM_ACK_PHASE: begin
	   spim_m1_ack = 1;
	   next_state = FSM_IDLE;
	end

   endcase


end

endmodule
