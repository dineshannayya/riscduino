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
////    0.2 - 28th Aug 2022, Dinesh A                             ////
////          Additional Mail Box Register added at addr 0xF      ////
//////////////////////////////////////////////////////////////////////
//
`include "user_params.svh"

module glbl_reg (
                       // System Signals
                       // Inputs
		               input logic             mclk                   ,
	                   input logic             e_reset_n              ,  // external reset
	                   input logic             p_reset_n              ,  // power-on reset
                       input logic             s_reset_n              ,  // soft reset

                       input logic [15:0]      pad_strap_in           , // strap from pad

                       input logic            user_clock1            ,
                       input logic            user_clock2            ,
                       input logic            int_pll_clock          ,
                       input logic            cpu_clk                ,
                       input logic            xtal_clk               ,

                       output logic            usb_clk                ,
                       output logic            rtc_clk                ,

                       // to/from Global Reset FSM
	                    input  logic [31:0]    system_strap           ,
	                    output logic [31:0]    strap_sticky           ,
	                    output logic [1:0]     strap_uartm            ,
                       

                       // Global Reset control
                       output logic  [3:0]     cpu_core_rst_n         ,
                       output logic            cpu_intf_rst_n         ,
                       output logic            qspim_rst_n            ,
                       output logic            sspim_rst_n            ,
                       output logic  [1:0]     uart_rst_n             ,
                       output logic            i2cm_rst_n             ,
                       output logic            usb_rst_n              ,

		       // Reg Bus Interface Signal
                       input logic             reg_cs                 ,
                       input logic             reg_wr                 ,
                       input logic [4:0]       reg_addr               ,
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
		               input  logic            pwm_intr              ,
		               input  logic            rtc_intr              ,
		               input  logic            ir_intr                ,

		               output logic [15:0]     cfg_riscv_ctrl         ,
                       output  logic [31:0]    cfg_multi_func_sel     ,// multifunction pins
                        

		               input   logic [2:0]      timer_intr            ,
		               input   logic [31:0]     gpio_intr             ,

                       // Digital PLL I/F
                       output logic          cfg_pll_enb        , // Enable PLL
                       output logic[4:0]     cfg_pll_fed_div    , // PLL feedback division ratio
                       output logic          cfg_dco_mode       , // Run PLL in DCO mode
                       output logic[25:0]    cfg_dc_trim        , // External trim for DCO mode
                       output logic          pll_ref_clk        , // Input oscillator to match

                       output logic          dbg_clk_mon        ,
                       output logic          cfg_gpio_dgmode    
   ); 


                       
//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

logic [15:0]    strap_latch           ;
logic          sw_rd_en               ;
logic          sw_wr_en;
logic [4:0]    sw_addr; // addressing 16 registers
logic [31:0]   sw_reg_wdata;
logic [3:0]    wr_be  ;

logic [31:0]   reg_out;
logic [31:0]   reg_0;  // Chip ID
logic [31:0]   reg_1;  // Global Reg-0
logic [31:0]   reg_2;  // Global Reg-1
logic [31:0]   reg_3;  // Global Interrupt Mask
logic [31:0]   reg_4;  // Global Interrupt Status
logic [31:0]   reg_5;  // Multi Function Sel
logic [31:0]   reg_6;  // 
logic [31:0]   reg_7;  // 
logic [31:0]   reg_8;  // 
logic [31:0]   reg_9;  // Random Number
//logic [31:0]   reg_10; // Interrupt Set
logic [31:0]   reg_12; // Latched Strap 
logic [31:0]   reg_13; // Strap Sticky
logic [31:0]   reg_14; // System Strap
logic [31:0]   reg_15; // MailBox Reg

logic [31:0]   reg_16;  // Software Reg-0  - p_reset
logic [31:0]   reg_17;  // Software Reg-1  - p_reset
logic [31:0]   reg_18;  // Software Reg-2  - p_reset
logic [31:0]   reg_19;  // Software Reg-3  - p_reset
logic [31:0]   reg_20;  // Software Reg-4  - s_reset
logic [31:0]   reg_21;  // Software Reg-5  - s_reset
logic [31:0]   reg_22;  // Software Reg-6  - s_reset
logic [31:0]   reg_23;  // Software Reg-7  - s_reset

logic           cs_int;
logic [3:0]     cfg_mon_sel;

assign       sw_addr       = reg_addr ;
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       wr_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;


always @ (posedge mclk or negedge s_reset_n)
begin : preg_out_Seq
   if (s_reset_n == 1'b0) begin
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
wire   sw_wr_en_0  = sw_wr_en  & (sw_addr == 5'h0);
wire   sw_wr_en_1  = sw_wr_en  & (sw_addr == 5'h1);
wire   sw_wr_en_2  = sw_wr_en  & (sw_addr == 5'h2);
wire   sw_wr_en_3  = sw_wr_en  & (sw_addr == 5'h3);
wire   sw_wr_en_4  = sw_wr_en  & (sw_addr == 5'h4);
wire   sw_wr_en_5  = sw_wr_en  & (sw_addr == 5'h5);
wire   sw_wr_en_6  = sw_wr_en  & (sw_addr == 5'h6);
wire   sw_wr_en_7  = sw_wr_en  & (sw_addr == 5'h7);
wire   sw_wr_en_8  = sw_wr_en  & (sw_addr == 5'h8);
wire   sw_wr_en_9  = sw_wr_en  & (sw_addr == 5'h9);
wire   sw_wr_en_10 = sw_wr_en  & (sw_addr == 5'hA);
wire   sw_wr_en_11 = sw_wr_en  & (sw_addr == 5'hB);
wire   sw_wr_en_12 = sw_wr_en  & (sw_addr == 5'hC);
wire   sw_wr_en_13 = sw_wr_en  & (sw_addr == 5'hD);
wire   sw_wr_en_14 = sw_wr_en  & (sw_addr == 5'hE);
wire   sw_wr_en_15 = sw_wr_en  & (sw_addr == 5'hF);
wire   sw_wr_en_16 = sw_wr_en  & (sw_addr == 5'h10);
wire   sw_wr_en_17 = sw_wr_en  & (sw_addr == 5'h11);
wire   sw_wr_en_18 = sw_wr_en  & (sw_addr == 5'h12);
wire   sw_wr_en_19 = sw_wr_en  & (sw_addr == 5'h13);
wire   sw_wr_en_20 = sw_wr_en  & (sw_addr == 5'h14);
wire   sw_wr_en_21 = sw_wr_en  & (sw_addr == 5'h15);
wire   sw_wr_en_22 = sw_wr_en  & (sw_addr == 5'h16);
wire   sw_wr_en_23 = sw_wr_en  & (sw_addr == 5'h17);
wire   sw_wr_en_24 = sw_wr_en  & (sw_addr == 5'h18);
wire   sw_wr_en_25 = sw_wr_en  & (sw_addr == 5'h19);
wire   sw_wr_en_26 = sw_wr_en  & (sw_addr == 5'h1A);
wire   sw_wr_en_27 = sw_wr_en  & (sw_addr == 5'h1B);
wire   sw_wr_en_28 = sw_wr_en  & (sw_addr == 5'h1C);
wire   sw_wr_en_29 = sw_wr_en  & (sw_addr == 5'h1D);
wire   sw_wr_en_30 = sw_wr_en  & (sw_addr == 5'h1E);
wire   sw_wr_en_31 = sw_wr_en  & (sw_addr == 5'h1F);

wire   sw_rd_en_0  = sw_rd_en  & (sw_addr == 5'h0);
wire   sw_rd_en_1  = sw_rd_en  & (sw_addr == 5'h1);
wire   sw_rd_en_2  = sw_rd_en  & (sw_addr == 5'h2);
wire   sw_rd_en_3  = sw_rd_en  & (sw_addr == 5'h3);
wire   sw_rd_en_4  = sw_rd_en  & (sw_addr == 5'h4);
wire   sw_rd_en_5  = sw_rd_en  & (sw_addr == 5'h5);
wire   sw_rd_en_6  = sw_rd_en  & (sw_addr == 5'h6);
wire   sw_rd_en_7  = sw_rd_en  & (sw_addr == 5'h7);
wire   sw_rd_en_8  = sw_rd_en  & (sw_addr == 5'h8);
wire   sw_rd_en_9  = sw_rd_en  & (sw_addr == 5'h9);
wire   sw_rd_en_10 = sw_rd_en  & (sw_addr == 5'hA);
wire   sw_rd_en_11 = sw_rd_en  & (sw_addr == 5'hB);
wire   sw_rd_en_12 = sw_rd_en  & (sw_addr == 5'hC);
wire   sw_rd_en_13 = sw_rd_en  & (sw_addr == 5'hD);
wire   sw_rd_en_14 = sw_rd_en  & (sw_addr == 5'hE);
wire   sw_rd_en_15 = sw_rd_en  & (sw_addr == 5'hF);
wire   sw_rd_en_16 = sw_rd_en  & (sw_addr == 5'h10);
wire   sw_rd_en_17 = sw_rd_en  & (sw_addr == 5'h11);
wire   sw_rd_en_18 = sw_rd_en  & (sw_addr == 5'h12);
wire   sw_rd_en_19 = sw_rd_en  & (sw_addr == 5'h13);
wire   sw_rd_en_20 = sw_rd_en  & (sw_addr == 5'h14);
wire   sw_rd_en_21 = sw_rd_en  & (sw_addr == 5'h15);
wire   sw_rd_en_22 = sw_rd_en  & (sw_addr == 5'h16);
wire   sw_rd_en_23 = sw_rd_en  & (sw_addr == 5'h17);
wire   sw_rd_en_24 = sw_rd_en  & (sw_addr == 5'h18);
wire   sw_rd_en_25 = sw_rd_en  & (sw_addr == 5'h19);
wire   sw_rd_en_26 = sw_rd_en  & (sw_addr == 5'h1A);
wire   sw_rd_en_27 = sw_rd_en  & (sw_addr == 5'h1B);
wire   sw_rd_en_28 = sw_rd_en  & (sw_addr == 5'h1C);
wire   sw_rd_en_29 = sw_rd_en  & (sw_addr == 5'h1D);
wire   sw_rd_en_30 = sw_rd_en  & (sw_addr == 5'h1E);
wire   sw_rd_en_31 = sw_rd_en  & (sw_addr == 5'h1F);

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
wire [3:0]  chip_id      =  4'h6;
wire [7:0]  chip_rev     =  8'h01;

assign reg_0 = {manu_id,total_core,chip_id,chip_rev};


//------------------------------------------
// reg-1: GLBL_CFG_0
//------------------------------------------
wire [31:0] cfg_rst_ctrl = reg_1;

ctech_buf u_buf_cpu_intf_rst  (.A(cfg_rst_ctrl[0]),.X(cpu_intf_rst_n));
ctech_buf u_buf_qspim_rst     (.A(cfg_rst_ctrl[1]),.X(qspim_rst_n));
ctech_buf u_buf_sspim_rst     (.A(cfg_rst_ctrl[2]),.X(sspim_rst_n));
ctech_buf u_buf_uart0_rst     (.A(cfg_rst_ctrl[3]),.X(uart_rst_n[0]));
ctech_buf u_buf_i2cm_rst      (.A(cfg_rst_ctrl[4]),.X(i2cm_rst_n));
ctech_buf u_buf_usb_rst       (.A(cfg_rst_ctrl[5]),.X(usb_rst_n));
ctech_buf u_buf_uart1_rst     (.A(cfg_rst_ctrl[6]),.X(uart_rst_n[1]));

ctech_buf u_buf_cpu0_rst      (.A(cfg_rst_ctrl[8]),.X(cpu_core_rst_n[0]));
ctech_buf u_buf_cpu1_rst      (.A(cfg_rst_ctrl[9]),.X(cpu_core_rst_n[1]));
ctech_buf u_buf_cpu2_rst      (.A(cfg_rst_ctrl[10]),.X(cpu_core_rst_n[2]));
ctech_buf u_buf_cpu3_rst      (.A(cfg_rst_ctrl[11]),.X(cpu_core_rst_n[3]));



//---------------------------------------------------------
// Default reset value decided based on riscv boot mode
//
//   bit [12]  - Riscv Reset control
//               0 - Keep Riscv on Reset
//               1 - Removed Riscv on Power On Reset
//  Default cpu_intf_rst_n & qspim_rst_n reset is removed
//---------------------------------------------------------
wire        strap_riscv_bmode = system_strap[`STRAP_RISCV_RESET_MODE];
wire [31:0] rst_in = (strap_riscv_bmode) ? 32'h103 : 32'h03;

