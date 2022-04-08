
// #################################################################
// Module: spi tasks
//
// Description : All ST and ATMEL commands are made into tasks
// Note: CMD+ADDRESS Sent is Big Endian
//       Write Data/Read Data Send as Little endian to match RISCV
//       Data accesss
// #################################################################

parameter LITTLE_ENDIAN  = 1'b0;
parameter BIG_ENDIAN     = 1'b1;

event      sspi_error_detected;
reg  [1:0] sspi_chip_no;

integer sspi_err_cnt;

task sspi_init;
begin
   sspi_err_cnt = 0;
   sspi_chip_no = 0;
end 
endtask 


always @sspi_error_detected
begin
    `TB_GLBL.test_err;
     sspi_err_cnt = sspi_err_cnt + 1;
end
//***** Read Double Word Data from Specific Address ******//
task sspi_dw_read;
    input    [7:0]  cmd;
    input    [23:0] address;
    output   [31:0] read_data;
    reg      [31:0] read_data;
begin
      sspi_write_dword({cmd,address[23:0]},BIG_ENDIAN,8'h0);
      sspi_write_byte(32'h00,BIG_ENDIAN,8'h0);  // 8 Bit Dummy Cycle
      sspi_read_dword(LITTLE_ENDIAN,read_data,8'h1);

end
endtask

task sspi_dw_write;
    input    [7:0]  cmd;
    input    [23:0] address;
    input   [31:0] write_data;
begin
      sspi_write_dword({cmd,address[23:0]},BIG_ENDIAN,8'h0);
      sspi_write_dword(write_data,LITTLE_ENDIAN,8'h1);

end
endtask

task sspi_dw_read_check;
    input    [7:0]  cmd;
    input    [23:0] address;
    input    [31:0] exp_data;
    reg      [31:0] read_data;
begin
      sspi_write_dword({cmd,address[23:0]},BIG_ENDIAN,8'h0);
      sspi_write_byte(32'h00,BIG_ENDIAN,8'h0);  // 8 Bit Dummy Cycle
      sspi_read_dword(LITTLE_ENDIAN,read_data,8'h1);
      if(read_data !== exp_data) begin
         -> sspi_error_detected;
         $display("%m : ERROR :  Address: %x Exp : %x Rxd : %x",address,exp_data,read_data);
      end else begin
         $display("%m : STATUS : Address: %x Matched : %x ",address,read_data);
      end

end
endtask

// Write One Byte
task sspi_write_byte;
    input [7:0] datain;
    input       endian;
    input [7:0] cs_byte;
    reg  [31:0] read_data;
    begin

      @(posedge `TB_GLBL.clock) 
      `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h4,{datain,24'h0});
      `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h0,{1'b1,5'h0,
	                        endian,
                                spi_chip_no[1:0],
                                2'b0,    // Write Operatopm
                                2'b0,    // Single Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                cs_byte }); // cs bit 0x40 for 1 byte transaction
      
     `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
     while(read_data[31]) begin
        @(posedge `TB_GLBL.clock) ;
        `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
      end 
    end
endtask

//***** ST : Write Enable task ******//
task sspi_write_dword;
    input [31:0] cmd;
    input        endian; // 0 - Little,1 - Big
    input [7:0]  cs_byte;
    reg   [31:0] read_data;
    begin
      @(posedge `TB_GLBL.clock) 
      `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h4,{cmd});
      `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h0,{1'b1,5'h0,
	                        endian,
                                spi_chip_no[1:0],
                                2'b0,    // Write Operatopm
                                2'h3,    // 4 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                cs_byte[7:0] }); // cs bit information
      
     `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
     while(read_data[31]) begin
        @(posedge `TB_GLBL.clock) ;
        `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
      end 
    end
endtask


//***** ST : Write Enable task ******//
task sspi_read_dword;
    input         endian;
    output [31:0] dataout;
    input  [7:0]  cs_byte;
    reg    [31:0] read_data;
    begin

      @(posedge `TB_GLBL.clock) 
      `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h0,{1'b1,5'h0,
	                        endian,
                                spi_chip_no[1:0],
                                2'b1,    // Read Operatopm
                                2'h3,    // 4 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                cs_byte[7:0] }); // cs bit information
      
     `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);

     while(read_data[31]) begin
        @(posedge `TB_GLBL.clock) ;
        `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
     end 

     `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h8,dataout);

    end
endtask



task sspi_sector_errase;
    input [23:0] address;
    reg   [31:0] read_data;
    begin

      @(posedge `TB_GLBL.clock) ;
      `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h4,{8'hD8,address[23:0]});
      `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h0,{1'b1,5'h0,
	                        BIG_ENDIAN,
                                spi_chip_no[1:0],
                                2'b0,    // Write Operatopm
                                2'h3,    // 4 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                8'h1 }); // cs bit information
      
     `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);

      $display("%t : %m : Sending Sector Errase for Address : %x",$time,address);
      

     `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
     while(read_data[31]) begin
        @(posedge `TB_GLBL.clock) ;
        `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
     end 
   end
endtask


task sspi_page_write;
    input [23:0] address;
    reg [7:0] i;
    reg [31:0] write_data;
    begin

      sspi_write_dword({8'h02,address[23:0]},BIG_ENDIAN,8'h0);

      for(i = 0; i < 252 ; i = i + 4) begin
         write_data [31:24]  = i;
         write_data [23:16]  = i+1;
         write_data [15:8]   = i+2;
         write_data [7:0]    = i+3;
         sspi_write_dword(write_data,LITTLE_ENDIAN,8'h0);
         $display("%m : Writing Data-%d : %x",i,write_data);
      end
     
      // Writting last 4 byte with de-selecting the chip select 
         write_data [31:24]  = i;
         write_data [23:16]  = i+1;
         write_data [15:8]   = i+2;
         write_data [7:0]    = i+3;
      sspi_write_dword(write_data,LITTLE_ENDIAN,8'h1);
      $display("%m : Writing Data-%d : %x",i,write_data);

    end
endtask


task sspi_page_read_verify;
    input [23:0] address;
    reg   [31:0] read_data;
    reg [7:0] i;
    reg [31:0] exp_data;
    begin

      sspi_write_dword({8'h03,address[23:0]},BIG_ENDIAN,8'h0);

      for(i = 0; i < 252 ; i = i + 4) begin
         exp_data [31:24]  = i;
         exp_data [23:16]  = i+1;
         exp_data [15:8]   = i+2;
         exp_data [7:0]    = i+3;
         sspi_read_dword(LITTLE_ENDIAN,read_data,8'h0);
         if(read_data != exp_data) begin
            -> sspi_error_detected;
            $display("%m : ERROR : Data:%d-> Exp : %x Rxd : %x",i,exp_data,read_data);
         end else begin
            $display("%m : STATUS :  Data:%d Matched : %x ",i,read_data);
         end

      end
     
      // Reading last 4 byte with de-selecting the chip select 
         exp_data [31:24]  = i;
         exp_data [23:16]  = i+1;
         exp_data [15:8]   = i+2;
         exp_data [7:0]    = i+3;

         sspi_read_dword(LITTLE_ENDIAN,read_data,8'h1);
         if(read_data != exp_data) begin
            -> sspi_error_detected;
            $display("%m : ERROR : Data:%d-> Exp : %x Rxd : %x",i,exp_data,read_data);
         end else begin
            $display("%m : STATUS :  Data:%d Matched : %x ",i,read_data);
         end

    end
endtask




task sspi_op_over;
    reg [31:0] read_data;
    begin
     `TB_GLBL.wb_user_core_read('h0,read_data);
      while(read_data[31]) begin
        @(posedge `TB_GLBL.clock) ;
        `TB_GLBL.wb_user_core_read('h0,read_data);
      end 
      #100;
    end
endtask

task sspi_wait_busy;
    reg [31:0] read_data;
    reg        exit_flag;
    integer    pretime;
    begin

    read_data = 1;
    pretime = $time;

     
  exit_flag = 1;
   while(exit_flag == 1) begin 

    `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h4,{8'h05,24'h0});
    `TB_GLBL.wb_user_core_write(`ADDR_SPACE_SSPI+'h0,{1'b1,5'h0,
	                        BIG_ENDIAN,
                                spi_chip_no[1:0],
                                2'b0,    // Write Operation
                                2'b0,    // 1 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                8'h0 }); // cs bit information


        `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
        while(read_data[31]) begin
          @(posedge `TB_GLBL.clock) ;
          `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
        end 

     // Send Status Request Cmd


      `TB_GLBL.wb_user_core_write('h0,{1'b1,5'h0,
	                        BIG_ENDIAN,
                                spi_chip_no[1:0],
                                2'b1,    // Read Operation
                                2'b0,    // 1 Transfer
                                6'h10,    // sck clock period
                                5'h2,    // cs setup/hold period
                                8'h40 }); // cs bit information

        
        `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
        while(read_data[31]) begin
          @(posedge `TB_GLBL.clock) ;
          `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h0,read_data);
        end 
      
        `TB_GLBL.wb_user_core_read(`ADDR_SPACE_SSPI+'h8,read_data);
        exit_flag = read_data[24];
        $display("Total time Elapsed: %0t(us): %m : Checking the SPI RDStatus : %x",($time - pretime)/1000000 ,read_data);
      repeat (1000) @ (posedge `TB_GLBL.clock) ;
     end
  end
endtask



task sspi_tb_status;
begin

   $display("#############################");
   $display("   Test Statistic            ");
   if(sspi_err_cnt >0) begin 
      $display("TEST STATUS : FAILED ");
      $display("TOTAL ERROR COUNT : %d ",sspi_err_cnt);
   end else begin
      $display("TEST STATUS : PASSED ");
   end
   $display("#############################");
end
endtask

