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
////  Global Register                                             ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      Hold all the Global and PinMux Register                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Feb 2021, Dinesh A                             ////
////          initial version                                     ////
//////////////////////////////////////////////////////////////////////
//
module glbl_reg (
                       // System Signals
                       // Inputs
		               input logic             mclk                   ,
                       input logic             h_reset_n              ,

                       // Global Reset control
                       output logic  [1:0]     cpu_core_rst_n         ,
                       output logic            cpu_intf_rst_n         ,
                       output logic            qspim_rst_n            ,
                       output logic            sspim_rst_n            ,
                       output logic  [1:0]     uart_rst_n             ,
                       output logic            i2cm_rst_n             ,
                       output logic            usb_rst_n              ,

		       // Reg Bus Interface Signal
                       input logic             reg_cs                 ,
                       input logic             reg_wr                 ,
                       input logic [3:0]       reg_addr               ,
                       input logic [31:0]      reg_wdata              ,
                       input logic [3:0]       reg_be                 ,

                       // Outputs
                       output logic [31:0]     reg_rdata              ,
                       output logic            reg_ack                ,

		               input  logic [1:0]      ext_intr_in            ,

		      // Risc configuration
                       output logic [31:0]     irq_lines              ,
                       output logic            soft_irq               ,
                       output logic [2:0]      user_irq               ,
		               input  logic            usb_intr               ,
		               input  logic            i2cm_intr              ,

		               output logic [15:0]     cfg_riscv_ctrl         ,
                       output  logic [31:0]    cfg_multi_func_sel     ,// multifunction pins
                        

		               input   logic [2:0]      timer_intr            ,
		               input   logic [31:0]     gpio_intr             
   ); 


                       
//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic          sw_rd_en               ;
logic          sw_wr_en;
logic [4:0]    sw_addr; // addressing 16 registers
logic [31:0]   sw_reg_wdata;
logic [3:0]    wr_be  ;

logic [31:0]   reg_out;
logic  [31:0]   reg_0;  // Chip ID
logic  [31:0]   reg_1;  // Global Reg-0
logic  [31:0]   reg_2;  // Global Reg-1
logic  [31:0]   reg_3;  // Global Interrupt Mask
logic [31:0]    reg_4;  // Global Interrupt Status
logic [31:0]    reg_5;  // Multi Function Sel
logic [31:0]    reg_6;  // Software Reg-0
logic [31:0]    reg_7;  // Software Reg-1
logic [31:0]    reg_8;  // Software Reg-2
logic [31:0]    reg_9;  // Software Reg-3
logic  [31:0]   reg_10; // Software Reg-4
logic [31:0]    reg_11; // Software Reg-5


logic           cs_int;


assign       sw_addr       = reg_addr ;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       wr_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;


