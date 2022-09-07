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
////  SPI Interface                                               ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description : This module contains SPI interface            ////
////                 state machine                                ////
////                                                              ////   
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com              ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 20th July 2022, Dinesh A                            ////
////          Initial version                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
/*********************************************************************
   CMD Decoding [7:0]
             [7:4] = 4'b1 - READ  REGISTER
                   = 4'b2 - WRITE REGISTER
             [3:0] = Byte Enable valid only during Write Command
*********************************************************************/

module sspis_if (

	     input  logic         sys_clk         ,
	     input  logic         rst_n           ,

             input  logic         sclk            ,
             input  logic         ssn             ,
             input  logic         sdin            ,
             output logic         sdout           ,
             output logic         sdout_oen       ,

             //spi_sm Interface
             output logic         reg_wr          , // write request
             output logic         reg_rd          , // read request
             output logic [31:0]  reg_addr        , // address
             output logic  [3:0]  reg_be          , // Byte enable
             output logic [31:0]  reg_wdata       , // write data
             input  logic [31:0]  reg_rdata       , // read data
             input  logic         reg_ack           // read valid
             );


//--------------------------------------------------------
// Wire and reg definitions
// -------------------------------------------------------

reg  [5:0]     bitcnt           ;
reg  [7:0]     cmd_reg          ;
reg  [31:0]    RegSdOut         ;
reg [2:0]      spi_if_st        ;

parameter    idle_st    = 3'b000,
             cmd_st     = 3'b001,
             adr_st     = 3'b010,
             wr_st      = 3'b011,
             wwait_st   = 3'b100,
             rwait_st   = 3'b101,
             rd_st      = 3'b110;

parameter READ_CMD      = 4'h1,
	  WRITE_CMD     = 4'h2;
    

wire adr_phase     = (spi_if_st == adr_st);
wire cmd_phase     = (spi_if_st == cmd_st);
wire wr_phase      = (spi_if_st == wr_st);
wire rd_phase      = (spi_if_st == rd_st);
wire cnt_phase     = (spi_if_st != wwait_st) && (spi_if_st != rwait_st);
wire wwait_phase   = (spi_if_st == wwait_st);
wire rwait_phase   = (spi_if_st == rwait_st);




// sclk pos and ned edge generation
logic     sck_l0,sck_l1,sck_l2;

wire sck_pdetect = (!sck_l2 && sck_l1) ? 1'b1: 1'b0;
wire sck_ndetect = (sck_l2 && !sck_l1) ? 1'b1: 1'b0;

always @ (posedge sys_clk or negedge rst_n) begin
if (!rst_n) begin
      sck_l0 <= 1'b1;
      sck_l1 <= 1'b1;
      sck_l2 <= 1'b1;
   end
   else begin
      sck_l0 <= sclk;
      sck_l1 <= sck_l0; // double sync
      sck_l2 <= sck_l1;
   end
end

// SSN double sync
logic     ssn_l0,ssn_l1, ssn_ss;

assign ssn_ss = ssn_l1;

always @ (posedge sys_clk or negedge rst_n) begin
if (!rst_n) begin
      ssn_l0 <= 1'b1;
      ssn_l1 <= 1'b1;
   end
   else begin
      ssn_l0 <= ssn;
      ssn_l1 <= ssn_l0; // double sync
   end
end


//command register accumation
assign reg_be = cmd_reg[3:0];

always @(negedge rst_n or posedge sys_clk)
begin
  if (!rst_n)
     cmd_reg[7:0] <= 8'b0;
  else if (cmd_phase & (sck_pdetect))
     cmd_reg[7:0] <= {cmd_reg[6:0], sdin};
end


// address accumation at posedge sclk
always @(negedge rst_n or posedge sys_clk)
begin
  if (!rst_n)
     reg_addr[31:0] <= 32'b0;
  else if (adr_phase & (sck_pdetect))
     reg_addr[31:0] <= {reg_addr[30:0], sdin};
end 

// write data accumation at posedge sclk
always @(negedge rst_n or posedge sys_clk)
begin
  if (!rst_n)
     reg_wdata[31:0] <= 32'b0;
  else if (wr_phase & (sck_pdetect))
     reg_wdata[31:0] <= {reg_wdata[30:0], sdin};
end