glbl_rst_reg  #(32'h0) u_reg_1	(
	      //List of Inputs
	      .s_reset_n  (s_reset_n     ),
          .rst_in     (rst_in        ),
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

wire [31:0] reg_2_rst_val = {4'h0,
                             system_strap[`STRAP_RISCV_CACHE_BYPASS],
                             system_strap[`STRAP_RISCV_CACHE_BYPASS],
                             2'b0,
                             1'b0,
                             3'b0,
                             system_strap[`STRAP_RISCV_SRAM_CLK_EDGE],
                             system_strap[`STRAP_RISCV_SRAM_CLK_EDGE],
                             system_strap[`STRAP_RISCV_SRAM_CLK_EDGE],
                             system_strap[`STRAP_RISCV_SRAM_CLK_EDGE],
                             16'h0};
gen_32b_reg2  u_reg_2	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
          .rst_in     (reg_2_rst_val ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_2    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_2         )
	      );

assign  cfg_gpio_dgmode   = reg_2[8]; // gpio de-glitch mode selection
assign  cfg_mon_sel       = reg_2[7:4];
assign  soft_irq          = reg_2[3]; 
assign  user_irq          = reg_2[2:0]; 
assign cfg_riscv_ctrl     = reg_2[31:16];

//-----------------------------------------------------------------------
//   reg-3 : Global Interrupt Mask
//-----------------------------------------------------------------------

