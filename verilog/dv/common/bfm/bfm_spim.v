

// SPI Master BFM
//   Command-1 :  0x10, 
//    SI :  <CMD[7:0]> <ADDR[31:0]><Dummy[7:0]>
//    SO :  ------------------------------------<RDATA[31:0]>
//   Command-2 : 0x2F , 
//    SI :  <CMD[7:0]> <ADDR[31:0]><WDATA[31:0]><Dummy[7:0]>
//    SO :   ---------------------------------------------

`timescale 1 ns / 1 ps
`define TB_SPI_CLK_PW 100

module bfm_spim (

                   // SPI
                   spi_clk,
                   spi_sel_n,
                   spi_din,
                   spi_dout

                  );

output	    spi_clk;
output	    spi_sel_n;
output      spi_din;
input       spi_dout;

reg	    spi_clk;
reg	    spi_sel_n;
reg         spi_din;
reg         error_ind;

event       error_detected;
integer     err_cnt;


initial begin

spi_clk = 0;
spi_sel_n = 1;
spi_din = 0;
error_ind = 0;
err_cnt = 0;

end

task init;
begin
   spi_clk=1;
   spi_sel_n=1;
   spi_din=1;  
end
endtask


always @error_detected begin
  error_ind = 1;
  err_cnt = err_cnt + 1;
end



task set_spi_sel_n;
begin
  #10;
  spi_sel_n=0;
  #100;
end
endtask

task reset_spi_sel_n;
begin
  #10;
  spi_sel_n=1;
  #100;
end
endtask




//-----------------------------
// Reg Write 32 Bit
//-----------------------------

task reg_wr_dword;
input [31:0] addr; 
input [31:0] dword;
reg [31:0]   addr;
reg [31:0]   dword;
begin

  set_spi_sel_n;
  send_cmd(8'h2F);
  send_dword(addr);
  send_dword(dword);
  send_byte(8'h0); // Dummy byte

  $display("STATUS: At time %t: SPI WRITE : ADDR = %h DATA = %h ", $time, addr, dword);

  reset_spi_sel_n;

end
endtask

//-----------------------------
// Reg Read 32 Bit
//-----------------------------
task reg_rd_dword;
input [31:0] addr;
output [31:0] dword;
reg [31:0] addr;
reg [31:0] dword;
integer i;
begin

  set_spi_sel_n;
  send_cmd(8'h10);
  send_dword(addr);
  send_byte(8'h0); // Dummy byte
  receive_dword(dword);

  $display("STATUS: At time %t: SPI READ :addr = %h data = %h ", $time, addr, dword);

  reset_spi_sel_n;
end
endtask

//-----------------------------
// Reg Read 32 Bit compare
//-----------------------------
task reg_rd_dword_cmp;
input [31:0] addr;
input [31:0] exp_dword;
reg [31:0] addr;
reg [31:0] dword;
integer i;
begin

  set_spi_sel_n;
  send_cmd(8'h10);
  send_dword(addr);
  send_byte(8'h0); // Dummy byte
  receive_dword(dword);

  if (exp_dword !== dword)
  begin
    $display("ERROR: At time %t: SPI READ FAILED ADDR: %x EXP = %x RXD : %x ",$time,addr,exp_dword,dword);
    -> error_detected;
  end else begin
    $display("STATUS: At time %t: SPI READ ADDR: %x RXD : %x ",$time,addr,dword);

  end

  reset_spi_sel_n;
end
endtask


//-----------------------------
// Command Byte
//-----------------------------
task       send_cmd;
input [7:0] data;
begin
begin
  send_byte(data[7:0]);
end

end
endtask
// Write 4 Byte
task send_dword;
input [31:0] dword;
begin
  send_word(dword[31:16]);
  send_word(dword[15:0]);
end
endtask

// Write 2 Byte
task send_word;
input [15:0] word;
begin
  send_byte(word[15:8]);
  send_byte(word[7:0]);
end
endtask // spi_send_word



// Write 1 Byte
task send_byte;
input [7:0] data;
integer i;
begin

  for (i=7; i>=0; i=i-1)
  begin
     spi_clk=0;
     spi_din = data[i];
     #`TB_SPI_CLK_PW;
     spi_clk=1;
    // if (i != 0)
       #`TB_SPI_CLK_PW;
  end

end
endtask
//----------------------------
// READ TASK
//----------------------------

// READ 4 BYTE
task receive_dword;
output [31:0] dword;
reg [31:0] dword;
begin
  receive_word(dword[31:16]);
  receive_word(dword[15:0]);
end
endtask

// READ 2 BYTE
task receive_word;
output [15:0] word;
reg [15:0] word;
begin
  receive_byte(word[15:8]);
  receive_byte(word[7:0]);
end
endtask



// READ 1 BYTE
task receive_byte;
output [7:0] data;
reg [7:0] data;
integer i;
begin
  for (i=7; i>=0; i=i-1)
  begin
     spi_clk=0;
     #`TB_SPI_CLK_PW;
     spi_clk=1;
     data[i] = spi_dout;
//     if (i !=0)
       #`TB_SPI_CLK_PW;
  end

end
endtask

endmodule

