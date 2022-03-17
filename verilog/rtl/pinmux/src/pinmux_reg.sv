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
////  Pinmux Register                                             ////
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
module pinmux_reg (
                       // System Signals
                       // Inputs
		       input logic             mclk,
                       input logic             h_reset_n,

                       // Global Reset control
                       output logic  [1:0]     cpu_core_rst_n   ,
                       output logic            cpu_intf_rst_n   ,
                       output logic            qspim_rst_n      ,
                       output logic            sspim_rst_n      ,
                       output logic            uart_rst_n       ,
                       output logic            i2cm_rst_n       ,
                       output logic            usb_rst_n        ,

		       // Reg Bus Interface Signal
                       input logic             reg_cs,
                       input logic             reg_wr,
                       input logic [7:0]       reg_addr,
                       input logic [31:0]      reg_wdata,
                       input logic [3:0]       reg_be,

                       // Outputs
                       output logic [31:0]     reg_rdata,
                       output logic            reg_ack,

		       input  logic [1:0]      ext_intr_in,

		      // Risc configuration
                       output logic [15:0]     irq_lines,
                       output logic            soft_irq,
                       output logic [2:0]      user_irq,
		       input  logic            usb_intr,
		       input  logic            i2cm_intr,

                       output logic [9:0]      cfg_pulse_1us,
		       output logic [1:0]      cfg_riscv_debug_sel,
		       
                       //---------------------------------------------------
                       // 6 PWM Configuration
                       //---------------------------------------------------
                       
                       output logic [15:0]    cfg_pwm0_high           ,
                       output logic [15:0]    cfg_pwm0_low            ,
                       output logic [15:0]    cfg_pwm1_high           ,
                       output logic [15:0]    cfg_pwm1_low            ,
                       output logic [15:0]    cfg_pwm2_high           ,
                       output logic [15:0]    cfg_pwm2_low            ,
                       output logic [15:0]    cfg_pwm3_high           ,
                       output logic [15:0]    cfg_pwm3_low            ,
                       output logic [15:0]    cfg_pwm4_high           ,
                       output logic [15:0]    cfg_pwm4_low            ,
                       output logic [15:0]    cfg_pwm5_high           ,
                       output logic [15:0]    cfg_pwm5_low            ,

                // GPIO input pins
                       input  logic [31:0]     gpio_in_data   ,// GPIO I/P pins
                       input  logic [31:0]     gpio_int_event ,// from gpio control blk



                // GPIO config pins
                       output  logic [31:0]     cfg_gpio_out_data        ,// to the GPIO control block 
                       output  logic [31:0]     cfg_gpio_data_in         ,// GPIO I/P pins data captured into this
                       output  logic [31:0]     cfg_gpio_dir_sel         ,// decides on GPIO pin is I/P or O/P at pad level
                       output  logic [31:0]     cfg_gpio_out_type        ,// O/P is static , '1' : waveform
                       output  logic [31:0]     cfg_gpio_posedge_int_sel ,// select posedge interrupt
                       output  logic [31:0]     cfg_gpio_negedge_int_sel ,// select negedge interrupt
                       output  logic [31:0]     cfg_multi_func_sel       ,// multifunction pins
                        
                       // Outputs
                       output logic [31:0]      gpio_prev_indata         ,// prv data from GPIO I/P pins

		       input   logic [2:0]      timer_intr               ,
                       output  logic [2:0]      cfg_timer_update         ,
                       output  logic [31:0]     cfg_timer0               ,      
                       output  logic [31:0]     cfg_timer1               ,      
                       output  logic [31:0]     cfg_timer2               
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
logic  [31:0]   reg_0; // Chip ID
logic  [31:0]   reg_1; // Risc Fuse Id
logic  [31:0]   reg_2; // Global config-1
logic  [31:0]   reg_3; // Global config-2
logic [31:0]    reg_4; // GPIO Read Data
logic [31:0]    reg_5; // GPIO Output Data
logic [31:0]    reg_6; // GPIO Dir Sel
logic [31:0]    reg_7; // GPIO Type
logic [31:0]    reg_8; // Interrupt
logic [31:0]    reg_9; // GPIO Interrupt Status
logic  [31:0]   reg_10; // GPIO Interrupt Status
logic [31:0]    reg_11; // GPIO Interrupt Mask
logic [31:0]    reg_12; // GPIO Posedge Interrupt Select
logic [31:0]    reg_13; // GPIO Negedge Interrupt Select
logic [31:0]    reg_14; // Software-Reg_14
logic [31:0]    reg_15; // Software-Reg_15
logic [31:0]    reg_16; // PWN-0 Config
logic [31:0]    reg_17; // PWN-1 Config
logic [31:0]    reg_18; // PWN-2 Config
logic [31:0]    reg_19; // PWN-3 Config
logic [31:0]    reg_20; // PWN-4 Config
logic [31:0]    reg_21; // PWN-5 Config
logic [31:0]    reg_22; // Software-Reg1
logic [31:0]    reg_23; // Software-Reg2
logic [31:0]    reg_24; // Software-Reg3
logic [31:0]    reg_25; // Software-Reg4
logic [31:0]    reg_26; // Software-Reg5
logic [31:0]    reg_27; // Software-Reg6
logic [31:0]    reg_28; // Software-Reg6
logic [31:0]    reg_29; // Software-Reg6
logic [31:0]    reg_30; // Software-Reg6


logic           cs_int;
logic           gpio_intr;


assign       sw_addr       = reg_addr [6:2];
assign       sw_rd_en      = reg_cs & !reg_wr;
assign       sw_wr_en      = reg_cs & reg_wr;
assign       wr_be         = reg_be;
assign       sw_reg_wdata  = reg_wdata;


//-----------------------------------
// Edge detection for Logic Bist
// ----------------------------------

logic wb_req;
logic wb_req_d;
logic wb_req_pedge;

always_ff @(negedge h_reset_n or posedge mclk) begin
    if ( h_reset_n == 1'b0 ) begin
        wb_req    <= '0;
	wb_req_d  <= '0;
   end else begin
       wb_req   <= reg_cs && (reg_ack == 0) ;
       wb_req_d <= wb_req;
   end
end

// Detect pos edge of request
assign wb_req_pedge = (wb_req_d ==0) && (wb_req==1'b1);


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
wire   sw_wr_en_0 = sw_wr_en  & (sw_addr == 5'h0);
wire   sw_wr_en_1 = sw_wr_en  & (sw_addr == 5'h1);
wire   sw_wr_en_2 = sw_wr_en  & (sw_addr == 5'h2);
wire   sw_wr_en_3 = sw_wr_en  & (sw_addr == 5'h3);
wire   sw_wr_en_4 = sw_wr_en  & (sw_addr == 5'h4);
wire   sw_wr_en_5 = sw_wr_en  & (sw_addr == 5'h5);
wire   sw_wr_en_6 = sw_wr_en  & (sw_addr == 5'h6);
wire   sw_wr_en_7 = sw_wr_en  & (sw_addr == 5'h7);
wire   sw_wr_en_8 = sw_wr_en  & (sw_addr == 5'h8);
wire   sw_wr_en_9 = sw_wr_en  & (sw_addr == 5'h9);
wire   sw_wr_en_10 = sw_wr_en & (sw_addr == 5'hA);
wire   sw_wr_en_11 = sw_wr_en & (sw_addr == 5'hB);
wire   sw_wr_en_12 = sw_wr_en & (sw_addr == 5'hC);
wire   sw_wr_en_13 = sw_wr_en & (sw_addr == 5'hD);
wire   sw_wr_en_14 = sw_wr_en & (sw_addr == 5'hE);
wire   sw_wr_en_15 = sw_wr_en & (sw_addr == 5'hF);
wire   sw_wr_en_16 = sw_wr_en & (sw_addr == 5'h10);
wire   sw_wr_en_17 = sw_wr_en & (sw_addr == 5'h11);
wire   sw_wr_en_18 = sw_wr_en & (sw_addr == 5'h12);
wire   sw_wr_en_19 = sw_wr_en & (sw_addr == 5'h13);
wire   sw_wr_en_20 = sw_wr_en & (sw_addr == 5'h14);
wire   sw_wr_en_21 = sw_wr_en & (sw_addr == 5'h15);

wire   sw_wr_en_22 = sw_wr_en & (sw_addr == 5'h16);
wire   sw_wr_en_23 = sw_wr_en & (sw_addr == 5'h17);
wire   sw_wr_en_24 = sw_wr_en & (sw_addr == 5'h18);
wire   sw_wr_en_25 = sw_wr_en & (sw_addr == 5'h19);
wire   sw_wr_en_26 = sw_wr_en & (sw_addr == 5'h1A);
wire   sw_wr_en_27 = sw_wr_en & (sw_addr == 5'h1B);
wire   sw_wr_en_28 = sw_wr_en & (sw_addr == 5'h1C);
wire   sw_wr_en_29 = sw_wr_en & (sw_addr == 5'h1D);
wire   sw_wr_en_30 = sw_wr_en & (sw_addr == 5'h1E);
wire   sw_wr_en_31 = sw_wr_en & (sw_addr == 5'h1F);

wire   sw_rd_en_28 = sw_rd_en & (sw_addr == 5'h1C);
wire   sw_rd_en_29 = sw_rd_en & (sw_addr == 5'h1D);
wire   sw_rd_en_30 = sw_rd_en & (sw_addr == 5'h1E);
wire   sw_rd_en_31 = sw_rd_en & (sw_addr == 5'h1F);


//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------


// Chip ID
// chip-id[3:0] mapping
//    0 -  YIFIVE (MPW-2)
//    1 -  Riscdunio (MPW-3)
//    2 -  Riscdunio (MPW-4)
//    3 -  Riscdunio (MPW-5)

wire [15:0] manu_id      =  16'h8268; // Asci value of RD
wire [3:0]  total_core   =  4'h1;
wire [3:0]  chip_id      =  4'h3;
wire [7:0]  chip_rev     =  8'h01;

assign reg_0 = {manu_id,total_core,chip_id,chip_rev};


//------------------------------------------
// reg-2: GLBL_CFG_0
//------------------------------------------
wire [31:0] cfg_glb_ctrl = reg_1;

ctech_buf u_buf_cpu_intf_rst  (.A(cfg_glb_ctrl[0]),.X(cpu_intf_rst_n));
ctech_buf u_buf_qspim_rst     (.A(cfg_glb_ctrl[1]),.X(qspim_rst_n));
ctech_buf u_buf_sspim_rst     (.A(cfg_glb_ctrl[2]),.X(sspim_rst_n));
ctech_buf u_buf_uart_rst      (.A(cfg_glb_ctrl[3]),.X(uart_rst_n));
ctech_buf u_buf_i2cm_rst      (.A(cfg_glb_ctrl[4]),.X(i2cm_rst_n));
ctech_buf u_buf_usb_rst       (.A(cfg_glb_ctrl[5]),.X(usb_rst_n));

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

assign cfg_pulse_1us       = reg_2[9:0];
assign cfg_riscv_debug_sel = reg_2[31:30];

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
assign  irq_lines     = reg_3[15:0] & reg_4[15:0]; 
assign  soft_irq      = reg_3[16]   & reg_4[16]; 
assign  user_irq      = reg_3[19:17]& reg_4[19:17]; 


generic_register #(8,0  ) u_reg4_be0 (
	      .we            ({8{sw_wr_en_4 & 
                                 wr_be[0]   }}   ),		 
	      .data_in       (sw_reg_wdata[7:0]  ),
	      .reset_n       (h_reset_n          ),
	      .clk           (mclk               ),
	      
	      //List of Outs
	      .data_out      (reg_4[7:0]         )
          );


wire [7:0] hware_intr_req = {gpio_intr, ext_intr_in[1:0], usb_intr, i2cm_intr,timer_intr[2:0]};

generic_intr_stat_reg #(.WD(8),
	                .RESET_DEFAULT(0)) u_reg4_be1 (
		 //inputs
		 .clk         (mclk              ),
		 .reset_n     (h_reset_n         ),
	         .reg_we      ({8{sw_wr_en_4 & reg_ack & 
                                 wr_be[1]   }}  ),		 
		 .reg_din    (sw_reg_wdata[15:8] ),
		 .hware_req  (hware_intr_req     ),
		 
		 //outputs
		 .data_out    (reg_4[15:8]       )
	      );



generic_register #(4,0  ) u_reg4_be2 (
	      .we            ({4{sw_wr_en_4 & 
                                 wr_be[2]   }}  ),		 
	      .data_in       (sw_reg_wdata[19:16]),
	      .reset_n       (h_reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_4[19:16]        )
          );

assign reg_4[31:20] = '0;


//-----------------------------------------------------------------------
// Logic for gpio_data_in 
//-----------------------------------------------------------------------
logic [31:0] gpio_in_data_s;
logic [31:0] gpio_in_data_ss;
// Double Sync the gpio pin data for edge detection
always @ (posedge mclk or negedge h_reset_n)
begin 
  if (h_reset_n == 1'b0) begin
    reg_5  <= 'h0 ;
    gpio_in_data_s  <= 32'd0;
    gpio_in_data_ss <= 32'd0;
  end
  else begin
    gpio_in_data_s   <= gpio_in_data;
    gpio_in_data_ss <= gpio_in_data_s;
    reg_5           <= gpio_in_data_ss;
  end
end


assign cfg_gpio_data_in = reg_5[31:0]; // to be used for edge interrupt detect
assign gpio_prev_indata = gpio_in_data_ss;

//-----------------------------------------------------------------------
// Logic for cfg_gpio_out_data 
//-----------------------------------------------------------------------
assign cfg_gpio_out_data = reg_6[31:0]; // data to the GPIO control blk 

gen_32b_reg  #(32'h0) u_reg_6	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_6    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_6         )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_dir_sel 
//-----------------------------------------------------------------------
assign cfg_gpio_dir_sel = reg_7[31:0]; // data to the GPIO O/P pins 

gen_32b_reg  #(32'h0) u_reg_7	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_7    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_7         )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_out_type 
//-----------------------------------------------------------------------
assign cfg_gpio_out_type = reg_8[31:0]; // to be used for read

gen_32b_reg  #(32'h0) u_reg_8	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_8    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_8         )
	      );



//-----------------------------------------------------------------------
// Logic for cfg_int_status 
// Always update int_status, even if no register write is occuring.
// Interrupt posting is higher priority than int clear by host 
//-----------------------------------------------------------------------
wire [31:0]  cfg_gpio_int_status = reg_9[31:0]; // to be used for read

//--------------------------------------------------------
// Interrupt Status Generation
// Note: Reg_9 --> Interrupt Status Register, Writting '1' will clear the
//                 corresponding interrupt status bit. Writting '0' has no
//                 effect 
//       Reg_10 --> Writting one to this register will set the interrupt in
//                  interrupt status register (reg_9), Writting '0' does not has any
//                  effect.
/// Always update int_status, even if no register write is occuring.
//	    Interrupt posting is higher priority than int clear by host 
//--------------------------------------------------------
wire [31:0] gpio_int_status = reg_9;				      

generic_intr_stat_reg #(.WD(32),
	                .RESET_DEFAULT(0))  u_reg_9 (
		 //inputs
		 .clk         (mclk              ),
		 .reset_n     (h_reset_n         ),
	         .reg_we      ({
		               {8{sw_wr_en_9 & reg_ack & wr_be[2]}},
		               {8{sw_wr_en_9 & reg_ack & wr_be[2]}},
		               {8{sw_wr_en_9 & reg_ack & wr_be[1]}},
		               {8{sw_wr_en_9 & reg_ack & wr_be[0]}}
		               }  ),		 
		 .reg_din    (sw_reg_wdata[31:0] ),
		 .hware_req  (gpio_int_event | {
		               {8{sw_wr_en_10 & reg_ack}} & sw_reg_wdata[31:24],
		               {8{sw_wr_en_10 & reg_ack}} & sw_reg_wdata[23:16],
		               {8{sw_wr_en_10 & reg_ack}} & sw_reg_wdata[15:8] ,
		               {8{sw_wr_en_10 & reg_ack}} & sw_reg_wdata[7:0]   
		               }     ),
		 
		 //outputs
		 .data_out    (reg_9[31:0]       )
	      );
//-------------------------------------------------
// Returns same value as interrupt status register
//------------------------------------------------

assign reg_10 = reg_9;
//-----------------------------------------------------------------------
// Logic for cfg_gpio_int_mask :  GPIO interrupt mask  
//-----------------------------------------------------------------------
wire [31:0]  cfg_gpio_int_mask = reg_11[31:0]; // to be used for read

assign gpio_intr  = ( | (reg_9 & reg_11) ); // interrupt pin to the RISC


//  Register-11
gen_32b_reg  #(32'h0) u_reg_11	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_11   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_11        )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_posedge_int_sel :  Enable posedge GPIO interrupt 
//-----------------------------------------------------------------------
assign  cfg_gpio_posedge_int_sel = reg_12[31:0]; // to be used for read
gen_32b_reg  #(32'h0) u_reg_12	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_12   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_12        )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_negedge_int_sel :  Enable negedge GPIO interrupt 
//-----------------------------------------------------------------------
assign cfg_gpio_negedge_int_sel = reg_13[31:0]; // to be used for read
gen_32b_reg  #(32'h0) u_reg_13	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_13   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_13        )
	      );

//-----------------------------------------------------------------------
// Logic for cfg_multi_func_sel :Enable GPIO to act as multi function pins 
//-----------------------------------------------------------------------
assign  cfg_multi_func_sel = reg_14[31:0]; // to be used for read


gen_32b_reg  #(32'h0) u_reg_14	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_14   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_14        )
	      );

// Reg-15
gen_32b_reg  #(32'h0) u_reg_15	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_15   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_15        )
	      );
//-----------------------------------------------------------------------
// Logic for PWM-0 Config
//-----------------------------------------------------------------------
assign  cfg_pwm0_low  = reg_16[15:0];  // low period of w/f 
assign  cfg_pwm0_high = reg_16[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_16	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_16   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_16        )
	      );


//-----------------------------------------------------------------------
// Logic for PWM-1 Config
//-----------------------------------------------------------------------
assign  cfg_pwm1_low  = reg_17[15:0];  // low period of w/f 
assign  cfg_pwm1_high = reg_17[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_17	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_17   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_17         )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-2 Config
//-----------------------------------------------------------------------
assign  cfg_pwm2_low  = reg_18[15:0];  // low period of w/f 
assign  cfg_pwm2_high = reg_18[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_18	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_18   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_18        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-3 Config
//-----------------------------------------------------------------------
assign  cfg_pwm3_low  = reg_19[15:0];  // low period of w/f 
assign  cfg_pwm3_high = reg_19[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_19	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_19   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_19        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-4 Config
//-----------------------------------------------------------------------
assign  cfg_pwm4_low  = reg_20[15:0];  // low period of w/f 
assign  cfg_pwm4_high = reg_20[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_20	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_20   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_20        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-5 Config
//-----------------------------------------------------------------------
assign  cfg_pwm5_low  = reg_21[15:0];  // low period of w/f 
assign  cfg_pwm5_high = reg_21[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_21	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_21   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_21       )
	      );


//-----------------------------------------
// Software Reg-1 : ASCI Representation of RISC = 32'h8273_8343
// ----------------------------------------
gen_32b_reg  #(32'h8273_8343) u_reg_22	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_22   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_22       )
	      );

//-----------------------------------------
// Software Reg-2, Release date: <DAY><MONTH><YEAR>
// ----------------------------------------
gen_32b_reg  #(32'h1603_2022) u_reg_23	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_23   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_23       )
	      );

//-----------------------------------------
// Software Reg-3: Poject Revison 3.9 = 0003900
// ----------------------------------------
gen_32b_reg  #(32'h0003_9000) u_reg_24	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_24   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_24       )
	      );

//-----------------------------------------
// Software Reg-4
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_25	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_25   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_25       )
	      );

//-----------------------------------------
// Software Reg-5
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_26	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_26   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_26       )
	      );

//-----------------------------------------
// Software Reg-6
// ----------------------------------------
gen_32b_reg  #(32'h0) u_reg_27	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_27   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_27       )
	      );


//-----------------------------------------------------------------------
//   reg-28
// Assumption: wr_en is two cycle and reg_ack is asserted in second cycle
//     In first cycle, local register will be updated
//     In second cycle, update indication sent to timer block
//   -----------------------------------------------------------------
assign cfg_timer0          = reg_28[18:0];
assign cfg_timer_update[0] = sw_wr_en_28 & reg_ack; 

gen_32b_reg  #(32'h0) u_reg_28	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_28   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_28[31:0]  )
	      );

//-----------------------------------------------------------------------
//   reg-29
// Assumption: wr_en is two cycle and reg_ack is asserted in second cycle
//     In first cycle, local register will be updated
//     In second cycle, update indication sent to timer block
//   -----------------------------------------------------------------
assign cfg_timer1          = reg_29[18:0];
assign cfg_timer_update[1] = sw_wr_en_29 & reg_ack;

gen_32b_reg  #(32'h0) u_reg_29	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_29   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_29[31:0]  )
	      );


//-----------------------------------------------------------------------
//   reg-30
// Assumption: wr_en is two cycle and reg_ack is asserted in second cycle
//     In first cycle, local register will be updated
//     In second cycle, update indication sent to timer block
//   -----------------------------------------------------------------
assign cfg_timer2          = reg_30[18:0];
assign cfg_timer_update[2] = sw_wr_en_30 & reg_ack;

gen_32b_reg  #(32'h0) u_reg_30	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_30   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_30[31:0]  )
	      );

//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [4:0])
    5'b00000 : reg_out [31:0] = reg_0 [31:0];     
    5'b00001 : reg_out [31:0] = reg_1 [31:0];    
    5'b00010 : reg_out [31:0] = reg_2 [31:0];     
    5'b00011 : reg_out [31:0] = reg_3 [31:0];    
    5'b00100 : reg_out [31:0] = reg_4 [31:0];    
    5'b00101 : reg_out [31:0] = reg_5 [31:0];    
    5'b00110 : reg_out [31:0] = reg_6 [31:0];    
    5'b00111 : reg_out [31:0] = reg_7 [31:0];    
    5'b01000 : reg_out [31:0] = reg_8 [31:0];    
    5'b01001 : reg_out [31:0] = reg_9 [31:0];    
    5'b01010 : reg_out [31:0] = reg_10 [31:0];   
    5'b01011 : reg_out [31:0] = reg_11 [31:0];   
    5'b01100 : reg_out [31:0] = reg_12 [31:0];   
    5'b01101 : reg_out [31:0] = reg_13 [31:0];
    5'b01110 : reg_out [31:0] = reg_14 [31:0];
    5'b01111 : reg_out [31:0] = reg_15 [31:0]; 
    5'b10000 : reg_out [31:0] = reg_16 [31:0];
    5'b10001 : reg_out [31:0] = reg_17 [31:0];
    5'b10010 : reg_out [31:0] = reg_18 [31:0];
    5'b10011 : reg_out [31:0] = reg_19 [31:0];
    5'b10100 : reg_out [31:0] = reg_20 [31:0];
    5'b10101 : reg_out [31:0] = reg_21 [31:0];
    5'b10110 : reg_out [31:0] = reg_22 [31:0];
    5'b10111 : reg_out [31:0] = reg_23 [31:0];
    5'b11000 : reg_out [31:0] = reg_24 [31:0];
    5'b11001 : reg_out [31:0] = reg_25 [31:0];
    5'b11010 : reg_out [31:0] = reg_26 [31:0];
    5'b11011 : reg_out [31:0] = reg_27 [31:0];
    5'b11100 : reg_out [31:0] = reg_28 [31:0];
    5'b11101 : reg_out [31:0] = reg_29 [31:0];
    5'b11110 : reg_out [31:0] = reg_30 [31:0]; 
    5'b11111 : reg_out [31:0] = 32'h0;
    default  : reg_out [31:0] = 32'h0;
  endcase
end


endmodule                       
