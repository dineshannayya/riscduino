/*********************************************************************************
 SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 SPDX-License-Identifier: Apache-2.0
 SPDX-FileContributor: Created by Dinesh Annayya <dinesh.annayya@gmail.com>

***********************************************************************************/
/**********************************************************************************
                                                              
                   RTC Test Bench
                                                              
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesh.annayya@gmail.com                 
                                                              
  Revision :                                                  
     0.0  - Nov 16, 2022 
            Initial Version 
     0.1  - Nov 21, 2022 
            A.Sys-clk and RTC clock domain are seperated.
            B.Register are moved to seperate module
            
************************************************************************************/
/************************************************************************************
                      Copyright (C) 2000-2002 
              Dinesh Annayya <dinesh.annayya@gmail.com>
                                                             
       This source file may be used and distributed without        
       restriction provided that this copyright statement is not   
       removed from the file and that any derivative work contains 
       the original copyright notice and the associated disclaimer.
                                                                   
           THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     
       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   
       TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   
       FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      
       OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         
       INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    
       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   
       GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        
       BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  
       LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  
       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  
       OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         
       POSSIBILITY OF SUCH DAMAGE.                                 
                                                             
************************************************************************************/

`timescale 1 ns / 1 ps



`define  CMD_C_INIT       4'h0 // Initialize the C PLI Timer
`define  CMD_C_NEXT_TIME  4'h1 // Get Next Second Value
`define  CMD_C_NEXT_DATE  4'h2 // Het Next Date value

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"

`define TB_TOP user_rtc_tb

module `TB_TOP;

parameter real CLK1_PERIOD  = 20; // 50Mhz
parameter real CLK2_PERIOD = 2.5;
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

parameter RTC_PERIOD = 30518; // 32768 Hz

