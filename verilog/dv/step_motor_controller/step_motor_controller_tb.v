////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2022 , Julien OURY                       
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
// SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>
//
////////////////////////////////////////////////////////////////////////////

`default_nettype none

`timescale 1 ns / 1 ps

module step_motor_controller_tb;
  reg clock;
  reg RSTB;
  reg CSB;
  reg power1, power2;
  reg power3, power4;

   tri gpio;

  wire [37:0] mprj_io;
  wire [15:0] checkbits;
  wire [15:0] errorbits;
  
  reg [7:0]  cmd_addr;
  reg [7:0]  cmd_data;

  assign checkbits = mprj_io[31:16];
  assign errorbits = mprj_io[15:0];
  
  assign (pull1,pull0)  mprj_io[37:0] = 38'b11111111111111111111111111111111111111;

  // External clock is used by default.  Make this artificially fast for the
  // simulation.  Normally this would be a slow clock and the digital PLL
  // would be the fast clock.

  always #12.5 clock <= (clock === 1'b0);

  initial begin
    clock = 0;
  end

`ifdef WFDUMP
  initial begin
    $dumpfile("simx.vcd");
    $dumpvars(0, step_motor_controller_tb);
  end
`endif

  initial begin
    // Repeat cycles of 1000 clock edges as needed to complete testbench
    repeat (7000) begin
      repeat (1000) @(posedge clock);
      // $display("+1000 cycles");
    end
    $display("%c[1;31m",27);
		$display ("##########################################################");
    `ifdef GL
      $display ("Monitor: Timeout, Test %m (GL) Failed");
    `else
      $display ("Monitor: Timeout, Test %m (RTL) Failed");
    `endif
		$display ("##########################################################");
    $display("%c[0m",27);
    $finish;
  end

  initial begin

    init();
    wait(checkbits == 16'hAB60);
    $display("Monitor: MPRJ-Logic WB Started");
    wait (checkbits == 16'hAB61);
    if (errorbits == 16'h0000) begin
		$display ("##########################################################");
      `ifdef GL
        $display("Monitor: %m (GL) Passed");
      `else
        $display("Monitor: %m (RTL) Passed");
      `endif
		$display ("##########################################################");
    end else begin
		$display ("##########################################################");
      `ifdef GL
        $display("Monitor: %m (GL) Failed [0x%h errors]", errorbits);
      `else
        $display("Monitor: %m (RTL) Failed [0x%h errors]", errorbits);
      `endif
		$display ("##########################################################");
    end
    $finish;
  end

  initial begin
    RSTB <= 1'b0;
    CSB  <= 1'b1;    // Force CSB high
    #2000;
    RSTB <= 1'b1;        // Release reset
    #100000;
    CSB = 1'b0;    // CSB can be released
  end

  initial begin    // Power-up sequence
	power1 <= 1'b0;
	power2 <= 1'b0;
	power3 <= 1'b0;
	power4 <= 1'b0;
	#100;
	power1 <= 1'b1;
	#100;
	power2 <= 1'b1;
	#100;
	power3 <= 1'b1;
	#100;
	power4 <= 1'b1;
  end

  wire flash_csb;
  wire flash_clk;
  wire flash_io0;
  wire flash_io1;


	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	caravel u_top (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
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
    .FILENAME("step_motor_controller.hex")
  ) spiflash (
    .csb(flash_csb),
    .clk(flash_clk),
    .io0(flash_io0),
    .io1(flash_io1),
    .io2(),      // not used
    .io3()      // not used
  );

`include "caravel_task.sv"
endmodule
`default_nettype wire
