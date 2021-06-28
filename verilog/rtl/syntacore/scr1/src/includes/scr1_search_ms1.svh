//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: Syntacore LLC © 2016-2021
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
// SPDX-FileContributor: Syntacore LLC
// //////////////////////////////////////////////////////////////////////////
/// @file       <scr1_search_ms1.svh>
/// @brief      Most significant one search function
///

`ifndef SCR1_SEARCH_MS1_SVH
`define SCR1_SEARCH_MS1_SVH

//-------------------------------------------------------------------------------
// Local types declaration
//-------------------------------------------------------------------------------
typedef struct packed {
    logic       vd;
    logic       idx;
} type_scr1_search_one_2_s;

typedef struct packed {
    logic           vd;
    logic [4:0]     idx;
} type_scr1_search_one_32_s;

//-------------------------------------------------------------------------------
// Leading Zeros Count Function
//-------------------------------------------------------------------------------
function automatic type_scr1_search_one_2_s scr1_lead_zeros_cnt_2(
    input   logic [1:0]     din
);
    type_scr1_search_one_2_s tmp;
begin
    tmp.vd  = |din;
    tmp.idx = ~din[1];
    scr1_lead_zeros_cnt_2 =  tmp;
end
endfunction

function automatic logic [4:0] scr1_lead_zeros_cnt_32(
    input   logic [31:0]    din
);
begin
    logic [15:0]    stage1_vd;
    logic [7:0]     stage2_vd;
    logic [3:0]     stage3_vd;
    logic [1:0]     stage4_vd;

    logic           stage1_idx [15:0];
    logic [1:0]     stage2_idx [7:0];
    logic [2:0]     stage3_idx [3:0];
    logic [3:0]     stage4_idx [1:0];
    type_scr1_search_one_32_s tmp;
    logic [4:0]     res;
    integer         i;

    // Stage 1
    for (i=0; i<16; i=i+1) begin // cp.4
        type_scr1_search_one_2_s tmp;
        tmp = scr1_lead_zeros_cnt_2(din[(i+1)*2-1-:2]);
        stage1_vd[i]  = tmp.vd;
        stage1_idx[i] = tmp.idx;
    end

    // Stage 2
    for (i=0; i<8;i=i+1) begin // cp.4
        type_scr1_search_one_2_s tmp;
        tmp = scr1_lead_zeros_cnt_2(stage1_vd[(i+1)*2-1-:2]);
        stage2_vd[i]  = tmp.vd;
        stage2_idx[i] = (tmp.idx) ? {tmp.idx, stage1_idx[2*i]} : {tmp.idx, stage1_idx[2*i+1]};
    end

    // Stage 3
    for (i=0; i<4; i=i+1) begin // cp.4
        type_scr1_search_one_2_s tmp;
        tmp = scr1_lead_zeros_cnt_2(stage2_vd[(i+1)*2-1-:2]);
        stage3_vd[i]  = tmp.vd;
        stage3_idx[i] = (tmp.idx) ? {tmp.idx, stage2_idx[2*i]} : {tmp.idx, stage2_idx[2*i+1]};
    end

    // Stage 4
    for (i=0; i<2; i=i+1) begin // cp.4
        type_scr1_search_one_2_s tmp;
        tmp = scr1_lead_zeros_cnt_2(stage3_vd[(i+1)*2-1-:2]);
        stage4_vd[i]  = tmp.vd;
        stage4_idx[i] = (tmp.idx) ? {tmp.idx, stage3_idx[2*i]} : {tmp.idx, stage3_idx[2*i+1]};
    end

    // Stage 5
    tmp.vd = |stage4_vd;
    tmp.idx = (stage4_vd[1]) ? {1'b0, stage4_idx[1]} : {1'b1, stage4_idx[0]};

    res = tmp.idx;

    scr1_lead_zeros_cnt_32 = res;
end
endfunction 

`endif // SCR1_SEARCH_MS1_SVH
