
/********************
parameter bit  [15:0] PAD_STRAP = (2'b00 << `PSTRAP_CLK_SRC             ) |
                                  (2'b00 << `PSTRAP_CLK_DIV             ) |
                                  (1'b1  << `PSTRAP_UARTM_CFG           ) |
                                  (1'b1  << `PSTRAP_QSPI_SRAM           ) |
                                  (2'b10 << `PSTRAP_QSPI_FLASH          ) |
                                  (1'b1  << `PSTRAP_RISCV_RESET_MODE    ) |
                                  (1'b1  << `PSTRAP_RISCV_CACHE_BYPASS  ) |
                                  (1'b1  << `PSTRAP_RISCV_SRAM_CLK_EDGE ) |
                                  (2'b00 << `PSTRAP_CLK_SKEW            ) |
                                  (1'b0  << `PSTRAP_DEFAULT_VALUE       ) ;
****/

`ifdef RISC_BOOT // RISCV Based Test case
parameter bit  [15:0] PAD_STRAP = 16'b0000_0001_1010_0000;
`else
parameter bit  [15:0] PAD_STRAP = 16'b0000_0000_1010_0000;
`endif

/***********************************************

wire  [15:0]    strap_in;
assign strap_in[`PSTRAP_CLK_SRC] = 2'b00;            // System Clock Source wbs/riscv: User clock1
assign strap_in[`PSTRAP_CLK_DIV] = 2'b00;            // Clock Division for wbs/riscv : 0 Div
assign strap_in[`PSTRAP_UARTM_CFG] = 1'b0;           // uart master config control -  constant value based on system clock selection
assign strap_in[`PSTRAP_QSPI_SRAM] = 1'b1;           // QSPI SRAM Mode Selection - Quad 
assign strap_in[`PSTRAP_QSPI_FLASH] = 2'b10;         // QSPI Fash Mode Selection - Quad
assign strap_in[`PSTRAP_RISCV_RESET_MODE] = 1'b1;    // Riscv Reset control - Removed Riscv on Power On Reset
assign strap_in[`PSTRAP_RISCV_CACHE_BYPASS] = 1'b0;  // Riscv Cache Bypass: 0 - Cache Enable
assign strap_in[`PSTRAP_RISCV_SRAM_CLK_EDGE] = 1'b0; // Riscv SRAM clock edge selection: 0 - Normal
assign strap_in[`PSTRAP_CLK_SKEW] = 2'b00;           // Skew selection 2'b00 - Default value