// drive sdout at negedge sclk 
always @(negedge rst_n or posedge sys_clk)
begin
  if (!rst_n) begin
     RegSdOut[31:0] <= 32'b0;
     sdout          <= 1'b0;
  end else begin
      if (reg_ack)
          RegSdOut <= reg_rdata[31:0];
      else if (rd_phase && sck_ndetect)
          RegSdOut <= {RegSdOut[30:0], 1'b0};

     sdout <= (rd_phase && sck_ndetect) ? RegSdOut[31] : sdout;
   end
end


// SPI State Machine
always @(negedge rst_n or posedge sys_clk)
begin
   if (!rst_n) begin
            reg_wr       <= 1'b0;
            reg_rd       <= 1'b0;
            sdout_oen    <= 1'b1;
            bitcnt       <= 6'b0;
            spi_if_st    <= idle_st;
   end else if(ssn_ss)    begin
            reg_wr       <= 1'b0;
            reg_rd       <= 1'b0;
            sdout_oen    <= 1'b1;
            bitcnt       <= 6'b0;
	    spi_if_st    <= idle_st; 
   end else begin
       case (spi_if_st)
          idle_st  : begin // Idle State
             reg_wr       <= 1'b0;
             reg_rd       <= 1'b0;
             sdout_oen    <= 1'b1;
             bitcnt       <= 6'b0;
             if (ssn_ss == 1'b0) begin
                spi_if_st <= cmd_st;
             end 
          end

          cmd_st : begin // Command State
             if (ssn_ss == 1'b1) begin
                spi_if_st <= idle_st;
            end else if (sck_pdetect) begin
                if(bitcnt   == 6'b000111)  begin
                     bitcnt     <= 6'b0;
                  spi_if_st  <= adr_st;
                end else begin
                    bitcnt       <= bitcnt  +1;
                end
             end
           end

          adr_st : begin // Address Phase
             reg_wr       <= 1'b0;
             reg_rd       <= 1'b0;
             sdout_oen    <= 1'b1;
             if (ssn_ss == 1'b1) begin
                spi_if_st <= idle_st;
             end else if (sck_pdetect) begin
                if (bitcnt   == 6'b011111) begin
                   bitcnt    <= 6'b0;
                   if(cmd_reg[7:4] == READ_CMD)      begin
         	      spi_if_st <= rwait_st;
                       reg_rd    <= 1'b1;
                   end else if(cmd_reg[7:4] == WRITE_CMD) begin
         	      spi_if_st <= wr_st;
                   end else begin
                       spi_if_st <= cmd_st;
                   end
                end else begin
                    bitcnt       <= bitcnt  +1;
                end
             end
          end

          wr_st   : begin // Write State
             if (ssn_ss == 1'b1) begin
                spi_if_st <= idle_st;
             end else if (sck_pdetect) begin
                if (bitcnt   == 6'b011111) begin
                   bitcnt     <= 6'b0;
                   spi_if_st  <= wwait_st;
                   reg_wr     <= 1;
                end else begin
                   bitcnt     <= bitcnt  +1;
                end
             end
          end
          wwait_st  : begin // Register Bus Busy Check State
	     if(reg_ack) reg_wr       <= 0;
             if (ssn_ss == 1'b1) begin
                spi_if_st <= idle_st;
             end else if (sck_pdetect) begin
                if (bitcnt   == 6'b000111) begin
                   bitcnt       <= 6'b0;
                   spi_if_st    <= cmd_st;
                end else begin
                   bitcnt       <= bitcnt  +1;
                end
             end
          end

          rwait_st  : begin // Read Wait State
             if(reg_ack) reg_rd     <= 1'b0;
             if (ssn_ss == 1'b1) begin
                spi_if_st <= idle_st;
             end else if (sck_pdetect) begin
                if (bitcnt   == 6'b000111) begin
                   reg_rd     <= 1'b0;
                   bitcnt     <= 6'b0;
                   sdout_oen  <= 1'b0;
                   spi_if_st  <= rd_st;
                end else begin
                   bitcnt     <= bitcnt  +1;
                end
             end
          end

          rd_st : begin // Send Data to SPI 
             if (ssn_ss == 1'b1) begin
                spi_if_st <= idle_st;
             end else if (sck_pdetect) begin
                if (bitcnt   == 6'b011111) begin
                   bitcnt     <= 6'b0;
                   sdout_oen  <= 1'b1;
                   spi_if_st  <= cmd_st;
                end else begin
                   bitcnt       <= bitcnt  +1;
                end
             end
          end

          default      : spi_if_st <= idle_st;
       endcase
   end
end

endmodule
