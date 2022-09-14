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
////  GPIO Register                                               ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesh.annayya@gmail.com              ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 15th Aug 2022, Dinesh A                             ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////
//
module gpio_reg  (
                       // System Signals
                       // Inputs
		               input logic           mclk               ,
                       input logic           h_reset_n          ,

		               // Reg Bus Interface Signal
                       input logic           reg_cs             ,
                       input logic           reg_wr             ,
                       input logic [3:0]     reg_addr           ,
                       input logic [31:0]    reg_wdata          ,
                       input logic [3:0]     reg_be             ,

                       // Outputs
                       output logic [31:0]   reg_rdata          ,
                       output logic          reg_ack            ,


                       input  logic  [31:0]  gpio_in_data             ,
                       output logic  [31:0]  gpio_prev_indata         ,// previously captured GPIO I/P pins data
                       input  logic  [31:0]  gpio_int_event           ,
                       output logic  [31:0]  cfg_gpio_out_data        ,// GPIO statuc O/P data from config reg
                       output logic  [31:0]  cfg_gpio_dir_sel         ,// decides on GPIO pin is I/P or O/P at pad level, 0 -> Input, 1 -> Output
                       output logic  [31:0]  cfg_gpio_out_type        ,// GPIO Type, 1 - WS_281X port
                       output logic  [31:0]  cfg_multi_func_sel       ,// GPIO Multi function type
                       output logic  [31:0]  cfg_gpio_posedge_int_sel ,// select posedge interrupt
                       output logic  [31:0]  cfg_gpio_negedge_int_sel ,// select negedge interrupt
                       output logic  [31:00] cfg_gpio_data_in         ,

                       output logic  [31:0]  gpio_intr          


                ); 

//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_rd_en        ;
logic          sw_wr_en        ;
logic [3:0]    sw_addr         ; // addressing 16 registers
logic [31:0]   sw_reg_wdata    ;
logic [3:0]    sw_be           ;

logic [31:0]   reg_out         ;
logic [31:0]   reg_0           ; // GPIO Direction Select
logic [31:0]   reg_1           ; // GPIO TYPE - Unused
logic [31:0]   reg_2           ; // GPIO IN DATA
logic [31:0]   reg_3           ; // GPIO OUT DATA
logic [31:0]   reg_4           ; // GPIO INTERRUPT STATUS/CLEAR
logic [31:0]   reg_5           ; // GPIO INTERRUPT SET
logic [31:0]   reg_6           ; // GPIO INTERRUPT MASK
logic [31:0]   reg_7           ; // GPIO POSEDGE INTERRUPT SEL
logic [31:0]   reg_8           ; // GPIO NEGEDGE INTERRUPT SEL

assign       sw_addr       = reg_addr;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       sw_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;

