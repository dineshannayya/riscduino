
//-------------------------------------------------------------------
// PWM waveform period:  1000/((cfg_pwm_high+1) + (cfg_pwm_low+1))
// For 1 Second with Duty cycle 50 =   1000/((499+1) + (499+1))
// For 1 Second with 1ms On and 999ms Off =  1000/((0+1) + (998+1))
// Timing Run's with 1 Milisecond pulse
//-------------------------------------------------------------------

module pwm(

	input  logic          h_reset_n         ,
	input  logic          mclk              ,

	output  logic         pwm_wfm_o         ,
	output  logic         pwm_os_done       ,
	output  logic         pwm_ovflow_pe     ,
    output  logic         gpio_tgr          ,

    input logic [7:0]     pad_gpio          ,

    input logic           cfg_pwm_enb       , // pwm operation enable
    input logic           cfg_pwm_run       , // pwm operation enable
    input logic [3:0]     cfg_pwm_scale     , // pwm clock scaling
    input logic           cfg_pwm_oneshot   , // pwm OneShot mode
    input logic           cfg_pwm_frun      , // pwm is free running
    input logic           cfg_pwm_gpio_enb  , // pwm gpio based trigger
    input logic           cfg_pwm_gpio_edge , // pwm gpio based trigger edge
    input logic [2:0]     cfg_pwm_gpio_sel  , // gpio Selection
    input logic           cfg_pwm_hold      , // Hold data pwm data During pwm Disable
    input logic           cfg_pwm_inv       , // invert output
    input logic           cfg_pwm_zeropd    , // Reset on pmw_cnt match to period
    input logic [1:0]     cfg_pwm_mode      , // pwm Pulse Generation mode
    input logic           cfg_comp0_center  , // Compare cnt at comp0 center
    input logic           cfg_comp1_center  , // Compare cnt at comp1 center
    input logic           cfg_comp2_center  , // Compare cnt at comp2 center
    input logic           cfg_comp3_center  , // Compare cnt at comp3 center
    input logic [15:0]    cfg_pwm_period    , // pwm period
    input logic [15:0]    cfg_pwm_comp0     , // compare0
    input logic [15:0]    cfg_pwm_comp1     , // compare1
    input logic [15:0]    cfg_pwm_comp2     , // compare2
    input logic [15:0]    cfg_pwm_comp3       // compare3
);

logic [14:0]  pwm_scnt    ; // PWM Scaling counter
logic [15:0]  pwm_cnt     ; // PWM counter
logic         cnt_trg     ;
logic         pwm_wfm_i   ;
logic         pwm_wfm_r   ; // Register pwm
logic         comp0_match ;
logic         comp1_match ;
logic         comp2_match ;
logic         comp3_match ;
//--------------------------------
// Counter Scaling
// In GPIO mode, wait for first GPIO transition
//--------------------------------

always @(posedge mclk or negedge h_reset_n)
begin 
   if ( ~h_reset_n ) begin
      pwm_scnt  <= 15'h0;
   end else begin
      //-------------------------------------------------------
      // Added additional case to handle when new gpio trigger
      // generated before completing the current Run
      //-------------------------------------------------------
      if(cfg_pwm_enb && cfg_pwm_run && !gpio_tgr) begin
         pwm_scnt <= pwm_scnt + 1;
      end else begin
         pwm_scnt <= 15'h0;
      end
   end
end 

//-----------------------------------------------------------------------------
// pwm_scaling used to decide on the trigger event for the pwm_cnt
// 0  ==> pwm_cnt increment every system cycle
// 1  ==> 2^0 => pmw_cnt increase once in two system cycle
// 15 ==>a 2^15 => pwm_cnt increase once in 32768 system cycle
//-----------------------------------------------------------------------------

always_comb
begin
   cnt_trg = 0;
   case(cfg_pwm_scale)
   4'b0000:  cnt_trg = 1;
   4'b0001:  cnt_trg = pwm_scnt[0];
   4'b0010:  cnt_trg = &pwm_scnt[1:0];
   4'b0011:  cnt_trg = &pwm_scnt[2:0];
   4'b0100:  cnt_trg = &pwm_scnt[3:0];
   4'b0101:  cnt_trg = &pwm_scnt[4:0];
   4'b0110:  cnt_trg = &pwm_scnt[5:0];
   4'b0111:  cnt_trg = &pwm_scnt[6:0];
   4'b1000:  cnt_trg = &pwm_scnt[7:0];
   4'b1001:  cnt_trg = &pwm_scnt[8:0];
   4'b1010:  cnt_trg = &pwm_scnt[9:0];
   4'b1011:  cnt_trg = &pwm_scnt[10:0];
   4'b1100:  cnt_trg = &pwm_scnt[11:0];
   4'b1101:  cnt_trg = &pwm_scnt[12:0];
   4'b1110:  cnt_trg = &pwm_scnt[13:0];
   4'b1111:  cnt_trg = &pwm_scnt[14:0];
   default:  cnt_trg = 0;
   endcase
end

//----------------------------------------------------------
//Counter Overflow condition
// 1. At Roll Over
// 2. If compare on period enable, then at period
//----------------------------------------------------------
logic pwm_ovflow_l;
wire pwm_ovflow = ((&pwm_cnt) | (cfg_pwm_zeropd  && (pwm_cnt == cfg_pwm_period))) & cfg_pwm_enb;


