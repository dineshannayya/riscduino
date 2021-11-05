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
////  SPI TX  Module                                              ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////    This is SPI Master Transmit Word control logic.           ////
////    This logic transmit data upto 32 bit in bit or Quad spi   ////
////    mode                                                      ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision:                                                   ////
////       0.1 - 16th Feb 2021, Dinesh A                          ////
////             Initial version                                  ////
////       0.2 - 24th Mar 2021, Dinesh A                          ////
////             1. Comments are added                            ////
////             2. RTL clean-up done and the output are registred////
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

module qspim_tx
(
    // General Input
    input  logic        clk,            // SPI clock
    input  logic        rstn,           // Active low Reset
    input  logic        flush,          // init the state
    input  logic        en,             // Transmit Enable
    input  logic        tx_edge,        // Transmiting Edge
    output logic        tx_done,        // Transmission completion
    output logic        sdo0,           // SPI Dout0
    output logic        sdo1,           // SPI Dout1
    output logic        sdo2,           // SPI Dout2
    output logic        sdo3,           // SPI Dout3
    input  logic [1:0]  s_spi_mode,     // SPI quad mode indication
    input  logic [15:0] counter_in,     // Transmit counter
    input  logic        counter_in_upd,
    input  logic [31:0] txdata,         // 32 bit tranmsit data
    input  logic        dummy_phase,    // dummy data
    input  logic        data_valid,     // Input data valid
    output logic        data_ready,     // Data in acepted, this for txfifo
    output logic        spi_dummy,      // spi dummy phase
    output logic        clk_en_o        // Enable Tx clock
);

//------------------------------------------------------
// Parameter Decleration
// -----------------------------------------------------
  parameter P_SINGLE = 2'b00;
  parameter P_DOUBLE = 2'b01;
  parameter P_QUAD   = 2'b10;
  parameter P_QDDR   = 2'b11;

