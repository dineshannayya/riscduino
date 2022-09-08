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
////  This file is part of the riscduino project                  ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////   This is a standalone test bench to validate the            ////
////   usb interfaface through External WB i/F.                   ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 09 Mar 2022, Dinesh A                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`default_nettype wire

`timescale 1 ns / 1 ps

`define TB_GLBL    user_usb_tb
`define USB_BFM    u_usb_agent

`include "usb_agents.v"
`include "test_control.v"
`include "usb1d_defines.v"
`include "usbd_files.v"

`include "sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v"

module user_usb_tb;

parameter  CLK1_PERIOD   = 10.4167; // 48Mhz Half cycle
parameter  CLK2_PERIOD = 2.7777; // 180Mhz Half cycle
parameter real IPLL_PERIOD = 5.008;
parameter real XTAL_PERIOD = 6;

`include "user_tasks.sv"

    wire usb_48mhz_clk;

        //-----------------------------------
        // Register Interface
        // ----------------------------------
        wire [31:0]   usbd_reg_addr;   // Register Address
       	wire 	      usbd_reg_rdwrn;  // 0 -> write, 1-> read
       	wire 	      usbd_reg_req;    //  Register Req
        wire [31:0]   usbd_reg_wdata;  // Register write data
        reg [31:0]    usbd_reg_rdata;  // Register Read Data
        reg           usbd_reg_ack = 1'b1;    // Register Ack

	reg  [31:0]   RegBank [0:15];


    assign usb_48mhz_clk = clock;

	`ifdef WFDUMP
	   initial begin
	   	$dumpfile("simx.vcd");
	   	$dumpvars(0, user_usb_tb);
	   	//$dumpvars(1, user_usb_tb.u_top);
	   	//$dumpvars(1, user_usb_tb.u_top.u_uart_i2c_usb_spi);
	   	//$dumpvars(0, user_usb_tb.u_top.u_uart_i2c_usb_spi.u_usb_host);
	   	//$dumpvars(0, user_usb_tb.u_top.u_intercon);
	   	//$dumpvars(0, user_usb_tb.u_top.u_wb_host);
	   end
       `endif

        always@(posedge wb_rst_i  or posedge clock)
	begin
	   if(wb_rst_i == 1'b1) begin
              usbd_reg_rdata = 'h0;
              usbd_reg_ack   = 'h0;
	   end else begin
	      if(usbd_reg_req && usbd_reg_rdwrn == 1'b0 && !usbd_reg_ack) begin
                 usbd_reg_ack = 'h1;
		 RegBank[usbd_reg_addr[5:2]] = usbd_reg_wdata;
		 $display("STATUS: Write Access Address : %x Data: %x",usbd_reg_addr[7:0],usbd_reg_wdata);
	      end else if(usbd_reg_req && usbd_reg_rdwrn == 1'b1 && !usbd_reg_ack) begin
                 usbd_reg_ack = 'h1;
		 usbd_reg_rdata = RegBank[usbd_reg_addr[5:2]];
		 $display("STATUS: Read Access Address : %x Data: %x",usbd_reg_addr[7:0],usbd_reg_rdata);
	      end else begin
                 usbd_reg_ack = 'h0;
	      end
	   end
	end

	initial begin
		$dumpon;
         init();
		#200; // Wait for reset removal
	        repeat (10) @(posedge clock);
		$display("Monitor: Standalone User Risc Boot Test Started");

         

         // Enable USB Multi Functional Ports
         wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_MUTI_FUNC,'h10000);

	        repeat (2) @(posedge clock);
		#1;
         
	     // Set USB clock : 180/3 = 60Mhz	
         wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CLK_CTRL,{16'h0,8'h61,8'h0});

         // Remove the reset
		// Remove WB and SPI/UART Reset, Keep CORE under Reset
         wb_user_core_write(`ADDR_SPACE_GLBL+`GLBL_CFG_CFG0,'h03F);


		test_fail = 0;
	    repeat (200) @(posedge clock);
        wb_user_core_write(`ADDR_SPACE_WBHOST+`WBHOST_BANK_SEL,'h1000); // Change the Bank Sel 10


		//usb_test1;
		usb_test2;


		repeat (100) @(posedge clock);
			// $display("+1000 cycles");

          	if(test_control.error_count == 0) begin
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
	        $finish;
	end

// SSPI Slave I/F
assign io_in[5]  = 1'b1; // RESET



    usb_agent u_usb_agent();
    test_control test_control();

// Drive USB Pads
//
tri usbd_txdp = (io_oeb[24] == 1'b0) ? io_out[24] : 1'bz;
tri usbd_txdn = (io_oeb[25] == 1'b0) ? io_out[25] : 1'bz;

assign io_in[24] = usbd_txdp;
assign io_in[25] = usbd_txdn;

// Full Speed Device Indication

pullup(usbd_txdp); 
pulldown(usbd_txdn);

usb1d_top u_usb_top(

	.clk_i           (clock), 
	.rstn_i          (!wb_rst_i),
 
		// USB PHY Interface
	.usb_dp          (usbd_txdp), 
	.usb_dn          (usbd_txdn), 
 
	// USB Misc
	.phy_tx_mode     (1'b1), 
        .usb_rst         (),
 
	// Interrupts
	.dropped_frame   (), 
	.misaligned_frame(),
	.crc16_err       (),
 
	// Vendor Features
	.v_set_int       (), 
	.v_set_feature   (), 
	.wValue          (),
	.wIndex          (), 
	.vendor_data     (),
 
	// USB Status
	.usb_busy        (), 
	.ep_sel          (),
 
	// End point 1 configuration
	.ep1_cfg         (	`ISO  | `IN  | 14'd0256		),
	// End point 1 'OUT' FIFO i/f
	.ep1_dout        (					),
	.ep1_we          (					),
	.ep1_full        (		1'b0			),
	// End point 1 'IN' FIFO i/f
	.ep1_din         (		8'h0		        ),
	.ep1_re          (		   		        ),
	.ep1_empty       (		1'b0     		),
	.ep1_bf_en       (		1'b0			),
	.ep1_bf_size     (		7'h0			),
 
	// End point 2 configuration
	.ep2_cfg         (	`ISO  | `OUT | 14'd0256		),
	// End point 2 'OUT' FIFO i/f
	.ep2_dout        (				        ),
	.ep2_we          (				        ),
	.ep2_full        (		1'b0     		),
	// End point 2 'IN' FIFO i/f
	.ep2_din         (		8'h0			),
	.ep2_re          (					),
	.ep2_empty       (		1'b0			),
	.ep2_bf_en       (		1'b0			),
	.ep2_bf_size     (		7'h0			),
 
	// End point 3 configuration
	.ep3_cfg         (	`BULK | `IN  | 14'd064		),
	// End point 3 'OUT' FIFO i/f
	.ep3_dout        (					),
	.ep3_we          (					),
	.ep3_full        (		1'b0			),
	// End point 3 'IN' FIFO i/f
	.ep3_din         (		8'h0      		),
	.ep3_re          (		        		),
	.ep3_empty       (		1'b0    		),
	.ep3_bf_en       (		1'b0			),
	.ep3_bf_size     (		7'h0			),
 
	// End point 4 configuration
	.ep4_cfg         (	`BULK | `OUT | 14'd064		),
	// End point 4 'OUT' FIFO i/f
	.ep4_dout        (		        		),
	.ep4_we          (		        		),
	.ep4_full        (		1'b0     		),
	// End point 4 'IN' FIFO i/f
	.ep4_din         (		8'h0			),
	.ep4_re          (					),
	.ep4_empty       (		1'b0			),
	.ep4_bf_en       (		1'b0			),
	.ep4_bf_size     (		7'h0			),
 
	// End point 5 configuration
	.ep5_cfg         (	`INT  | `IN  | 14'd064		),
	// End point 5 'OUT' FIFO i/f
	.ep5_dout        (					),
	.ep5_we          (					),
	.ep5_full        (		1'b0			),
	// End point 5 'IN' FIFO i/f
	.ep5_din         (		8'h0     		),
	.ep5_re          (				        ),
	.ep5_empty       (		1'b0     		),
	.ep5_bf_en       (		1'b0			),
	.ep5_bf_size     (		7'h0			),
 
	// End point 6 configuration
	.ep6_cfg         (		14'h00			),
	// End point 6 'OUT' FIFO i/f
	.ep6_dout        (					),
	.ep6_we          (					),
	.ep6_full        (		1'b0			),
	// End point 6 'IN' FIFO i/f
	.ep6_din         (		8'h0			),
	.ep6_re          (					),
	.ep6_empty       (		1'b0			),
	.ep6_bf_en       (		1'b0			),
	.ep6_bf_size     (		7'h0			),
 
	// End point 7 configuration
	.ep7_cfg         (		14'h00			),
	// End point 7 'OUT' FIFO i/f
	.ep7_dout        (					),
	.ep7_we          (					),
	.ep7_full        (		1'b0			),
	// End point 7 'IN' FIFO i/f
	.ep7_din         (		8'h0			),
	.ep7_re          (					),
	.ep7_empty       (		1'b0			),
	.ep7_bf_en       (		1'b0			),
	.ep7_bf_size     (		7'h0			),
 
        // Register Interface
	.reg_addr        (usbd_reg_addr),
	.reg_rdwrn       (usbd_reg_rdwrn),
	.reg_req         (usbd_reg_req),
	.reg_wdata       (usbd_reg_wdata),
	.reg_rdata       (usbd_reg_rdata),
	.reg_ack         (usbd_reg_ack)
 
	);


//----------------------------------------------------
//  Task
// --------------------------------------------------
task test_err;
begin
     test_fail = 1;
end
endtask

`include "tests/usb_test1.v"
`include "tests/usb_test2.v"
endmodule
`default_nettype wire
