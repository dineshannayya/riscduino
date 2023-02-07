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
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Steper Motor Controller                                     ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Julien OURY <julien.oury@outlook.fr>                  ////
////      - Dinesh Annayya<dinesh.annayya@gmail.com>              ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 02 Jan 2023, Dinesh A                               ////
////          Initial Version picked from                         ////
////      https://github.com/JulienOury/ChristmasTreeController   ////
////    0.2 - 03 Jan 2022, Dinesh A                               ////
////          A. Changed the Reg decoding                         ////
//////////////////////////////////////////////////////////////////////

module sm_ctrl #(
  parameter PSIZE = 32         , // Size of prescaler counter(bits)
  parameter DSIZE = 32           // Size of delay counter (bits)
)(

  input  logic        rst_n     , // Asynchronous reset (active low)
  input  logic        clk       , // Clock (rising edge)

  // Wishbone bus
  input  logic        wbs_cyc_i , // Wishbone strobe/request
  input  logic        wbs_stb_i , // Wishbone strobe/request
  input  logic [4:0]  wbs_adr_i , // Wishbone address
  input  logic        wbs_we_i  , // Wishbone write (1:write, 0:read)
  input  logic [31:0] wbs_dat_i , // Wishbone data output
  input  logic [3:0]  wbs_sel_i , // Wishbone byte enable
  output logic [31:0] wbs_dat_o , // Wishbone data input
  output logic        wbs_ack_o , // Wishbone acknowlegement

  // Motor outputs
  output logic        motor_a1  ,  // A1 moto output
  output logic        motor_a2  ,  // A2 moto output
  output logic        motor_b1  ,  // B1 moto output
  output logic        motor_b2     // B2 moto output

);

  wire             controller_en   ;
  wire [PSIZE-1:0] multiplier      ;
  wire [PSIZE-1:0] divider         ;
  wire             tick            ;
  wire [7:0]       duty_cycle      ;
  wire             start           ;
  wire             pwm             ;
  wire             ptype           ;
  wire             mode            ;
  wire             direction       ;
  wire [DSIZE-1:0] period          ;
  wire             run             ;
  wire             step_strobe     ;

  prescaler #(
    .BITS(PSIZE)
  ) i_prescaler (
    .rst_n      (rst_n         ),
    .clk        (clk           ),
    .clear_n    (controller_en ),
    .multiplier (multiplier    ),
    .divider    (divider       ),
    .tick       (tick          )
  );

  pwm_generator i_pwm_generator (
    .rst_n      (rst_n         ),
    .clk        (clk           ),
    .clear_n    (controller_en ),
    .duty_cycle (duty_cycle    ),
    .tick       (tick          ),
    .start      (start         ),
    .pwm        (pwm           )
  );

  motor_sequencer #(
    .DSIZE(DSIZE)
  )i_motor_sequencer (
    .rst_n      (rst_n         ),
    .clk        (clk           ),
    .clear_n    (controller_en ),
    .ptype      (ptype         ),
    .mode       (mode          ),
    .direction  (direction     ),
    .period     (period        ),
    .run        (run           ),
    .step_strobe(step_strobe   ),
    .start      (start         ),
    .pwm        (pwm           ),
    .motor_a1   (motor_a1      ),
    .motor_a2   (motor_a2      ),
    .motor_b1   (motor_b1      ),
    .motor_b2   (motor_b2      )
  );

  sm_regs #(
    .PSIZE(PSIZE),
    .DSIZE(DSIZE)
  ) u_regs (
    .rst_n        (rst_n        ),
    .clk          (clk          ),
    .controller_en(controller_en),
    .multiplier   (multiplier   ),
    .divider      (divider      ),
    .duty_cycle   (duty_cycle   ),
    .ptype        (ptype        ),
    .mode         (mode         ),
    .direction    (direction    ),
    .period       (period       ),
    .run          (run          ),
    .step_strobe  (step_strobe  ),
    .wbs_cyc_i    (wbs_cyc_i    ),
    .wbs_stb_i    (wbs_stb_i    ),
    .wbs_adr_i    (wbs_adr_i    ),
    .wbs_we_i     (wbs_we_i     ),
    .wbs_dat_i    (wbs_dat_i    ),
    .wbs_sel_i    (wbs_sel_i    ),
    .wbs_dat_o    (wbs_dat_o    ),
    .wbs_ack_o    (wbs_ack_o    )
  );

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PWM generator
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module pwm_generator (
  input  wire        rst_n      , // Asynchronous reset (active low)
  input  wire        clk        , // Clock (rising edge)
  input  wire        clear_n    , // Synchronous reset (active low)
  input  wire [7:0]  duty_cycle , // PWM duty cycle
  input  wire        tick       , // Input tick (PWM resolution)
  output reg         start      , // Start strobe (One clk pulse at start of PWM period)
  output reg         pwm          // PWM signal
);

  wire [7:0] next_counter;
  reg  [7:0] counter;

  assign next_counter = counter + 1'b1;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      counter <= 8'h00;
      start   <= 1'b0;
      pwm     <= 1'b0;
    end else begin
      if (clear_n == 1'b0) begin
        counter <= 8'h00;
        start   <= 1'b0;
        pwm     <= 1'b0;
      end else begin
        if (tick == 1'b1) begin
          counter <= next_counter;
        end
        if ((tick == 1'b1) && (counter[7] == 1'b1) && (next_counter[7] == 1'b0)) begin
          start <= 1'b1;
        end else begin
          start <= 1'b0;
        end
        if (counter <= duty_cycle) begin
          pwm <= 1'b1;
        end else begin
          pwm <= 1'b0;
        end
      end
    end
  end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Motor_sequencer
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module motor_sequencer #(
  parameter DSIZE = 32 // Number of bits of delay counter
)(
  input  wire             rst_n         , // Asynchronous reset (active low)
  input  wire             clk           , // Clock (rising edge)
  input  wire             clear_n       , // Synchronous reset (active low)
  input  wire             ptype         , // Type of motor (1'b0:Unipolar, 1'b1:Bipolar)
  input  wire             mode          , // Mode of drive (1'b0:FullStep, 1'b1:HalfStep)
  input  wire             direction     , // Direction of motor
  input  wire [DSIZE-1:0] period        , // Period of each motor step
  input  wire             run           , // Motor run
  output reg              step_strobe   , // Motor step strobe (one clk pulse by step)

  // PWM input
  input  wire             start         , // Start strobe (One clk pulse at start of PWM period)
  input  wire             pwm           , // PWM signal

  // Motor outputs
  output reg              motor_a1      , // A1 motor output
  output reg              motor_a2      , // A2 motor output
  output reg              motor_b1      , // B1 motor output
  output reg              motor_b2        // B2 motor output
);

  reg  [2:0]       motor_state;
  reg  [DSIZE-1:0] counter;
  reg              pwmo;

  wire [DSIZE-1:0] next_counter;
  wire [3:0]       motor_values[7:0];

  assign next_counter = counter + 1'b1;
  assign motor_values[0] = 4'b1_0_0_1; // b2 b1 a2 a1
  assign motor_values[1] = 4'b0_0_0_1; // b2 b1 a2 a1
  assign motor_values[2] = 4'b0_0_1_1; // b2 b1 a2 a1
  assign motor_values[3] = 4'b0_0_1_0; // b2 b1 a2 a1
  assign motor_values[4] = 4'b0_1_1_0; // b2 b1 a2 a1
  assign motor_values[5] = 4'b0_1_0_0; // b2 b1 a2 a1
  assign motor_values[6] = 4'b1_1_0_0; // b2 b1 a2 a1
  assign motor_values[7] = 4'b1_0_0_0; // b2 b1 a2 a1


  // Frame decoder
  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      counter     <= {(DSIZE){1'b0}};
      step_strobe <= 1'b0;
      pwmo        <= 1'b0;
      motor_state <= 3'b000;
      motor_a1    <= 1'b0;
      motor_a2    <= 1'b0;
      motor_b1    <= 1'b0;
      motor_b2    <= 1'b0;
    end else begin

      if (clear_n == 1'b0) begin
        counter     <= {(DSIZE){1'b0}};
        step_strobe <= 1'b0;
        pwmo        <= 1'b0;
        motor_state <= 3'b000;
        motor_a1    <= 1'b0;
        motor_a2    <= 1'b0;
        motor_b1    <= 1'b0;
        motor_b2    <= 1'b0;
      end else begin

        if (run == 1'b0) begin
          counter <= {(DSIZE){1'b0}};
        end else if (start == 1'b1) begin
          if (counter < period) begin
            counter <= next_counter;
          end else begin
            counter <= {(DSIZE){1'b0}};
            if (direction == 1'b0) begin
              motor_state <= motor_state + 1'b1;
            end else begin
              motor_state <= motor_state - 1'b1;
            end
          end
        end

        if ((run == 1'b1) && (start == 1'b1) && (counter >= period)) begin
          step_strobe <= 1'b1;
        end else begin
          step_strobe <= 1'b0;
        end

        pwmo <= pwm;

        if (ptype == 1'b0) begin // Unipolar
          motor_a1 <= motor_values[motor_state & {2'b11, mode}][0] & pwmo ;
          motor_a2 <= motor_values[motor_state & {2'b11, mode}][1] & pwmo ;
          motor_b1 <= motor_values[motor_state & {2'b11, mode}][2] & pwmo ;
          motor_b2 <= motor_values[motor_state & {2'b11, mode}][3] & pwmo ;
        end else begin // Bipolar
          motor_a1 <= motor_values[motor_state & {2'b11, mode}][0] & pwmo ;
          motor_a2 <= motor_values[motor_state & {2'b11, mode}][2] & pwmo ;
          motor_b1 <= motor_values[motor_state & {2'b11, mode}][1] & pwmo ;
          motor_b2 <= motor_values[motor_state & {2'b11, mode}][3] & pwmo ;
        end

      end
    end
  end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Registers
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module sm_regs #(
  parameter PSIZE = 32 , // Size of prescaler counter(bits)
  parameter DSIZE = 32   // Size of delay counter (bits)
)(

  input                   rst_n           , // Asynchronous reset (active low)
  input                   clk             , // Clock (rising edge)

  // Configuration
  output reg              controller_en   , // Controller enable (active high)
  output reg  [PSIZE-1:0] multiplier      , // frequency multiplier
  output reg  [PSIZE-1:0] divider         , // frequency divider
  output reg  [7:0]       duty_cycle      , // PWM duty cycle
  output reg              ptype           , // Type of motor (1'b0:Unipolar, 1'b1:Bipolar)
  output reg              mode            , // Mode of drive (1'b0:FullStep, 1'b1:HalfStep)
  output reg              direction       , // Direction of motor
  output reg  [DSIZE-1:0] period          , // Period of each motor step
  output reg              run             , // Motor run
  input  wire             step_strobe     , // Motor step strobe (one clk pulse by step)

  // Wishbone bus
  input  wire             wbs_cyc_i       , // Wishbone strobe/request
  input  wire             wbs_stb_i       , // Wishbone strobe/request
  input  wire [4:0]       wbs_adr_i       , // Wishbone address
  input  wire             wbs_we_i        , // Wishbone write (1:write, 0:read)
  input  wire [31:0]      wbs_dat_i       , // Wishbone data output
  input  wire [ 3:0]      wbs_sel_i       , // Wishbone byte enable
  output reg  [31:0]      wbs_dat_o       , // Wishbone data input
  output wire             wbs_ack_o         // Wishbone acknowlegement

 );

  localparam
    config_reg_addr     = 3'b000,
    multiplier_reg_addr = 3'b001,
    divider_reg_addr    = 3'b010,
    period_reg_addr     = 3'b011,
    step_reg_addr       = 3'b100;

  wire        valid;
  wire [31:0] wstrb;
  wire [2:0]  addr;
  wire [23:0] next_cycles;

  reg         free;
  reg         ready;
  reg  [15:0] cycles;

  integer i = 0;

  assign valid     = wbs_cyc_i && wbs_stb_i;
  assign wstrb     = {{8{wbs_sel_i[3]}}, {8{wbs_sel_i[2]}}, {8{wbs_sel_i[1]}}, {8{wbs_sel_i[0]}}} & {32{wbs_we_i}};
  assign addr      = wbs_adr_i[4:2];
  assign wbs_ack_o = ready;

  assign next_cycles = cycles - 1'b1;

  always @(negedge rst_n or posedge clk) begin
    if (rst_n == 1'b0) begin
      ready         <= 1'b0;
      wbs_dat_o     <= 32'h00000000;
      controller_en <= 1'b0;
      ptype         <= 1'b0;
      mode          <= 1'b0;
      duty_cycle    <= 8'h00;
      multiplier    <= {PSIZE{1'b0}};
      divider       <= {PSIZE{1'b0}};
      period        <= {DSIZE{1'b0}};
      run           <= 1'b0;
      direction     <= 1'b0;
      free          <= 1'b0;
      cycles        <= 16'h0000;
    end else begin

      if (valid && !ready) begin

        //Write
        case (addr)
          config_reg_addr : begin
            wbs_dat_o[31]   <= controller_en; if (wstrb[31]) controller_en <= wbs_dat_i[31];
            wbs_dat_o[30]   <= ptype        ; if (wstrb[30]) ptype         <= wbs_dat_i[30];
            wbs_dat_o[29]   <= mode         ; if (wstrb[29]) mode          <= wbs_dat_i[29];
            wbs_dat_o[28:8] <= 11'b0;
            wbs_dat_o[ 7]   <= duty_cycle[7]; if (wstrb[ 7]) duty_cycle[7] <= wbs_dat_i[ 7];
            wbs_dat_o[ 6]   <= duty_cycle[6]; if (wstrb[ 6]) duty_cycle[6] <= wbs_dat_i[ 6];
            wbs_dat_o[ 5]   <= duty_cycle[5]; if (wstrb[ 5]) duty_cycle[5] <= wbs_dat_i[ 5];
            wbs_dat_o[ 4]   <= duty_cycle[4]; if (wstrb[ 4]) duty_cycle[4] <= wbs_dat_i[ 4];
            wbs_dat_o[ 3]   <= duty_cycle[3]; if (wstrb[ 3]) duty_cycle[3] <= wbs_dat_i[ 3];
            wbs_dat_o[ 2]   <= duty_cycle[2]; if (wstrb[ 2]) duty_cycle[2] <= wbs_dat_i[ 2];
            wbs_dat_o[ 1]   <= duty_cycle[1]; if (wstrb[ 1]) duty_cycle[1] <= wbs_dat_i[ 1];
            wbs_dat_o[ 0]   <= duty_cycle[0]; if (wstrb[ 0]) duty_cycle[0] <= wbs_dat_i[ 0];
          end
          multiplier_reg_addr : begin
            for (i = 0; i < 32; i = i + 1) begin
              if (i >= PSIZE) begin
                wbs_dat_o[i] <= 1'b0 ;
              end else begin
                wbs_dat_o[i] <= multiplier[i] ; if (wstrb[i]) multiplier[i] <= wbs_dat_i[i];
              end
            end
          end
          divider_reg_addr : begin
            for (i = 0; i < 32; i = i + 1) begin
              if (i >= PSIZE) begin
                wbs_dat_o[i] <= 1'b0 ;
              end else begin
                wbs_dat_o[i] <= divider[i] ; if (wstrb[i]) divider[i] <= wbs_dat_i[i];
              end
            end
          end
          period_reg_addr : begin
            for (i = 0; i < 32; i = i + 1) begin
              if (i >= DSIZE) begin
                wbs_dat_o[i] <= 1'b0 ;
              end else begin
                wbs_dat_o[i] <= period[i] ; if (wstrb[i]) period[i] <= wbs_dat_i[i];
              end
            end
          end
          step_reg_addr : begin
            wbs_dat_o[31]    <= run;
            wbs_dat_o[30]    <= direction    ; if (wstrb[30]) direction     <= wbs_dat_i[30];
            wbs_dat_o[29]    <= free         ; if (wstrb[29]) free          <= wbs_dat_i[29];
            wbs_dat_o[28:16] <= 13'b0000000000000;
            wbs_dat_o[15:0]  <= cycles;
          end
        endcase

        ready <= 1'b1;
      end else begin
        ready <= 1'b0;
      end

      if (valid && !ready && (addr == step_reg_addr) && wstrb[31]) begin
        run <= wbs_dat_i[31];
      end else if ((free == 1'b0) && (step_strobe == 1'b1) && (cycles == 16'h0000)) begin
        run <= 1'b0;
      end

      if (valid && !ready && (addr == step_reg_addr) && wbs_we_i) begin
        cycles <= wbs_dat_i[15:0];
      end else if ((step_strobe == 1'b1) && (cycles != 16'h0000)) begin
        cycles <= next_cycles;
      end

    end
  end

endmodule
