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
//-----------------------------------------------------------------
//                     USB Full Speed (12mbps) Phy
//                              V0.2
//                        Ultra-Embedded.com
//                          Copyright 2015
//
//                 Email: admin@ultra-embedded.com
//
//                         License: LGPL
//-----------------------------------------------------------------
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
//                          Generated File
//-----------------------------------------------------------------

module usb_transceiver
(
    // Inputs
     input           usb_phy_tx_dp_i,
     input           usb_phy_tx_dn_i,
     input           usb_phy_tx_oen_i,
     input           mode_i,

     output reg       out_dp,
     output reg       out_dn,
     output           out_tx_oen,

    // Outputs
     input            in_dp,
     input            in_dn,

     output          usb_phy_rx_rcv_o,
     output          usb_phy_rx_dp_o,
     output          usb_phy_rx_dn_o
);



//-----------------------------------------------------------------
// Module: usb_transceiver
// Emulate standard USB PHY interface and produce a D+/D- outputs.
// Allows direct connection of USB port to FPGA.
// Limitations:
// As no differential amplifier present, no common mode noise
// rejection occurs.
// Unlikely to work well with longer connections!
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Wires
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------

// D+/D- Tristate buffers
//assign usb_dp_io = (usb_phy_tx_oen_i == 1'b0) ? out_dp : 1'bz;
//assign usb_dn_io = (usb_phy_tx_oen_i == 1'b0) ? out_dn : 1'bz;
//
assign   out_tx_oen = usb_phy_tx_oen_i;

// Receive D+/D-
assign usb_phy_rx_dp_o = in_dp;
assign usb_phy_rx_dn_o = in_dn;

// Receive output
assign usb_phy_rx_rcv_o = (in_dp == 1'b1 && in_dn == 1'b0) ? 1'b1 : 1'b0;

// PHY Transmit Mode:
// When phy_tx_mode_i is '0' the outputs are encoded as:
//     vmo_i, vpo_i
//      0    0    Differential Logic '0'
//      0    1    Differential Logic '1'
//      1    0    Single Ended '0'
//      1    1    Single Ended '0'
// When phy_tx_mode_i is '1' the outputs are encoded as:
//     vmo_i, vpo_i
//      0    0    Single Ended '0'
//      0    1    Differential Logic '1'
//      1    0    Differential Logic '0'
//      1    1    Illegal State
always_comb 
begin : MUX
// Logic "0"
out_dp = 1'b0;
out_dn = 1'b1;
 case(mode_i)
    1'b0:
    begin
        if (usb_phy_tx_dp_i == 1'b0 && usb_phy_tx_dn_i == 1'b0)
        begin
            // Logic "0"
            out_dp = 1'b0;
            out_dn = 1'b1;
        end
        else if (usb_phy_tx_dp_i == 1'b0 && usb_phy_tx_dn_i == 1'b1)
        begin
            // SE0 (both low)
            out_dp = 1'b0;
            out_dn = 1'b0;
        end
        else if (usb_phy_tx_dp_i == 1'b1 && usb_phy_tx_dn_i == 1'b0)
        begin
            // Logic "1"
            out_dp = 1'b1;
            out_dn = 1'b0;
        end
        else if (usb_phy_tx_dp_i == 1'b1 && usb_phy_tx_dn_i == 1'b1)
        begin
            // SE0 (both low)
            out_dp = 1'b0;
            out_dn = 1'b0;
        end
    end
    1'b1 :
    begin
        if (usb_phy_tx_dp_i == 1'b0 && usb_phy_tx_dn_i == 1'b0)
        begin
            // SE0 (both low)
            out_dp = 1'b0;
            out_dn = 1'b0;
        end
        else if (usb_phy_tx_dp_i == 1'b0 && usb_phy_tx_dn_i == 1'b1)
        begin
            // Logic "0"
            out_dp = 1'b0;
            out_dn = 1'b1;
        end
        else if (usb_phy_tx_dp_i == 1'b1 && usb_phy_tx_dn_i == 1'b0)
        begin
            // Logic "1"
            out_dp = 1'b1;
            out_dn = 1'b0;
        end
        else if (usb_phy_tx_dp_i == 1'b1 && usb_phy_tx_dn_i == 1'b1)
        begin
            // Illegal
            out_dp = 1'b1;
            out_dn = 1'b1;
        end
    end
 endcase
end


endmodule
