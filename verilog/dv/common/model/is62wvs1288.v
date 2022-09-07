`default_nettype none
/*
 *  SPDX-FileCopyrightText: 2022 <Dinesh Annayya>
 *
 *  Riscdunio 
 *
 *  Copyright (C) 2022  Dinesh Annayya <dinesha.opencore.org>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  SPDX-License-Identifier: ISC
 */

`timescale 1 ns / 1 ps

//
// Simple SPI Ram simulation model for 128Kx8 LOW VOLTAGE, FAST SERIAL SRAM
// (IS62/65WVS1288GALL)
//
// This model samples io input signals 1ns before the SPI clock edge and
// updates output signals 1ns after the SPI clock edge.
//
// Supported commands:
//    0x03, 0x02, 0x3B , 0x38, 0xFF, 0x05 , 0x01
//    Instruction   Hex     Description
//    READ          0x03    Read data from memory array beginning at selected address
//    WRITE         0x02    Write data to memory array beginning at selected address
//    ESDI          0x3B    Enter SDI mode
//    ESQI          0x38    Enter SQI mode
//    RSTDQI        0xFF    Reset SDI/SQI mode
//    RDMR          0x05    Read Mode Register
//    WRMR          0x01    Write Mode Register
//

module is62wvs1288 #(
	//parameter mem_file_name = "firmware.hex"
	parameter mem_file_name = "none"
)(
	input csb,
	input clk,
	inout io0, // MOSI
	inout io1, // MISO
	inout io2,
	inout io3
);
	localparam verbose = 0;
	localparam integer latency = 8;
	
	reg [7:0] buffer;
	reg [3:0] reset_count = 0;
	reg [3:0] reset_monitor = 0;
	integer bitcount = 0;
	integer bytecount = 0;
	integer dummycount = 0;

	reg [7:0] spi_cmd;
	reg [23:0] spi_addr;

	reg [7:0] spi_in;
	reg [7:0] spi_out;
	reg spi_io_vld;


	localparam [1:0] sspi     = 1;
	localparam [1:0] dspi     = 2;
	localparam [1:0] qspi     = 3;

	localparam [3:0] mode_sspi_rd     = 1;
	localparam [3:0] mode_sspi_wr     = 2;
	localparam [3:0] mode_dspi_rd     = 3;
	localparam [3:0] mode_dspi_wr     = 4;
	localparam [3:0] mode_qspi_rd     = 5;
	localparam [3:0] mode_qspi_wr     = 6;

	reg [3:0] spi_phase = mode_sspi_rd;
	reg [3:0] spi_data_phase = 0;
	reg [3:0] spi_mode = sspi;

	reg io0_oe = 0;
	reg io1_oe = 0;
	reg io2_oe = 0;
	reg io3_oe = 0;

	reg io0_dout = 0;
	reg io1_dout = 0;
	reg io2_dout = 0;
	reg io3_dout = 0;

	assign #1 io0 = io0_oe ? io0_dout : 1'bz;
	assign #1 io1 = io1_oe ? io1_dout : 1'bz;
	assign #1 io2 = io2_oe ? io2_dout : 1'bz;
	assign #1 io3 = io3_oe ? io3_dout : 1'bz;

	wire io0_delayed;
	wire io1_delayed;
	wire io2_delayed;
	wire io3_delayed;

	assign #1 io0_delayed = io0;
	assign #1 io1_delayed = io1;
	assign #1 io2_delayed = io2;
	assign #1 io3_delayed = io3;

	// 128KB RAM
	reg [7:0] memory [0:128*1024-1];

	initial begin
           if (!(mem_file_name == "none"))
              $readmemh(mem_file_name,memory);
	end

	task spi_action;
		begin
		   spi_in = buffer;

		   if (bytecount == 1) begin
		   	spi_cmd = buffer;

			if (spi_cmd == 8'h 3b) begin
		   		spi_mode = dspi;
			end

			if (spi_cmd == 8'h 38) begin
		   		spi_mode = qspi;
			end

			if (spi_cmd == 8'h ff) begin
		   		spi_mode = sspi;
			end

			// spi read
		   	if (spi_cmd == 8'h 03 && spi_mode == sspi)
			   spi_phase = mode_sspi_rd;

		        // spi write
		   	if (spi_cmd == 8'h 02 && spi_mode == sspi)
			   spi_phase = mode_sspi_wr;

		        // dual spi read
		   	if (spi_cmd == 8'h 03 && spi_mode == dspi)
			   spi_phase = mode_dspi_rd;

		        // dual spi write
		   	if (spi_cmd == 8'h 02 && spi_mode == dspi)
			   spi_phase = mode_dspi_wr;

		        // quad spi read
		   	if (spi_cmd == 8'h 03 && spi_mode == qspi)
			   spi_phase = mode_qspi_rd;

		        // quad spi write
		   	if (spi_cmd == 8'h 02 && spi_mode == qspi)
			   spi_phase = mode_qspi_wr;
		   end

		   if (spi_cmd == 'h 03 || (spi_cmd == 'h 02)) begin
		   	if (bytecount == 2)
		   		spi_addr[23:16] = buffer;

		   	if (bytecount == 3)
		   		spi_addr[15:8] = buffer;

			if (bytecount == 4) begin
		   	   spi_addr[7:0] = buffer;
			   spi_data_phase = spi_phase;
			end

			// Dummy by selection at end of address phase for read
			// mode only
		   	if (bytecount == 4 && spi_mode == sspi && spi_cmd ==8'h03 )
				dummycount = 8;
		   	if (bytecount == 4 && spi_mode == dspi && spi_cmd ==8'h03)
				dummycount = 4;
		   	if (bytecount == 4 && spi_mode == qspi && spi_cmd ==8'h03)
				dummycount = 2;

		   	if (bytecount >= 4 && spi_cmd ==8'h03) begin // Data Read Phase
		   		buffer = memory[spi_addr];
				//$display("%m: Read Memory Address: %x Data: %x",spi_addr,buffer);
		   		spi_addr = spi_addr + 1;
		   	end
		   	if (bytecount > 4 && spi_cmd ==8'h02) begin // Data Write Phase
		   		memory[spi_addr] = buffer;
				//$display("%m: Write Memory Address: %x Data: %x",spi_addr,buffer);
		   		spi_addr = spi_addr + 1;
		   	end
		   end

			spi_out = buffer;
			spi_io_vld = 1;

			if (verbose) begin
				if (bytecount == 1)
					$write("<SPI-START>");
				$write("<SPI:%02x:%02x>", spi_in, spi_out);
			end

		end
	endtask


	always @(csb) begin
		if (csb) begin
			if (verbose) begin
				$display("");
				$fflush;
			end
			buffer = 0;
			bitcount = 0;
			bytecount = 0;
			io0_oe = 0;
			io1_oe = 0;
			io2_oe = 0;
			io3_oe = 0; 
			spi_data_phase = 0;

		end
	end


	always @(csb, clk) begin
		spi_io_vld = 0;
		if (!csb && !clk) begin
			if (dummycount > 0) begin
				io0_oe = 0;
				io1_oe = 0;
				io2_oe = 0;
				io3_oe = 0;
			end else
			case (spi_data_phase)
				mode_sspi_rd: begin
					io0_oe = 0;
					io1_oe = 1;
					io2_oe = 0;
					io3_oe = 0;
					io1_dout = buffer[7];
				end
				mode_sspi_wr: begin
					io0_oe = 0;
					io1_oe = 0;
					io2_oe = 0;
					io3_oe = 0;
				end
				mode_dspi_wr: begin
					io0_oe = 0;
					io1_oe = 0;
					io2_oe = 0;
					io3_oe = 0;
				end
				mode_dspi_rd: begin
					io0_oe = 1;
					io1_oe = 1;
					io2_oe = 0;
					io3_oe = 0;
					io0_dout = buffer[6];
					io1_dout = buffer[7];
				end
				mode_qspi_wr: begin
					io0_oe = 0;
					io1_oe = 0;
					io2_oe = 0;
					io3_oe = 0;
				end
				mode_qspi_rd: begin
					io0_oe = 1;
					io1_oe = 1;
					io2_oe = 1;
					io3_oe = 1;
					io0_dout = buffer[4];
					io1_dout = buffer[5];
					io2_dout = buffer[6];
					io3_dout = buffer[7];
				end
				default: begin
					io0_oe = 0;
					io1_oe = 0;
					io2_oe = 0;
					io3_oe = 0;
				end
			endcase
		end
	end

	always @(posedge clk) begin
		if (!csb) begin
			if (dummycount > 0) begin
				dummycount = dummycount - 1;
			end else
			case (spi_mode)
				sspi: begin
					buffer = {buffer, io0};
					bitcount = bitcount + 1;
					if (bitcount == 8) begin
						bitcount = 0;
						bytecount = bytecount + 1;
						spi_action;
					end
				end
				dspi: begin
					buffer = {buffer, io1, io0};
					bitcount = bitcount + 2;
					if (bitcount == 8) begin
						bitcount = 0;
						bytecount = bytecount + 1;
						spi_action;
					end
				end
				qspi: begin
					buffer = {buffer, io3, io2, io1, io0};
					bitcount = bitcount + 4;
					if (bitcount == 8) begin
						bitcount = 0;
						bytecount = bytecount + 1;
						spi_action;
					end
				end
			endcase
		end
	end
endmodule
