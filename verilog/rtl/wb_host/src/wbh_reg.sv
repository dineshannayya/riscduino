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
// SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>
//
//////////////////////////////////////////////////////////////////////

`include "user_params.svh"
module wbh_reg  (
                       // System Signals
                       // Inputs
		               input logic           mclk               ,
	                   input logic          e_reset_n          ,  // external reset
	                   input logic          p_reset_n          ,  // power-on reset
                       input logic          s_reset_n          ,  // soft reset
                       input logic          int_pll_clock      ,

                       input   logic         clk_enb            ,
                       input   logic         force_refclk       ,
                       input   logic         soft_reboot        ,
	                   output  logic [31:0]  system_strap       ,
	                   input   logic [31:0]  strap_sticky       ,
      
                       input logic           user_clock1        ,
                       input logic           user_clock2        ,
                       input   logic         xtal_clk           ,

		               // Reg Bus Interface Signal
                       input logic           reg_cs             ,
                       input logic           reg_wr             ,
                       input logic [2:0]     reg_addr           ,
                       input logic [31:0]    reg_wdata          ,
                       input logic [3:0]     reg_be             ,

                       // Outputs
                       output logic [31:0]   reg_rdata          ,
                       output logic          reg_ack            ,


                       // Global Reset control
                       output logic          wbd_int_rst_n      ,
                       output logic          wbd_pll_rst_n      ,

                       // CPU Clock and Reset
                       output logic          cpu_clk            ,

                       // WishBone Slave Clkout/in
                       output  logic         wbs_clk_out        ,  // System clock

              
                       output  logic [15:0]  cfg_bank_sel       ,
                       output logic [31:0]   cfg_clk_skew_ctrl1 ,
                       output logic [31:0]   cfg_clk_skew_ctrl2 ,

                       output logic          cfg_fast_sim       
    );

logic [2:0]         sw_addr               ;
logic [3:0]         sw_be                 ;
logic               sw_rd_en              ;
logic               sw_wr_en              ;
logic               sw_wr_en_0            ;
logic               sw_wr_en_1            ;
logic               sw_wr_en_2            ;
logic               sw_wr_en_3            ;
logic               sw_wr_en_4            ;
logic               sw_wr_en_5            ;
logic [31:0]        reg_out               ;

logic [31:0]        reg_0                 ;  // Software_Reg_0
logic [7:0]         cfg_clk_ctrl         ;
logic  [3:0]        cfg_wb_clk_ctrl       ;
logic  [3:0]        cfg_cpu_clk_ctrl      ;
logic  [15:0]       cfg_glb_ctrl          ;
logic               wbs_clk_div           ;
logic               wbs_ref_clk_div_2     ;
logic               wbs_ref_clk_div_4     ;
logic               wbs_ref_clk_div_8     ;


assign  sw_addr       = reg_addr ;
assign  sw_be         = reg_be ;
assign  sw_rd_en      = reg_cs & !reg_wr;
assign  sw_wr_en      = reg_cs & reg_wr;

assign  sw_wr_en_0 = sw_wr_en && (sw_addr==0);
assign  sw_wr_en_1 = sw_wr_en && (sw_addr==1);
assign  sw_wr_en_2 = sw_wr_en && (sw_addr==2);
assign  sw_wr_en_3 = sw_wr_en && (sw_addr==3);
assign  sw_wr_en_4 = sw_wr_en && (sw_addr==4);
assign  sw_wr_en_5 = sw_wr_en && (sw_addr==5);

always @ (posedge mclk or negedge p_reset_n)
begin : preg_out_Seq
   if (p_reset_n == 1'b0)
   begin
      reg_rdata  <= 'h0;
      reg_ack    <= 1'b0;
   end
   else if (sw_rd_en && !reg_ack) 
   begin
      reg_rdata <= reg_out ;
      reg_ack   <= 1'b1;
   end
   else if (sw_wr_en && !reg_ack) 
      reg_ack          <= 1'b1;
   else
   begin
      reg_ack        <= 1'b0;
   end
end


//-----------------------------------
// reg-out mux
//-----------------------------------

always @( *)
begin 
  reg_out [31:0] = 'h0;

  case (sw_addr [2:0])
    3'b000 :   reg_out [31:0] = {8'h0,cfg_clk_ctrl[7:0],cfg_glb_ctrl[15:0]};
    3'b001 :   reg_out [31:0] = {16'h0,cfg_bank_sel [15:0]};     
    3'b010 :   reg_out [31:0] = cfg_clk_skew_ctrl1 [31:0];    
    3'b011 :   reg_out [31:0] = cfg_clk_skew_ctrl2[31:0];    
    3'b101 :   reg_out [31:0] = system_strap [31:0];     
    default : reg_out [31:0] = 'h0;
  endcase
end


//-----------------------------------
// reg-0
//-------------------------------------

// Reset control
// On Power-up wb & pll power default enabled
ctech_buf u_buf_wb_rst        (.A(cfg_glb_ctrl[0] & s_reset_n),.X(wbd_int_rst_n));
// Change to p_reset to avoid pll reset on every system reset
ctech_buf u_buf_pll_rst       (.A(cfg_glb_ctrl[1] & p_reset_n),.X(wbd_pll_rst_n)); 

//assign cfg_fast_sim        = cfg_glb_ctrl[8]; 
ctech_clk_buf u_fastsim_buf (.A (cfg_glb_ctrl[8]), . X(cfg_fast_sim)); // To Bypass Reset FSM initial wait time
gen_16b_reg #(16'h3  ) u_glb_ctrl (
          .cs            (sw_wr_en_0       ),
	      .we            (sw_be[1:0]       ),		 
	      .data_in       (reg_wdata[15:0]  ),
	      .reset_n       (e_reset_n        ),
	      .clk           (mclk             ),
	      
	      //List of Outs
	      .data_out      (cfg_glb_ctrl[15:0])
          );


//--------------------------------
// clock control
//--------------------------------
assign cfg_wb_clk_ctrl      = cfg_clk_ctrl[3:0];
assign cfg_cpu_clk_ctrl     = cfg_clk_ctrl[7:4];
always @ (posedge mclk) begin 
  if (p_reset_n == 1'b0) begin
     cfg_clk_ctrl  <= strap_sticky[7:0] ;
  end
  else begin 
     if(sw_wr_en_0 & sw_be[2] ) 
       cfg_clk_ctrl   <= reg_wdata[23:16];
  end
end
//-------------------------------------------------
// reg-1
//-------------------------------------------------

generic_register #(16,16'h1000 ) u_bank_sel (
	      .we            ({16{sw_wr_en_1}}   ),		 
	      .data_in       (reg_wdata[15:0]    ),
	      .reset_n       (e_reset_n         ),
	      .clk           (mclk         ),
	      
	      //List of Outs
	      .data_out      (cfg_bank_sel[15:0] )
          );

//-----------------------------------------------
// reg-2: clock skew control-1
//----------------------------------------------

wire [31:0] rst_clk_ctrl1;

assign rst_clk_ctrl1[3:0]   = (strap_sticky[`STRAP_SCLK_SKEW_WI] == 2'b00) ? CLK_SKEW1_RESET_VAL[3:0] :
                              (strap_sticky[`STRAP_SCLK_SKEW_WI] == 2'b01) ? CLK_SKEW1_RESET_VAL[3:0] + 2 :
                              (strap_sticky[`STRAP_SCLK_SKEW_WI] == 2'b10) ? CLK_SKEW1_RESET_VAL[3:0] + 4 : CLK_SKEW1_RESET_VAL[3:0]-4;

assign rst_clk_ctrl1[7:4]   = (strap_sticky[`STRAP_SCLK_SKEW_WH] == 2'b00) ? CLK_SKEW1_RESET_VAL[7:4]  :
                              (strap_sticky[`STRAP_SCLK_SKEW_WH] == 2'b01) ? CLK_SKEW1_RESET_VAL[7:4] + 2 :
                              (strap_sticky[`STRAP_SCLK_SKEW_WH] == 2'b10) ? CLK_SKEW1_RESET_VAL[7:4] + 4 : CLK_SKEW1_RESET_VAL[7:4]-4;

assign rst_clk_ctrl1[11:8]  = (strap_sticky[`STRAP_SCLK_SKEW_RISCV] == 2'b00) ?  CLK_SKEW1_RESET_VAL[11:8]  :
                              (strap_sticky[`STRAP_SCLK_SKEW_RISCV] == 2'b01) ?  CLK_SKEW1_RESET_VAL[11:8] + 2 :
                              (strap_sticky[`STRAP_SCLK_SKEW_RISCV] == 2'b10) ?  CLK_SKEW1_RESET_VAL[11:8] + 4 : CLK_SKEW1_RESET_VAL[11:8]-4;

assign rst_clk_ctrl1[15:12] = (strap_sticky[`STRAP_SCLK_SKEW_QSPI] == 2'b00) ?  CLK_SKEW1_RESET_VAL[15:12]  :
                              (strap_sticky[`STRAP_SCLK_SKEW_QSPI] == 2'b01) ?  CLK_SKEW1_RESET_VAL[15:12] + 2 :
                              (strap_sticky[`STRAP_SCLK_SKEW_QSPI] == 2'b10) ?  CLK_SKEW1_RESET_VAL[15:12] + 4 : CLK_SKEW1_RESET_VAL[15:12]-4;

assign rst_clk_ctrl1[19:16] = (strap_sticky[`STRAP_SCLK_SKEW_UART] == 2'b00) ?  CLK_SKEW1_RESET_VAL[19:16]  :
                              (strap_sticky[`STRAP_SCLK_SKEW_UART] == 2'b01) ?  CLK_SKEW1_RESET_VAL[19:16] + 2 :
                              (strap_sticky[`STRAP_SCLK_SKEW_UART] == 2'b10) ?  CLK_SKEW1_RESET_VAL[19:16] + 4 : CLK_SKEW1_RESET_VAL[19:16]-4;

assign rst_clk_ctrl1[23:20] = (strap_sticky[`STRAP_SCLK_SKEW_PINMUX] == 2'b00) ?  CLK_SKEW1_RESET_VAL[23:20]  :
                              (strap_sticky[`STRAP_SCLK_SKEW_PINMUX] == 2'b01) ?  CLK_SKEW1_RESET_VAL[23:20] + 2 :
                              (strap_sticky[`STRAP_SCLK_SKEW_PINMUX] == 2'b10) ?  CLK_SKEW1_RESET_VAL[23:20] + 4 : CLK_SKEW1_RESET_VAL[23:20]-4;

assign rst_clk_ctrl1[27:24] = (strap_sticky[`STRAP_SCLK_SKEW_QSPI_CO] == 2'b00) ?  CLK_SKEW1_RESET_VAL[27:24] :
                              (strap_sticky[`STRAP_SCLK_SKEW_QSPI_CO] == 2'b01) ?  CLK_SKEW1_RESET_VAL[27:24] + 2 :
                              (strap_sticky[`STRAP_SCLK_SKEW_QSPI_CO] == 2'b10) ?  CLK_SKEW1_RESET_VAL[27:24] + 4 : CLK_SKEW1_RESET_VAL[27:24]-4;

assign rst_clk_ctrl1[31:28] = CLK_SKEW1_RESET_VAL[31:28];


always @ (posedge mclk ) begin 
  if (p_reset_n == 1'b0) begin
     cfg_clk_skew_ctrl1  <= rst_clk_ctrl1 ;
  end
  else begin 
     if(sw_wr_en_2 ) 
       cfg_clk_skew_ctrl1   <= reg_wdata[31:0];
  end
end

//-----------------------------------------------
// reg-3: clock skew control-2
//     This skew control the RISCV clock, Since riscv clock need to stable on power-up
//     we have not given any strap control for it.
//----------------------------------------------

always @ (posedge mclk ) begin 
  if (p_reset_n == 1'b0) begin
     cfg_clk_skew_ctrl2  <= CLK_SKEW2_RESET_VAL ;
  end
  else begin 
     if(sw_wr_en_3 ) 
       cfg_clk_skew_ctrl2   <= reg_wdata[31:0];
  end
end

//-------------------------------------------------------------
// Note: system_strap reset (p_reset_n) will be released
//     eariler than s_reset_n to take care of strap loading
//--------------------------------------------------------------
always @ (posedge mclk) begin 
  if (s_reset_n == 1'b0) begin
     system_strap  <= {soft_reboot,strap_sticky[30:0]};
  end
  else if(sw_wr_en_5 ) begin
       system_strap   <= reg_wdata;
  end
end



//----------------------------------
// Generate Internal WishBone Clock
//----------------------------------
logic         wb_clk_div;
logic         wbs_ref_clk_int;
logic         wbs_ref_clk;

wire  [1:0]   cfg_wb_clk_src_sel   =  cfg_wb_clk_ctrl[1:0];
wire  [1:0]   cfg_wb_clk_ratio     =  cfg_wb_clk_ctrl[3:2];

 // Keep WBS in Ref clock during initial boot to strap loading 
assign wbs_ref_clk_int = (cfg_wb_clk_src_sel ==2'b00) ? user_clock1 :
                         (cfg_wb_clk_src_sel ==2'b01) ? user_clock2 :	
                         (cfg_wb_clk_src_sel ==2'b10) ? int_pll_clock :	xtal_clk;

ctech_clk_buf u_wbs_ref_clkbuf (.A (wbs_ref_clk_int), . X(wbs_ref_clk));
ctech_clk_gate u_clkgate_wbs (.GATE (clk_enb), . CLK(wbs_clk_div), .GCLK(wbs_clk_out));

assign wbs_clk_div   =(force_refclk)             ? user_clock1 :
                      (cfg_wb_clk_ratio == 2'b00) ? wbs_ref_clk :
                      (cfg_wb_clk_ratio == 2'b01) ? wbs_ref_clk_div_2 :
                      (cfg_wb_clk_ratio == 2'b10) ? wbs_ref_clk_div_4 : wbs_ref_clk_div_8;

clk_div8  u_wbclk (
   // Outputs
       .clk_div_8     (wbs_ref_clk_div_8      ),
       .clk_div_4     (wbs_ref_clk_div_4      ),
       .clk_div_2     (wbs_ref_clk_div_2      ),
   // Inputs
       .mclk          (wbs_ref_clk            ),
       .reset_n       (p_reset_n              ) 
   );


//----------------------------------
// Generate CORE Clock Generation
//----------------------------------
wire   cpu_clk_div;
wire   cpu_ref_clk_int;
wire   cpu_ref_clk;
wire   cpu_clk_int;
wire   cpu_ref_clk_div_2;
wire   cpu_ref_clk_div_4;
wire   cpu_ref_clk_div_8;

wire [1:0] cfg_cpu_clk_src_sel   = cfg_cpu_clk_ctrl[1:0];
wire [1:0] cfg_cpu_clk_ratio     = cfg_cpu_clk_ctrl[3:2];

assign cpu_ref_clk_int = (cfg_cpu_clk_src_sel ==2'b00) ? user_clock1 :
                         (cfg_cpu_clk_src_sel ==2'b01) ? user_clock2 :	
                         (cfg_cpu_clk_src_sel ==2'b10) ? int_pll_clock : xtal_clk;	

ctech_clk_buf u_cpu_ref_clkbuf (.A (cpu_ref_clk_int), . X(cpu_ref_clk));

ctech_clk_gate u_clkgate_cpu (.GATE (clk_enb), . CLK(cpu_clk_div), .GCLK(cpu_clk));

assign cpu_clk_div   = (cfg_wb_clk_ratio == 2'b00) ? cpu_ref_clk :
                       (cfg_wb_clk_ratio == 2'b01) ? cpu_ref_clk_div_2 :
                       (cfg_wb_clk_ratio == 2'b10) ? cpu_ref_clk_div_4 : cpu_ref_clk_div_8;


clk_div8 u_cpuclk (
   // Outputs
       .clk_div_8     (cpu_ref_clk_div_8      ),
       .clk_div_4     (cpu_ref_clk_div_4      ),
       .clk_div_2     (cpu_ref_clk_div_2      ),
   // Inputs
       .mclk          (cpu_ref_clk            ),
       .reset_n       (p_reset_n              )
   );





endmodule