gen_32b_reg  #(32'h0) u_reg_3	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
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

logic usb_intr_s,usb_intr_ss;   // Usb Interrupt Double Sync
logic i2cm_intr_s,i2cm_intr_ss; // I2C Interrupt Double Sync
logic rtc_intr_s,rtc_intr_ss;
logic ir_intr_s,ir_intr_ss;

always @ (posedge mclk or negedge s_reset_n)
begin  
   if (s_reset_n == 1'b0) begin
     usb_intr_s       <= 'h0;
     usb_intr_ss      <= 'h0;
     i2cm_intr_s      <= 'h0;
     i2cm_intr_ss     <= 'h0;
     rtc_intr_s       <= 'h0;
     rtc_intr_ss      <= 'h0;
     ir_intr_s        <= 'h0;
     ir_intr_ss       <= 'h0;
   end else begin
     usb_intr_s   <= usb_intr;
     usb_intr_ss  <= usb_intr_s;
     i2cm_intr_s  <= i2cm_intr;
     i2cm_intr_ss <= i2cm_intr_s;
     rtc_intr_s   <= rtc_intr;
     rtc_intr_ss  <= rtc_intr_s;

     ir_intr_s   <= ir_intr;
     ir_intr_ss  <= ir_intr_s;
   end
end

wire [31:0] hware_intr_req = {gpio_intr[31:8], ir_intr_ss,rtc_intr_ss,pwm_intr,usb_intr_ss, i2cm_intr_ss,timer_intr[2:0]};

// Interrupt can be set by hware req or by writting reg_10
wire [31:0]  intr_req = {{({8{sw_wr_en_10 & reg_ack & wr_be[3]}} & sw_reg_wdata[31:24]) | hware_intr_req[31:24] },
                        {({8{sw_wr_en_10 & reg_ack & wr_be[2]}} & sw_reg_wdata[23:16]) | hware_intr_req[23:16] },
                        {({8{sw_wr_en_10 & reg_ack & wr_be[1]}} & sw_reg_wdata[15:8])  | hware_intr_req[15:8]  },
                        {({8{sw_wr_en_10 & reg_ack & wr_be[0]}} & sw_reg_wdata[7:0])   | hware_intr_req[7:0]  }};


generic_intr_stat_reg #(.WD(32),
	                .RESET_DEFAULT(0)) u_reg4 (
		 //inputs
		 .clk         (mclk              ),
		 .reset_n     (s_reset_n         ),
	     .reg_we      ({{8{sw_wr_en_4 & reg_ack & wr_be[3]}},
                        {8{sw_wr_en_4 & reg_ack & wr_be[2]}},
                        {8{sw_wr_en_4 & reg_ack & wr_be[1]}},
                        {8{sw_wr_en_4 & reg_ack & wr_be[0]}}}),		 
		 .reg_din    (sw_reg_wdata[31:0] ),
		 .hware_req  (intr_req           ),
		 
		 //outputs
		 .data_out    (reg_4[31:0]       )
	      );