//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_wr_en  & (sw_addr == 4'h0);
wire   sw_wr_en_1 = sw_wr_en  & (sw_addr == 4'h1);
wire   sw_wr_en_2 = sw_wr_en  & (sw_addr == 4'h2);
wire   sw_wr_en_3 = sw_wr_en  & (sw_addr == 4'h3);
wire   sw_wr_en_4 = sw_wr_en  & (sw_addr == 4'h4);
wire   sw_wr_en_5 = sw_wr_en  & (sw_addr == 4'h5);
wire   sw_wr_en_6 = sw_wr_en  & (sw_addr == 4'h6);
wire   sw_wr_en_7 = sw_wr_en  & (sw_addr == 4'h7);
wire   sw_wr_en_8 = sw_wr_en  & (sw_addr == 4'h8);

wire   sw_rd_en_0 = sw_rd_en  & (sw_addr == 4'h0);
wire   sw_rd_en_1 = sw_rd_en  & (sw_addr == 4'h1);
wire   sw_rd_en_2 = sw_rd_en  & (sw_addr == 4'h2);
wire   sw_rd_en_3 = sw_rd_en  & (sw_addr == 4'h3);
wire   sw_rd_en_4 = sw_rd_en  & (sw_addr == 4'h4);
wire   sw_rd_en_5 = sw_rd_en  & (sw_addr == 4'h5);
wire   sw_rd_en_6 = sw_rd_en  & (sw_addr == 4'h6);
wire   sw_rd_en_7 = sw_rd_en  & (sw_addr == 4'h7);
wire   sw_rd_en_8 = sw_rd_en  & (sw_addr == 4'h8);


always @ (posedge mclk or negedge h_reset_n)
begin : preg_out_Seq
   if (h_reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (reg_cs && !reg_ack) begin
      reg_rdata  <= reg_out;
      reg_ack    <= 1'b1;
   end else begin
      reg_ack    <= 1'b0;
   end
end

//-----------------------------------------------------------------------
// Logic for cfg_gpio_dir_sel 
//-----------------------------------------------------------------------
assign cfg_gpio_dir_sel = reg_0[31:0]; // data to the GPIO O/P pins 

gen_32b_reg  #(32'h0) u_reg_0	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_0    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_0         )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_out_type 
//-----------------------------------------------------------------------
assign cfg_gpio_out_type = reg_1[31:0]; // Un-used

gen_32b_reg  #(32'h0) u_reg_1	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_1    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_1         )
	      );
//-----------------------------------------------------------------------
// Logic for gpio_data_in 
//-----------------------------------------------------------------------
// Double Sync the gpio pin data for edge detection
always @ (posedge mclk or negedge h_reset_n)
begin 
  if (h_reset_n == 1'b0) begin
    reg_2  <= 'h0 ;
  end
  else begin
    reg_2  <= gpio_in_data;
  end
end


assign cfg_gpio_data_in = gpio_in_data; // to be used for edge interrupt detect
assign gpio_prev_indata = reg_2[31:0];

//-----------------------------------------------------------------------
// Logic for cfg_gpio_out_data 
//-----------------------------------------------------------------------
assign cfg_gpio_out_data = reg_3[31:0]; // data to the GPIO control blk 

gen_32b_reg  #(32'h0) u_reg_3	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_3    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_3         )
	      );



//--------------------------------------------------------
// Interrupt Status Generation
// Note: Reg_4 --> Interrupt Status Register, Writting '1' will clear the
//                 corresponding interrupt status bit. Writting '0' has no
//                 effect 
//       Reg_5 --> Writting one to this register will set the interrupt in
//                  interrupt status register (reg_4), Writting '0' does not has any
//                  effect.
/// Always update int_status, even if no register write is occuring.
//	    Interrupt posting is higher priority than int clear by host 
//--------------------------------------------------------
wire [31:0] gpio_int_status = reg_4;				      

generic_intr_stat_reg #(.WD(32),
	                .RESET_DEFAULT(0))  u_reg_4 (
		 //inputs
		 .clk         (mclk              ),
		 .reset_n     (h_reset_n         ),
	     .reg_we      ({
		               {8{sw_wr_en_4 & reg_ack & sw_be[2]}},
		               {8{sw_wr_en_4 & reg_ack & sw_be[2]}},
		               {8{sw_wr_en_4 & reg_ack & sw_be[1]}},
		               {8{sw_wr_en_4 & reg_ack & sw_be[0]}}
		               }  ),		 
		 .reg_din    (sw_reg_wdata[31:0] ),
		 .hware_req  (gpio_int_event | {
		               {8{sw_wr_en_5 & reg_ack}} & sw_reg_wdata[31:24],
		               {8{sw_wr_en_5 & reg_ack}} & sw_reg_wdata[23:16],
		               {8{sw_wr_en_5 & reg_ack}} & sw_reg_wdata[15:8] ,
		               {8{sw_wr_en_5 & reg_ack}} & sw_reg_wdata[7:0]   
		               }     ),
		 
		 //outputs
		 .data_out    (reg_4[31:0]       )
	      );
//-------------------------------------------------
// Returns same value as interrupt status register
//------------------------------------------------

assign reg_5 = reg_4;
//-----------------------------------------------------------------------
// Logic for cfg_gpio_int_mask :  GPIO interrupt mask  
//-----------------------------------------------------------------------
wire [31:0]  cfg_gpio_int_mask = reg_6[31:0]; // to be used for read

assign gpio_intr  = reg_4 & reg_6; // interrupt pin to the RISC


//  Register-11
gen_32b_reg  #(32'h0) u_reg_6	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_6    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_6         )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_posedge_int_sel :  Enable posedge GPIO interrupt 
//-----------------------------------------------------------------------
assign  cfg_gpio_posedge_int_sel = reg_7[31:0]; // to be used for read
gen_32b_reg  #(32'h0) u_reg_7	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_7    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_7        )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_negedge_int_sel :  Enable negedge GPIO interrupt 
//-----------------------------------------------------------------------
assign cfg_gpio_negedge_int_sel = reg_8[31:0]; // to be used for read
gen_32b_reg  #(32'h0) u_reg_8	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_8    ),
	      .we         (sw_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_8        )
	      );


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
    4'b0100    : reg_out [31:0] = reg_4 [31:0];    
    4'b0101    : reg_out [31:0] = reg_5 [31:0];    
    4'b0110    : reg_out [31:0] = reg_6 [31:0];    
    4'b0111    : reg_out [31:0] = reg_7 [31:0];    
    4'b1000    : reg_out [31:0] = reg_8 [31:0];    
    default    : reg_out [31:0] = 32'h0;
  endcase
end

endmodule