always @ (posedge mclk or negedge h_reset_n)
begin : preg_out_Seq
   if (h_reset_n == 1'b0) begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end else if (reg_cs && !reg_ack) begin
      reg_rdata <= reg_out ;
      reg_ack   <= 1'b1;
   end else begin
      reg_ack        <= 1'b0;
   end
end



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
wire   sw_wr_en_9 = sw_wr_en  & (sw_addr == 4'h9);
wire   sw_wr_en_10 = sw_wr_en & (sw_addr == 4'hA);
wire   sw_wr_en_11 = sw_wr_en & (sw_addr == 4'hB);


wire   sw_rd_en_0  = sw_rd_en  & (sw_addr == 4'h0);
wire   sw_rd_en_1  = sw_rd_en  & (sw_addr == 4'h1);
wire   sw_rd_en_2  = sw_rd_en  & (sw_addr == 4'h2);
wire   sw_rd_en_3  = sw_rd_en  & (sw_addr == 4'h3);
wire   sw_rd_en_4  = sw_rd_en  & (sw_addr == 4'h4);
wire   sw_rd_en_5  = sw_rd_en  & (sw_addr == 4'h5);
wire   sw_rd_en_6  = sw_rd_en  & (sw_addr == 4'h6);
wire   sw_rd_en_7  = sw_rd_en  & (sw_addr == 4'h7);
wire   sw_rd_en_8  = sw_rd_en  & (sw_addr == 4'h8);
wire   sw_rd_en_9  = sw_rd_en  & (sw_addr == 4'h9);
wire   sw_rd_en_10 = sw_rd_en  & (sw_addr == 4'hA);
wire   sw_rd_en_11 = sw_rd_en  & (sw_addr == 4'hB);

//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------

// Chip ID
// chip-id[3:0] mapping
//    0 -  YIFIVE (MPW-2)
//    1 -  Riscdunio (MPW-3)
//    2 -  Riscdunio (MPW-4)
//    3 -  Riscdunio (MPW-5)
//    4 -  Riscdunio (MPW-6)
//    5 -  Riscdunio (MPW-7)
//    6 -  Riscdunio (MPW-8)
//    7 -  Riscdunio (MPW-9)

wire [15:0] manu_id      =  16'h8268; // Asci value of RD
wire [3:0]  total_core   =  4'h1;
wire [3:0]  chip_id      =  4'h5;
wire [7:0]  chip_rev     =  8'h01;

assign reg_0 = {manu_id,total_core,chip_id,chip_rev};


//------------------------------------------
// reg-1: GLBL_CFG_0
//------------------------------------------
wire [31:0] cfg_glb_ctrl = reg_1;

ctech_buf u_buf_cpu_intf_rst  (.A(cfg_glb_ctrl[0]),.X(cpu_intf_rst_n));
ctech_buf u_buf_qspim_rst     (.A(cfg_glb_ctrl[1]),.X(qspim_rst_n));
ctech_buf u_buf_sspim_rst     (.A(cfg_glb_ctrl[2]),.X(sspim_rst_n));
ctech_buf u_buf_uart0_rst     (.A(cfg_glb_ctrl[3]),.X(uart_rst_n[0]));
ctech_buf u_buf_i2cm_rst      (.A(cfg_glb_ctrl[4]),.X(i2cm_rst_n));
ctech_buf u_buf_usb_rst       (.A(cfg_glb_ctrl[5]),.X(usb_rst_n));
ctech_buf u_buf_uart1_rst     (.A(cfg_glb_ctrl[6]),.X(uart_rst_n[1]));

ctech_buf u_buf_cpu0_rst      (.A(cfg_glb_ctrl[8]),.X(cpu_core_rst_n[0]));
ctech_buf u_buf_cpu1_rst      (.A(cfg_glb_ctrl[9]),.X(cpu_core_rst_n[1]));

gen_32b_reg  #(32'h0) u_reg_1	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_1    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_1         )
	      );

//----------------------------------------------
// reg-2: GLBL_CFG_1
//------------------------------------------

gen_32b_reg  #(32'h0) u_reg_2	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_2    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_2         )
	      );

assign  soft_irq      = reg_2[3]; 
assign  user_irq      = reg_2[2:0]; 
assign cfg_riscv_ctrl = reg_2[31:16];

//-----------------------------------------------------------------------
//   reg-3 : Global Interrupt Mask
//-----------------------------------------------------------------------

gen_32b_reg  #(32'h0) u_reg_3	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_3    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_3         )
	      );

//-----------------------------------------------------------------------
//   reg-4 : Global Interrupt Status
//-----------------------------------------------------------------
assign  irq_lines     = reg_3[31:0] & reg_4[31:0]; 

// In Arduino GPIO[7:0] is corresponds to PORT-A which is not available for user access
wire [31:0] hware_intr_req = {gpio_intr[31:8], 3'b0,usb_intr, i2cm_intr,timer_intr[2:0]};

generic_intr_stat_reg #(.WD(32),
	                .RESET_DEFAULT(0)) u_reg4_be1 (
		 //inputs
		 .clk         (mclk              ),
		 .reset_n     (h_reset_n         ),
	     .reg_we      ({{8{sw_wr_en_4 & reg_ack & wr_be[3]}},
                        {8{sw_wr_en_4 & reg_ack & wr_be[2]}},
                        {8{sw_wr_en_4 & reg_ack & wr_be[1]}},
                        {8{sw_wr_en_4 & reg_ack & wr_be[0]}}}),		 
		 .reg_din    (sw_reg_wdata[31:0] ),
		 .hware_req  (hware_intr_req     ),
		 
		 //outputs
		 .data_out    (reg_4[31:0]       )
	      );





//-----------------------------------------------------------------------
// Logic for cfg_multi_func_sel :Enable GPIO to act as multi function pins 
//-----------------------------------------------------------------------
assign  cfg_multi_func_sel = reg_5[31:0]; // to be used for read


gen_32b_reg  #(32'h0) u_reg_5	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_5    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_5        )
	      );

//-----------------------------------------
// Software Reg-0 : ASCI Representation of RISC = 32'h8273_8343
// ----------------------------------------
gen_32b_reg  #(32'h8273_8343) u_reg_6	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_6    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_6       )
	      );

//-----------------------------------------
// Software Reg-1, Release date: <DAY><MONTH><YEAR>
// ----------------------------------------
gen_32b_reg  #(32'h1508_2022) u_reg_7	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_7    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_7       )
	      );

//-----------------------------------------
// Software Reg-2: Poject Revison 5.0 = 0005000
// ----------------------------------------
gen_32b_reg  #(32'h0005_0000) u_reg_8	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_8    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_8       )
	      );

//-----------------------------------------
// Software Reg-3
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_9	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_9   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_9       )
	      );

//-----------------------------------------
// Software Reg-4
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_10	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_10   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_10       )
	      );

//-----------------------------------------
// Software Reg-5
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_11	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_11   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_11       )
	      );



//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [3:0])
    4'b0000 : reg_out [31:0] = reg_0  [31:0];     
    4'b0001 : reg_out [31:0] = reg_1  [31:0];    
    4'b0010 : reg_out [31:0] = reg_2  [31:0];     
    4'b0011 : reg_out [31:0] = reg_3  [31:0];    
    4'b0100 : reg_out [31:0] = reg_4  [31:0];    
    4'b0101 : reg_out [31:0] = reg_5  [31:0];    
    4'b0110 : reg_out [31:0] = reg_6  [31:0];    
    4'b0111 : reg_out [31:0] = reg_7  [31:0];    
    4'b1000 : reg_out [31:0] = reg_8  [31:0];    
    4'b1001 : reg_out [31:0] = reg_9  [31:0];    
    4'b1010 : reg_out [31:0] = reg_10 [31:0];   
    4'b1011 : reg_out [31:0] = reg_11 [31:0];   
    default  : reg_out [31:0] = 32'h0;
  endcase
end


endmodule                       
