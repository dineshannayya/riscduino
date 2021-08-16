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
/// @file       <scr1_pipe_ialu.sv>
/// @brief      Integer Arithmetic Logic Unit (IALU)
////     Ver 0.1 - 18th July 2021, Dinesh A, project: yifive
////           A. For Timing Reason, Input and Output are registered
////              Added SCR1_GOLDEN define to preserve the Previous Logic
////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------
 //
 // Functionality:
 // - Performs addition/subtraction and arithmetic and branch comparisons
 // - Performs logical operations (AND(I), OR(I), XOR(I))
 // - Performs address calculation for branch, jump, DMEM load and store and AUIPC
 //   instructions
 // - Performs shift operations
 // - Performs MUL/DIV operations
 //
 // Structure:
 // - Main adder
 // - Address adder
 // - Shift logic
 // - MUL/DIV logic
 // - Output result multiplexer
 //
//-------------------------------------------------------------------------------

`include "scr1_arch_description.svh"
`include "scr1_riscv_isa_decoding.svh"
`include "scr1_search_ms1.svh"


module scr1_pipe_ialu (
`ifdef SCR1_RVM_EXT
    // Common
    input   logic                           clk,                        // IALU clock
    input   logic                           rst_n,                      // IALU reset
    input   logic                           exu2ialu_rvm_cmd_vd_i,      // MUL/DIV command valid
    output  logic                           ialu2exu_rvm_res_rdy_o,     // MUL/DIV result ready
`endif // SCR1_RVM_EXT

    // Main adder
    input   logic [`SCR1_XLEN-1:0]          exu2ialu_main_op1_i,        // main ALU 1st operand
    input   logic [`SCR1_XLEN-1:0]          exu2ialu_main_op2_i,        // main ALU 2nd operand
    input   type_scr1_ialu_cmd_sel_e        exu2ialu_cmd_i,             // IALU command
    output  logic [`SCR1_XLEN-1:0]          ialu2exu_main_res_o,        // main ALU result
    output  logic                           ialu2exu_cmp_res_o,         // IALU comparison result

    // Address adder
    input   logic [`SCR1_XLEN-1:0]          exu2ialu_addr_op1_i,        // Address adder 1st operand
    input   logic [`SCR1_XLEN-1:0]          exu2ialu_addr_op2_i,        // Address adder 2nd operand
    output  logic [`SCR1_XLEN-1:0]          ialu2exu_addr_res_o         // Address adder result
);

//-------------------------------------------------------------------------------
// Local parameters declaration
//-------------------------------------------------------------------------------

`ifdef SCR1_RVM_EXT
localparam SCR1_MUL_WIDTH     = `SCR1_XLEN;
localparam SCR1_MUL_RES_WIDTH = 2 * `SCR1_XLEN;
localparam SCR1_MDU_SUM_WIDTH = `SCR1_XLEN + 1;

localparam SCR1_DIV_WIDTH     = 1;
localparam SCR1_DIV_CNT_INIT  = 32'b1 << (`SCR1_XLEN/SCR1_DIV_WIDTH - 2);
`endif // SCR1_RVM_EXT

//-------------------------------------------------------------------------------
// Local types declaration
//-------------------------------------------------------------------------------

typedef struct packed {
    logic       z;      // Zero
    logic       s;      // Sign
    logic       o;      // Overflow
    logic       c;      // Carry
} type_scr1_ialu_flags_s;

 `ifdef SCR1_RVM_EXT
//typedef enum logic [1:0] {
parameter    SCR1_IALU_MDU_FSM_IDLE  = 2'b00;
parameter    SCR1_IALU_MDU_FSM_ITER  = 2'b01;
parameter    SCR1_IALU_MDU_FSM_CORR  = 2'b10;
//} type_scr1_ialu_fsm_state;

