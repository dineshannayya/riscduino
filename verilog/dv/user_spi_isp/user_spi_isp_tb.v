////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText:  2021 , Dinesh Annayya
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
// SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Standalone User validation Test bench                       ////
////                                                              ////
////  This file is part of the Riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   Digital core using spi isp i/f.                            ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 20th Feb 2022, Dinesh A                             ////
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

`default_nettype wire

`timescale 1 ns / 1 ps

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "bfm_spim.v"

module user_spi_isp_tb;

parameter real CLK1_PERIOD  = 25;
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"



reg       flag;

// SCLK
wire     sclk;
wire     ssn;
wire     sdi;
wire     sdo;
wire     sd_oen;

integer i,j;


	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(0, user_spi_isp_tb);
	   end
       `endif

initial
begin

   init();

   $display("Monitor: Standalone User SPI ISP Test Started");


   // Remove Wb Reset
   //u_spim.reg_wr_dword(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h1);

   repeat (2) @(posedge clock);
   #1;

   $display("Monitor: Writing  expected value");
   
   test_fail = 0;
   u_spim.reg_wr_dword(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,32'h11223344);
   u_spim.reg_wr_dword(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_1,32'h22334455);
   u_spim.reg_wr_dword(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_2,32'h33445566);
   u_spim.reg_wr_dword(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_3,32'h44556677);
   u_spim.reg_wr_dword(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_4,32'h55667788);
   u_spim.reg_wr_dword(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_5,32'h66778899);

   u_spim.reg_rd_dword_cmp(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_0,32'h11223344);
   u_spim.reg_rd_dword_cmp(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_1,32'h22334455);
   u_spim.reg_rd_dword_cmp(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_2,32'h33445566);
   u_spim.reg_rd_dword_cmp(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_3,32'h44556677);
   u_spim.reg_rd_dword_cmp(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_4,32'h55667788);
   u_spim.reg_rd_dword_cmp(`ADDR_SPACE_GLBL+`GLBL_CFG_SOFT_REG_5,32'h66778899);
   
   
   
   $display("###################################################");
   if(u_spim.err_cnt == 0) begin
      `ifdef GL
          $display("Monitor: %m (GL) Passed");
      `else
          $display("Monitor: %m (RTL) Passed");
      `endif
   end else begin
       `ifdef GL
           $display("Monitor: %m (GL) Failed");
       `else
           $display("Monitor: %m (RTL) Failed");
       `endif
    end
   $display("###################################################");
   #100
   $finish;
end


assign io_in[5]  = (io_oeb[5]  == 1'b1) ? 1'b0 : 1'b0;
assign io_in[21] = (io_oeb[21] == 1'b1) ? sclk : 1'b0;
assign io_in[20] = (io_oeb[20] == 1'b1) ? sdi  : 1'b0;
assign sdo       = (io_oeb[19] == 1'b0) ? io_out[19] : 1'b0;

bfm_spim  u_spim (
          // SPI
                .spi_clk     (sclk         ),
                .spi_sel_n   (ssn          ),
                .spi_din     (sdi          ),
                .spi_dout    (sdo          )

                );


endmodule
`default_nettype wire
