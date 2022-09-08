
/***********************************************

wire  [15:0]    strap_in;
assign strap_in[`PSTRAP_CLK_SRC] = 2'b00;            // System Clock Source wbs/riscv: User clock1
assign strap_in[`PSTRAP_CLK_DIV] = 2'b00;            // Clock Division for wbs/riscv : 0 Div
assign strap_in[`PSTRAP_UARTM_CFG] = 2'b0;           // uart master config control -  constant value based on system clock selection
assign strap_in[`PSTRAP_QSPI_SRAM] = 1'b1;           // QSPI SRAM Mode Selection - Quad 
assign strap_in[`PSTRAP_QSPI_FLASH] = 2'b10;         // QSPI Fash Mode Selection - Quad
assign strap_in[`PSTRAP_RISCV_RESET_MODE] = 1'b1;    // Riscv Reset control - Removed Riscv on Power On Reset
assign strap_in[`PSTRAP_RISCV_CACHE_BYPASS] = 1'b0;  // Riscv Cache Bypass: 0 - Cache Enable
assign strap_in[`PSTRAP_RISCV_SRAM_CLK_EDGE] = 1'b0; // Riscv SRAM clock edge selection: 0 - Normal
assign strap_in[`PSTRAP_CLK_SKEW] = 2'b00;           // Skew selection 2'b00 - Default value

assign strap_in[`PSTRAP_DEFAULT_VALUE] = 1'b0;       // 0 - Normal
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

//--------------------------------------------------------
// Pad Pull-up/down initialization based on Boot Mode
//---------------------------------------------------------

`ifdef RISC_BOOT // RISCV Based Test case
parameter bit  [15:0] PAD_STRAP = 16'b0000_0001_1010_0000;
`else
parameter bit  [15:0] PAD_STRAP = 16'b0000_0000_1010_0000;
`endif

//-------------------------------------------------------------
// Variable Decleration
//-------------------------------------------------------------

reg            clock         ;
reg            clock2        ;
reg            xtal_clk      ;
reg            wb_rst_i      ;

reg            power1, power2;
reg            power3, power4;

// Wishbone Interface
reg            wbd_ext_cyc_i ;  // strobe/request
reg            wbd_ext_stb_i ;  // strobe/request
reg [31:0]     wbd_ext_adr_i ;  // address
reg            wbd_ext_we_i  ;  // write
reg [31:0]     wbd_ext_dat_i ;  // data output
reg [3:0]      wbd_ext_sel_i ;  // byte enable

wire [31:0]    wbd_ext_dat_o ;  // data input
wire           wbd_ext_ack_o ;  // acknowlegement
wire           wbd_ext_err_o ;  // error

// User I/O
wire [37:0]    io_oeb        ;
wire [37:0]    io_out        ;
wire [37:0]    io_in         ;
reg  [127:0]   la_data_in;

reg            test_fail     ;
reg [31:0]     write_data    ;
reg [31:0]     read_data     ;
integer    d_risc_id;


wire USER_VDD1V8 = 1'b1;
wire VSS = 1'b0;

//-----------------------------------------
// Clock Decleration
//-----------------------------------------

always #(CLK1_PERIOD/2) clock  <= (clock === 1'b0);
always #(CLK2_PERIOD/2) clock2 <= (clock2 === 1'b0);
always #(XTAL_PERIOD/2) xtal_clk <= (xtal_clk === 1'b0);


//-----------------------------------------
// Variable Initiatlization
//-----------------------------------------
initial
begin
   // Run in Fast Sim Mode
   `ifdef GL
       force u_top.u_wb_host.u_reg._8654_.Q= 1'b1; 
   `else
       force u_top.u_wb_host.u_reg.u_fastsim_buf.X = 1'b1; 
    `endif

    clock = 0;
    clock2 = 0;
    xtal_clk = 0;
    test_fail = 0;
    wbd_ext_cyc_i ='h0;  // strobe/request
    wbd_ext_stb_i ='h0;  // strobe/request
    wbd_ext_adr_i ='h0;  // address
    wbd_ext_we_i  ='h0;  // write
    wbd_ext_dat_i ='h0;  // data output
    wbd_ext_sel_i ='h0;  // byte enable
	la_data_in = 1;
end
//-----------------------------------------
// DUT Instatiation
//-----------------------------------------
user_project_wrapper u_top(
`ifdef USE_POWER_PINS
    .vccd1(USER_VDD1V8),	// User area 1 1.8V supply
    .vssd1(VSS),	// User area 1 digital ground
`endif
    .wb_clk_i        (clock),  // System clock
    .user_clock2     (clock2),  // Real-time clock
    .wb_rst_i        (wb_rst_i),  // Regular Reset signal

    .wbs_cyc_i   (wbd_ext_cyc_i),  // strobe/request
    .wbs_stb_i   (wbd_ext_stb_i),  // strobe/request
    .wbs_adr_i   (wbd_ext_adr_i),  // address
    .wbs_we_i    (wbd_ext_we_i),  // write
    .wbs_dat_i   (wbd_ext_dat_i),  // data output
    .wbs_sel_i   (wbd_ext_sel_i),  // byte enable

    .wbs_dat_o   (wbd_ext_dat_o),  // data input
    .wbs_ack_o   (wbd_ext_ack_o),  // acknowlegement

 
    // Logic Analyzer Signals
    .la_data_in      (la_data_in) ,
    .la_data_out     (),
    .la_oenb         ('0),
 

    // IOs
    .io_in          (io_in )  ,
    .io_out         (io_out) ,
    .io_oeb         (io_oeb) ,

    .user_irq       () 

);

task init;
begin
   //#1 - Apply Reset
   #1000 wb_rst_i = 0; 
   repeat (10) @(posedge clock);
   #1000 wb_rst_i = 1; 

   //#3 - Remove Reset
   #1000 wb_rst_i = 0; 
   repeat (10) @(posedge clock);
   //#4 - Wait for Power on reset removal
   wait(u_top.p_reset_n == 1);          

   // #5 - Wait for system reset removal
   wait(u_top.s_reset_n == 1);          // Wait for system reset removal
   repeat (10) @(posedge clock);

  end
endtask

//-----------------------------------------------
// Apply user defined strap at power-on
//-----------------------------------------------

task         apply_strap;
input [15:0] strap;
begin

   repeat (10) @(posedge clock);
   //#1 - Apply Reset
   wb_rst_i = 1; 
   //#2 - Apply Strap
   force u_top.io_in[36:29] = strap[15:8];
   force u_top.io_in[20:13] = strap[7:0];
   repeat (10) @(posedge clock);
    
   //#3 - Remove Reset
   wb_rst_i = 0; // Remove Reset

   //#4 - Wait for Power on reset removal
   wait(u_top.p_reset_n == 1);          

   // #5 - Release the Strap
   release u_top.io_in[36:29];
   release u_top.io_in[20:13];

   // #6 - Wait for system reset removal
   wait(u_top.s_reset_n == 1);          // Wait for system reset removal
   repeat (10) @(posedge clock);

end
endtask

//---------------------------------------------------------
// Create Pull Up/Down Based on Reset Strap Parameter
//---------------------------------------------------------
genvar gCnt;
generate
 for(gCnt=0; gCnt<16; gCnt++) begin : g_strap
    if(gCnt < 8) begin
       if(PAD_STRAP[gCnt]) begin
           pullup(io_in[13+gCnt]); 
       end else begin
           pulldown(io_in[13+gCnt]); 
       end
    end else begin
       if(PAD_STRAP[gCnt]) begin
           pullup(io_in[29+gCnt-8]); 
       end else begin
           pulldown(io_in[29+gCnt-8]); 
       end
    end
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
   read_data = 0;
   while((read_data >> (d_risc_id*8)) != 8'h1) begin
       wb_user_core_read(`ADDR_SPACE_GLBL+`GLBL_CFG_MAIL_BOX,read_data);
	    repeat (1000) @(posedge clock);
   end

   $display("Status:  RISCV Core is Booted ");

end
endtask

task wait_riscv_exit;
begin
   // GLBL_CFG_MAIL_BOX used as mail box, each core update boot up handshake at 8 bit
   // bit[7:0]  - core-0
   // bit[15:8]  - core-1
   // bit[23:16] - core-2
   // bit[31:24] - core-3
   $display("Status:  Waiting for RISCV Core Boot ... ");
   read_data = 0;
   while((read_data >> (d_risc_id*8)) != 8'hFF) begin
       wb_user_core_read(`ADDR_SPACE_GLBL+`GLBL_CFG_MAIL_BOX,read_data);
	    repeat (1000) @(posedge clock);
   end

   $display("Status:  RISCV Core is Booted ");

end
endtask

`endif

//-------------------------------
// Wishbone Write
//-------------------------------
task wb_user_core_write;
input [31:0] address;
input [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h1;  // write
  wbd_ext_dat_i =data;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  $display("DEBUG WB USER ACCESS WRITE Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask


//--------------------------------------
// Wishbone Read
//--------------------------------------
task  wb_user_core_read;
input [31:0] address;
output [31:0] data;
reg    [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='0;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(negedge clock);
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  $display("DEBUG WB USER ACCESS READ Address : %x, Data : %x",address,data);
  repeat (2) @(posedge clock);
end
endtask


//--------------------------------------
// Wishbone Read and compare
//--------------------------------------
task  wb_user_core_read_check;
input [31:0] address;
output [31:0] data;
input [31:0] cmp_data;
reg    [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='0;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(negedge clock);
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  if(data !== cmp_data) begin
     $display("ERROR : WB USER ACCESS READ  Address : 0x%x, Exd: 0x%x Rxd: 0x%x ",address,cmp_data,data);
     test_fail = 1;
  end else begin
     $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  end
  repeat (2) @(posedge clock);
end
endtask


task  wb_user_core_read_cmp;
input [31:0] address;
input [31:0] cmp_data;
reg    [31:0] data;
begin
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_adr_i =address;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='0;  // data output
  wbd_ext_sel_i ='hF;  // byte enable
  wbd_ext_cyc_i ='h1;  // strobe/request
  wbd_ext_stb_i ='h1;  // strobe/request
  wait(wbd_ext_ack_o == 1);
  repeat (1) @(negedge clock);
  data  = wbd_ext_dat_o;  
  repeat (1) @(posedge clock);
  #1;
  wbd_ext_cyc_i ='h0;  // strobe/request
  wbd_ext_stb_i ='h0;  // strobe/request
  wbd_ext_adr_i ='h0;  // address
  wbd_ext_we_i  ='h0;  // write
  wbd_ext_dat_i ='h0;  // data output
  wbd_ext_sel_i ='h0;  // byte enable
  if(data !== cmp_data) begin
     $display("ERROR : WB USER ACCESS READ  Address : 0x%x, Exd: 0x%x Rxd: 0x%x ",address,cmp_data,data);
     test_fail = 1;
  end else begin
     $display("STATUS: WB USER ACCESS READ  Address : 0x%x, Data : 0x%x",address,data);
  end
  repeat (2) @(posedge clock);
end
endtask


/**
`ifdef GL
//-----------------------------------------------------------------------------
// RISC IMEM amd DMEM Monitoring TASK
//-----------------------------------------------------------------------------

`define RISC_CORE  user_uart_tb.u_top.u_core.u_riscv_top

always@(posedge `RISC_CORE.wb_clk) begin
    if(`RISC_CORE.wbd_imem_ack_i)
          $display("RISCV-DEBUG => IMEM ADDRESS: %x Read Data : %x", `RISC_CORE.wbd_imem_adr_o,`RISC_CORE.wbd_imem_dat_i);
    if(`RISC_CORE.wbd_dmem_ack_i && `RISC_CORE.wbd_dmem_we_o)
          $display("RISCV-DEBUG => DMEM ADDRESS: %x Write Data: %x Resonse: %x", `RISC_CORE.wbd_dmem_adr_o,`RISC_CORE.wbd_dmem_dat_o);
    if(`RISC_CORE.wbd_dmem_ack_i && !`RISC_CORE.wbd_dmem_we_o)
          $display("RISCV-DEBUG => DMEM ADDRESS: %x READ Data : %x Resonse: %x", `RISC_CORE.wbd_dmem_adr_o,`RISC_CORE.wbd_dmem_dat_i);
end

`endif
**/

