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
////  OMS8051 I2C Master bit-controller Module                    ////
////  WISHBONE rev.B2 compliant I2C Master bit-controller         ////
////                                                              ////
////  This file is part of the OMS 8051 cores project             ////
////  http://www.opencores.org/cores/oms8051mini/                 ////
////                                                              ////
////  Description                                                 ////
////  OMS 8051 definitions.                                       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      -Richard Herveille ,  richard@asics.ws, www.asics.ws    ////
////      -Dinesh Annayya, dinesha@opencores.org                  ////
////                                                              ////
////  Revision : Jan 6, 2017                                      //// 
////                                                              ////
//////////////////////////////////////////////////////////////////////
//     v0.0 - Dinesh A, 6th Jan 2017
//          1. Initail version picked from
//              http://www.opencores.org/projects/i2c/
//     v0.1 - Dinesh A, 19th Jan 2017
//          1. Lint warning clean up
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
/////////////////////////////////////
// Bit controller section
/////////////////////////////////////
//
// Translate simple commands into SCL/SDA transitions
// Each command has 5 states, A/B/C/D/idle
//
// start:	SCL	~~~~~~~~~~\____
//	SDA	~~~~~~~~\______
//		 x | A | B | C | D | i
//
// repstart	SCL	____/~~~~\___
//	SDA	__/~~~\______
//		 x | A | B | C | D | i
//
// stop	SCL	____/~~~~~~~~
//	SDA	==\____/~~~~~
//		 x | A | B | C | D | i
//
//- write	SCL	____/~~~~\____
//	SDA	==X=========X=
//		 x | A | B | C | D | i
//
//- read	SCL	____/~~~~\____
//	SDA	XXXX=====XXXX
//		 x | A | B | C | D | i
//

// Timing:     Normal mode      Fast mode
///////////////////////////////////////////////////////////////////////
// Fscl        100KHz           400KHz
// Th_scl      4.0us            0.6us   High period of SCL
// Tl_scl      4.7us            1.3us   Low period of SCL
// Tsu:sta     4.7us            0.6us   setup time for a repeated start condition
// Tsu:sto     4.0us            0.6us   setup time for a stop conditon
// Tbuf        4.7us            1.3us   Bus free time between a stop and start condition
//