//-----------------------------------------------------------------------
// Logic for cfg_multi_func_sel :Enable GPIO to act as multi function pins 
//-----------------------------------------------------------------------
assign  cfg_multi_func_sel = reg_5[31:0]; // to be used for read

// bit[31] '1' - uart master enable on power up
// bit[30] '1' - Riscv Tap enable on power up

gen_32b_reg  #(32'hC000_0000) u_reg_5	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_5    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_5        )
	      );


//-----------------------------------------
// Reg-6: Clock Control
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_6	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_6   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_6       )
	      );
wire [7:0] cfg_rtc_clk_ctrl     = reg_6[7:0];
wire [7:0] cfg_usb_clk_ctrl     = reg_6[15:8];

//-----------------------------------------
// Reg-7: PLL Control-1
// PLL register we don't want to reset during system reboot
// ----------------------------------------
gen_32b_reg  #(32'h8) u_reg_7	(
	      //List of Inputs
	      .reset_n    (p_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_7   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_7       )
	      );

assign     cfg_pll_enb         = reg_7[3];
wire [2:0] cfg_ref_pll_div     = reg_7[2:0];
//-----------------------------------------
// Reg-2: PLL Control-2
// PLL register we don't want to reset during system reboot
// ----------------------------------------
gen_32b_reg  #({1'b1,5'b00000,26'b0000000000000_1010101101001} ) u_reg_8	(
	      //List of Inputs
	      .reset_n    (p_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_8   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_8       )
	      );