//------------------------------------------------------
// Variable Decleration
// -----------------------------------------------------
  logic [31:0]          data_int       ; // Data Input
  logic [31:0]          data_int_next  ; // Next Data Input
  logic [15:0]          counter        ; // Tx Counter
  logic [15:0]          counter_next   ; // tx next counter
  logic [15:0]          counter_trgt   ; // counter exit counter
  logic                 tx32b_done     ;  // 32 bit Transmit done
  logic  [1:0]          spi_mode     ;
  logic  [1:0]          spi_mode_next;

  logic                 data_ready_i;     // Data in acepted, this for txfifo
  logic                 next_data_ready_i;// Data in acepted, this for txfifo
  enum logic [1:0] { IDLE, TRANSMIT,WAIT_FIFO_AVAIL } tx_CS, tx_NS;


  // Indicate 32 bit data done, usefull for readining next 32b from txfifo
  assign tx32b_done  = (spi_mode == P_SINGLE  && (counter[4:0] == 5'b11111)) || 
                       (spi_mode == P_DOUBLE  && (counter[3:0] == 4'b1111)) || 
	               (spi_mode == P_QUAD    && (counter[2:0] == 3'b111))   ||
	               (spi_mode == P_QDDR    && (counter[2:0] == 3'b111));

  assign tx_done    = (counter == (counter_trgt-1)) && (tx_CS == TRANSMIT);

  assign   clk_en_o  = (tx_NS == TRANSMIT);

  always_comb
  begin
    tx_NS         = tx_CS;
    data_int_next = data_int;
    data_ready_i    = 1'b0;
    next_data_ready_i    = 1'b0;
    counter_next  = counter;
    spi_mode_next  =  spi_mode;

    case (tx_CS)
      IDLE: begin
        data_int_next = txdata;
        counter_next  = '0;

        if (en && data_valid && tx_edge) begin
	  spi_mode_next    = s_spi_mode;
          data_ready_i    = 1'b1;
          tx_NS         = TRANSMIT;
        end
      end

      TRANSMIT: begin
         if ((counter + 1) ==counter_trgt) begin
               counter_next = 0;
               // Check if there is next data
               if (en && data_valid && tx_edge) begin 
	         spi_mode_next    = s_spi_mode;
                 data_int_next = txdata;
                 data_ready_i    = 1'b1;
                 tx_NS         = TRANSMIT;
               end else begin
                 tx_NS    = IDLE;
               end
         end else if (tx32b_done) begin
               if (en && (spi_dummy || data_valid) && tx_edge) begin
	         spi_mode_next    = s_spi_mode;
                 data_int_next = txdata;
                 next_data_ready_i    = 1'b1;
                 counter_next = counter + 1;
                 tx_NS         = TRANSMIT;
               end else begin
                 tx_NS    = WAIT_FIFO_AVAIL;
               end
           end else begin
              counter_next = counter + 1;
              data_int_next = (spi_mode == P_QDDR   ) ? {data_int[27:0],4'b0000} :
		              (spi_mode == P_QUAD   ) ? {data_int[27:0],4'b0000} : 
		              (spi_mode == P_DOUBLE ) ? {data_int[29:0],2'b00} : {data_int[30:0],1'b0};
           end
      end
      WAIT_FIFO_AVAIL: begin
           if (en && data_valid && tx_edge) begin 
	     spi_mode_next    = s_spi_mode;
             data_int_next = txdata;
             data_ready_i    = 1'b1;
             tx_NS         = TRANSMIT;
           end 
        end
    endcase
  end

  logic data_ready_f;

  always_ff @(posedge clk, negedge rstn)
  begin
    if (~rstn)
    begin
      counter      <= 0;
      data_int     <= 'h0;
      tx_CS        <= IDLE;
      sdo0         <= '0;
      sdo1         <= '0;
      sdo2         <= '1;
      sdo3         <= '1;
      counter_trgt <= '0;
      data_ready   <= '0;
      data_ready_f <= 0;
      spi_dummy    <= 0;
      spi_mode     <= P_SINGLE;
    end
    else if(flush && tx_edge) begin
       counter      <= 0;
       data_int     <= 'h0;
       tx_CS        <= IDLE;
       sdo0         <= '0;
       sdo1         <= '0;
       sdo2         <= '1;
       sdo3         <= '1;
       counter_trgt <= '0;
       data_ready   <= '0;
       data_ready_f <= 0;
       spi_dummy     <= dummy_phase;
      spi_mode     <= P_SINGLE;
    end else begin
       data_ready_f <= data_ready_i | next_data_ready_i;
       data_ready   <= data_ready_f && !(data_ready_i | next_data_ready_i); // Generate Pulse at falling edge
       if(tx_edge || (spi_mode_next == P_QDDR)) begin
          tx_CS        <= tx_NS;
          counter      <= counter_next;
          data_int     <= data_int_next;
       end
       // Counter Exit condition, quad mode div-4 , else actual counter
       if (en && data_ready_i && tx_edge) begin
	  spi_mode      <= s_spi_mode;
	  spi_dummy     <= dummy_phase;
          counter_trgt <= (s_spi_mode == P_QDDR )   ? {2'b00,counter_in[15:2]} : 
		          (s_spi_mode == P_QUAD )   ? {2'b00,counter_in[15:2]} : 
		          (s_spi_mode == P_DOUBLE ) ? {1'b0, counter_in[15:1]} :    counter_in;
       end else if (en == 0) begin
	  spi_dummy     <= '0;
       end
       if((tx_edge || (spi_mode_next == P_QDDR)) && tx_NS == TRANSMIT) begin
          sdo0         <= ((spi_mode_next == P_QUAD) || (spi_mode_next == P_QDDR))? data_int_next[28] : (spi_mode_next == P_DOUBLE) ? data_int_next[30] : data_int_next[31];
          sdo1         <= ((spi_mode_next == P_QUAD) || (spi_mode_next == P_QDDR))? data_int_next[29] : (spi_mode_next == P_DOUBLE) ? data_int_next[31] :  1'b0;
          sdo2         <= ((spi_mode_next == P_QUAD) || (spi_mode_next == P_QDDR))? data_int_next[30] : 1'b1; // Protect
          sdo3         <= ((spi_mode_next == P_QUAD) || (spi_mode_next == P_QDDR))? data_int_next[31] : 1'b1; // Hold need to '1'
       end
    end      
  end
endmodule