`include "user_tasks.sv"

reg		    rtc_clk;
reg		    rst_n;
reg [15:0]  error_cnt;

//---------------------
// Register I/F
wire        trig_s  = u_top.u_peri.inc_time_s;
wire        trig_d  = u_top.u_peri.inc_date_d;


// Wishbone Interface

always #(RTC_PERIOD/2) rtc_clk = ~rtc_clk;

assign io_in[11] = rtc_clk;

	initial begin
		test_fail = 0;
        wbd_ext_cyc_i ='h0;  // strobe/request
        wbd_ext_stb_i ='h0;  // strobe/request
        wbd_ext_adr_i ='h0;  // address
        wbd_ext_we_i  ='h0;  // write
        wbd_ext_dat_i ='h0;  // data output
        wbd_ext_sel_i ='h0;  // byte enable
	    rtc_clk       = 0;
	    error_cnt     = 0;
	end

initial
   begin
	$value$plusargs("risc_core_id=%d", d_risc_id);
    init();

	$display("\n\n");
	$display("*****************************************************");
	$display("* RTC Test bench ...");
	$display("*****************************************************");
	$display("\n");


    normal_test;
    fast_test1;
    fast_test2;

	repeat(1000)	@(posedge clock);

    if(error_cnt > 0) test_fail = 1;

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
	repeat(10)	@(posedge clock);
	$finish;
end

`ifdef WFDUMP
   initial begin
   	  $dumpfile("simx.vcd");
   	  $dumpvars(0, `TB_TOP);
   end
`endif



wire [7:0] rtl_time   = {1'b0, u_top.u_peri.u_rtc.time_ts,u_top.u_peri.u_rtc.time_s};
wire [7:0] rtl_minute = {1'b0, u_top.u_peri.u_rtc.time_tm,u_top.u_peri.u_rtc.time_m};
wire [7:0] rtl_hour   = {1'b0, u_top.u_peri.u_rtc.time_th,u_top.u_peri.u_rtc.time_h};
wire [7:0] rtl_dow    = {5'b0, u_top.u_peri.u_rtc.time_dow};

wire [7:0] rtl_date   = {2'b0,u_top.u_peri.u_rtc.date_td,u_top.u_peri.u_rtc.date_d};
wire [7:0] rtl_month  = {2'b0,u_top.u_peri.u_rtc.date_tm,u_top.u_peri.u_rtc.date_m};
wire [15:0] rtl_year  = {u_top.u_peri.u_rtc.date_tc,u_top.u_peri.u_rtc.date_c,u_top.u_peri.u_rtc.date_ty,u_top.u_peri.u_rtc.date_y};
wire [7:0] rtl_cent   = {u_top.u_peri.u_rtc.date_tc,u_top.u_peri.u_rtc.date_c};

//---------------------------
// Normal Test Without any Over-ride
task normal_test;
reg [31:0] exp_time;
reg [31:0] cfg_time;
reg [31:0] cfg_date;
integer i;
begin
    //initialize the Timer Structure in C-PLI
   $c_rtc(`CMD_C_INIT,2022,10,19,0,0,0);
   init();

   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_TIME,{8'h01,8'h0,8'h0,8'h0});
   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_DATE,{16'h2022,8'h10,8'h19});
   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_CMD ,{30'h0,2'b01});

   for(i=0; i < 10; i = i+1) begin
     repeat(1)	@(negedge trig_s);
     exp_time = $c_rtc(1);
     wb_user_core_write(`ADDR_SPACE_RTC+`RTC_CMD ,{30'h0,2'b10});
     wb_user_core_read(`ADDR_SPACE_RTC+`RTC_TIME,cfg_time);
     wb_user_core_read(`ADDR_SPACE_RTC+`RTC_DATE,cfg_date);

     if(exp_time == {cfg_date[7:0],cfg_time[23:0]}) begin
        $display("STATUS: Exp: [Day: %02x Hour: %02x Minute: %02x Second: %02x] RTL: [Day: %02x Hour: %02x Minute: %02x Second: %02x]",
                      exp_time[31:24],exp_time[23:16],exp_time[15:8],exp_time[7:0],cfg_date[7:0],cfg_time[23:16],cfg_time[15:8],cfg_time[7:0]);
     end else begin
        error_cnt = error_cnt+1;
        $display("ERROR: Exp: [Day: %02x Hour: %02x Minute: %02x Second: %02x] RTL: [Day: %02x Hour: %02x Minute: %02x Second: %02x]",
                      exp_time[31:24],exp_time[23:16],exp_time[15:8],exp_time[7:0],cfg_date[7:0],cfg_time[23:16],cfg_time[15:8],cfg_time[7:0]);
        repeat(10) @(posedge clock);
        $finish;
     end
   end
   if(error_cnt > 0)
      $display("STATUS: Normal Test[Day, Hour,Minute,Second] without Over-ride Failed");
   else
      $display("STATUS: Normal Test[Day, Hour, Minute,Second] without Over-ride Passed");


end
endtask

//------------------------------------------------------
// Fast Time Test With Over-ride fast_sim_time=1
//------------------------------------------------------
task fast_test1;
reg [31:0] exp_time;
integer i;
begin
  //initialize the Timer Structure in C-PLI
   $c_rtc(`CMD_C_INIT,2022,10,19,0,0,0);

   init();

   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_TIME,{8'h01,8'h0,8'h0,8'h0});
   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_DATE,{16'h2022,8'h10,8'h19});
   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_CMD ,{30'h0,2'b01});

   fork
   begin
      //fast_sim_time=1;
      wb_user_core_write(`ADDR_SPACE_RTC+`RTC_CTRL ,{16'h0,2'b01,14'h400});
   end
   begin
      for(i=0; i < (65536*10); i = i+1) begin
        repeat(1)	@(negedge trig_s);
        exp_time = $c_rtc(`CMD_C_NEXT_TIME);
        if(exp_time == {rtl_date,rtl_hour,rtl_minute,rtl_time}) begin
           $display("STATUS: Exp: [Day: %02x Hour: %02x Minute: %02x Second: %02x] RTL: [Year:%04x Month: %02x Day: %02x Hour: %02x Minute: %02x Second: %02x]",
                         exp_time[31:24],exp_time[23:16],exp_time[15:8],exp_time[7:0],rtl_year,rtl_month,rtl_date,rtl_hour,rtl_minute,rtl_time);
        end else begin
           error_cnt = error_cnt+1;
           $display("ERROR: Exp: [Day: %02x Hour: %02x Minute: %02x Second: %02x] RTL: [Year:%04x Month: %02x Day: %02x Hour: %02x Minute: %02x Second: %02x]",
                         exp_time[31:24],exp_time[23:16],exp_time[15:8],exp_time[7:0],rtl_year,rtl_month,rtl_date,rtl_hour,rtl_minute,rtl_time);
           repeat(10) @(posedge clock);
           $finish;
        end
      end
    end
    join

   //fast_sim_time=0;
   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_CTRL ,{16'h0,2'b00,14'h400});

   if(error_cnt > 0)
      $display("STATUS: Fast Test1 with (Fast Time) Over-ride Failed");
   else
      $display("STATUS: Fast Test1 with (Fast Time) Over-ride Passed");
end
endtask

//------------------------------------------------------
// Fast Time Test With Over-ride fast_sim_date=1
//------------------------------------------------------
task fast_test2;
reg [31:0] exp_date;
integer i;
begin
  //initialize the Timer Structure in C-PLI
   $c_rtc(`CMD_C_INIT,2022,10,19,0,0,0);

   init();

   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_TIME,{8'h01,8'h0,8'h0,8'h0});
   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_DATE,{16'h2022,8'h10,8'h19});
   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_CMD ,{30'h0,2'b01});

   fork
   begin
      wb_user_core_write(`ADDR_SPACE_RTC+`RTC_CTRL ,{16'h0,2'b10,14'h400});
      repeat(1) @(posedge clock);
   end
   begin
      for(i=0; i < (65536*10); i = i+1) begin
        repeat(1)	@(negedge trig_d);
        exp_date = $c_rtc(`CMD_C_NEXT_DATE);
        if(exp_date == {rtl_year,rtl_month,rtl_date}) begin
           $display("STATUS: Exp: [Year: %04x Month: %02x Date: %02x] RTL: [Year:%04x Month: %02x Day: %02x]",
                         exp_date[31:16],exp_date[15:8],exp_date[7:0],rtl_year,rtl_month,rtl_date);
        end else begin
           error_cnt = error_cnt+1;
           $display("ERROR: Exp: [Year: %04x Month: %02x Date: %02x] RTL: [Year:%04x Month: %02x Day: %02x]",
                         exp_date[31:16],exp_date[15:8],exp_date[7:0],rtl_year,rtl_month,rtl_date);
           repeat(10) @(posedge clock);
           $finish;
        end
      end
   end
   join

   wb_user_core_write(`ADDR_SPACE_RTC+`RTC_CTRL ,{16'h0,2'b00,14'h0});

   if(error_cnt > 0)
      $display("STATUS: Fast Test2 with (Fast Date) Over-ride Failed");
   else
      $display("STATUS: Fast Test2 with (Fast Date) Over-ride Passed");
end
endtask







endmodule