//------------------------------------------
// PLL Trim Value
//-----------------------------------------
assign    cfg_dco_mode     = reg_8[31];
assign    cfg_pll_fed_div  = reg_8[30:26];
assign    cfg_dc_trim      = reg_8[25:0];


//------------------------------------------
// reg_9: Random Number Generator
//------------------------------------------
pseudorandom u_random (
  .rst_n     ( s_reset_n     ), 
  .clk       ( mclk          ), 
  .next      ( reg_ack       ), 
  .random    ( reg_9         )  
);


//-------------------------------------------------
// Strap control
//---------------------------------------------
strap_ctrl u_strap (
	       .clk                 (mclk        ),
	       .e_reset_n           (e_reset_n   ),  // external reset
	       .p_reset_n           (p_reset_n   ),  // power-on reset
	       .s_reset_n           (s_reset_n   ),  // soft reset

           .pad_strap_in        (pad_strap_in), // strap from pad
	      //List of Inputs
	       .cs                  (sw_wr_en_13 ),
	       .we                  (wr_be       ),		 
	       .data_in             (sw_reg_wdata),
	      
	      //List of Outs
           .strap_latch         (strap_latch ),
	       .strap_sticky        (strap_sticky),
	       .strap_uartm         (strap_uartm) 
         );


assign  reg_12 = {16'h0,strap_latch};
assign  reg_13 = strap_sticky;
assign  reg_14 = system_strap;

//-----------------------------------------
// MailBox Register
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_15	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_15   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_15       )
	      );



//-----------------------------------------
// Software Reg-0 : ASCI Representation of RISC = 32'h8273_8343
// ----------------------------------------
gen_32b_reg  #(CHIP_SIGNATURE) u_reg_16	(
	      //List of Inputs
	      .reset_n    (p_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_16    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_16       )
	      );

//-----------------------------------------
// Software Reg-1, Release date: <DAY><MONTH><YEAR>
// ----------------------------------------
gen_32b_reg  #(CHIP_RELEASE_DATE) u_reg_17	(
	      //List of Inputs
	      .reset_n    (p_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_17    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_17       )
	      );

