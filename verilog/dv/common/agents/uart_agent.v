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
//

`timescale  1ns/1ps

module uart_agent (
	mclk,
	txd,
	rxd
	);

input	mclk;
output	txd;

input	rxd;

event	uart_read_done, uart_write_done;
event	error_detected,uart_parity_error, uart_stop_error1, uart_stop_error2;
event 	uart_timeout_error;
event	abort;

reg [15:0] rx_count;
reg [15:0] tx_count;
reg [15:0] par_err_count;
reg [15:0] stop_err1_cnt;
reg [15:0] stop_err2_cnt;
reg [15:0] timeout_err_cnt;
reg [15:0] err_cnt;
reg        uart_rxenb; // uart rx enable

reg 	   txd, read, write;
wire	   uart_rx_clk;
reg	   uart_clk;
reg	   stop_err_check;

integer timeout_count;
integer data_bit_number;
reg [15:0] clk_count;
reg        debug_mode;

reg      error_ind; // 1 indicate error

initial 
begin
    uart_rxenb = 0;
	debug_mode = 1; // Keep in debug mode and enable display
	txd = 1'b1;
 	uart_clk = 0;
	clk_count = 0;
	stop_err_check = 0;
  error_ind = 0;
end

always @(posedge mclk)
begin
   if (clk_count == 'h0) begin
      uart_clk  = ~uart_clk;
      clk_count = control_setup.divisor;	
   end else begin
      clk_count = clk_count - 1;	
   end
end
assign uart_rx_clk = uart_clk;

always @(posedge mclk)
begin
    if(uart_rxenb) begin
      	timeout_count = timeout_count + 1;
      	if (timeout_count >= (control_setup.maxtime * 16)) begin
            timeout_count = 0;
            uart_rxenb    = 0;
      	    -> abort;
        end
    end else begin
      	timeout_count = 0;
    end
end

always @uart_read_done
    rx_count = rx_count + 1;

always @uart_write_done
    tx_count = tx_count + 1;

always @uart_parity_error begin
    error_ind = 1;
    par_err_count = par_err_count + 1;
end

always @uart_stop_error1 begin
    error_ind = 1;
    stop_err1_cnt = stop_err1_cnt + 1;
end

always @uart_stop_error2 begin
    error_ind = 1;
    stop_err2_cnt = stop_err2_cnt + 1;
end

always @uart_timeout_error begin
    error_ind = 1;
    timeout_err_cnt = timeout_err_cnt + 1;
end


always @error_detected begin
    error_ind = 1;
    err_cnt = err_cnt + 1;
end


////////////////////////////////////////////////////////////////////////////////
task uart_init;
begin
  uart_rxenb = 0;
  read = 0;
  write = 0;
  tx_count = 0;
  rx_count = 0;
  stop_err_check = 0;
  par_err_count = 0;
  stop_err1_cnt = 0;
  stop_err2_cnt = 0;
  timeout_err_cnt = 0;
  err_cnt = 0;
  clk_count = 0;

end 
endtask 


////////////////////////////////////////////////////////////////////////////////
task read_char_chk;
input [7:0]	expected_data;

integer i;
reg 	[7:0] data;
reg	parity;

begin
	data = 8'h0;
	parity = 1;
	timeout_count = 0;
    uart_rxenb = 1;

fork	
   begin : loop_1
        @(abort)
	if(debug_mode)
         $display ("%m: >>>>> Exceed time limit, uart no responce.\n");
         ->uart_timeout_error;
         disable loop_2;
   end

   begin : loop_2

// start cycle
	@(negedge rxd) 
	 disable loop_1;

    // Cross-check We enter Due any glitch in rxd (in Gate Sim) then expit
	@(negedge mclk)
    if(rxd== 1)  disable loop_2;

	@(posedge mclk)
    if(rxd== 1)  disable loop_2;

    // Now Bit Extraction Start
	 read = 1;

// data cycle
	@(posedge uart_rx_clk);
	 for (i = 0; i < data_bit_number; i = i + 1)
	  begin
	    @(posedge uart_rx_clk)
	    data[i] =  rxd;
	    parity = parity ^ rxd;
	  end		

// parity cycle
	if(control_setup.parity_en)
	begin
          @(posedge uart_rx_clk);
	  if ((control_setup.even_odd_parity && (rxd == parity)) ||
	     (!control_setup.even_odd_parity && (rxd != parity)))
	     begin
		   $display ("%m: >>>>>  Parity Error");	
 		-> error_detected;
		-> uart_parity_error;
	     end
	end

// stop cycle 1
        @(posedge uart_rx_clk);	
	  if (!rxd)
	     begin
		$display ("%m: >>>>>  Stop signal 1 Error");	
 		-> error_detected;
		-> uart_stop_error1;
	     end

// stop cycle 2
	if (control_setup.stop_bit_number)
	begin
	      @(posedge uart_rx_clk);	// stop cycle 2
		if (!rxd)
		  begin
		    $display ("%m: >>>>>  Stop signal 2 Error");	
 		    -> error_detected;
		    -> uart_stop_error2;
		  end
	end

	read = 0;
	-> uart_read_done;

	if (expected_data != data)
	begin
		$display ("%m: Error! Data return is %h, expecting %h", data, expected_data);
		-> error_detected;
	end
	else begin
	        if(debug_mode)
		  $display ("%m: Data match  %h", expected_data);
	end

	if(debug_mode)
	   $display ("%m:... Read Data from UART done cnt :%d...",rx_count +1);
   end
join
    uart_rxenb = 0;

end

endtask

////////////////////////////////////////////////////////////////////////////////
task read_char2;
output [7:0]	rxd_data;
output          timeout; // 1-> timeout
integer j;
reg	[7:0] rxd_data;
reg 	[7:0] data;
reg	parity;

begin
	data = 8'h0;
	parity = 1;
	timeout_count = 0;
	timeout = 0;
    uart_rxenb = 1;

   fork	
   begin 
        @(abort)
         //$display (">>>>>  Exceed time limit, uart no responce.\n");
         //->uart_timeout_error;
	  timeout = 1;
   end

   begin

// start cycle
	@(negedge rxd) 
	 read = 1;

// data cycle
	@(posedge uart_rx_clk );
	 for (j = 0; j < data_bit_number; j = j + 1)
	  begin
	    @(posedge uart_rx_clk)
	    data[j] =  rxd;
	    parity = parity ^ rxd;
	  end		

// parity cycle
	if(control_setup.parity_en)
	begin
          @(posedge uart_rx_clk);
	  if ((control_setup.even_odd_parity && (rxd == parity)) ||
	     (!control_setup.even_odd_parity && (rxd != parity)))
	     begin
		$display (">>>>>  Parity Error");	
 		-> error_detected;
		-> uart_parity_error;
	     end
	end

// stop cycle 1
        @(posedge uart_rx_clk);	
	  if (!rxd)
	     begin
		$display (">>>>>  Stop signal 1 Error");	
 		-> error_detected;
		-> uart_stop_error1;
	     end

// stop cycle 2
	if (control_setup.stop_bit_number)
	begin
	      @(posedge uart_rx_clk);	// stop cycle 2
		if (!rxd)
		  begin
		    $display (">>>>>  Stop signal 2 Error");	
 		    -> error_detected;
		    -> uart_stop_error2;
		  end
	end

	read = 0;
	-> uart_read_done;

//      $display ("(%m) Received Data  %c", data);
//	$display ("... Read Data from UART done cnt :%d...",rx_count +1);
        $write ("%c",data);
	rxd_data = data;
   end
   join_any
   disable fork; //disable pending fork activity

    uart_rxenb = 0;
end

endtask


////////////////////////////////////////////////////////////////////////////////
task read_char;
output [7:0]	rxd_data;
output          timeout; // 1-> timeout

reg	[7:0] rxd_data;


integer i;
reg 	[7:0] data;
reg	parity;

begin
    rxd_data = 8'h0;
	data = 8'h0;
	parity = 1;
	timeout_count = 0;
	timeout = 0;
    uart_rxenb = 1;


fork	
   begin : loop_1
        @(abort)
	 if(debug_mode)
             $display ("%m: >>>>> Exceed time limit, uart no responce.\n");
	 timeout = 1;
         ->uart_timeout_error;
         disable loop_2;
   end

   begin : loop_2

// start cycle
	@(negedge rxd) 
	 disable loop_1;

    // Cross-check We enter Due any glitch in rxd (in Gate Sim) then expit
	@(negedge mclk)
    if(rxd== 1)  disable loop_2;

	@(posedge mclk)
    if(rxd== 1)  disable loop_2;

    // Now Bit Extraction Start
	 read = 1;

// data cycle
	@(posedge uart_rx_clk);
	 for (i = 0; i < data_bit_number; i = i + 1)
	  begin
	    @(posedge uart_rx_clk)
	    data[i] =  rxd;
	    parity = parity ^ rxd;
	  end		

// parity cycle
	if(control_setup.parity_en)
	begin
          @(posedge uart_rx_clk);
	  if ((control_setup.even_odd_parity && (rxd == parity)) ||
	     (!control_setup.even_odd_parity && (rxd != parity)))
	     begin
		$display ("%m: >>>>>  Parity Error");	
 		-> error_detected;
		-> uart_parity_error;
	     end
	end

// stop cycle 1
        @(posedge uart_rx_clk);	
	  if (!rxd)
	     begin
		$display ("%m: >>>>>  Stop signal 1 Error");	
 		-> error_detected;
		-> uart_stop_error1;
	     end

// stop cycle 2
	if (control_setup.stop_bit_number)
	begin
	      @(posedge uart_rx_clk);	// stop cycle 2
		if (!rxd)
		  begin
		    $display ("%m: >>>>>  Stop signal 2 Error");	
 		    -> error_detected;
		    -> uart_stop_error2;
		  end
	end

	read = 0;
	-> uart_read_done;

	rxd_data = data;


	if(debug_mode) begin
	   $display ("%m: Received Data %h", rxd_data);
	   $display ("%m:... Read Data from UART done cnt :%d...",rx_count +1);
        end
   end
join
    uart_rxenb = 0;

end

endtask


// Read Task without Timeout
task read_char3;
output [7:0]	rxd_data;
reg	[7:0] rxd_data;
integer i;
reg 	[7:0] data;
reg	parity;

begin
	data = 8'h0;
	parity = 1;
    uart_rxenb = 1;


fork	
   begin : loop_2

// start cycle
	@(negedge rxd) 
	 read = 1;

// data cycle
	@(posedge uart_rx_clk);
	 for (i = 0; i < data_bit_number; i = i + 1)
	  begin
	    @(posedge uart_rx_clk)
	    data[i] =  rxd;
	    parity = parity ^ rxd;
	  end		

// parity cycle
	if(control_setup.parity_en)
	begin
          @(posedge uart_rx_clk);
	  if ((control_setup.even_odd_parity && (rxd == parity)) ||
	     (!control_setup.even_odd_parity && (rxd != parity)))
	     begin
		$display ("%m: >>>>>  Parity Error");	
 		-> error_detected;
		-> uart_parity_error;
	     end
	end

// stop cycle 1
        @(posedge uart_rx_clk);	
	  if (!rxd)
	     begin
		$display ("%m: >>>>>  Stop signal 1 Error");	
 		-> error_detected;
		-> uart_stop_error1;
	     end

// stop cycle 2
	if (control_setup.stop_bit_number)
	begin
	      @(posedge uart_rx_clk);	// stop cycle 2
		if (!rxd)
		  begin
		    $display ("%m: >>>>>  Stop signal 2 Error");	
 		    -> error_detected;
		    -> uart_stop_error2;
		  end
	end

	read = 0;
	-> uart_read_done;

	rxd_data = data;
   end
join
    uart_rxenb = 0;

end

endtask

////////////////////////////////////////////////////////////////////////////////
task write_char;
input [7:0] data;

integer i;
reg parity;	// 0: odd parity, 1: even parity

begin
	parity =  #1 1;

// start cycle
	@(posedge uart_clk)
	 begin
		txd = #1 0;
		write = #1 1;
	 end

// data cycle
	begin
	   for (i = 0; i < data_bit_number; i = i + 1)
	   begin
		@(posedge uart_clk)
		    txd = #1 data[i];
		parity = parity ^ data[i];
	   end
	end

// parity cycle
	if (control_setup.parity_en)
	begin
		@(posedge uart_clk)
			txd = #1 
//				control_setup.stick_parity ? ~control_setup.even_odd_parity : 
				control_setup.even_odd_parity ? !parity : parity;
	end

// stop cycle 1
	@(posedge uart_clk)
		txd = #1 stop_err_check ? 0 : 1;

// stop cycle 2
	@(posedge uart_clk);
		txd = #1 1;
	if (data_bit_number == 5)
		@(negedge uart_clk);
	else if (control_setup.stop_bit_number)
		@(posedge uart_clk);

	write = #1 0;
	if(debug_mode)
	   $display ("%m:... Write data %h to UART done cnt : %d ...\n", data,tx_count+1);
        else
	   $write ("%c",data);
	-> uart_write_done;
end
endtask


////////////////////////////////////////////////////////////////////////////////
task control_setup;
input	  [1:0] data_bit_set;	
input		stop_bit_number;
input		parity_en;
input		even_odd_parity;
input		stick_parity;
input	 [15:0] maxtime;
input	 [15:0] divisor;

begin
        clk_count = divisor;	
	data_bit_number = data_bit_set + 5;
end
endtask


////////////////////////////////////////////////////////////////////////////////
task report_status;
output 	[15:0] rx_nu;
output 	[15:0] tx_nu;
begin
	$display ("-------------------- UART Reporting Configuration --------------------");
	$display ("	Data bit number setting is : %0d", data_bit_number);
	$display ("	Stop bit number setting is : %0d", control_setup.stop_bit_number + 1);
	$display ("	Divisor of Uart clock   is : %0d", control_setup.divisor);
	if (control_setup.parity_en) 
	$display ("	Parity is enable");
	else
	$display ("	Parity is disable");
	
	if (control_setup.even_odd_parity)
	$display ("	Even parity setting");
	else	
	$display ("	Odd parity setting");


	$display ("-----------------------------------------------------------------");

	$display ("-------------------- Reporting Status --------------------\n");
	$display ("	Number of character received is : %d", rx_count);
	$display ("	Number of character sent     is : %d", tx_count);
	$display ("	Number of parity error rxd   is : %d", par_err_count);
	$display ("	Number of stop1  error rxd   is : %d", stop_err1_cnt);
	$display ("	Number of stop2  error rxd   is : %d", stop_err2_cnt);
	$display ("	Number of timeout error      is : %d", timeout_err_cnt);
	$display ("	Number of error              is : %d", err_cnt);
	$display ("-----------------------------------------------------------------");

	rx_nu = rx_count;
	tx_nu = tx_count;
end
endtask


////////////////////////////////////////////////////////////////////////////////
endmodule
