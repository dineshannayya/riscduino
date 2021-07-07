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
////  SPI CTRL I/F Module                                         ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
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
module spim_ctrl  #(
     parameter ENDIEAN = 0  // 0 - Little, 1 - Big endian, since RISV is Little indian default set 0
     )

(
    input  logic                          clk,
    input  logic                          rstn,

    input  logic                    [7:0] spi_clk_div,
    output logic                    [8:0] spi_status,

    // Master 0 Configuration
    input  logic [3:0]                   cfg_m0_cs_reg    ,  // Chip select
    input  logic [1:0]                   cfg_m0_spi_mode  ,  // Final SPI Mode 
    input  logic [1:0]                   cfg_m0_spi_switch,  // SPI Mode Switching Place

    input  logic [3:0]                   cfg_m1_cs_reg    ,  // Chip select
    input  logic [1:0]                   cfg_m1_spi_mode  ,  // Final SPI Mode 
    input  logic [1:0]                   cfg_m1_spi_switch,  // SPI Mode Switching Place

    input  logic [1:0]                   cfg_cs_early     ,  // Amount of cycle early CS asserted
    input  logic [1:0]                   cfg_cs_late      ,  // Amount of cycle late CS de-asserted

    // Master 0 Command FIFO Interface
    input  logic                         m0_cmd_fifo_empty,
    output logic                         m0_cmd_fifo_rd,
    input  logic [33:0]                  m0_cmd_fifo_rdata,

    // Master 0 response FIFO Interface
    output logic 	                 m0_res_fifo_flush,
    input  logic                         m0_res_fifo_empty,
    input  logic                         m0_res_fifo_full,
    output logic                         m0_res_fifo_wr,
    output logic [31:0]                  m0_res_fifo_wdata,

    // Master 1 Command FIFO Interface
    output logic 	                 m1_res_fifo_flush,
    input  logic                         m1_cmd_fifo_empty,
    output logic                         m1_cmd_fifo_rd,
    input  logic [33:0]                  m1_cmd_fifo_rdata,

    // Master 1 response FIFO Interface
    input  logic                         m1_res_fifo_empty,
    input  logic                         m1_res_fifo_full,
    output logic                         m1_res_fifo_wr,
    output logic [31:0]                  m1_res_fifo_wdata,

    output logic [3:0]                   ctrl_state,

    output logic                          spi_clk,
    output logic                          spi_csn0,
    output logic                          spi_csn1,
    output logic                          spi_csn2,
    output logic                          spi_csn3,
    output logic                    [1:0] spi_mode,
    output logic                          spi_sdo0,
    output logic                          spi_sdo1,
    output logic                          spi_sdo2,
    output logic                          spi_sdo3,
    input  logic                          spi_sdi0,
    input  logic                          spi_sdi1,
    input  logic                          spi_sdi2,
    input  logic                          spi_sdi3,
    output logic                          spi_en_tx // Spi Direction control
);

//--------------------------------------
// Parameter
// --------------------------------------
parameter  SPI_STD     = 2'b00;
parameter  SPI_QUAD_TX = 2'b01;
parameter  SPI_QUAD_RX = 2'b10;

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

//---------------------
  parameter P_8BIT   = 2'b00;
  parameter P_16BIT  = 2'b01;
  parameter P_24BIT  = 2'b10;
  parameter P_32BIT  = 2'b11;

//---- Phase where to switch the SPI Mode
//---- This need to decided based on command
  parameter P_MODE_SWITCH_IDLE     = 2'b00;
  parameter P_MODE_SWITCH_AT_ADDR  = 2'b01;
  parameter P_MODE_SWITCH_AT_DATA  = 2'b10;
