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
////  ws281x Register                                             ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////     Manages the 4x ws281x driver register                    ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 23rd Aug 2022, Dinesh A                             ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////


module ws281x_reg  #(   parameter NP = 2,     // Number of PORT
                        parameter DW = 32,    // DATA WIDTH
                        parameter AW = 4,     // ADDRESS WIDTH
                        parameter BW = 4      // BYTE WIDTH
                    ) (
                       // System Signals
                       // Inputs
		               input logic           mclk                 ,
                       input logic           h_reset_n            ,

		               // Reg Bus Interface Signal
                       input logic           reg_cs               ,
                       input logic           reg_wr               ,
                       input logic [AW-1:0]  reg_addr             ,
                       input logic [DW-1:0]  reg_wdata            ,
                       input logic [BW-1:0]  reg_be               ,

                       // Outputs
                       output logic [DW-1:0] reg_rdata            ,
                       output logic          reg_ack              ,

                       output logic[15:0]    cfg_reset_period     ,   // Reset period interm of clk
                       output logic [9:0]    cfg_clk_period       ,   // Total bit clock period
                       output logic [9:0]    cfg_th0_period        ,   // bit-0 drive low period
                       output logic [9:0]    cfg_th1_period        ,   // bit-1 drive low period

                       // wd281x port-0 data
                       output  logic          port0_enb            ,
                       input  logic          port0_rd             ,
                       output logic [23:0]   port0_data           ,
                       output logic          port0_dval           ,

                       // wd281x port-1 data
                       output  logic          port1_enb            ,
                       input  logic          port1_rd             ,
                       output logic [23:0]   port1_data           ,
                       output logic          port1_dval           

                       //// wd281x port-2 data
                       //output  logic          port2_enb            ,
                       //input  logic          port2_rd             ,
                       //output logic [23:0]   port2_data           ,
                       //output logic          port2_dval           ,

                       //// wd281x port-3 data
                       //output  logic         port3_enb            ,
                       //input  logic          port3_rd             ,    
                       //output logic [23:0]   port3_data           ,
                       //output logic          port3_dval             


                ); 

//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_rd_en              ;
logic          sw_wr_en              ;
logic [AW-1:0] sw_addr               ; 
logic [DW-1:0] sw_reg_wdata          ;
logic [BW-1:0] sw_be                 ;

logic [DW-1:0] reg_out               ;
logic [DW-1:0] reg_0                 ; 
logic [DW-1:0] reg_1                 ; 
logic [DW-1:0] reg_2                 ; 
logic [DW-1:0] reg_3                 ; 

logic [NP-1:0] fifo_full             ;
logic [NP-1:0] fifo_empty            ;
logic [NP-1:0] fifo_wr               ;
logic [NP-1:0] fifo_rd               ;
logic [23:0]   fifo_rdata[0:NP-1]    ;
logic [NP-1:0] port_op_done          ;

assign       sw_addr       = reg_addr;
assign       sw_be         = reg_be;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       sw_reg_wdata  = reg_wdata;

