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
////  Global confg register                                       ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  https://github.com/dineshannayya/yifive_r0.git              ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////      This block generate all the global config and status    ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 08 June 2021  Dinesh A                              ////
////          Initial version                                     ////
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

module glbl_cfg (

        input logic             mclk,
        input logic             reset_n,

        // Reg Bus Interface Signal
        input logic             reg_cs,
        input logic             reg_wr,
        input logic [7:0]       reg_addr,
        input logic [31:0]      reg_wdata,
        input logic [3:0]       reg_be,

       // Outputs
        output logic [31:0]     reg_rdata,
        output logic            reg_ack,

       // Risc configuration
       output logic [31:0]     fuse_mhartid,
       output logic [15:0]     irq_lines,
       output logic            soft_irq,
       output logic [2:0]      user_irq,

       // SDRAM Config
       input logic             sdr_init_done       , // Indicate SDRAM Initialisation Done
       output logic [1:0]      cfg_sdr_width       , // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
       output logic [1:0]      cfg_colbits         , // 2'b00 - 8 Bit column address, 
       output logic [3:0]      cfg_sdr_tras_d      , // Active to precharge delay
       output logic [3:0]      cfg_sdr_trp_d       , // Precharge to active delay
       output logic [3:0]      cfg_sdr_trcd_d      , // Active to R/W delay
       output logic 	       cfg_sdr_en          , // Enable SDRAM controller
       output logic [1:0]      cfg_req_depth       , // Maximum Request accepted by SDRAM controller
       output logic [12:0]     cfg_sdr_mode_reg    ,
       output logic [2:0]      cfg_sdr_cas         , // SDRAM CAS Latency
       output logic [3:0]      cfg_sdr_trcar_d     , // Auto-refresh period
       output logic [3:0]      cfg_sdr_twr_d       , // Write recovery delay
       output logic [11:0]     cfg_sdr_rfsh        ,
       output logic [2:0]      cfg_sdr_rfmax       


        );



//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic           sw_rd_en;
logic           sw_wr_en;
logic  [3:0]    sw_addr ; // addressing 16 registers
logic  [3:0]    wr_be   ;
logic  [31:0]   sw_reg_wdata;

logic           reg_cs_l    ;
logic           reg_cs_2l    ;


logic [31:0]    reg_0;  // Software_Reg_0
logic [31:0]    reg_1;  // Risc Fuse ID
logic [31:0]    reg_2;  // Software-Reg_2
logic [31:0]    reg_3;  // Interrup Control
logic [31:0]    reg_4;  // SDRAM_CTRL1
logic [31:0]    reg_5;  // SDRAM_CTRL2
logic [31:0]    reg_6;  // Software-Reg_6
logic [31:0]    reg_7;  // Software-Reg_7
logic [31:0]    reg_8;  // Software-Reg_8
logic [31:0]    reg_9;  // Software-Reg_9
logic [31:0]    reg_10; // Software-Reg_10
logic [31:0]    reg_11; // Software-Reg_11
logic [31:0]    reg_12; // Software-Reg_12
logic [31:0]    reg_13; // Software-Reg_13
logic [31:0]    reg_14; // Software-Reg_14
logic [31:0]    reg_15; // Software-Reg_15
logic [31:0]    reg_out;