// overflow single cycle pos edge pulse
assign pwm_ovflow_pe = (!pwm_ovflow_l & pwm_ovflow);

// Don't generate PWM done at exact clash at gpio trigger, higer priority to gpio trigger
assign pwm_os_done = (cfg_pwm_oneshot && !gpio_tgr) ? pwm_ovflow_pe : 1'b0;

always @(posedge mclk or negedge h_reset_n)
begin 
   if ( ~h_reset_n ) begin
      pwm_cnt      <= 16'h0;
      pwm_ovflow_l <= 1'b0;
   end else begin
      pwm_ovflow_l <= pwm_ovflow;
      //-------------------------------------------------------
      // Added additional case to handle when new gpio trigger
      // generated before completing the current Run
      //-------------------------------------------------------
      if(cfg_pwm_enb && cfg_pwm_run && !gpio_tgr) begin
         if(cnt_trg) begin
            if(pwm_ovflow) begin
               pwm_cnt  <= 'h0;
            end else begin
               pwm_cnt <= pwm_cnt + 1;
            end
         end 
      end else begin
         pwm_cnt  <= 16'h0;
      end
   end
end

//-----------------------------
// compare-0 match logic generation
//------------------------------

always_comb begin
   comp0_match = 0;
   if(cfg_comp0_center)begin
      comp0_match = (({16{pwm_cnt[15]}} ^ pwm_cnt) >= cfg_pwm_comp0);
   end else begin
      comp0_match = (pwm_cnt >= cfg_pwm_comp0);
   end
end

//-----------------------------
// compare-1 match logic generation
//------------------------------
always_comb begin
   comp1_match = 0;
   if(cfg_comp1_center)begin
      comp1_match = (({16{pwm_cnt[15]}}^ pwm_cnt) >= cfg_pwm_comp1);
   end else begin
      comp1_match = (pwm_cnt >= cfg_pwm_comp1);
   end
end

//-----------------------------
// compare-2 match logic generation
//------------------------------
always_comb begin
   comp2_match = 0;
   if(cfg_comp2_center)begin
      comp2_match = (({16{pwm_cnt[15]}} ^ pwm_cnt) >= cfg_pwm_comp2);
   end else begin
      comp2_match = (pwm_cnt >= cfg_pwm_comp2);
   end
end

//-----------------------------
// compare-3 match logic generation
//------------------------------
always_comb begin
   comp3_match = 0;
   if(cfg_comp3_center) begin
      comp3_match = (({16{pwm_cnt[15]}} ^ pwm_cnt) >= cfg_pwm_comp3);
   end else begin
      comp3_match = (pwm_cnt >= cfg_pwm_comp3);
   end
end

//---------------------------------------------
// Consolidated pwm waform generation 
// based on pwm mode
//---------------------------------------------

always_comb begin
   pwm_wfm_i = 0;
   case(cfg_pwm_mode)
   2'b00: pwm_wfm_i =  comp0_match;
   2'b01: pwm_wfm_i =  comp0_match ^ comp1_match;
   2'b10: pwm_wfm_i =  comp0_match ^ comp1_match ^ comp2_match;
   2'b11: pwm_wfm_i =  comp0_match ^ comp1_match ^ comp2_match ^ comp3_match;
   default: pwm_wfm_i=0;
   endcase
end

//-----------------------------------------------
// Holding the pwm waveform in active region
//------------------------------------------------
always @(posedge mclk or negedge h_reset_n)
begin 
   if ( ~h_reset_n ) begin
      pwm_wfm_r     <= 1'b0;
   end else begin 
      if(cfg_pwm_hold) begin
          if(cfg_pwm_enb ) begin
              pwm_wfm_r   <= pwm_wfm_i;
          end 
      end else begin
         pwm_wfm_r   <= pwm_wfm_i;
      end
   end
end


//--------------------------------------------
// Final Waveform output generation based
// on pwm_hold and pwm_inv combination
//--------------------------------------------
always_comb begin
   pwm_wfm_o = 0;
   if(cfg_pwm_inv) pwm_wfm_o = !pwm_wfm_r;
   else            pwm_wfm_o = pwm_wfm_r;
end

//----------------------------------------
// GPIO Trigger Generation
//----------------------------------------
logic gpio_l;
wire gpio = pad_gpio[cfg_pwm_gpio_sel];

// GPIO Pos and Neg Edge Selection
wire gpio_pe = (gpio & !gpio_l);
wire gpio_ne = (!gpio & gpio_l);

always @(posedge mclk or negedge h_reset_n)
begin 
   if ( ~h_reset_n ) begin
      gpio_l        <= 1'b0;
      gpio_tgr      <= 1'b0;
   end else begin
      gpio_l <= gpio;
      if(cfg_pwm_enb && cfg_pwm_gpio_enb) begin
         gpio_l <= gpio;
         if(cfg_pwm_gpio_edge) begin
             gpio_tgr        <= gpio_ne;
         end else begin
             gpio_tgr        <= gpio_pe;
         end
      end else begin
         gpio_l        <= 1'b0;
         gpio_tgr      <= 1'b0;
      end
   end
end


endmodule
