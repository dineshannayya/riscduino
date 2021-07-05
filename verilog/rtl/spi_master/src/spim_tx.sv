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

module spim_tx
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
    input  logic        en_quad_in,     // SPI quad mode indication
    input  logic [15:0] counter_in,     // Transmit counter
    input  logic [31:0] txdata,         // 32 bit tranmsit data
    input  logic        data_valid,     // Input data valid
    output logic        data_ready,     // Data in acepted, this for txfifo
    output logic        clk_en_o        // Enable Tx clock
);

  logic [31:0]          data_int       ; // Data Input
  logic [31:0]          data_int_next  ; // Next Data Input
  logic [15:0]          counter        ; // Tx Counter
  logic [15:0]          counter_next   ; // tx next counter
  logic [15:0]          counter_trgt   ; // counter exit counter
  logic                 tx32b_done     ;  // 32 bit Transmit done
  logic                 en_quad;
  logic                 en_quad_next;

  logic                 data_ready_i;     // Data in acepted, this for txfifo
  enum logic [0:0] { IDLE, TRANSMIT } tx_CS, tx_NS;


  // Indicate 32 bit data done, usefull for readining next 32b from txfifo
  assign tx32b_done  = (!en_quad && (counter[4:0] == 5'b11111)) || (en_quad && (counter[2:0] == 3'b111));

  assign tx_done    = (counter == (counter_trgt-1)) && (tx_CS == TRANSMIT);

  assign   clk_en_o  = (tx_NS == TRANSMIT);

  always_comb
  begin
    tx_NS         = tx_CS;
    data_int_next = data_int;
    data_ready_i    = 1'b0;
    counter_next  = counter;
    en_quad_next  =  en_quad;

    case (tx_CS)
      IDLE: begin
        data_int_next = txdata;
        counter_next  = '0;

        if (en && data_valid) begin
	  en_quad_next    = en_quad_in;
          data_ready_i    = 1'b1;
          tx_NS         = TRANSMIT;
        end
      end

      TRANSMIT: begin
         if ((counter + 1) ==counter_trgt) begin
               counter_next = 0;
               // Check if there is next data
               if (en && data_valid) begin 
	         en_quad_next    = en_quad_in;
                 data_int_next = txdata;
                 data_ready_i    = 1'b1;
                 tx_NS         = TRANSMIT;
               end else begin
                 tx_NS    = IDLE;
               end
         end else if (tx32b_done) begin
               if (en && data_valid) begin
	         en_quad_next    = en_quad_in;
                 data_int_next = txdata;
                 data_ready_i    = 1'b1;
                 tx_NS         = TRANSMIT;
               end else begin
                 tx_NS    = IDLE;
               end
           end else begin
              counter_next = counter + 1;
              data_int_next = (en_quad) ? {data_int[27:0],4'b0000} : {data_int[30:0],1'b0};
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
      en_quad      <= 0;
      sdo0         <= '0;
      sdo1         <= '0;
      sdo2         <= '1;
      sdo3         <= '1;
      counter_trgt <= '0;
      data_ready   <= '0;
      data_ready_f <= 0;
    end
    else if(flush) begin
       counter      <= 0;
       data_int     <= 'h0;
       tx_CS        <= IDLE;
       en_quad      <= 0;
       sdo0         <= '0;
       sdo1         <= '0;
       sdo2         <= '1;
       sdo3         <= '1;
       counter_trgt <= '0;
       data_ready   <= '0;
       data_ready_f <= 0;
    end else begin
       data_ready_f <= data_ready_i;
       data_ready   <= data_ready_f && !data_ready_i; // Generate Pulse at falling edge
       if(tx_edge) begin
          tx_CS        <= tx_NS;
          counter      <= counter_next;
          data_int     <= data_int_next;
       end
       // Counter Exit condition, quad mode div-4 , else actual counter
       if (en && data_ready_i && tx_edge) begin
	  en_quad      <= en_quad_in;
          counter_trgt <= (en_quad_in) ? {2'b00,counter_in[15:2]} : counter_in;
       end
       if(tx_edge && tx_NS == TRANSMIT) begin
          sdo0         <= (en_quad_next) ? data_int_next[28] : data_int_next[31];
          sdo1         <= (en_quad_next) ? data_int_next[29] : 1'b0;
          sdo2         <= (en_quad_next) ? data_int_next[30] : 1'b1; // Protect
          sdo3         <= (en_quad_next) ? data_int_next[31] : 1'b1; // Hold need to '1'
       end
    end      
  end
endmodule