//-----------------------------------------------------------------------
// Main code starts here
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// To avoid interface timing, all the content are registered
//-----------------------------------------------------------------------
always @ (posedge mclk or negedge reset_n)
begin 
   if (reset_n == 1'b0)
   begin
    sw_addr       <= '0;
    sw_rd_en      <= '0;
    sw_wr_en      <= '0;
    sw_reg_wdata  <= '0;
    wr_be         <= '0;
    reg_cs_l      <= '0;
    reg_cs_2l     <= '0;
  end else begin
    sw_addr       <= reg_addr [5:2];
    sw_rd_en      <= reg_cs & !reg_wr;
    sw_wr_en      <= reg_cs & reg_wr;
    sw_reg_wdata  <= reg_wdata;
    wr_be         <= reg_be;
    reg_cs_l      <= reg_cs;
    reg_cs_2l     <= reg_cs_l;
  end
end


//-----------------------------------------------------------------------
// Read path mux
//-----------------------------------------------------------------------

always @ (posedge mclk or negedge reset_n)
begin : preg_out_Seq
   if (reset_n == 1'b0) begin
      reg_rdata [31:0]  <= 32'h0000_0000;
      reg_ack           <= 1'b0;
   end else if (sw_rd_en && !reg_ack && !reg_cs_2l) begin
      reg_rdata [31:0]  <= reg_out [31:0];
      reg_ack           <= 1'b1;
   end else if (sw_wr_en && !reg_ack && !reg_cs_2l) begin 
      reg_ack           <= 1'b1;
   end else begin
      reg_ack        <= 1'b0;
   end
end


//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_wr_en & (sw_addr == 4'h0);
wire   sw_rd_en_0 = sw_rd_en & (sw_addr == 4'h0);
wire   sw_wr_en_1 = sw_wr_en & (sw_addr == 4'h1);
wire   sw_rd_en_1 = sw_rd_en & (sw_addr == 4'h1);
wire   sw_wr_en_2 = sw_wr_en & (sw_addr == 4'h2);
wire   sw_rd_en_2 = sw_rd_en & (sw_addr == 4'h2);
wire   sw_wr_en_3 = sw_wr_en & (sw_addr == 4'h3);
wire   sw_rd_en_3 = sw_rd_en & (sw_addr == 4'h3);
wire   sw_wr_en_4 = sw_wr_en & (sw_addr == 4'h4);
wire   sw_rd_en_4 = sw_rd_en & (sw_addr == 4'h4);
wire   sw_wr_en_5 = sw_wr_en & (sw_addr == 4'h5);
wire   sw_rd_en_5 = sw_rd_en & (sw_addr == 4'h5);
wire   sw_wr_en_6 = sw_wr_en & (sw_addr == 4'h6);
wire   sw_rd_en_6 = sw_rd_en & (sw_addr == 4'h6);
wire   sw_wr_en_7 = sw_wr_en & (sw_addr == 4'h7);
wire   sw_rd_en_7 = sw_rd_en & (sw_addr == 4'h7);
wire   sw_wr_en_8 = sw_wr_en & (sw_addr == 4'h8);
wire   sw_rd_en_8 = sw_rd_en & (sw_addr == 4'h8);
wire   sw_wr_en_9 = sw_wr_en & (sw_addr == 4'h9);
wire   sw_rd_en_9 = sw_rd_en & (sw_addr == 4'h9);
wire   sw_wr_en_10 = sw_wr_en & (sw_addr == 4'hA);
wire   sw_rd_en_10 = sw_rd_en & (sw_addr == 4'hA);
wire   sw_wr_en_11 = sw_wr_en & (sw_addr == 4'hB);
wire   sw_rd_en_11 = sw_rd_en & (sw_addr == 4'hB);
wire   sw_wr_en_12 = sw_wr_en & (sw_addr == 4'hC);
wire   sw_rd_en_12 = sw_rd_en & (sw_addr == 4'hC);
wire   sw_wr_en_13 = sw_wr_en & (sw_addr == 4'hD);
wire   sw_rd_en_13 = sw_rd_en & (sw_addr == 4'hD);
wire   sw_wr_en_14 = sw_wr_en & (sw_addr == 4'hE);
wire   sw_rd_en_14 = sw_rd_en & (sw_addr == 4'hE);
wire   sw_wr_en_15 = sw_wr_en & (sw_addr == 4'hF);
wire   sw_rd_en_15 = sw_rd_en & (sw_addr == 4'hF);


always @( *)
begin : preg_sel_Com

  reg_out [31:0] = 32'd0;

  case (sw_addr [3:0])
    4'b0000 : reg_out [31:0] = reg_0 [31:0];     
    4'b0001 : reg_out [31:0] = reg_1 [31:0];    
    4'b0010 : reg_out [31:0] = reg_2 [31:0];     
    4'b0011 : reg_out [31:0] = reg_3 [31:0];    
    4'b0100 : reg_out [31:0] = reg_4 [31:0];    
    4'b0101 : reg_out [31:0] = reg_5 [31:0];    
    4'b0110 : reg_out [31:0] = reg_6 [31:0];    
    4'b0111 : reg_out [31:0] = reg_7 [31:0];    
    4'b1000 : reg_out [31:0] = reg_8 [31:0];    
    4'b1001 : reg_out [31:0] = reg_9 [31:0];    
    4'b1010 : reg_out [31:0] = reg_10 [31:0];   
    4'b1011 : reg_out [31:0] = reg_11 [31:0];   
    4'b1100 : reg_out [31:0] = reg_12 [31:0];   
    4'b1101 : reg_out [31:0] = reg_13 [31:0];
    4'b1110 : reg_out [31:0] = reg_14 [31:0];
    4'b1111 : reg_out [31:0] = reg_15 [31:0]; 
  endcase
end



//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//   reg-0
//   -----------------------------------------------------------------



generic_register #(8,8'hAA  ) u_reg0_be0 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[7:0]        )
          );

generic_register #(8,8'hBB  ) u_reg0_be1 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[15:8]        )
          );
generic_register #(8,8'hCC  ) u_reg0_be2 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[23:16]        )
          );

generic_register #(8,8'hDD  ) u_reg0_be3 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[31:24]        )
          );



//-----------------------------------------------------------------------
//   reg-1, reset value = 32'hA55A_A55A
//   -----------------------------------------------------------------

assign  fuse_mhartid     = reg_1[31:0]; 
generic_register #(.WD(8),.RESET_DEFAULT(8'h5A)) u_reg1_be0 (
	      .we            ({8{sw_wr_en_1 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[7:0]        )
          );

generic_register #(.WD(8),.RESET_DEFAULT(8'hA5)  ) u_reg1_be1 (
	      .we            ({8{sw_wr_en_1 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[15:8]        )
          );
generic_register #(.WD(8),.RESET_DEFAULT(8'h5A)  ) u_reg1_be2 (
	      .we            ({8{sw_wr_en_1 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[23:16]        )
          );

generic_register #(.WD(8),.RESET_DEFAULT(8'hA5)  ) u_reg1_be3 (
	      .we            ({8{sw_wr_en_1 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[31:24]        )
          );

//-----------------------------------------------------------------------
//   reg-2, reset value = 32'hAABBCCDD
//-----------------------------------------------------------------

generic_register #(.WD(8),.RESET_DEFAULT(8'hDD)  ) u_reg2_be0 (
	      .we            ({8{sw_wr_en_2 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_2[7:0]        )
          );

generic_register #(.WD(8),.RESET_DEFAULT(8'hCC)  ) u_reg2_be1 (
	      .we            ({8{sw_wr_en_2 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_2[15:8]        )
          );
generic_register #(.WD(8),.RESET_DEFAULT(8'hBB)  ) u_reg2_be2 (
	      .we            ({8{sw_wr_en_2 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_2[23:16]        )
          );

generic_register #(.WD(8),.RESET_DEFAULT(8'hAA)  ) u_reg2_be3 (
	      .we            ({8{sw_wr_en_2 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_2[31:24]        )
          );

//-----------------------------------------------------------------------
//   reg-3
//-----------------------------------------------------------------
assign  irq_lines     = reg_3[15:0]; 
assign  soft_irq      = reg_3[16]; 
assign  user_irq      = reg_3[19:17]; 

generic_register #(8,0  ) u_reg3_be0 (
	      .we            ({8{sw_wr_en_3 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_3[7:0]        )
          );

generic_register #(8,0  ) u_reg3_be1 (
	      .we            ({8{sw_wr_en_3 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_3[15:8]        )
          );
generic_register #(4,0  ) u_reg3_be2 (
	      .we            ({4{sw_wr_en_3 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[19:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_3[19:16]        )
          );

assign reg_3[31:20] = '0;


//-----------------------------------------------------------------------
//   reg-4
//   recommended Default value:
//   1'b1,3'h3,2'h3,4'h1,4'h7',4'h2,4'h2,4'h6,2'b01,2'b10 = 32'h2F17_2266
//-----------------------------------------------------------------
assign      cfg_sdr_width     = reg_4[1:0] ;  // 2'b10 // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
assign      cfg_colbits       = reg_4[3:2] ;  // 2'b00 8 Bit column address, 2'b01 -  9 Bit column address, 
assign      cfg_sdr_tras_d    = reg_4[7:4] ;  // 4'h4  // Active to precharge delay
assign      cfg_sdr_trp_d     = reg_4[11:8];  // 4'h2  // Precharge to active delay
assign      cfg_sdr_trcd_d    = reg_4[15:12]; // 4'h2  // Active to R/W delay
assign      cfg_sdr_trcar_d   = reg_4[19:16]; // 4'h7  // Auto-refresh period
assign      cfg_sdr_twr_d     = reg_4[23:20]; // 4'h1  // Write recovery delay
assign      cfg_req_depth     = reg_4[25:24]; // 2'h3  // Maximum Request accepted by SDRAM controller
assign      cfg_sdr_cas       = reg_4[28:26]; // 3'h3  // SDRAM CAS Latency
assign      cfg_sdr_en        = reg_4[29]   ; // 1'b1 // Enable SDRAM controller
assign      reg_4[30]         = sdr_init_done ; // Indicate SDRAM Initialisation Done
assign      reg_4[31]         = 1'b0;


generic_register #(8,0  ) u_reg4_be0 (
	      .we            ({8{sw_wr_en_4 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_4[7:0]        )
          );

generic_register #(8,0  ) u_reg4_be1 (
	      .we            ({8{sw_wr_en_4 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_4[15:8]        )
          );
generic_register #(8,0  ) u_reg4_be2 (
	      .we            ({8{sw_wr_en_4 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_4[23:16]        )
          );

generic_register #(6,0  ) u_reg4_be3 (
	      .we            ({6{sw_wr_en_4 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[29:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_4[29:24]        )
          );
//-----------------------------------------------------------------------
//   reg-5, recomended default value {12'h100,13'h33,3'h6} = 32'h100_019E
//-----------------------------------------------------------------
assign      cfg_sdr_rfmax     = reg_5[2:0] ;   // 3'h6
assign      cfg_sdr_mode_reg  = reg_5[15:3] ;  // 13'h033
assign      cfg_sdr_rfsh      = reg_5[27:16];  // 12'h100

generic_register #(8,0  ) u_reg5_be0 (
	      .we            ({8{sw_wr_en_5 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_5[7:0]        )
          );

generic_register #(8,0  ) u_reg5_be1 (
	      .we            ({8{sw_wr_en_5 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_5[15:8]        )
          );
generic_register #(8,0  ) u_reg5_be2 (
	      .we            ({8{sw_wr_en_5 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_5[23:16]        )
          );

generic_register #(8,0  ) u_reg5_be3 (
	      .we            ({8{sw_wr_en_5 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_5[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 6
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg6_be0 (
	      .we            ({8{sw_wr_en_6 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_6[7:0]        )
          );

generic_register #(8,0  ) u_reg6_be1 (
	      .we            ({8{sw_wr_en_6 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_6[15:8]        )
          );
generic_register #(8,0  ) u_reg6_be2 (
	      .we            ({8{sw_wr_en_6 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_6[23:16]        )
          );

generic_register #(8,0  ) u_reg6_be3 (
	      .we            ({8{sw_wr_en_6 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_6[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 7
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg7_be0 (
	      .we            ({8{sw_wr_en_7 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_7[7:0]        )
          );

generic_register #(8,0  ) u_reg7_be1 (
	      .we            ({8{sw_wr_en_7 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_7[15:8]        )
          );
generic_register #(8,0  ) u_reg7_be2 (
	      .we            ({8{sw_wr_en_7 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_7[23:16]        )
          );

generic_register #(8,0  ) u_reg7_be3 (
	      .we            ({8{sw_wr_en_7 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_7[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 8
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg8_be0 (
	      .we            ({8{sw_wr_en_8 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_8[7:0]        )
          );

generic_register #(8,0  ) u_reg8_be1 (
	      .we            ({8{sw_wr_en_8 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_8[15:8]        )
          );
generic_register #(8,0  ) u_reg8_be2 (
	      .we            ({8{sw_wr_en_8 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_8[23:16]        )
          );

generic_register #(8,0  ) u_reg8_be3 (
	      .we            ({8{sw_wr_en_8 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_8[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 9
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg9_be0 (
	      .we            ({8{sw_wr_en_9 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_9[7:0]        )
          );

generic_register #(8,0  ) u_reg9_be1 (
	      .we            ({8{sw_wr_en_9 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_9[15:8]        )
          );
generic_register #(8,0  ) u_reg9_be2 (
	      .we            ({8{sw_wr_en_9 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_9[23:16]        )
          );

generic_register #(8,0  ) u_reg9_be3 (
	      .we            ({8{sw_wr_en_9 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_9[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 10
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg10_be0 (
	      .we            ({8{sw_wr_en_10 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_10[7:0]        )
          );

generic_register #(8,0  ) u_reg10_be1 (
	      .we            ({8{sw_wr_en_10 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_10[15:8]        )
          );
generic_register #(8,0  ) u_reg10_be2 (
	      .we            ({8{sw_wr_en_10 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_10[23:16]        )
          );

generic_register #(8,0  ) u_reg10_be3 (
	      .we            ({8{sw_wr_en_10 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_10[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 11
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg11_be0 (
	      .we            ({8{sw_wr_en_11 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_11[7:0]        )
          );

generic_register #(8,0  ) u_reg11_be1 (
	      .we            ({8{sw_wr_en_11 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_11[15:8]        )
          );
generic_register #(8,0  ) u_reg11_be2 (
	      .we            ({8{sw_wr_en_11 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_11[23:16]        )
          );

generic_register #(8,0  ) u_reg11_be3 (
	      .we            ({8{sw_wr_en_11 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_11[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 12
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg12_be0 (
	      .we            ({8{sw_wr_en_12 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_12[7:0]        )
          );

generic_register #(8,0  ) u_reg12_be1 (
	      .we            ({8{sw_wr_en_12 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_12[15:8]        )
          );
generic_register #(8,0  ) u_reg12_be2 (
	      .we            ({8{sw_wr_en_12 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_12[23:16]        )
          );

generic_register #(8,0  ) u_reg12_be3 (
	      .we            ({8{sw_wr_en_12 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_12[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 13
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg13_be0 (
	      .we            ({8{sw_wr_en_13 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_13[7:0]        )
          );

generic_register #(8,0  ) u_reg13_be1 (
	      .we            ({8{sw_wr_en_13 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_13[15:8]        )
          );
generic_register #(8,0  ) u_reg13_be2 (
	      .we            ({8{sw_wr_en_13 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_13[23:16]        )
          );

generic_register #(8,0  ) u_reg13_be3 (
	      .we            ({8{sw_wr_en_13 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_13[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 14
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg14_be0 (
	      .we            ({8{sw_wr_en_14 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_14[7:0]        )
          );

generic_register #(8,0  ) u_reg14_be1 (
	      .we            ({8{sw_wr_en_14 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_14[15:8]        )
          );
generic_register #(8,0  ) u_reg14_be2 (
	      .we            ({8{sw_wr_en_14 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_14[23:16]        )
          );

generic_register #(8,0  ) u_reg14_be3 (
	      .we            ({8{sw_wr_en_14 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_14[31:24]        )
          );


//-----------------------------------------------------------------
//   reg- 15
//-----------------------------------------------------------------

generic_register #(8,0  ) u_reg15_be0 (
	      .we            ({8{sw_wr_en_15 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_15[7:0]        )
          );

generic_register #(8,0  ) u_reg15_be1 (
	      .we            ({8{sw_wr_en_15 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_15[15:8]        )
          );
generic_register #(8,0  ) u_reg15_be2 (
	      .we            ({8{sw_wr_en_15 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[23:16]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_15[23:16]        )
          );

generic_register #(8,0  ) u_reg15_be3 (
	      .we            ({8{sw_wr_en_15 & 
                                 wr_be[3]   }}  ),		 
	      .data_in       (sw_reg_wdata[31:24]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_15[31:24]     )
          );





endmodule