//-----------------------------------------
// Software Reg-2: Poject Revison 5.1 = 0005200
// ----------------------------------------
gen_32b_reg  #(CHIP_REVISION) u_reg_18	(
	      //List of Inputs
	      .reset_n    (p_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_18    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_18       )
	      );

//-----------------------------------------
// Software Reg-3
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_19	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_19   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_19       )
	      );

//-----------------------------------------
// Software Reg-4
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_20	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_20   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_20       )
	      );

//-----------------------------------------
// Software Reg-5
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_21	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_21    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_21       )
	      );

//-----------------------------------------
// Software Reg-6: 
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_22	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_22    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_22       )
	      );

//-----------------------------------------
// Software Reg-7
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_23	(
	      //List of Inputs
	      .reset_n    (s_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_23   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_23       )
	      );
//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [4:0])
    5'b00000 : reg_out [31:0] = reg_0  ;     
    5'b00001 : reg_out [31:0] = reg_1  ;    
    5'b00010 : reg_out [31:0] = reg_2  ;     
    5'b00011 : reg_out [31:0] = reg_3  ;    
    5'b00100 : reg_out [31:0] = reg_4  ;    
    5'b00101 : reg_out [31:0] = reg_5  ;    
    5'b00110 : reg_out [31:0] = reg_6  ;    
    5'b00111 : reg_out [31:0] = reg_7  ;    
    5'b01000 : reg_out [31:0] = reg_8  ;    
    5'b01001 : reg_out [31:0] = reg_9  ;    
    5'b01010 : reg_out [31:0] = reg_4  ; // Interrupt Set   
    5'b01011 : reg_out [31:0] = 'h0 ;   
    5'b01100 : reg_out [31:0] = reg_12 ;   
    5'b01101 : reg_out [31:0] = reg_13 ;   
    5'b01110 : reg_out [31:0] = reg_14 ;   
    5'b01111 : reg_out [31:0] = reg_15 ;   
    5'b10000 : reg_out [31:0] = reg_16  ;     
    5'b10001 : reg_out [31:0] = reg_17  ;    
    5'b10010 : reg_out [31:0] = reg_18  ;     
    5'b10011 : reg_out [31:0] = reg_19  ;    
    5'b10100 : reg_out [31:0] = reg_20  ;    
    5'b10101 : reg_out [31:0] = reg_21  ;    
    5'b10110 : reg_out [31:0] = reg_22  ;    
    5'b10111 : reg_out [31:0] = reg_23  ;    
    5'b11000 : reg_out [31:0] = 'h0  ;    
    5'b11001 : reg_out [31:0] = 'h0  ;    
    5'b11010 : reg_out [31:0] = 'h0 ;   
    5'b11011 : reg_out [31:0] = 'h0 ;   
    5'b11100 : reg_out [31:0] = 'h0 ;   
    5'b11101 : reg_out [31:0] = 'h0 ;   
    5'b11110 : reg_out [31:0] = 'h0 ;   
    5'b11111 : reg_out [31:0] = 'h0 ;   
    default  : reg_out [31:0] = 32'h0;
  endcase
end


//----------------------------------
// Generate RTC Clock Generation
//----------------------------------
wire   rtc_clk_div;
wire   rtc_ref_clk_int;
wire   rtc_ref_clk;
wire   rtc_clk_int;

wire [1:0] cfg_rtc_clk_sel_sel   = cfg_rtc_clk_ctrl[7:6];
wire       cfg_rtc_clk_div       = cfg_rtc_clk_ctrl[5];
wire [4:0] cfg_rtc_clk_ratio     = cfg_rtc_clk_ctrl[4:0];