assign strap_in[`PSTRAP_DEFAULT_VALUE] = 1'b0;       // 0 - Normal
***/

initial
begin
   // Run in Fast Sim Mode
   `ifdef GL
       force u_top.mprj.u_wb_host.u_reg._8654_.Q= 1'b1; 
   `else
       force u_top.mprj.u_wb_host.u_reg.u_fastsim_buf.X = 1'b1; 
    `endif

end
task init;
begin
   //#1 - Apply Reset
   #1000 RSTB = 1; 
   repeat (10) @(posedge clock);
   #1000 RSTB = 0; 

   //#3 - Remove Reset
   #1000 RSTB = 1; 
   repeat (10) @(posedge clock);
   //#4 - Wait for Power on reset removal
   wait(u_top.mprj.p_reset_n == 1);          

   // #5 - Wait for system reset removal
   wait(u_top.mprj.s_reset_n == 1);          // Wait for system reset removal
   repeat (10) @(posedge clock);

/****
   //#2 - Apply Strap
   strap_in[`PSTRAP_CLK_SRC] = 2'b00;            // System Clock Source wbs/riscv: User clock1
   strap_in[`PSTRAP_CLK_DIV] = 2'b00;            // Clock Division for wbs/riscv : 0 Div
   strap_in[`PSTRAP_UARTM_CFG] = 1'b0;           // uart master config control -  constant value based on system clock selection
   strap_in[`PSTRAP_QSPI_SRAM] = 1'b1;           // QSPI SRAM Mode Selection - Quad 
   strap_in[`PSTRAP_QSPI_FLASH] = 2'b10;         // QSPI Fash Mode Selection - Quad
   strap_in[`PSTRAP_RISCV_RESET_MODE] = 1'b1;    // Riscv Reset control - Removed Riscv on Power On Reset
   strap_in[`PSTRAP_RISCV_CACHE_BYPASS] = 1'b0;  // Riscv Cache Bypass: 0 - Cache Enable
   strap_in[`PSTRAP_RISCV_SRAM_CLK_EDGE] = 1'b0; // Riscv SRAM clock edge selection: 0 - Normal
   strap_in[`PSTRAP_CLK_SKEW] = 2'b00;           // Skew selection 2'b00 - Default value

   strap_in[`PSTRAP_DEFAULT_VALUE] = 1'b0;       // 0 - Normal

   force u_top.io_in[36:29] = strap_in[15:8];
   force u_top.io_in[20:13] = strap_in[7:0];
   repeat (10) @(posedge clock);
   
   //#3 - Remove Reset
   wb_rst_i = 0; // Remove Reset
   repeat (10) @(posedge clock);
   //#4 - Wait for Power on reset removal
   wait(u_top.p_reset_n == 1);          

    // #5 - Release the Strap
    release u_top.io_in[36:29];
    release u_top.io_in[20:13];

    // #6 - Wait for system reset removal
    wait(u_top.s_reset_n == 1);          // Wait for system reset removal
    repeat (10) @(posedge clock);

***/
  end
endtask

task  apply_strap;
input [15:0] strap;
reg   strap_load;
begin
   
   repeat (10) @(posedge clock);
   //#1 - Apply Reset
   RSTB = 0; 
   strap_load = 1;
   //#2 - Apply Strap
   force mprj_io[37] = strap[11];
   force mprj_io[32] = strap[10];
   force mprj_io[31] = strap[9];
   force mprj_io[30] = strap[8];
   force mprj_io[29] = strap[7];
   force mprj_io[28] = strap[6];
   force mprj_io[21] = strap[5];
   force mprj_io[18] = strap[4];
   force mprj_io[17] = strap[3];
   force mprj_io[13] = strap[2];
   force mprj_io[10] = strap[1];
   force mprj_io[7]  = strap[0];
   repeat (10) @(posedge clock);
    
   //#3 - Remove Reset
   RSTB = 1; // Remove Reset

   //#4 - Wait for Power on reset removal
   wait(u_top.mprj.p_reset_n == 1);          

   // #5 - Release the Strap
   release mprj_io[37] ;
   release mprj_io[32] ;
   release mprj_io[31] ;
   release mprj_io[30] ;
   release mprj_io[29] ;
   release mprj_io[28] ;
   release mprj_io[21] ;
   release mprj_io[18] ;
   release mprj_io[17] ;
   release mprj_io[13] ;
   release mprj_io[10] ;
   release mprj_io[7]  ;

   // #6 - Wait for system reset removal
   wait(u_top.mprj.s_reset_n == 1);          // Wait for system reset removal
   repeat (10) @(posedge clock);
   strap_load = 0;

end
endtask

//---------------------------------------------------------
// Create Pull Up/Down Based on Reset Strap Parameter
//---------------------------------------------------------
    // Assign TriState for Strap ports - Otherwse iverilog is assumming pullup/down as strong driver
    assign  mprj_io[37] = 1'bz;
    assign  mprj_io[32] = 1'bz;
    assign  mprj_io[31] = 1'bz;
    assign  mprj_io[30] = 1'bz;
    assign  mprj_io[29] = 1'bz;
    assign  mprj_io[28] = 1'bz;
    assign  mprj_io[21] = 1'bz;
    assign  mprj_io[18] = 1'bz;
    assign  mprj_io[17] = 1'bz;
    assign  mprj_io[13] = 1'bz;
    assign  mprj_io[10] = 1'bz;
    assign  mprj_io[7] = 1'bz;


generate
    if(PAD_STRAP[0]) begin
        pullup  (mprj_io[7]); 
    end else begin
        pulldown  (mprj_io[7]); 
    end

    if(PAD_STRAP[1]) begin
        pullup  (mprj_io[10]); 
    end else begin
        pulldown (mprj_io[10]); 
    end
    if(PAD_STRAP[2]) begin
        pullup  (mprj_io[13]); 
    end else begin
        pulldown  (mprj_io[13]); 
    end
    if(PAD_STRAP[3]) begin
        pullup  (mprj_io[17]); 
    end else begin
        pulldown  (mprj_io[17]); 
    end
    if(PAD_STRAP[4]) begin
        pullup  (mprj_io[18]); 
    end else begin
        pulldown  (mprj_io[18]); 
    end
    if(PAD_STRAP[5]) begin
        pullup  (mprj_io[21]); 
    end else begin
        pulldown  (mprj_io[21]); 
    end
    if(PAD_STRAP[6]) begin
        pullup  (mprj_io[28]); 
    end else begin
        pulldown  (mprj_io[28]); 
    end
    if(PAD_STRAP[7]) begin
        pullup  (mprj_io[29]); 
    end else begin
        pulldown  (mprj_io[29]); 
    end
    if(PAD_STRAP[8]) begin
        pullup  (mprj_io[30]); 
    end else begin
        pulldown  (mprj_io[30]); 
    end
    if(PAD_STRAP[9]) begin
        pullup  (mprj_io[31]); 
    end else begin
        pulldown  (mprj_io[31]); 
    end
    if(PAD_STRAP[10]) begin
        pullup  (mprj_io[32]); 
    end else begin
        pulldown  (mprj_io[32]); 
    end
    if(PAD_STRAP[11]) begin
        pullup  (mprj_io[37]); 
    end else begin
        pulldown  (mprj_io[37]); 
    end
endgenerate

`ifdef RISC_BOOT // RISCV Based Test case
//-------------------------------------------
task wait_riscv_boot;
begin
   // GLBL_CFG_MAIL_BOX used as mail box, each core update boot up handshake at 8 bit
   // bit[7:0]  - core-0
   // bit[15:8]  - core-1
   // bit[23:16] - core-2
   // bit[31:24] - core-3
   $display("Status:  Waiting for RISCV Core Boot ... ");

   wait(u_top.mprj.u_pinmux.u_glbl_reg.reg_15 == 8'h1);
   $display("Status:  RISCV Core is Booted ");

end
endtask

`endif



 /*************************************************************************
 * This is Baud Rate to clock divider conversion for Test Bench
 * Note: DUT uses 16x baud clock, where are test bench uses directly
 * baud clock, Due to 16x Baud clock requirement at RTL, there will be
 * some resolution loss, we expect at lower baud rate this resolution
 * loss will be less. For Quick simulation perpose higher baud rate used
 * *************************************************************************/
 task tb_set_uart_baud;
 input [31:0] ref_clk;
 input [31:0] baud_rate;
 output [31:0] baud_div;
 reg   [31:0] baud_div;
 begin
// for 230400 Baud = (50Mhz/230400) = 216.7
baud_div = ref_clk/baud_rate; // Get the Bit Baud rate
// Baud 16x = 216/16 = 13
    baud_div = baud_div/16; // To find the RTL baud 16x div value to find similar resolution loss in test bench
// Test bench baud clock , 16x of above value
// 13 * 16 = 208,  
// (Note if you see original value was 216, now it's 208 )
    baud_div = baud_div * 16;
// Test bench half cycle counter to toggle it 
// 208/2 = 104
     baud_div = baud_div/2;
//As counter run's from 0 , substract from 1
 baud_div = baud_div-1;
 end
 endtask


