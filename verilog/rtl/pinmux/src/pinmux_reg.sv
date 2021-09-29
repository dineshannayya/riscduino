
module pinmux_reg (
                       // System Signals
                       // Inputs
		       input logic             mclk,
                       input logic             h_reset_n,

		       // Reg Bus Interface Signal
                       input logic             reg_cs,
                       input logic             reg_wr,
                       input logic [7:0]       reg_addr,
                       input logic [31:0]      reg_wdata,
                       input logic [3:0]       reg_be,

                       // Outputs
                       output logic [31:0]     reg_rdata,
                       output logic            reg_ack,

		       input  logic [1:0]      ext_intr_in,

		      // Risc configuration
                       output logic [31:0]     fuse_mhartid,
                       output logic [15:0]     irq_lines,
                       output logic            soft_irq,
                       output logic [2:0]      user_irq,

                       output logic [9:0]      cfg_pulse_1us,
		       
                       //---------------------------------------------------
                       // 6 PWM Configuration
                       //---------------------------------------------------
                       
                       output logic [15:0]    cfg_pwm0_high           ,
                       output logic [15:0]    cfg_pwm0_low            ,
                       output logic [15:0]    cfg_pwm1_high           ,
                       output logic [15:0]    cfg_pwm1_low            ,
                       output logic [15:0]    cfg_pwm2_high           ,
                       output logic [15:0]    cfg_pwm2_low            ,
                       output logic [15:0]    cfg_pwm3_high           ,
                       output logic [15:0]    cfg_pwm3_low            ,
                       output logic [15:0]    cfg_pwm4_high           ,
                       output logic [15:0]    cfg_pwm4_low            ,
                       output logic [15:0]    cfg_pwm5_high           ,
                       output logic [15:0]    cfg_pwm5_low            ,

                // GPIO input pins
                       input  logic [31:0]     gpio_in_data   ,// GPIO I/P pins
                       input  logic [31:0]     gpio_int_event ,// from gpio control blk



                // GPIO config pins
                       output  logic [31:0]     cfg_gpio_out_data        ,// to the GPIO control block 
                       output  logic [31:0]     cfg_gpio_data_in         ,// GPIO I/P pins data captured into this
                       output  logic [31:0]     cfg_gpio_dir_sel         ,// decides on GPIO pin is I/P or O/P at pad level
                       output  logic [31:0]     cfg_gpio_out_type        ,// O/P is static , '1' : waveform
                       output  logic [31:0]     cfg_gpio_posedge_int_sel ,// select posedge interrupt
                       output  logic [31:0]     cfg_gpio_negedge_int_sel ,// select negedge interrupt
                       output  logic [31:0]     cfg_multi_func_sel       ,// multifunction pins
                        
                       // Outputs
                       output logic [31:0]      gpio_prev_indata       // prv data from GPIO I/P pins
   ); 


                       
//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

reg           sw_rd_en               ;
reg           sw_wr_en;
reg  [4:0]    sw_addr; // addressing 16 registers
reg  [31:0]   sw_reg_wdata;
reg    [3:0]  wr_be  ;
reg          reg_cs_l;
reg          reg_cs_2l;

reg [31:0]   reg_out;

wire [31:0]   reg_0; // Chip ID
wire [31:0]   reg_1; // Risc Fuse Id
reg [31:0]    reg_2; // GPIO Read Data
reg [31:0]    reg_3; // GPIO Output Data
reg [31:0]    reg_4; // GPIO Dir Sel
reg [31:0]    reg_5; // GPIO Type
reg [31:0]    reg_6; // Interrupt
reg [31:0]    reg_7; // 
reg [31:0]    reg_8; // 
reg [31:0]    reg_9; // GPIO Interrupt Status
wire [31:0]   reg_10; // GPIO Interrupt Status
reg [31:0]    reg_11; // GPIO Interrupt Mask
reg [31:0]    reg_12; // GPIO Posedge Interrupt Select
reg [31:0]    reg_13; // GPIO Negedge Interrupt Select
reg [31:0]    reg_14; // Software-Reg_14
reg [31:0]    reg_15; // Software-Reg_15
reg [31:0]    reg_16; // PWN-0 Config
reg [31:0]    reg_17; // PWN-1 Config
reg [31:0]    reg_18; // PWN-2 Config
reg [31:0]    reg_19; // PWN-3 Config
reg [31:0]    reg_20; // PWN-4 Config
reg [31:0]    reg_21; // PWN-5 Config


