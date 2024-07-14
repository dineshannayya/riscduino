// SPDX-FileCopyrightText: 2020 Efabless Corporation
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

`default_nettype none
/*	
	StriVe housekeeping SPI testbench.
*/

`timescale 1 ns / 1 ps


module caravel_hkspi_tb;
	reg clock;
	reg SDI, CSB, SCK, RSTB;
	reg power1, power2;

	wire gpio;
	wire [15:0] checkbits;
	wire [37:0] mprj_io;
	wire uart_tx;
	wire uart_rx;

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;
	wire flash_io2;
	wire flash_io3;
    reg  test_fail;

	wire SDO;

	always #10 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end

    // The main testbench is here.  Put the housekeeping SPI into
    // pass-thru mode and read several bytes from the flash SPI.

    // First define tasks for SPI functions

	task start_csb;
	    begin
		SCK <= 1'b0;
		SDI <= 1'b0;
		CSB <= 1'b0;
		#50;
	    end
	endtask

	task end_csb;
	    begin
		SCK <= 1'b0;
		SDI <= 1'b0;
		CSB <= 1'b1;
		#50;
	    end
	endtask

	task write_byte;
	    input [7:0] odata;
	    begin
		SCK <= 1'b0;
		for (i=7; i >= 0; i--) begin
		    #50;
		    SDI <= odata[i];
                    #50;
		    SCK <= 1'b1;
                    #100;
		    SCK <= 1'b0;
		end
	    end
	endtask

	task read_byte;
	    output [7:0] idata;
	    begin
		SCK <= 1'b0;
		SDI <= 1'b0;
		for (i=7; i >= 0; i--) begin
		    #50;
                    idata[i] = SDO;
                    #50;
		    SCK <= 1'b1;
                    #100;
		    SCK <= 1'b0;
		end
	    end
	endtask

	task read_write_byte
	    (input [7:0] odata,
	    output [7:0] idata);
	    begin
		SCK <= 1'b0;
		for (i=7; i >= 0; i--) begin
		    #50;
		    SDI <= odata[i];
                    idata[i] = SDO;
                    #50;
		    SCK <= 1'b1;
                    #100;
		    SCK <= 1'b0;
		end
	    end
	endtask
	
	integer i;

    // Now drive the digital signals on the housekeeping SPI
	reg [7:0] tbdata;

	initial begin
	    $dumpfile("hkspi.vcd");
	    $dumpvars(0, caravel_hkspi_tb);
        test_fail = 0;

	    CSB <= 1'b1;
	    SCK <= 1'b0;
	    SDI <= 1'b0;
	    RSTB <= 1'b0;

	    // Delay, then bring chip out of reset
	    #1000;
	    RSTB <= 1'b1;
	    #2000;

            // First do a normal read from the housekeeping SPI to
	    // make sure the housekeeping SPI works.

	    start_csb();
	    write_byte(8'h40);	// Read stream command
	    write_byte(8'h03);	// Address (register 3 = product ID)
	    read_byte(tbdata);
	    end_csb();
	    #10;
	    $display("Read data = 0x%02x (should be 0x11)", tbdata);

	    // Toggle external reset
	    start_csb();
	    write_byte(8'h80);	// Write stream command
	    write_byte(8'h0b);	// Address (register 7 = external reset)
	    write_byte(8'h01);	// Data = 0x01 (apply external reset)
	    end_csb();

	    start_csb();
	    write_byte(8'h80);	// Write stream command
	    write_byte(8'h0b);	// Address (register 7 = external reset)
	    write_byte(8'h00);	// Data = 0x00 (release external reset)
	    end_csb();

	    // Read all registers (0 to 18)
	    start_csb();
	    write_byte(8'h40);	// Read stream command
	    write_byte(8'h00);	// Address (register 3 = product ID)
	    read_byte(tbdata);

	    $display("Read register 0 = 0x%02x (should be 0x00)", tbdata);
		if(tbdata !== 8'h00) test_fail = 1;

	    read_byte(tbdata);
	    $display("Read register 1 = 0x%02x (should be 0x04)", tbdata);
		if(tbdata !== 8'h04) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 2 = 0x%02x (should be 0x56)", tbdata);
		if(tbdata !== 8'h56) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 3 = 0x%02x (should be 0x11)", tbdata);
		if(tbdata !== 8'h11) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 4 = 0x%02x (should be 0x00)", tbdata);
		if(tbdata !== 8'h00) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 5 = 0x%02x (should be 0x00)", tbdata);
		if(tbdata !== 8'h00) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 6 = 0x%02x (should be 0x00)", tbdata);
		if(tbdata !== 8'h00) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 7 = 0x%02x (should be 0x00)", tbdata);
		if(tbdata !== 8'h00) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 8 = 0x%02x (should be 0x02)", tbdata);
		if(tbdata !== 8'h02) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 9 = 0x%02x (should be 0x01)", tbdata);
		if(tbdata !== 8'h01) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 10 = 0x%02x (should be 0x00)", tbdata);
		if(tbdata !== 8'h00) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 11 = 0x%02x (should be 0x00)", tbdata);
		if(tbdata !== 8'h00) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 12 = 0x%02x (should be 0x00)", tbdata);
		if(tbdata !== 8'h00) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 13 = 0x%02x (should be 0xff)", tbdata);
		if(tbdata !== 8'hff) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 14 = 0x%02x (should be 0xef)", tbdata);
		if(tbdata !== 8'hef) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 15 = 0x%02x (should be 0xff)", tbdata);
		if(tbdata !== 8'hff) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 16 = 0x%02x (should be 0x03)", tbdata);
		if(tbdata !== 8'h03) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 17 = 0x%02x (should be 0x12)", tbdata);
		if(tbdata !== 8'h12) test_fail = 1;
	    read_byte(tbdata);
	    $display("Read register 18 = 0x%02x (should be 0x04)", tbdata);
		if(tbdata !== 8'h04) test_fail = 1;
		
        end_csb();

        if(test_fail == 0) begin
		    `ifdef GL
		    	$display("Monitor: Test %m (GL) Passed");
		    `else
		    	$display("Monitor: Test %m (RTL) Passed");
		    `endif
        end else begin
		    `ifdef GL
		    	$display("Monitor: Test %m (GL) Failed");
		    `else
		    	$display("Monitor: Test %m (RTL) Failed");
		    `endif

        end

	    #10000;
 	    $finish;
	end

	wire VDD3V3;
	wire VDD1V8;
	wire VSS;

	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	wire hk_sck;
	wire hk_csb;
	wire hk_sdi;

	assign hk_sck = SCK;
	assign hk_csb = CSB;
	assign hk_sdi = SDI;

	assign checkbits = mprj_io[31:16];
	assign uart_tx = mprj_io[6];
	assign mprj_io[5] = uart_rx;
	assign mprj_io[4] = hk_sck;
	assign mprj_io[3] = hk_csb;
	assign mprj_io[2] = hk_sdi;
	assign SDO = mprj_io[1];
	
	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("hkspi.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	tbuart tbuart (
		.ser_rx(uart_tx)
	);
		
endmodule
`default_nettype wire