//typedef enum logic [1:0] {
parameter   SCR1_IALU_MDU_NONE       = 2'b00;
parameter   SCR1_IALU_MDU_MUL        = 2'b01;
parameter   SCR1_IALU_MDU_DIV        = 2'b10;
//} type_scr1_ialu_mdu_cmd;
 `endif // SCR1_RVM_EXT

//-------------------------------------------------------------------------------
// Local signals declaration
//-------------------------------------------------------------------------------

// Main adder signals
logic        [`SCR1_XLEN:0]                 main_sum_res;       // Main adder result
type_scr1_ialu_flags_s                      main_sum_flags;     // Main adder flags
logic                                       main_sum_pos_ovflw; // Main adder positive overflow
logic                                       main_sum_neg_ovflw; // Main adder negative overflow
logic                                       main_ops_diff_sgn;  // Main adder operands have different signs
logic                                       main_ops_non_zero;  // Both main adder operands are NOT 0

// Shifter signals
logic                                       ialu_cmd_shft;      // IALU command is shift
logic signed [`SCR1_XLEN-1:0]               shft_op1;           // SHIFT operand 1
logic        [4:0]                          shft_op2;           // SHIFT operand 2
logic        [1:0]                          shft_cmd;           // SHIFT command: 00 - logical left, 10 - logical right, 11 - arithmetical right
logic        [`SCR1_XLEN-1:0]               shft_res;           // SHIFT result

// MUL/DIV signals
`ifdef SCR1_RVM_EXT

// MDU command signals
logic                                       mdu_cmd_mul;        // MDU command is MUL(HSU)
logic                                       mdu_cmd_div;        // MDU command is DIV(U)/REM(U)
logic        [1:0]                          mul_cmd;            // MUL command: 00 - MUL,  01 - MULH, 10 - MULHSU, 11 - MULHU
logic                                       mul_cmd_hi;         // High part of MUL result is requested
logic        [1:0]                          div_cmd;            // DIV command: 00 - DIV,  01 - DIVU, 10 - REM,    11 - REMU
logic                                       div_cmd_rem;        // DIV command is REM(U)

// Multiplier signals
logic                                       mul_op1_is_sgn;     // First MUL operand is signed
logic                                       mul_op2_is_sgn;     // Second MUL operand is signed
logic                                       mul_op1_sgn;        // First MUL operand is negative
logic                                       mul_op2_sgn;        // Second MUL operand is negative
logic signed [`SCR1_XLEN:0]                 mul_op1;            // MUL operand 1
logic signed [SCR1_MUL_WIDTH:0]             mul_op2;            // MUL operand 1
logic signed [SCR1_MUL_RES_WIDTH-1:0]       mul_res;            // MUL result