//----------------------------------------
// Local Variable
// ---------------------------------------
  logic spi_rise;
  logic spi_fall;

  logic spi_clock_en;

  logic spi_en_rx;

  logic        res_fifo_flush;

  logic [15:0] counter_tx;
  logic        counter_tx_valid;
  logic [15:0] counter_rx;
  logic        counter_rx_valid;

  logic [31:0] data_to_tx;
  logic        data_to_tx_valid;
  logic        data_to_tx_ready;
  logic        tx_data_ready;


  logic       tx_done;
  logic       rx_done;

  logic [1:0] s_spi_mode;

  logic       ctrl_data_valid;

  logic       spi_cs;

  logic        tx_clk_en;
  logic        rx_clk_en;
  logic        en_quad_in;
  logic [1:0]  cnt; // counter for cs assertion and de-assertion
  logic [1:0]  nxt_cnt;
  logic [1:0]  gnt;

  logic  [7:0] cfg_data_cnt    ;
  logic  [1:0] cfg_dummy_cnt   ;
  logic  [1:0] cfg_addr_cnt    ;
  logic  [3:0] cfg_spi_seq     ;
  logic [7:0]  spi_mode_cmd    ;
  

  enum logic [2:0] {DATA_NULL,DATA_EMPTY,DATA_CMD,DATA_ADDR,DATA_MODE,DATA_FIFO} ctrl_data_mux;

  enum logic [4:0] {FSM_IDLE,FSM_CS_ASSERT,FSM_CMD_PHASE,FSM_ADR_PHASE,FSM_DUMMY_PHASE,FSM_MODE_PHASE,FSM_WRITE_CMD,FSM_WRITE_PHASE,
	            FSM_READ_WAIT,FSM_READ_PHASE,FSM_TX_DONE,FSM_CS_DEASEERT} state,next_state;

 
  assign ctrl_state =  state[3:0];
  assign en_quad_in = (s_spi_mode == SPI_STD) ? 1'b0 : 1'b1;

  assign spi_mode = s_spi_mode;

  //----------------------------
  // Configuration
  //----------------------------
  logic [3:0]  cfg_cs_reg    ;  // Chip select
  logic [1:0]  cfg_spi_mode  ;  // Final SPI Mode 
  logic [1:0]  cfg_spi_switch;  // SPI Mode Switching Place

  
  assign cfg_cs_reg     = (gnt == 2'b01) ? cfg_m0_cs_reg    : cfg_m1_cs_reg;
  assign cfg_spi_mode   = (gnt == 2'b01) ? cfg_m0_spi_mode  : cfg_m1_spi_mode;  // Final SPI Mode 
  assign cfg_spi_switch = (gnt == 2'b01) ? cfg_m0_spi_switch: cfg_m1_spi_switch;  // SPI Mode Switching Place

  //----------------------------
  // Command FIFO
  //----------------------------
  logic              cmd_fifo_empty;
  logic              cmd_fifo_rd;
  logic [33:0]       cmd_fifo_rdata;

  assign cmd_fifo_empty = (gnt == 2'b01) ? m0_cmd_fifo_empty : m1_cmd_fifo_empty;
  assign cmd_fifo_rdata = (gnt == 2'b01) ? m0_cmd_fifo_rdata : m1_cmd_fifo_rdata;

  assign m0_cmd_fifo_rd = (gnt == 2'b01) ? cmd_fifo_rd : 1'b0;
  assign m1_cmd_fifo_rd = (gnt == 2'b10) ? cmd_fifo_rd : 1'b0;

  //----------------------------
  // Response FIFO
  //----------------------------
  logic              res_fifo_empty;
  logic              res_fifo_full;
  logic              res_fifo_wr;
  logic [31:0]       res_fifo_wdata;

  assign res_fifo_empty = (gnt == 2'b01) ? m0_res_fifo_empty : m1_res_fifo_empty;
  assign res_fifo_full  = (gnt == 2'b01) ? m0_res_fifo_full  : m1_res_fifo_full;

  assign m0_res_fifo_wr = (gnt == 2'b01) ? res_fifo_wr : 1'b0;
  assign m1_res_fifo_wr = (gnt == 2'b10) ? res_fifo_wr : 1'b0;

  assign m0_res_fifo_wdata = (gnt == 2'b01) ? res_fifo_wdata : 1'b0;
  assign m1_res_fifo_wdata = (gnt == 2'b10) ? res_fifo_wdata : 1'b0;

  //---------------------------------------------------------------------------
  // To take care of partial/stall data in response fifo
  // we are flushing the content
  //
  // WARNING: This will work well for burst size 4,
  // If User given 6 Word Burst and Read only one location
  // Read Path will hang waiting for Response FIFO to empty, User need to take
  // care of partial reading case.
  //---------------------------------------------------------------------------
  
  assign m0_res_fifo_flush   =  (gnt == 2'b01) ? res_fifo_flush : 1'b0;
  assign m1_res_fifo_flush   =  (gnt == 2'b10) ? res_fifo_flush : 1'b0;

  assign spi_clock_en =  tx_clk_en |  rx_clk_en;

  logic  fsm_flush;
  assign fsm_flush  =  (state == FSM_IDLE);

  spim_clkgen u_clkgen
  (
    .clk            ( clk                    ),
    .rstn           ( rstn                   ),
    .en             ( spi_clock_en           ),
    .cfg_sck_period ( spi_clk_div [5:0]      ),
    .spi_clk        ( spi_clk                ),
    .spi_fall       ( spi_fall               ),
    .spi_rise       ( spi_rise               )
  );
  spim_tx u_txreg
  (
    .clk            ( clk                    ),
    .rstn           ( rstn                   ),
    .flush          ( fsm_flush              ),
    .en             ( spi_en_tx              ),
    .tx_edge        ( spi_fall               ),
    .tx_done        ( tx_done                ),
    .sdo0           ( spi_sdo0               ),
    .sdo1           ( spi_sdo1               ),
    .sdo2           ( spi_sdo2               ),
    .sdo3           ( spi_sdo3               ),
    .en_quad_in     ( en_quad_in             ),
    .counter_in     ( counter_tx             ),
    .txdata         ( data_to_tx             ),
    .data_valid     ( data_to_tx_valid       ),
    .data_ready     ( tx_data_ready          ),
    .clk_en_o       ( tx_clk_en              )
  );
  spim_rx #(.ENDIEAN(ENDIEAN)) u_rxreg
  (
    .clk            ( clk                    ),
    .rstn           ( rstn                   ),
    .flush          ( fsm_flush              ),
    .en             ( spi_en_rx              ),
    .rx_edge        ( spi_rise               ),
    .rx_done        ( rx_done                ),
    .sdi0           ( spi_sdi0               ),
    .sdi1           ( spi_sdi1               ),
    .sdi2           ( spi_sdi2               ),
    .sdi3           ( spi_sdi3               ),
    .en_quad_in     ( en_quad_in             ),
    .counter_in     ( counter_rx             ),
    .counter_in_upd ( counter_rx_valid       ),
    .data           ( res_fifo_wdata         ),
    .data_valid     ( res_fifo_wr            ),
    .data_ready     ( !res_fifo_full         ),
    .clk_en_o       ( rx_clk_en              )
  );

  always_comb
  begin
      data_to_tx       =  'h0;
      data_to_tx_valid = 1'b0;

      case(ctrl_data_mux)
          DATA_NULL:
          begin
              data_to_tx       =  '0;
              data_to_tx_valid = 1'b0;
          end

          DATA_EMPTY:
          begin
              data_to_tx       =  '0;
              data_to_tx_valid = 1'b1;
          end

          DATA_CMD:
          begin
              data_to_tx       = {cmd_fifo_rdata[7:0],24'h0};
              data_to_tx_valid = ctrl_data_valid;
          end
          DATA_MODE:
          begin
              data_to_tx       = {spi_mode_cmd,24'h0};
              data_to_tx_valid = ctrl_data_valid;
          end

          DATA_ADDR:
          begin
              data_to_tx       = (cfg_addr_cnt == P_8BIT)  ? {cmd_fifo_rdata[7:0],24'h0}  :
		                 (cfg_addr_cnt == P_16BIT) ? {cmd_fifo_rdata[15:0],16'h0} :
		                 (cfg_addr_cnt == P_24BIT) ? {cmd_fifo_rdata[23:0],8'h0}  : {cmd_fifo_rdata[31:0]};
              data_to_tx_valid = ctrl_data_valid;
          end

	  // RISV is little endian, so data is converted to little endian format
          DATA_FIFO: begin
             data_to_tx     = (ENDIEAN) ? cmd_fifo_rdata[31:0] : 
		                 {cmd_fifo_rdata[7:0],cmd_fifo_rdata[15:8],cmd_fifo_rdata[23:16],cmd_fifo_rdata[31:24]};
             data_to_tx_valid  = !cmd_fifo_empty;
          end
      endcase
  end

  always_comb
  begin
    counter_tx         =  '0;
    counter_tx_valid   = 1'b0;
    counter_rx         =  '0;
    counter_rx_valid   = 1'b0;
    next_state         = state;
    ctrl_data_mux      = DATA_NULL;
    ctrl_data_valid    = 1'b0;
    spi_en_rx          = 1'b0;
    spi_en_tx          = 1'b0;
    spi_status         =  '0;
    cmd_fifo_rd        = 1'b0;
    res_fifo_flush     = 0;
    nxt_cnt            = cnt;
    case(state)
      FSM_IDLE:
      begin
        spi_status[0] = 1'b1;
	nxt_cnt    = 0;
	if(!m0_cmd_fifo_empty || !m1_cmd_fifo_empty )  begin
	   next_state  = FSM_CS_ASSERT;
        end
      end

      // Asserted CS# low
      FSM_CS_ASSERT: begin
	 if(cfg_cs_early == cnt) begin
	     next_state  = FSM_CMD_PHASE;
	 end else begin
             nxt_cnt = nxt_cnt+1;
	 end
      end

      // WAIT for COMMAND Phase Completed
      FSM_CMD_PHASE: begin
              counter_tx       = 8'h8;
              ctrl_data_mux    = DATA_CMD;
              ctrl_data_valid  = 1'b1;
              counter_tx       = 'd8;
              counter_tx_valid = 1'b1;
              spi_en_tx        = 1'b1;
	 if (tx_data_ready) begin
	      cmd_fifo_rd      = 1'b1;
	      case(cfg_spi_seq)
	      P_FSM_C:     next_state = FSM_TX_DONE;
	      P_FSM_CW:    next_state = FSM_WRITE_CMD;
	      P_FSM_CA:    next_state = FSM_ADR_PHASE;
	      P_FSM_CAR:   next_state = FSM_ADR_PHASE;
              P_FSM_CADR:  next_state = FSM_ADR_PHASE;
	      P_FSM_CAMR:  next_state = FSM_ADR_PHASE;
	      P_FSM_CAMDR: next_state = FSM_ADR_PHASE;
	      P_FSM_CAW:   next_state = FSM_ADR_PHASE;
	      P_FSM_CADW:  next_state = FSM_ADR_PHASE;
	      P_FSM_CDR:   next_state = FSM_DUMMY_PHASE;
	      P_FSM_CDW:   next_state = FSM_DUMMY_PHASE;
	      default  :   next_state = FSM_TX_DONE;
              endcase
	  end
      end

      // WAIT for ADDR Command Accepted
      FSM_ADR_PHASE: begin
          nxt_cnt          = 0;
          ctrl_data_mux    = DATA_ADDR;
          ctrl_data_valid  = 1'b1;
          counter_tx       =  (cfg_addr_cnt == P_8BIT) ? 'd8 :
	                      (cfg_addr_cnt == P_16BIT) ? 'd16 :
	                      (cfg_addr_cnt == P_24BIT) ? 'd24 : 'd20;
          counter_tx_valid = 1'b1;
          spi_en_tx        = 1'b1;
	  if (tx_data_ready) begin
              ctrl_data_valid  = 1'b0;
	      cmd_fifo_rd      = 1'b1;
	      case(cfg_spi_seq)
	      P_FSM_CA:    next_state = FSM_TX_DONE;
	      P_FSM_CAR:   next_state = FSM_READ_WAIT;
              P_FSM_CADR:  next_state = FSM_DUMMY_PHASE;
	      P_FSM_CAMR:  next_state = FSM_MODE_PHASE;
	      P_FSM_CAMDR: next_state = FSM_MODE_PHASE;
	      P_FSM_CAW:   next_state = FSM_WRITE_CMD;
	      P_FSM_CADW:  next_state = FSM_DUMMY_PHASE;
	      default  :   next_state = FSM_TX_DONE;
              endcase
           end
        end

      // WAIT for DUMMY command Accepted
      FSM_DUMMY_PHASE: begin
          nxt_cnt          = 0;
          ctrl_data_mux    = DATA_EMPTY;
          ctrl_data_valid  = 1'b1;
          counter_tx_valid = 1'b1;
          counter_tx       =  (cfg_dummy_cnt == P_8BIT) ? 'd8 :
	                      (cfg_dummy_cnt == P_16BIT) ? 'd16 :
	                      (cfg_dummy_cnt == P_24BIT) ? 'd24 : 'd20;
          spi_en_tx        = 1'b1;
	  if (tx_data_ready) begin
              ctrl_data_valid = 1'b0;
	      case(cfg_spi_seq)
              P_FSM_CADR:  next_state = FSM_READ_WAIT;
	      P_FSM_CAMDR: next_state = FSM_READ_WAIT;
	      P_FSM_CADW:  next_state = FSM_WRITE_CMD;
	      P_FSM_CDR:   next_state = FSM_READ_WAIT;
	      P_FSM_CDW:   next_state = FSM_WRITE_CMD;
	      default  :   next_state = FSM_CS_DEASEERT;
              endcase
           end
        end
      // WAIT for MODE command accepted
      FSM_MODE_PHASE: begin
          nxt_cnt          = 0;
          ctrl_data_mux    = DATA_MODE;
          ctrl_data_valid  = 1'b1;
          counter_tx_valid = 1'b1;
          counter_tx       = 'd8;
          spi_en_tx        = 1'b1;
	  if (tx_data_ready) begin
	      case(cfg_spi_seq)
	      P_FSM_CAMR:  next_state = FSM_READ_WAIT;
	      P_FSM_CAMDR: next_state = FSM_DUMMY_PHASE;
	      default  :   next_state = FSM_CS_DEASEERT;
              endcase
           end
        end

      // Wait for WRITE COMMAND ACCEPTED
      FSM_WRITE_CMD: begin
          nxt_cnt          = 0;
          ctrl_data_mux    = DATA_FIFO;
          ctrl_data_valid  = 1'b1;
          counter_tx_valid = 1'b1;
          counter_tx       = {5'b0,cfg_data_cnt[7:0],3'b000}; // Convert Byte to Bit Count
          spi_en_tx        = 1'b1;
	  if (tx_data_ready) begin
	      cmd_fifo_rd      = 1'b1;
	      next_state = FSM_WRITE_PHASE;
	   end
        end

      // Wait for ALL WRITE DATA ACCEPTED
      FSM_WRITE_PHASE: begin
          nxt_cnt          = 0;
          ctrl_data_mux    = DATA_FIFO;
          ctrl_data_valid  = 1'b1;
          spi_en_tx        = 1'b1;
	  if (tx_done) begin
	      next_state = FSM_CS_DEASEERT;
           end else if(tx_data_ready  && cmd_fifo_empty == 0) begin
	      // Once Current Data is accepted by TX FSM, check FIFO not empty
	      // and read next location
	      cmd_fifo_rd      = 1'b1;
	   end
        end

      // Wait for Previous TX Completeion
      FSM_READ_WAIT: begin
          spi_en_tx        = 1'b1;
	  if (tx_done) begin
              res_fifo_flush  = 1; // Flush any stall data in response fifo
	      next_state = FSM_READ_PHASE;
	  end
      end

      FSM_READ_PHASE: begin
          nxt_cnt          = 0;
          counter_rx_valid = 1'b1;
          counter_rx       = {5'b0,cfg_data_cnt[7:0],3'b000}; // Convert Byte to Bit Count
          spi_en_rx        = 1'b1;
	  if(!cmd_fifo_empty) begin
             // If you see new command request, then abort the current request
	      next_state = FSM_CS_DEASEERT;
	  end else begin
	     if (rx_done && spi_rise) begin
	         next_state = FSM_CS_DEASEERT;
             end 
	  end
        end

      // Wait for TX Done
      FSM_TX_DONE: begin
         spi_en_tx        = 1'b1;
	 if(tx_done) next_state  = FSM_CS_DEASEERT;
      end

      // De-assert CS#
      FSM_CS_DEASEERT: begin
	 if(cfg_cs_late == cnt) begin
	     next_state  = FSM_IDLE;
	 end else begin
             nxt_cnt = nxt_cnt+1;
	 end
      end
   endcase
end




  always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) begin
      state       <= FSM_IDLE;
      cnt         <= 'h0;
    end else begin
       state <= next_state;
       cnt   <= nxt_cnt;
    end
  end

  //---------------------------------------------------------------------
  //  Grant Generation Based on FIFO empty, priority given to Master 0
  //  Grant switch happens only at FSM IDLE State
  // ---------------------------------------------------------------------

  always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) begin
      gnt             <= 0;
      spi_mode_cmd    <= 'h0;
      cfg_spi_seq     <= 'h0;
      cfg_addr_cnt    <= 'h0;
      cfg_dummy_cnt   <= 'h0;
      cfg_data_cnt    <= 'h0;
    end else begin
       if(state == FSM_IDLE) begin
           if(!m0_cmd_fifo_empty) begin
              cfg_data_cnt    <= m0_cmd_fifo_rdata[31:24];
              cfg_dummy_cnt   <= m0_cmd_fifo_rdata[23:22];
              cfg_addr_cnt    <= m0_cmd_fifo_rdata[21:20];
              cfg_spi_seq     <= m0_cmd_fifo_rdata[19:16];
              spi_mode_cmd    <= m0_cmd_fifo_rdata[15:8];
              gnt             <= 2'b01;
           end
           else if(!m1_cmd_fifo_empty ) begin
              cfg_data_cnt    <= m1_cmd_fifo_rdata[31:24];
              cfg_dummy_cnt   <= m1_cmd_fifo_rdata[23:22];
              cfg_addr_cnt    <= m1_cmd_fifo_rdata[21:20];
              cfg_spi_seq     <= m1_cmd_fifo_rdata[19:16];
              spi_mode_cmd    <= m1_cmd_fifo_rdata[15:8];
              gnt             <= 2'b10;
           end
        end
      end
   end


  //-----------------------------------------------------------------------
  // SPI Mode Switch Control Logic
  // Note: SPI Protocl Start with SPI_STD Mode (Sigle Bit Mode) Base on the
  // Command, Type it Switch the mode at ADDRESS/DUMMY/DATA Phase
  // QIOR(0xEB) -> Mode switch at Address Phase
  // DIOR(0xBB) -> Mode Switch at Address Phase
  // QOR (0x6B) -> Mode Switch at Data Phase
  // DOR (0x3B) -> Mode Switch at Data Phase
  // QPP (0x32) -> Mode Switch at Data Phase 
  // ----------------------------------------------------------------------
  always @(posedge clk or negedge rstn) begin
     if (rstn == 1'b0) begin
        s_spi_mode <= SPI_STD;
     end else begin
	if(state == FSM_IDLE) begin // Reset the Mode at IDLE State
            s_spi_mode <= SPI_STD;
	end else if(state == FSM_ADR_PHASE && cfg_spi_switch == P_MODE_SWITCH_AT_ADDR) begin
            s_spi_mode <= cfg_spi_mode;
	end else if(state == FSM_DUMMY_PHASE && cfg_spi_switch == P_MODE_SWITCH_AT_DATA) begin
            s_spi_mode <= cfg_spi_mode;
	end
     end
  end

  // SPI Chip Select Logic
  always @(posedge clk or negedge rstn) begin
     if (rstn == 1'b0) begin
        spi_csn0 <= 1'b1;
        spi_csn1 <= 1'b1;
        spi_csn2 <= 1'b1;
        spi_csn3 <= 1'b1;
     end else begin
	if(state != FSM_IDLE) begin
           spi_csn0 <= ~cfg_cs_reg[0];
           spi_csn1 <= ~cfg_cs_reg[1];
           spi_csn2 <= ~cfg_cs_reg[2];
           spi_csn3 <= ~cfg_cs_reg[3];
	end else begin
           spi_csn0 <= 1'b1;
           spi_csn1 <= 1'b1;
           spi_csn2 <= 1'b1;
           spi_csn3 <= 1'b1;
	end
     end
  end

endmodule