`include "i2cm_defines.v"

module i2cm_bit_ctrl (
    input             clk,      // system clock
    input             sresetn,  // synchronous active low reset
    input             aresetn,  // asynchronous active low reset
    input             ena,      // core enable signal

    input      [15:0] clk_cnt,  // clock prescale value

    input      [ 3:0] cmd,      // command (from byte controller)
    output reg        cmd_ack,  // command complete acknowledge
    output reg        busy,     // i2c bus busy
    output reg        al,       // i2c bus arbitration lost

    input             din,
    output reg        dout,

    input             scl_i,    // i2c clock line input
    output            scl_o,    // i2c clock line output
    output reg        scl_oen,  // i2c clock line output enable (active low)
    input             sda_i,    // i2c data line input
    output            sda_o,    // i2c data line output
    output reg        sda_oen   // i2c data line output enable (active low)
);


    //
    // variable declarations
    //

    reg [ 1:0] cSCL, cSDA;      // capture SCL and SDA
    reg [ 2:0] fSCL, fSDA;      // SCL and SDA filter inputs
    reg        sSCL, sSDA;      // filtered and synchronized SCL and SDA inputs
    reg        dSCL, dSDA;      // delayed versions of sSCL and sSDA
    reg        dscl_oen;        // delayed scl_oen
    reg        sda_chk;         // check SDA output (Multi-master arbitration)
    reg        clk_en;          // clock generation signals
    reg        slave_wait;      // slave inserts wait states
    reg [15:0] cnt;             // clock divider counter (synthesis)
    reg [13:0] filter_cnt;      // clock divider for filter


    // state machine variable
    reg [17:0] c_state; // synopsys enum_state

    //
    // module body
    //

    // whenever the slave is not ready it can delay the cycle by pulling SCL low
    // delay scl_oen
    always @(posedge clk)
      dscl_oen <= scl_oen;

    // slave_wait is asserted when master wants to drive SCL high, but the slave pulls it low
    // slave_wait remains asserted until the slave releases SCL
    always @(posedge clk or negedge aresetn)
      if (!aresetn) slave_wait <= 1'b0;
      else         slave_wait <= (scl_oen & ~dscl_oen & ~sSCL) | (slave_wait & ~sSCL);

    // master drives SCL high, but another master pulls it low
    // master start counting down its low cycle now (clock synchronization)
    wire scl_sync   = dSCL & ~sSCL & scl_oen;


    // generate clk enable signal
    always @(posedge clk or negedge aresetn)
      if (~aresetn)
      begin
          cnt    <= 16'h0;
          clk_en <= 1'b1;
      end
      else if (!sresetn || ~|cnt || !ena || scl_sync)
      begin
          cnt    <= clk_cnt;
          clk_en <= 1'b1;
      end
      else if (slave_wait)
      begin
          cnt    <= cnt;
          clk_en <= 1'b0;    
      end
      else
      begin
          cnt    <= cnt - 16'h1;
          clk_en <= 1'b0;
      end


    // generate bus status controller

    // capture SDA and SCL
    // reduce metastability risk
    always @(posedge clk or negedge aresetn)
      if (!aresetn)
      begin
          cSCL <= 2'b00;
          cSDA <= 2'b00;
      end
      else if (!sresetn)
      begin
          cSCL <= 2'b00;
          cSDA <= 2'b00;
      end
      else
      begin
          cSCL <= {cSCL[0],scl_i};
          cSDA <= {cSDA[0],sda_i};
      end


    // filter SCL and SDA signals; (attempt to) remove glitches
    always @(posedge clk or negedge aresetn)
      if      (!aresetn     ) filter_cnt <= 14'h0;
      else if (!sresetn || !ena ) filter_cnt <= 14'h0;
      else if (~|filter_cnt) filter_cnt <= clk_cnt >> 2; //16x I2C bus frequency
      else                   filter_cnt <= filter_cnt -1;


    always @(posedge clk or negedge aresetn)
      if (!aresetn)
      begin
          fSCL <= 3'b111;
          fSDA <= 3'b111;
      end
      else if (!sresetn)
      begin
          fSCL <= 3'b111;
          fSDA <= 3'b111;
      end
      else if (~|filter_cnt)
      begin
          fSCL <= {fSCL[1:0],cSCL[1]};
          fSDA <= {fSDA[1:0],cSDA[1]};
      end


    // generate filtered SCL and SDA signals
    always @(posedge clk or negedge aresetn)
      if (~aresetn)
      begin
          sSCL <= 1'b1;
          sSDA <= 1'b1;

          dSCL <= 1'b1;
          dSDA <= 1'b1;
      end
      else if (!sresetn)
      begin
          sSCL <= 1'b1;
          sSDA <= 1'b1;

          dSCL <= 1'b1;
          dSDA <= 1'b1;
      end
      else
      begin
          sSCL <= &fSCL[2:1] | &fSCL[1:0] | (fSCL[2] & fSCL[0]);
          sSDA <= &fSDA[2:1] | &fSDA[1:0] | (fSDA[2] & fSDA[0]);

          dSCL <= sSCL;
          dSDA <= sSDA;
      end

    // detect start condition => detect falling edge on SDA while SCL is high
    // detect stop condition => detect rising edge on SDA while SCL is high
    reg sta_condition;
    reg sto_condition;
    always @(posedge clk or negedge aresetn)
      if (~aresetn)
      begin
          sta_condition <= 1'b0;
          sto_condition <= 1'b0;
      end
      else if (!sresetn)
      begin
          sta_condition <= 1'b0;
          sto_condition <= 1'b0;
      end
      else
      begin
          sta_condition <= ~sSDA &  dSDA & sSCL;
          sto_condition <=  sSDA & ~dSDA & sSCL;
      end


    // generate i2c bus busy signal
    always @(posedge clk or negedge aresetn)
      if      (!aresetn) busy <= 1'b0;
      else if (!sresetn    ) busy <= 1'b0;
      else              busy <= (sta_condition | busy) & ~sto_condition;


    // generate arbitration lost signal
    // aribitration lost when:
    // 1) master drives SDA high, but the i2c bus is low
    // 2) stop detected while not requested
    reg cmd_stop;
    always @(posedge clk or negedge aresetn)
      if (~aresetn)
          cmd_stop <= 1'b0;
      else if (!sresetn)
          cmd_stop <= 1'b0;
      else if (clk_en)
          cmd_stop <= cmd == `I2C_CMD_STOP;

    always @(posedge clk or negedge aresetn)
      if (~aresetn)
          al <= 1'b0;
      else if (!sresetn)
          al <= 1'b0;
      else
          al <= (sda_chk & ~sSDA & sda_oen) | (|c_state & sto_condition & ~cmd_stop);


    // generate dout signal (store SDA on rising edge of SCL)
    always @(posedge clk)
      if (sSCL & ~dSCL) dout <= sSDA;


    // generate statemachine

    // nxt_state decoder
    parameter [17:0] idle    = 18'b0_0000_0000_0000_0000;
    parameter [17:0] start_a = 18'b0_0000_0000_0000_0001;
    parameter [17:0] start_b = 18'b0_0000_0000_0000_0010;
    parameter [17:0] start_c = 18'b0_0000_0000_0000_0100;
    parameter [17:0] start_d = 18'b0_0000_0000_0000_1000;
    parameter [17:0] start_e = 18'b0_0000_0000_0001_0000;
    parameter [17:0] stop_a  = 18'b0_0000_0000_0010_0000;
    parameter [17:0] stop_b  = 18'b0_0000_0000_0100_0000;
    parameter [17:0] stop_c  = 18'b0_0000_0000_1000_0000;
    parameter [17:0] stop_d  = 18'b0_0000_0001_0000_0000;
    parameter [17:0] rd_a    = 18'b0_0000_0010_0000_0000;
    parameter [17:0] rd_b    = 18'b0_0000_0100_0000_0000;
    parameter [17:0] rd_c    = 18'b0_0000_1000_0000_0000;
    parameter [17:0] rd_d    = 18'b0_0001_0000_0000_0000;
    parameter [17:0] wr_a    = 18'b0_0010_0000_0000_0000;
    parameter [17:0] wr_b    = 18'b0_0100_0000_0000_0000;
    parameter [17:0] wr_c    = 18'b0_1000_0000_0000_0000;
    parameter [17:0] wr_d    = 18'b1_0000_0000_0000_0000;

    always @(posedge clk or negedge aresetn)
      if (!aresetn)
      begin
          c_state <= idle;
          cmd_ack <= 1'b0;
          scl_oen <= 1'b1;
          sda_oen <= 1'b1;
          sda_chk <= 1'b0;
      end
      else if (!sresetn | al)
      begin
          c_state <= idle;
          cmd_ack <= 1'b0;
          scl_oen <= 1'b1;
          sda_oen <= 1'b1;
          sda_chk <= 1'b0;
      end
      else
      begin
          cmd_ack   <= 1'b0; // default no command acknowledge + assert cmd_ack only 1clk cycle

          if (clk_en)
              case (c_state) // synopsys full_case parallel_case
                    // idle state
                    idle:
                    begin
                        case (cmd) // synopsys full_case parallel_case
                             `I2C_CMD_START: c_state <= start_a;
                             `I2C_CMD_STOP:  c_state <= stop_a;
                             `I2C_CMD_WRITE: c_state <= wr_a;
                             `I2C_CMD_READ:  c_state <= rd_a;
                             default:        c_state <= idle;
                        endcase

                        scl_oen <= scl_oen; // keep SCL in same state
                        sda_oen <= sda_oen; // keep SDA in same state
                        sda_chk <= 1'b0;    // don't check SDA output
                    end

                    // start
                    start_a:
                    begin
                        c_state <= start_b;
                        scl_oen <= scl_oen; // keep SCL in same state
                        sda_oen <= 1'b1;    // set SDA high
                        sda_chk <= 1'b0;    // don't check SDA output
                    end

                    start_b:
                    begin
                        c_state <= start_c;
                        scl_oen <= 1'b1; // set SCL high
                        sda_oen <= 1'b1; // keep SDA high
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    start_c:
                    begin
                        c_state <= start_d;
                        scl_oen <= 1'b1; // keep SCL high
                        sda_oen <= 1'b0; // set SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    start_d:
                    begin
                        c_state <= start_e;
                        scl_oen <= 1'b1; // keep SCL high
                        sda_oen <= 1'b0; // keep SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    start_e:
                    begin
                        c_state <= idle;
                        cmd_ack <= 1'b1;
                        scl_oen <= 1'b0; // set SCL low
                        sda_oen <= 1'b0; // keep SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    // stop
                    stop_a:
                    begin
                        c_state <= stop_b;
                        scl_oen <= 1'b0; // keep SCL low
                        sda_oen <= 1'b0; // set SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    stop_b:
                    begin
                        c_state <= stop_c;
                        scl_oen <= 1'b1; // set SCL high
                        sda_oen <= 1'b0; // keep SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    stop_c:
                    begin
                        c_state <= stop_d;
                        scl_oen <= 1'b1; // keep SCL high
                        sda_oen <= 1'b0; // keep SDA low
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    stop_d:
                    begin
                        c_state <= idle;
                        cmd_ack <= 1'b1;
                        scl_oen <= 1'b1; // keep SCL high
                        sda_oen <= 1'b1; // set SDA high
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    // read
                    rd_a:
                    begin
                        c_state <= rd_b;
                        scl_oen <= 1'b0; // keep SCL low
                        sda_oen <= 1'b1; // tri-state SDA
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    rd_b:
                    begin
                        c_state <= rd_c;
                        scl_oen <= 1'b1; // set SCL high
                        sda_oen <= 1'b1; // keep SDA tri-stated
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    rd_c:
                    begin
                        c_state <= rd_d;
                        scl_oen <= 1'b1; // keep SCL high
                        sda_oen <= 1'b1; // keep SDA tri-stated
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    rd_d:
                    begin
                        c_state <= idle;
                        cmd_ack <= 1'b1;
                        scl_oen <= 1'b0; // set SCL low
                        sda_oen <= 1'b1; // keep SDA tri-stated
                        sda_chk <= 1'b0; // don't check SDA output
                    end

                    // write
                    wr_a:
                    begin
                        c_state <= wr_b;
                        scl_oen <= 1'b0; // keep SCL low
                        sda_oen <= din;  // set SDA
                        sda_chk <= 1'b0; // don't check SDA output (SCL low)
                    end

                    wr_b:
                    begin
                        c_state <= wr_c;
                        scl_oen <= 1'b1; // set SCL high
                        sda_oen <= din;  // keep SDA
                        sda_chk <= 1'b0; // don't check SDA output yet
                                            // allow some time for SDA and SCL to settle
                    end

                    wr_c:
                    begin
                        c_state <= wr_d;
                        scl_oen <= 1'b1; // keep SCL high
                        sda_oen <= din;
                        sda_chk <= 1'b1; // check SDA output
                    end

                    wr_d:
                    begin
                        c_state <= idle;
                        cmd_ack <= 1'b1;
                        scl_oen <= 1'b0; // set SCL low
                        sda_oen <= din;
                        sda_chk <= 1'b0; // don't check SDA output (SCL low)
                    end

              endcase
      end


    // assign scl and sda output (always gnd)
    assign scl_o = 1'b0;
    assign sda_o = 1'b0;

endmodule
