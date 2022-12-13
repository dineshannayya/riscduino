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
`timescale 1ns/1ps

module bfm_ir (
  output reg       ir_signal
);

  reg     p_polarity;
  integer p_period;
  integer i;
  integer state;

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // TASK : init
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task init(
    input         polarity,
    input integer tick_period_ns
  );
  begin
    $display("simetime = %g : Init IR interface with", $time);
    $display("simetime = %g :  - polarity = %b", $time, polarity);
    $display("simetime = %g :  - period to %d ns", $time, tick_period_ns); 
    
    // Parameters
    p_polarity = polarity;
    p_period = tick_period_ns;
    
    // Init output signals
    ir_signal = ~p_polarity;

  end
  endtask
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // TASK : write
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task send_nec(
    input [7:0] addr,
    input [7:0] data
  );
  begin
    $display("simetime = %g : Send IR NEC trame (0x%h -> 0x%h)", $time, addr, data);

    state = 0;
    send_start();
    
    state = 1;
    // Send address
    for (i=0 ; i<8 ; i=i+1) begin
      send_bit(addr[i]);
    end
    
    state = 2;
    // Send address (complement)
    for (i=0 ; i<8 ; i=i+1) begin
      send_bit(~addr[i]);
    end
    
    state = 3;
    // Send data
    for (i=0 ; i<8 ; i=i+1) begin
      send_bit(data[i]);
    end
    
    state = 4;
    // Send data (complement)
    for (i=0 ; i<8 ; i=i+1) begin
      send_bit(~data[i]);
    end
    
    state = 5;
    // Send stop
    send_stop();
    state = 6;
    

  end
  endtask

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // TASK : send_start
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task send_start;
  begin
    ir_signal = p_polarity;
    #(p_period*16) ir_signal = ~p_polarity;
    #(p_period*8)  ir_signal =  p_polarity;
  end 
  endtask
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // TASK : send_bit
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task send_bit(
    input reg value
  );
  begin
    ir_signal = p_polarity;
    #(p_period)  ir_signal = ~p_polarity;
    if (value == 1'b1) begin
      #(p_period*3)  ir_signal = p_polarity;
    end else begin
      #(p_period)  ir_signal = p_polarity;
    end
  end 
  endtask
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // TASK : send_stop
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task send_stop;
  begin
    ir_signal = p_polarity;
    #(p_period) ir_signal = ~p_polarity;
  end 
  endtask
  
endmodule