// Divisor signals
logic signed [`SCR1_XLEN:0]                 div_op1;            // DIV operand 1
logic signed [SCR1_MUL_WIDTH:0]             div_op2;            // DIV operand 2
logic                                       div_ops_are_sgn;
logic                                       div_op1_is_neg;
logic                                       div_op2_is_neg;
logic        [`SCR1_XLEN-1:0]               div_res_rem;
logic        [`SCR1_XLEN-1:0]               div_res_quo;


`endif // SCR1_RVM_EXT


//-------------------------------------------------------
// Adding Input Register to break Timing Path 
// ------------------------------------------------------
logic [`SCR1_XLEN-1:0]          exu2ialu_main_op1_ff;        // main ALU 1st operand
logic [`SCR1_XLEN-1:0]          exu2ialu_main_op2_ff;        // main ALU 2nd operand
type_scr1_ialu_cmd_sel_e        exu2ialu_cmd_ff;             // IALU command
logic                           exu2ialu_rvm_cmd_vd_ff;      // MUL/DIV command valid
logic [`SCR1_XLEN-1:0]          ialu2exu_main_res_i;        // main ALU result
logic                           ialu2exu_cmp_res_i;         // IALU comparison result
logic                           ialu2exu_rvm_res_rdy_i;     // MUL/DIV result ready
logic                           ialu_rdy        ;           // ialu ready
logic                           ialu_data_pdone ;           // ialu data process done


`ifdef SCR1_GOLDEN
assign	exu2ialu_main_op1_ff = exu2ialu_main_op1_i;
assign  exu2ialu_main_op2_ff = exu2ialu_main_op2_i;
assign  exu2ialu_cmd_ff      = exu2ialu_cmd_i;
assign	exu2ialu_rvm_cmd_vd_ff = exu2ialu_rvm_cmd_vd_i;

assign	ialu2exu_main_res_o     = ialu2exu_main_res_i;
assign  ialu2exu_cmp_res_o      = ialu2exu_cmp_res_i;
assign  ialu2exu_rvm_res_rdy_o  = ialu2exu_rvm_res_rdy_i;
assign  ialu_rdy                = 1; 

`else
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
	exu2ialu_main_op1_ff <= '0;
        exu2ialu_main_op2_ff <= '0;
        exu2ialu_cmd_ff      <= SCR1_IALU_CMD_NONE;
	exu2ialu_rvm_cmd_vd_ff <= '0;
    end else begin
	exu2ialu_main_op1_ff <= exu2ialu_main_op1_i;
        exu2ialu_main_op2_ff <= exu2ialu_main_op2_i;
        exu2ialu_cmd_ff      <= exu2ialu_cmd_i;
	exu2ialu_rvm_cmd_vd_ff <= exu2ialu_rvm_cmd_vd_i;
    end
end

//-------------------------------------------------------
// Adding Output Register to break Timing Path 
// ------------------------------------------------------

always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
	ialu2exu_main_res_o         <= '0;
        ialu2exu_cmp_res_o          <= '0;
        ialu2exu_rvm_res_rdy_o      <= '0;
	ialu_data_pdone             <= '0;
    end else begin
	ialu_data_pdone             <= ialu2exu_rvm_res_rdy_o; // generate one cycle delayed process done
	ialu2exu_main_res_o         <= ialu2exu_main_res_i;
        ialu2exu_cmp_res_o          <= ialu2exu_cmp_res_i;
        ialu2exu_rvm_res_rdy_o      <= ialu2exu_rvm_res_rdy_i;
    end
end

//-------------------------------------------------------
// Creating Two cycle Latency to break timing path
// One Cycle for Register Input + One Cycle Registered Output
// -----------------------------------------------------
logic cmd_vd_d;
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
	cmd_vd_d <= '0;
        ialu_rdy <= '0;
    end else begin
	cmd_vd_d <= exu2ialu_rvm_cmd_vd_i & (ialu_rdy ==0);
        ialu_rdy <= cmd_vd_d & exu2ialu_rvm_cmd_vd_i & (ialu_rdy ==0) ;
    end
end

`endif

//-------------------------------------------------------------------------------
// Main adder
//-------------------------------------------------------------------------------
//
 // Main adder is used for the following types of operations:
 // - Addition/subtraction          (ADD/ADDI/SUB)
 // - Branch comparisons            (BEQ/BNE/BLT(U)/BGE(U))
 // - Arithmetic comparisons        (SLT(U)/SLTI(U))
//

// Carry out (MSB of main_sum_res) is evaluated correctly because the result
// width equals to the maximum width of both the right-hand and left-hand side variables
always_comb begin
    main_sum_res = (exu2ialu_cmd_ff != SCR1_IALU_CMD_ADD)
                 ? (exu2ialu_main_op1_ff - exu2ialu_main_op2_ff)   // Subtraction and comparison
                 : (exu2ialu_main_op1_ff + exu2ialu_main_op2_ff);  // Addition

    main_sum_pos_ovflw = ~exu2ialu_main_op1_ff[`SCR1_XLEN-1]
                       &  exu2ialu_main_op2_ff[`SCR1_XLEN-1]
                       &  main_sum_res[`SCR1_XLEN-1];
    main_sum_neg_ovflw =  exu2ialu_main_op1_ff[`SCR1_XLEN-1]
                       & ~exu2ialu_main_op2_ff[`SCR1_XLEN-1]
                       & ~main_sum_res[`SCR1_XLEN-1];

    // FLAGS1 - flags for comparison (result of subtraction)
    main_sum_flags.c = main_sum_res[`SCR1_XLEN];
    main_sum_flags.z = ~|main_sum_res[`SCR1_XLEN-1:0];
    main_sum_flags.s = main_sum_res[`SCR1_XLEN-1];
    main_sum_flags.o = main_sum_pos_ovflw | main_sum_neg_ovflw;
end

//-------------------------------------------------------------------------------
// Address adder
//-------------------------------------------------------------------------------
//
 // Additional adder is used for the following types of operations:
 // - PC-based address calculation          (AUIPC)
 // - IMEM branch address calculation       (BEQ/BNE/BLT(U)/BGE(U))
 // - IMEM jump address calculation         (JAL/JALR)
 // - DMEM load address calculation         (LB(U)/LH(U)/LW)
 // - DMEM store address calculation        (SB/SH/SW)
//

assign ialu2exu_addr_res_o = exu2ialu_addr_op1_i + exu2ialu_addr_op2_i;

//-------------------------------------------------------------------------------
// Shift logic
//-------------------------------------------------------------------------------
 //
 // Shift logic supports the following types of shift operations:
 // - Logical left shift      (SLLI/SLL)
 // - Logical right shift     (SRLI/SRL)
 // - Arithmetic right shift  (SRAI/SRA)
//

assign ialu_cmd_shft = (exu2ialu_cmd_ff == SCR1_IALU_CMD_SLL)
                     | (exu2ialu_cmd_ff == SCR1_IALU_CMD_SRL)
                     | (exu2ialu_cmd_ff == SCR1_IALU_CMD_SRA);
assign shft_cmd      = ialu_cmd_shft
                     ? {(exu2ialu_cmd_ff != SCR1_IALU_CMD_SLL),
                        (exu2ialu_cmd_ff == SCR1_IALU_CMD_SRA)}
                     : 2'b00;

always_comb begin
    shft_op1 = exu2ialu_main_op1_ff;
    shft_op2 = exu2ialu_main_op2_ff[4:0];
    case (shft_cmd)
        2'b10   : shft_res = shft_op1  >> shft_op2;
        2'b11   : shft_res = shft_op1 >>> shft_op2;
        default : shft_res = shft_op1  << shft_op2;
    endcase
end

`ifdef SCR1_RVM_EXT
//-------------------------------------------------------------------------------
// MUL/DIV logic
//-------------------------------------------------------------------------------
//
 // MUL/DIV instructions use the following functional units:
 // - MUL/DIV FSM control logic, including iteration number counter
 // - MUL/DIV FSM
 // - MUL logic
 // - DIV logic
 // - MDU adder to produce an intermediate result
 // - 2 registers to save the intermediate result (shared between MUL and DIV
 //   operations)
//

//-------------------------------------------------------------------------------
// MUL/DIV FSM Control logic
//-------------------------------------------------------------------------------

assign mdu_cmd_div = ((exu2ialu_cmd_ff == SCR1_IALU_CMD_DIV)
                   | (exu2ialu_cmd_ff == SCR1_IALU_CMD_DIVU)
                   | (exu2ialu_cmd_ff == SCR1_IALU_CMD_REM)
                   | (exu2ialu_cmd_ff == SCR1_IALU_CMD_REMU)) & exu2ialu_rvm_cmd_vd_ff;
assign mdu_cmd_mul = ((exu2ialu_cmd_ff == SCR1_IALU_CMD_MUL)
                   | (exu2ialu_cmd_ff == SCR1_IALU_CMD_MULH)
                   | (exu2ialu_cmd_ff == SCR1_IALU_CMD_MULHU)
                   | (exu2ialu_cmd_ff == SCR1_IALU_CMD_MULHSU)) & exu2ialu_rvm_cmd_vd_ff;


assign main_ops_non_zero = |exu2ialu_main_op1_ff & |exu2ialu_main_op2_ff;
assign main_ops_diff_sgn = exu2ialu_main_op1_ff[`SCR1_XLEN-1]
                         ^ exu2ialu_main_op2_ff[`SCR1_XLEN-1];



assign div_cmd_rem = div_cmd[1];



//-------------------------------------------------------------------------------
// Multiplier logic
//-------------------------------------------------------------------------------
//
 // Multiplication has 2 options: fast (1 cycle) and Radix-2 (8 cycles) multiplication.
 //
 // 1. Fast multiplication uses the straightforward approach when 2 operands are
 // multiplied in one cycle
 //
 // 2. Radix-2 multiplication does 4bit multication at time
 //
 //
//

assign mul_cmd  = {((exu2ialu_cmd_ff == SCR1_IALU_CMD_MULHU) | (exu2ialu_cmd_ff == SCR1_IALU_CMD_MULHSU)),
                   ((exu2ialu_cmd_ff == SCR1_IALU_CMD_MULHU) | (exu2ialu_cmd_ff == SCR1_IALU_CMD_MULH))};

assign mul_cmd_hi     = |mul_cmd;
assign mul_op1_is_sgn = ~&mul_cmd;
assign mul_op2_is_sgn = ~mul_cmd[1];
assign mul_op1_sgn    = mul_op1_is_sgn & exu2ialu_main_op1_ff[`SCR1_XLEN-1];
assign mul_op2_sgn    = mul_op2_is_sgn & exu2ialu_main_op2_ff[`SCR1_XLEN-1];

`ifdef SCR1_FAST_MUL
assign mul_op1 = mdu_cmd_mul ? $signed({mul_op1_sgn, exu2ialu_main_op1_ff}) : '0;
assign mul_op2 = mdu_cmd_mul ? $signed({mul_op2_sgn, exu2ialu_main_op2_ff}) : '0;
assign mul_res = mdu_cmd_mul ? mul_op1 * mul_op2                           : 'sb0;
`else // ~SCR1_FAST_MUL

assign mul_op1 = mdu_cmd_mul ? $signed({mul_op1_sgn, exu2ialu_main_op1_ff}) : '0;
assign mul_op2 = mdu_cmd_mul ? $signed({mul_op2_sgn, exu2ialu_main_op2_ff}) : '0;

logic mul_rdy;

scr1_pipe_mul u_mul(
	.clk          (clk), 
	.rstn         (rst_n), 
	.data_valid   (mdu_cmd_mul),   // input valid
	.Din1         (mul_op1),       // first operand
	.Din2         (mul_op2),       // second operand
	.des_hig      (mul_res[SCR1_MUL_RES_WIDTH-1:`SCR1_XLEN]),    // first result
	.des_low      (mul_res[`SCR1_XLEN-1:0]),    // second result
	.mul_rdy_o    (mul_rdy),      // Multiply result ready
	.data_done    (ialu_data_pdone)    // data_process_done
    );


`endif // ~SCR1_FAST_MUL



//-------------------------------------------------------------------------------
// Divider logic
//-------------------------------------------------------------------------------

assign div_cmd  = {((exu2ialu_cmd_ff == SCR1_IALU_CMD_REM)   | (exu2ialu_cmd_ff == SCR1_IALU_CMD_REMU)),
                   ((exu2ialu_cmd_ff == SCR1_IALU_CMD_REMU)  | (exu2ialu_cmd_ff == SCR1_IALU_CMD_DIVU))};

assign div_ops_are_sgn = ~div_cmd[0];
assign div_op1_is_neg  = div_ops_are_sgn & exu2ialu_main_op1_ff[`SCR1_XLEN-1];
assign div_op2_is_neg  = div_ops_are_sgn & exu2ialu_main_op2_ff[`SCR1_XLEN-1];

assign div_op1 = mdu_cmd_div ? $signed({div_op1_is_neg, exu2ialu_main_op1_ff}) : '0;
assign div_op2 = mdu_cmd_div ? $signed({div_op2_is_neg, exu2ialu_main_op2_ff}) : '0;

logic div_rdy;

scr1_pipe_div u_div(
	.clk          (clk), 
	.rstn         (rst_n), 
	.data_valid   (mdu_cmd_div),   // input valid
	.Din1         (div_op1),       // first operand
	.Din2         (div_op2),       // second operand
	.quotient     (div_res_quo),   // Remainder
	.remainder    (div_res_rem),   // Quotient
	.div_rdy_o    (div_rdy),       // Divide result ready
	.data_done    (ialu_data_pdone)     // data_process_done
    );


`endif // SCR1_RVM_EXT

//-------------------------------------------------------------------------------
// Operation result forming
//-------------------------------------------------------------------------------

always_comb begin
    ialu2exu_main_res_i    = '0;
    ialu2exu_cmp_res_i     = 1'b0;
    ialu2exu_rvm_res_rdy_i = 1'b0;

    case (exu2ialu_cmd_ff)
        SCR1_IALU_CMD_AND : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = exu2ialu_main_op1_ff & exu2ialu_main_op2_ff;
        end
        SCR1_IALU_CMD_OR : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = exu2ialu_main_op1_ff | exu2ialu_main_op2_ff;
        end
        SCR1_IALU_CMD_XOR : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = exu2ialu_main_op1_ff ^ exu2ialu_main_op2_ff;
        end
        SCR1_IALU_CMD_ADD : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = main_sum_res[`SCR1_XLEN-1:0];
        end
        SCR1_IALU_CMD_SUB : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = main_sum_res[`SCR1_XLEN-1:0];
        end
        SCR1_IALU_CMD_SUB_LT : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = `SCR1_XLEN'(main_sum_flags.s ^ main_sum_flags.o);
            ialu2exu_cmp_res_i  = main_sum_flags.s ^ main_sum_flags.o;
        end
        SCR1_IALU_CMD_SUB_LTU : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = `SCR1_XLEN'(main_sum_flags.c);
            ialu2exu_cmp_res_i  = main_sum_flags.c;
        end
        SCR1_IALU_CMD_SUB_EQ : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = `SCR1_XLEN'(main_sum_flags.z);
            ialu2exu_cmp_res_i  = main_sum_flags.z;
        end
        SCR1_IALU_CMD_SUB_NE : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = `SCR1_XLEN'(~main_sum_flags.z);
            ialu2exu_cmp_res_i  = ~main_sum_flags.z;
        end
        SCR1_IALU_CMD_SUB_GE : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = `SCR1_XLEN'(~(main_sum_flags.s ^ main_sum_flags.o));
            ialu2exu_cmp_res_i  = ~(main_sum_flags.s ^ main_sum_flags.o);
        end
        SCR1_IALU_CMD_SUB_GEU : begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = `SCR1_XLEN'(~main_sum_flags.c);
            ialu2exu_cmp_res_i  = ~main_sum_flags.c;
        end
        SCR1_IALU_CMD_SLL,
        SCR1_IALU_CMD_SRL,
        SCR1_IALU_CMD_SRA: begin
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = shft_res;
        end
`ifdef SCR1_RVM_EXT
        SCR1_IALU_CMD_MUL,
        SCR1_IALU_CMD_MULHU,
        SCR1_IALU_CMD_MULHSU,
        SCR1_IALU_CMD_MULH : begin
 `ifdef SCR1_FAST_MUL
            ialu2exu_rvm_res_rdy_i = ialu_rdy;
            ialu2exu_main_res_i = mul_cmd_hi
                                ? mul_res[SCR1_MUL_RES_WIDTH-1:`SCR1_XLEN]
                                : mul_res[`SCR1_XLEN-1:0];
 `else // ~SCR1_FAST_MUL
            ialu2exu_rvm_res_rdy_i = mul_rdy;
            ialu2exu_main_res_i = mul_cmd_hi
                                ? mul_res[SCR1_MUL_RES_WIDTH-1:`SCR1_XLEN]
                                : mul_res[`SCR1_XLEN-1:0];
 `endif // ~SCR1_FAST_MUL
        end
        SCR1_IALU_CMD_DIV,
        SCR1_IALU_CMD_DIVU,
        SCR1_IALU_CMD_REM,
        SCR1_IALU_CMD_REMU : begin
            ialu2exu_main_res_i    = div_cmd_rem ? div_res_rem : div_res_quo;
            ialu2exu_rvm_res_rdy_i = div_rdy;
        end
`endif // SCR1_RVM_EXT
        default : begin end
    endcase
end


`ifdef SCR1_TRGT_SIMULATION
//-------------------------------------------------------------------------------
// Assertion
//-------------------------------------------------------------------------------

`ifdef SCR1_RVM_EXT

// X checks

SCR1_SVA_IALU_XCHECK_QUEUE : assert property (
    @(negedge clk) disable iff (~rst_n)
    exu2ialu_rvm_cmd_vd_ff |->
    !$isunknown({exu2ialu_main_op1_ff, exu2ialu_main_op2_ff, exu2ialu_cmd_ff})
    ) else $error("IALU Error: unknown values in queue");

// Behavior checks


`endif // SCR1_RVM_EXT

`endif // SCR1_TRGT_SIMULATION

endmodule : scr1_pipe_ialu