reg          cs_int;
wire         gpio_intr;



//-----------------------------------------------------------------------
// To avoid interface timing, all the content are registered
//-----------------------------------------------------------------------
always @ (posedge mclk or negedge h_reset_n)
begin 
   if (h_reset_n == 1'b0)
   begin
    sw_addr       <= '0;
    sw_rd_en      <= '0;
    sw_wr_en      <= '0;
    sw_reg_wdata  <= '0;
    wr_be         <= '0;
    reg_cs_l      <= '0;
    reg_cs_2l     <= '0;
  end else begin
    sw_addr       <= reg_addr [6:2];
    sw_rd_en      <= reg_cs & !reg_wr;
    sw_wr_en      <= reg_cs & reg_wr;
    sw_reg_wdata  <= reg_wdata;
    wr_be         <= reg_be;
    reg_cs_l      <= reg_cs;
    reg_cs_2l     <= reg_cs_l;
  end
end


//-----------------------------------------------------------------------
// Read path mux
//-----------------------------------------------------------------------

always @ (posedge mclk or negedge h_reset_n)
begin : preg_out_Seq
   if (h_reset_n == 1'b0) begin
      reg_rdata [31:0]  <= 32'h0000_0000;
      reg_ack           <= 1'b0;
   end else if (sw_rd_en && !reg_ack && !reg_cs_2l) begin
      reg_rdata [31:0]  <= reg_out [31:0];
      reg_ack           <= 1'b1;
   end else if (sw_wr_en && !reg_ack && !reg_cs_2l) begin 
      reg_ack           <= 1'b1;
   end else begin
      reg_ack        <= 1'b0;
   end
end


//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_wr_en  & (sw_addr == 5'h0);
wire   sw_rd_en_0 = sw_rd_en  & (sw_addr == 5'h0);
wire   sw_wr_en_1 = sw_wr_en  & (sw_addr == 5'h1);
wire   sw_rd_en_1 = sw_rd_en  & (sw_addr == 5'h1);
wire   sw_wr_en_2 = sw_wr_en  & (sw_addr == 5'h2);
wire   sw_rd_en_2 = sw_rd_en  & (sw_addr == 5'h2);
wire   sw_wr_en_3 = sw_wr_en  & (sw_addr == 5'h3);
wire   sw_rd_en_3 = sw_rd_en  & (sw_addr == 5'h3);
wire   sw_wr_en_4 = sw_wr_en  & (sw_addr == 5'h4);
wire   sw_rd_en_4 = sw_rd_en  & (sw_addr == 5'h4);
wire   sw_wr_en_5 = sw_wr_en  & (sw_addr == 5'h5);
wire   sw_rd_en_5 = sw_rd_en  & (sw_addr == 5'h5);
wire   sw_wr_en_6 = sw_wr_en  & (sw_addr == 5'h6);
wire   sw_rd_en_6 = sw_rd_en  & (sw_addr == 5'h6);
wire   sw_wr_en_7 = sw_wr_en  & (sw_addr == 5'h7);
wire   sw_rd_en_7 = sw_rd_en  & (sw_addr == 5'h7);
wire   sw_wr_en_8 = sw_wr_en  & (sw_addr == 5'h8);
wire   sw_rd_en_8 = sw_rd_en  & (sw_addr == 5'h8);
wire   sw_wr_en_9 = sw_wr_en  & (sw_addr == 5'h9);
wire   sw_rd_en_9 = sw_rd_en  & (sw_addr == 5'h9);
wire   sw_wr_en_10 = sw_wr_en & (sw_addr == 5'hA);
wire   sw_rd_en_10 = sw_rd_en & (sw_addr == 5'hA);
wire   sw_wr_en_11 = sw_wr_en & (sw_addr == 5'hB);
wire   sw_rd_en_11 = sw_rd_en & (sw_addr == 5'hB);
wire   sw_wr_en_12 = sw_wr_en & (sw_addr == 5'hC);
wire   sw_rd_en_12 = sw_rd_en & (sw_addr == 5'hC);
wire   sw_wr_en_13 = sw_wr_en & (sw_addr == 5'hD);
wire   sw_rd_en_13 = sw_rd_en & (sw_addr == 5'hD);
wire   sw_wr_en_14 = sw_wr_en & (sw_addr == 5'hE);
wire   sw_rd_en_14 = sw_rd_en & (sw_addr == 5'hE);
wire   sw_wr_en_15 = sw_wr_en & (sw_addr == 5'hF);
wire   sw_rd_en_15 = sw_rd_en & (sw_addr == 5'hF);
wire   sw_wr_en_16 = sw_wr_en & (sw_addr == 5'h10);
wire   sw_rd_en_16 = sw_rd_en & (sw_addr == 5'h10);
wire   sw_wr_en_17 = sw_wr_en & (sw_addr == 5'h11);
wire   sw_rd_en_17 = sw_rd_en & (sw_addr == 5'h11);
wire   sw_wr_en_18 = sw_wr_en & (sw_addr == 5'h12);
wire   sw_rd_en_18 = sw_rd_en & (sw_addr == 5'h12);
wire   sw_wr_en_19 = sw_wr_en & (sw_addr == 5'h13);
wire   sw_rd_en_19 = sw_rd_en & (sw_addr == 5'h13);
wire   sw_wr_en_20 = sw_wr_en & (sw_addr == 5'h14);
wire   sw_rd_en_20 = sw_rd_en & (sw_addr == 5'h14);
wire   sw_wr_en_21 = sw_wr_en & (sw_addr == 5'h15);
wire   sw_rd_en_21 = sw_rd_en & (sw_addr == 5'h15);



//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------

// Chip ID
wire [15:0] manu_id  =  16'h8949; // Asci value of YI
wire [7:0] chip_id   =  8'h02;
wire [7:0] chip_rev  =  8'h01;

assign reg_0 = {manu_id,chip_id,chip_rev};


//-----------------------------------------------------------------------
//   reg-1, reset value = 32'hA55A_A55A
//   -----------------------------------------------------------------

gen_32b_reg  #(32'hA55A_A55A) u_reg_1	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_1    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_1         )
	      );

assign fuse_mhartid = reg_1;

//-----------------------------------------------------------------------
// Logic for gpio_data_in 
//-----------------------------------------------------------------------
logic [31:0] gpio_in_data_s;
logic [31:0] gpio_in_data_ss;
// Double Sync the gpio pin data for edge detection
always @ (posedge mclk or negedge h_reset_n)
begin 
  if (h_reset_n == 1'b0) begin
    reg_2  <= 'h0 ;
    gpio_in_data_s  <= 32'd0;
    gpio_in_data_ss <= 32'd0;
  end
  else begin
    gpio_in_data_s   <= gpio_in_data;
    gpio_in_data_ss <= gpio_in_data_s;
    reg_2           <= gpio_in_data_ss;
  end
end


assign cfg_gpio_data_in = reg_2[31:0]; // to be used for edge interrupt detect
assign gpio_prev_indata = gpio_in_data_ss;

//-----------------------------------------------------------------------
// Logic for cfg_gpio_out_data 
//-----------------------------------------------------------------------
assign cfg_gpio_out_data = reg_3[31:0]; // data to the GPIO control blk 

gen_32b_reg  #(32'h0) u_reg_3	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_3    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_3         )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_dir_sel 
//-----------------------------------------------------------------------
assign cfg_gpio_dir_sel = reg_4[31:0]; // data to the GPIO O/P pins 

gen_32b_reg  #(32'h0) u_reg_4	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_4    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_4         )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_out_type 
//-----------------------------------------------------------------------
assign cfg_gpio_out_type = reg_5[31:0]; // to be used for read

gen_32b_reg  #(32'h0) u_reg_5	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_5    ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_5         )
	      );


//-----------------------------------------------------------------------
//   reg-6
//-----------------------------------------------------------------
assign  irq_lines     = reg_6[15:0]; 
assign  soft_irq      = reg_6[16]; 
assign  user_irq      = {gpio_intr,ext_intr_in}; 

generic_register #(8,0  ) u_reg6_be0 (
	      .we            ({8{sw_wr_en_6 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (sw_reg_wdata[7:0]    ),
	      .reset_n       (h_reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_6[7:0]        )
          );

generic_register #(8,0  ) u_reg6_be1 (
	      .we            ({8{sw_wr_en_6 & 
                                 wr_be[1]   }}  ),		 
	      .data_in       (sw_reg_wdata[15:8]),
	      .reset_n       (h_reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_6[15:8]        )
          );

assign reg_6[31:16] = '0;

//  Register-7
gen_32b_reg  #(32'h0) u_reg_7	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_7   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_7        )
	      );

assign cfg_pulse_1us = reg_7[9:0];

//-----------------------------------------------------------------------
// Logic for cfg_int_status 
// Always update int_status, even if no register write is occuring.
// Interrupt posting is higher priority than int clear by host 
//-----------------------------------------------------------------------
wire [31:0]  cfg_gpio_int_status = reg_9[31:0]; // to be used for read

//--------------------------------------------------------
// Interrupt Status Generation
// Note: Reg_9 --> Interrupt Status Register, Writting '1' will clear the
//                 corresponding interrupt status bit. Writting '0' has no
//                 effect 
//       Reg_10 --> Writting one to this register will set the interrupt in
//                  interrupt status register (reg_9), Writting '0' does not has any
//                  effect.
/// Always update int_status, even if no register write is occuring.
//	    Interrupt posting is higher priority than int clear by host 
//--------------------------------------------------------
wire [31:0] gpio_int_status = reg_9;				      
always @(posedge mclk or negedge h_reset_n)
begin
   if(~h_reset_n)
   begin
      reg_9[31:0]   <= 32'h0;
   end
   else
   begin
      if(sw_wr_en_9 && wr_be[0])
      begin
         reg_9[7:0] <=  ((~sw_reg_wdata[7:0] & gpio_int_status[7:0]) | gpio_int_event[7:0]);
      end
      else if(sw_wr_en_10 && wr_be[0]) 
      begin
         reg_9[7:0] <= ((sw_reg_wdata[7:0] | gpio_int_status[7:0]) | gpio_int_event[7:0]);
      end
      else
      begin
         reg_9[7:0] <=   (gpio_int_status[7:0] | gpio_int_event[7:0]);
      end

      if(sw_wr_en_9 && wr_be[1])
      begin
         reg_9[15:8] <=  ((~sw_reg_wdata[15:8] & gpio_int_status[15:8]) | gpio_int_event[15:8]);
      end
      else if(sw_wr_en_10 && wr_be[1]) 
      begin
         reg_9[15:8] <= ((sw_reg_wdata[15:8] | gpio_int_status[15:8]) | gpio_int_event[15:8]);
      end
      else
      begin
         reg_9[15:8] <=   (gpio_int_status[15:8] | gpio_int_event[15:8]);
      end

      if(sw_wr_en_9 && wr_be[2])
      begin
         reg_9[23:16] <=  ((~sw_reg_wdata[23:16] & gpio_int_status[23:16]) | gpio_int_event[23:16]);
      end
      else if(sw_wr_en_10 && wr_be[2]) 
      begin
         reg_9[23:16] <= ((sw_reg_wdata[23:16] | gpio_int_status[23:16]) | gpio_int_event[23:16]);
      end
      else
      begin
         reg_9[23:16] <=   (gpio_int_status[23:16] | gpio_int_event[23:16]);
      end

      if(sw_wr_en_9 && wr_be[3])
      begin
         reg_9[31:24] <=  ((~sw_reg_wdata[31:24] & gpio_int_status[31:24]) | gpio_int_event[31:24]);
      end
      else if(sw_wr_en_10 && wr_be[3]) 
      begin
         reg_9[31:24] <= ((sw_reg_wdata[31:24] | gpio_int_status[31:24]) | gpio_int_event[31:24]);
      end
      else
      begin
         reg_9[31:24] <=   (gpio_int_status[31:24] | gpio_int_event[31:24]);
      end
   end
end
//-------------------------------------------------
// Returns same value as interrupt status register
//------------------------------------------------

assign reg_10 = reg_9;
//-----------------------------------------------------------------------
// Logic for cfg_gpio_int_mask :  GPIO interrupt mask  
//-----------------------------------------------------------------------
wire [31:0]  cfg_gpio_int_mask = reg_11[31:0]; // to be used for read

assign gpio_intr  = ( | (reg_9 & reg_11) ); // interrupt pin to the RISC


//  Register-11
gen_32b_reg  #(32'h0) u_reg_11	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_11   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_11        )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_posedge_int_sel :  Enable posedge GPIO interrupt 
//-----------------------------------------------------------------------
assign  cfg_gpio_posedge_int_sel = reg_12[31:0]; // to be used for read
gen_32b_reg  #(32'h0) u_reg_12	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_12   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_12        )
	      );
//-----------------------------------------------------------------------
// Logic for cfg_gpio_negedge_int_sel :  Enable negedge GPIO interrupt 
//-----------------------------------------------------------------------
assign cfg_gpio_negedge_int_sel = reg_13[31:0]; // to be used for read
gen_32b_reg  #(32'h0) u_reg_13	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_13   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_13        )
	      );

//-----------------------------------------------------------------------
// Logic for cfg_multi_func_sel :Enable GPIO to act as multi function pins 
//-----------------------------------------------------------------------
assign  cfg_multi_func_sel = reg_14[31:0]; // to be used for read


gen_32b_reg  #(32'h0) u_reg_14	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_14   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_14        )
	      );

// Reg-15
gen_32b_reg  #(32'h0) u_reg_15	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_15   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_15        )
	      );
//-----------------------------------------------------------------------
// Logic for PWM-0 Config
//-----------------------------------------------------------------------
assign  cfg_pwm0_low  = reg_16[15:0];  // low period of w/f 
assign  cfg_pwm0_high = reg_16[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_16	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_16   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_16        )
	      );


//-----------------------------------------------------------------------
// Logic for PWM-1 Config
//-----------------------------------------------------------------------
assign  cfg_pwm1_low  = reg_17[15:0];  // low period of w/f 
assign  cfg_pwm1_high = reg_17[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_17	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_17   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_17         )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-2 Config
//-----------------------------------------------------------------------
assign  cfg_pwm2_low  = reg_18[15:0];  // low period of w/f 
assign  cfg_pwm2_high = reg_18[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_18	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_18   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_18        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-3 Config
//-----------------------------------------------------------------------
assign  cfg_pwm3_low  = reg_19[15:0];  // low period of w/f 
assign  cfg_pwm3_high = reg_19[31:16]; // high period of w/f 
gen_32b_reg  #(32'h0) u_reg_19	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_19   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_19        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-4 Config
//-----------------------------------------------------------------------
assign  cfg_pwm4_low  = reg_20[15:0];  // low period of w/f 
assign  cfg_pwm4_high = reg_20[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_20	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_20   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_20        )
	      );

//-----------------------------------------------------------------------
// Logic for PWM-5 Config
//-----------------------------------------------------------------------
assign  cfg_pwm5_low  = reg_21[15:0];  // low period of w/f 
assign  cfg_pwm5_high = reg_21[31:16]; // high period of w/f 

gen_32b_reg  #(32'h0) u_reg_21	(
	      //List of Inputs
	      .reset_n    (h_reset_n     ),
	      .clk        (mclk          ),
	      .cs         (sw_wr_en_21   ),
	      .we         (wr_be         ),		 
	      .data_in    (sw_reg_wdata  ),
	      
	      //List of Outs
	      .data_out   (reg_21       )
	      );



//-----------------------------------------------------------------------
// Register Read Path Multiplexer instantiation
//-----------------------------------------------------------------------

always_comb
begin 
  reg_out [31:0] = 32'h0;

  case (sw_addr [4:0])
    5'b00000 : reg_out [31:0] = reg_0 [31:0];     
    5'b00001 : reg_out [31:0] = reg_1 [31:0];    
    5'b00010 : reg_out [31:0] = reg_2 [31:0];     
    5'b00011 : reg_out [31:0] = reg_3 [31:0];    
    5'b00100 : reg_out [31:0] = reg_4 [31:0];    
    5'b00101 : reg_out [31:0] = reg_5 [31:0];    
    5'b00110 : reg_out [31:0] = reg_6 [31:0];    
    5'b00111 : reg_out [31:0] = reg_7 [31:0];    
    5'b01000 : reg_out [31:0] = reg_8 [31:0];    
    5'b01001 : reg_out [31:0] = reg_9 [31:0];    
    5'b01010 : reg_out [31:0] = reg_10 [31:0];   
    5'b01011 : reg_out [31:0] = reg_11 [31:0];   
    5'b01100 : reg_out [31:0] = reg_12 [31:0];   
    5'b01101 : reg_out [31:0] = reg_13 [31:0];
    5'b01110 : reg_out [31:0] = reg_14 [31:0];
    5'b01111 : reg_out [31:0] = reg_15 [31:0]; 
    5'b10000 : reg_out [31:0] = reg_16 [31:0];
    5'b10010 : reg_out [31:0] = reg_17 [31:0];
    5'b10011 : reg_out [31:0] = reg_18 [31:0];
    5'b10100 : reg_out [31:0] = reg_19 [31:0];
    5'b10101 : reg_out [31:0] = reg_20 [31:0];
    5'b10110 : reg_out [31:0] = reg_21 [31:0];
    default  : reg_out [31:0] = 32'h0;
  endcase
end


endmodule                       