//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0  = sw_wr_en  & (sw_addr == 4'h0);
wire   sw_wr_en_1  = sw_wr_en  & (sw_addr == 4'h1);
wire   sw_wr_en_2  = sw_wr_en  & (sw_addr == 4'h2);
wire   sw_wr_en_3  = sw_wr_en  & (sw_addr == 4'h3);
wire   sw_wr_en_4  = sw_wr_en  & (sw_addr == 4'h4) & !fifo_full[0]; // Write only if fifo is not full
wire   sw_wr_en_5  = sw_wr_en  & (sw_addr == 4'h5) & !fifo_full[1]; // Write only if fifo is not full


// Generated seperate write enable case to block the reg ack duration when fifo is full
wire  sw_wr_en_t =  sw_wr_en_0 | sw_wr_en_1 | sw_wr_en_2 | sw_wr_en_3 | sw_wr_en_4 | sw_wr_en_5 ;


always @ (posedge mclk or negedge h_reset_n)
begin : preg_out_Seq
   if (h_reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (reg_cs && !reg_ack && sw_rd_en) begin
      reg_rdata  <= reg_out[DW-1:0] ;
      reg_ack    <= 1'b1;
   end else if (reg_cs && !reg_ack && sw_wr_en_t) begin // Block Ack generation when FIFO is full
      reg_ack    <= 1'b1;
   end else begin
      reg_ack    <= 1'b0;
   end
end

//----------------------------------------
// Hardware Command Register
//  Assumption: Maximum 32 port assumed
//----------------------------------------

assign port0_enb    = reg_0[0];
assign port1_enb    = reg_0[1];
//assign port2_enb    = reg_0[2];
//assign port3_enb    = reg_0[3];

 generic_register	#(.WD(4)) u_reg_0(
	      //List of Inputs
	      .we         ({4{sw_wr_en_0 & 
                          sw_be[0]   }}),
	      .data_in    (sw_reg_wdata[3:0]),
	      .reset_n    (h_reset_n        ),
	      .clk        (mclk             ),
	      
	      //List of Outs
	      .data_out   (reg_0[3:0]       )
	      );

assign reg_0[31:4] = 'h0;

// CONFIG-0
assign cfg_reset_period = reg_1[15:0];
gen_16b_reg  #(32'h0) u_reg_1	(
	      //List of Inputs
	      .reset_n    (h_reset_n           ),
	      .clk        (mclk                ),
	      .cs         (sw_wr_en_1          ),
	      .we         (sw_be[1:0]          ),		 
	      .data_in    (sw_reg_wdata[15:0]  ),
	      
	      //List of Outs
	      .data_out   (reg_1[15:0]         )
	      );

assign reg_1[31:16] = 0;

// CONFIG-1

assign cfg_th1_period  = reg_2[29:20]; // High Exit Period for Data-1
assign cfg_th0_period  = reg_2[19:10];  // High Exit period for Data-0
assign cfg_clk_period  = reg_2[9:0];

gen_32b_reg  #(32'h0) u_reg_2	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_2    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_2         )
	      );



assign port0_dval =!fifo_empty[0];
assign port1_dval =!fifo_empty[1];
//assign port2_dval =!fifo_empty[2];
//assign port3_dval =!fifo_empty[3];

assign reg_3 = { 2'b00,fifo_empty[1],fifo_full[1],
                 2'b00,fifo_empty[0],fifo_full[0]};


//----------------------------------------------------
//  DATA FIFO
//----------------------------------------------------

assign fifo_wr[0] = sw_wr_en_4 & reg_ack;
assign fifo_wr[1] = sw_wr_en_5 & reg_ack;
//assign fifo_wr[2] = sw_wr_en_6 & reg_ack;
//assign fifo_wr[3] = sw_wr_en_7 & reg_ack;

assign fifo_rd[0] = port0_rd;
assign fifo_rd[1] = port1_rd;
//assign fifo_rd[2] = port2_rd;
//assign fifo_rd[3] = port3_rd;

assign port0_data = fifo_rdata[0];
assign port1_data = fifo_rdata[1];
//assign port2_data = fifo_rdata[2];
//assign port3_data = fifo_rdata[3];

genvar port;
generate
for (port = 0; $unsigned(port) < NP; port=port+1) begin : gfifo

sync_fifo #(.W(24), .D(2)) u_fifo
           (
            .clk         (mclk                 ),
	        .reset_n     (h_reset_n            ),
		    .wr_en       (fifo_wr[port]        ),
		    .wr_data     (sw_reg_wdata[23:0]   ),
		    .full        (fifo_full[port]      ),
		    .empty       (fifo_empty[port]     ),
		    .rd_en       (fifo_rd[port]        ),
		    .rd_data     (fifo_rdata[port]     ) 
           );

end
endgenerate // gfifo


//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [3:0])
    4'b0000    : reg_out [31:0] = reg_0 [31:0];     
    4'b0001    : reg_out [31:0] = reg_1 [31:0];    
    4'b0010    : reg_out [31:0] = reg_2 [31:0];     
    4'b0011    : reg_out [31:0] = reg_3 [31:0];    
    4'b0100    : reg_out [31:0] = port0_data;
    4'b0101    : reg_out [31:0] = port1_data;
//    4'b0110    : reg_out [31:0] = port2_data;
//    4'b0111    : reg_out [31:0] = port3_data;
    default    : reg_out [31:0] = 32'h0;
  endcase
end
endmodule