assign rtc_ref_clk_int = (cfg_rtc_clk_sel_sel ==2'b00) ? user_clock1   :
                         (cfg_rtc_clk_sel_sel ==2'b01) ? user_clock2   :	
                         (cfg_rtc_clk_sel_sel ==2'b01) ? int_pll_clock : xtal_clk;	
ctech_clk_buf u_rtc_ref_clkbuf (.A (rtc_ref_clk_int), . X(rtc_ref_clk));
//assign rtc_clk_int = (cfg_rtc_clk_div)     ? rtc_clk_div : rtc_ref_clk;
ctech_mux2x1 u_rtc_clk_sel (.A0 (rtc_ref_clk), .A1 (rtc_clk_div), .S  (cfg_rtc_clk_div), .X  (rtc_clk_int));


ctech_clk_buf u_clkbuf_rtc (.A (rtc_clk_int), . X(rtc_clk));

clk_ctl #(4) u_rtcclk (
   // Outputs
       .clk_o         (rtc_clk_div      ),
   // Inputs
       .mclk          (rtc_ref_clk      ),
       .reset_n       (s_reset_n        ), 
       .clk_div_ratio (cfg_rtc_clk_ratio)
   );

//----------------------------------
// Generate USB Clock Generation
//----------------------------------
wire   usb_clk_div;
wire   usb_ref_clk_int;
wire   usb_ref_clk;
wire   usb_clk_int;

wire [1:0] cfg_usb_clk_sel_sel   = cfg_usb_clk_ctrl[7:6];
wire       cfg_usb_clk_div       = cfg_usb_clk_ctrl[5];
wire [4:0] cfg_usb_clk_ratio     = cfg_usb_clk_ctrl[4:0];

assign usb_ref_clk_int = (cfg_usb_clk_sel_sel ==2'b00) ? user_clock1   :
                         (cfg_usb_clk_sel_sel ==2'b01) ? user_clock2   :	
                         (cfg_usb_clk_sel_sel ==2'b01) ? int_pll_clock : xtal_clk;	
ctech_clk_buf u_usb_ref_clkbuf (.A (usb_ref_clk_int), . X(usb_ref_clk));
//assign usb_clk_int = (cfg_usb_clk_div)     ? usb_clk_div : usb_ref_clk;
ctech_mux2x1 u_usb_clk_sel (.A0 (usb_ref_clk), .A1 (usb_clk_div), .S  (cfg_usb_clk_div), .X  (usb_clk_int));


ctech_clk_buf u_clkbuf_usb (.A (usb_clk_int), . X(usb_clk));

clk_ctl #(4) u_usbclk (
   // Outputs
       .clk_o         (usb_clk_div      ),
   // Inputs
       .mclk          (usb_ref_clk      ),
       .reset_n       (s_reset_n        ), 
       .clk_div_ratio (cfg_usb_clk_ratio)
   );

// PLL Ref CLock

clk_ctl #(2) u_pll_ref_clk (
   // Outputs
       .clk_o         (pll_ref_clk      ),
   // Inputs
       .mclk          (user_clock1      ),
       .reset_n       (e_reset_n        ), 
       .clk_div_ratio (cfg_ref_pll_div  )
   );

// Debug clock monitor optin
wire  dbg_clk_ref       = (cfg_mon_sel == 4'b000) ? user_clock1    :
	                       (cfg_mon_sel == 4'b001) ? user_clock2    :
	                       (cfg_mon_sel == 4'b010) ? xtal_clk     :
	                       (cfg_mon_sel == 4'b011) ? int_pll_clock: 
	                       (cfg_mon_sel == 4'b100) ? mclk         : 
	                       (cfg_mon_sel == 4'b101) ? cpu_clk      : 
	                       (cfg_mon_sel == 4'b110) ? usb_clk      : 
	                       (cfg_mon_sel == 4'b111) ? rtc_clk      : 1'b0;

wire dbg_clk_ref_buf;
ctech_clk_buf u_clkbuf_dbg_ref (.A (dbg_clk_ref), . X(dbg_clk_ref_buf));

//  DIv16 to debug monitor purpose
logic dbg_clk_div16;

clk_ctl #(3) u_dbgclk (
   // Outputs
       .clk_o         (dbg_clk_div16    ),
   // Inputs
       .mclk          (dbg_clk_ref_buf  ),
       .reset_n       (e_reset_n        ), 
       .clk_div_ratio (4'hE             )
   );

ctech_clk_buf u_clkbuf_dbg (.A (dbg_clk_div16), . X(dbg_clk_mon));

endmodule                       
