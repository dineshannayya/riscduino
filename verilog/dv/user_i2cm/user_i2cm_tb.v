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
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   i2c Master .                                               ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Feb 2021, Dinesh A                             ////
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

`timescale 1 ns / 1 ns

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`include "i2c_slave_model.v"

module user_i2cm_tb;
parameter real CLK1_PERIOD  = 20; // 50Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"

reg [15:0] prescale;

//----------------------------------
// Uart Configuration
// ---------------------------------

integer i,j;


	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(0, user_i2cm_tb);
	   end
       `endif

initial
begin
   test_fail = 0;
   init();
    
   #200; // Wait for reset removal
   repeat (10) @(posedge clock);
   $display("############################################");
   $display("   Testing I2CM Read/Write Access           ");
   $display("############################################");
   

   repeat (10) @(posedge clock);
   #1;
   // Enable I2M Block & WB Reset and Enable I2CM Mux Select
   wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_GLBL_CFG,'h01);

   // Enable I2C Multi Functional Ports
   wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_MUTI_FUNC,'h8000);

   // Remove i2m reset
   wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h010);

   repeat (100) @(posedge clock);  

    @(posedge  clock);
    $display("---------- Initialize I2C Master ----------"); 

    // Sysclock: 50Mhz, I2C : 400Khz
    tb_set_i2c_prescale(50000000,400000,prescale);
    
    //Wrire Prescale registers
     wb_user_core_write(`ADDR_SPACE_I2CM+(8'h0<<2),prescale[7:0]);  
     wb_user_core_write(`ADDR_SPACE_I2CM+(8'h1<<2),prescale[15:8]);  
    // Core Enable
     wb_user_core_write(`ADDR_SPACE_I2CM+(8'h2<<2),8'h80);  
    
    // Writing Data

    $display("---------- Writing Data ----------"); 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h20); // Slave Addr + WR  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h90);  
    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  
     
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h66);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h10);  

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  
   
   /* Byte1: 12 */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h12);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h10); // No Stop + Write  

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  
   
   /* Byte1: 34 */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h34);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h10); // No Stop + Write 

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

   /* Byte1: 56 */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h56);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h10); // No Stop + Write 

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

   /* Byte1: 78 */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h78);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h50); // Stop + Write 

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Reading Data
    
    //Wrire Address
    $display("---------- Writing Data ----------"); 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h20);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h90);  
    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  
     
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h66);  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h50);  

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Generate Read
    $display("---------- Writing Data ----------"); 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h3<<2),8'h21); // Slave Addr + RD  
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h90);  
    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    /* BYTE-1 : 0x12  */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h20);  // RD + ACK

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Compare received data
    wb_user_core_read_cmp(`ADDR_SPACE_I2CM+(8'h3<<2),8'h12);  
     
    /* BYTE-2 : 0x34  */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h20);  // RD + ACK

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Compare received data
    wb_user_core_read_cmp(`ADDR_SPACE_I2CM+(8'h3<<2),8'h34);  

    /* BYTE-3 : 0x56  */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4 <<2),8'h20);  // RD + ACK

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4<<2),read_data);  

    //Compare received data
    wb_user_core_read_cmp(`ADDR_SPACE_I2CM+(8'h3<<2),8'h56);  

    /* BYTE-4 : 0x78  */ 
    wb_user_core_write(`ADDR_SPACE_I2CM+(8'h4<<2),8'h68);  // STOP + RD + NACK 

    read_data[1] = 1'b1;
    while(read_data[1]==1)
      wb_user_core_read(`ADDR_SPACE_I2CM+(8'h4 <<2),read_data);  

    //Compare received data
    wb_user_core_read_cmp(`ADDR_SPACE_I2CM+(8'h3 <<2),8'h78);  

    repeat(100)@(posedge clock);



     $display("###################################################");
     if(test_fail == 0) begin
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

// SSPI Slave I/F
assign io_in[5]  = 1'b1; // RESET


//---------------------------
// I2C
// --------------------------
tri scl,sda;

assign sda  =  (io_oeb[26] == 1'b0) ? io_out[26] : 1'bz;
assign scl   = (io_oeb[27] == 1'b0) ? io_out[27]: 1'bz;
assign io_in[26]  =  sda;
assign io_in[27]  =  scl;

pullup p1(scl); // pullup scl line
pullup p2(sda); // pullup sda line

 
i2c_slave_model u_i2c_slave (
	.scl   (scl), 
	.sda   (sda)
       );



endmodule
`default_nettype wire
