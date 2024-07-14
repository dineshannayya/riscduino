
// One Word write
task uartm_reg_write;
input [31:0] addr;
input [31:0] data;
reg [7:0] read_data;
reg flag;
begin
       tb_master_uart.write_char("w");
       tb_master_uart.write_char("m");
       tb_master_uart.write_char(" ");
       tb_master_uart.write_char(hex2char(addr[31:28]));
       tb_master_uart.write_char(hex2char(addr[27:24]));
       tb_master_uart.write_char(hex2char(addr[23:20]));
       tb_master_uart.write_char(hex2char(addr[19:16]));
       tb_master_uart.write_char(hex2char(addr[15:12]));
       tb_master_uart.write_char(hex2char(addr[11:8]));
       tb_master_uart.write_char(hex2char(addr[7:4]));
       tb_master_uart.write_char(hex2char(addr[3:0]));
       tb_master_uart.write_char(" ");
       tb_master_uart.write_char(hex2char(data[31:28]));
       tb_master_uart.write_char(hex2char(data[27:24]));
       tb_master_uart.write_char(hex2char(data[23:20]));
       tb_master_uart.write_char(hex2char(data[19:16]));
       tb_master_uart.write_char(hex2char(data[15:12]));
       tb_master_uart.write_char(hex2char(data[11:8]));
       tb_master_uart.write_char(hex2char(data[7:4]));
       tb_master_uart.write_char(hex2char(data[3:0]));
       tb_master_uart.write_char("\n");
       // Wait for sucess command
       flag = 0;
       while(flag == 0)
       begin
          tb_master_uart.read_char2(read_data,flag);
             //$write ("%c",read_data);
       end
end
endtask

// One Byte write
task uartm_byte_reg_write;
input [31:0] addr;
input [7:0] data;
reg [7:0] read_data;
reg flag;
begin
       tb_master_uart.write_char("w");
       tb_master_uart.write_char("m");
       tb_master_uart.write_char(" ");
       tb_master_uart.write_char(hex2char(addr[31:28]));
       tb_master_uart.write_char(hex2char(addr[27:24]));
       tb_master_uart.write_char(hex2char(addr[23:20]));
       tb_master_uart.write_char(hex2char(addr[19:16]));
       tb_master_uart.write_char(hex2char(addr[15:12]));
       tb_master_uart.write_char(hex2char(addr[11:8]));
       tb_master_uart.write_char(hex2char(addr[7:4]));
       tb_master_uart.write_char(hex2char(addr[3:0]));
       tb_master_uart.write_char(" ");
       tb_master_uart.write_char(hex2char(data[7:4]));
       tb_master_uart.write_char(hex2char(data[3:0]));
       tb_master_uart.write_char("\n");
       // Wait for sucess command
       flag = 0;
       while(flag == 0)
       begin
          tb_master_uart.read_char2(read_data,flag);
             //$write ("%c",read_data);
       end
end
endtask

// Three Byte Burst Reg Write
task uartm_three_burst_reg_write;
input [31:0] addr;
input [31:0] data1;
input [31:0] data2;
input [31:0] data3;
reg [7:0] read_data;
reg flag;
begin
       tb_master_uart.write_char("w");
       tb_master_uart.write_char("m");
       tb_master_uart.write_char(" ");
       tb_master_uart.write_char(hex2char(addr[31:28]));
       tb_master_uart.write_char(hex2char(addr[27:24]));
       tb_master_uart.write_char(hex2char(addr[23:20]));
       tb_master_uart.write_char(hex2char(addr[19:16]));
       tb_master_uart.write_char(hex2char(addr[15:12]));
       tb_master_uart.write_char(hex2char(addr[11:8]));
       tb_master_uart.write_char(hex2char(addr[7:4]));
       tb_master_uart.write_char(hex2char(addr[3:0]));
       tb_master_uart.write_char(" ");
       tb_master_uart.write_char(hex2char(data1[31:28]));
       tb_master_uart.write_char(hex2char(data1[27:24]));
       tb_master_uart.write_char(hex2char(data1[23:20]));
       tb_master_uart.write_char(hex2char(data1[19:16]));
       tb_master_uart.write_char(hex2char(data1[15:12]));
       tb_master_uart.write_char(hex2char(data1[11:8]));
       tb_master_uart.write_char(hex2char(data1[7:4]));
       tb_master_uart.write_char(hex2char(data1[3:0]));
       tb_master_uart.write_char(" ");
       tb_master_uart.write_char(hex2char(data2[31:28]));
       tb_master_uart.write_char(hex2char(data2[27:24]));
       tb_master_uart.write_char(hex2char(data2[23:20]));
       tb_master_uart.write_char(hex2char(data2[19:16]));
       tb_master_uart.write_char(hex2char(data2[15:12]));
       tb_master_uart.write_char(hex2char(data2[11:8]));
       tb_master_uart.write_char(hex2char(data2[7:4]));
       tb_master_uart.write_char(hex2char(data2[3:0]));
       tb_master_uart.write_char(" ");
       tb_master_uart.write_char(hex2char(data3[31:28]));
       tb_master_uart.write_char(hex2char(data3[27:24]));
       tb_master_uart.write_char(hex2char(data3[23:20]));
       tb_master_uart.write_char(hex2char(data3[19:16]));
       tb_master_uart.write_char(hex2char(data3[15:12]));
       tb_master_uart.write_char(hex2char(data3[11:8]));
       tb_master_uart.write_char(hex2char(data3[7:4]));
       tb_master_uart.write_char(hex2char(data3[3:0]));
       tb_master_uart.write_char("\n");
       // Wait for sucess command
       flag = 0;
       while(flag == 0)
       begin
          tb_master_uart.read_char2(read_data,flag);
             //$write ("%c",read_data);
       end
end
endtask

task uartm_reg_read;
input [31:0] addr;
output [31:0] data;
reg [7:0] read_data;
reg flag;
integer i;
begin
   tb_master_uart.write_char("r");
   tb_master_uart.write_char("m");
   tb_master_uart.write_char(" ");
   tb_master_uart.write_char(hex2char(addr[31:28]));
   tb_master_uart.write_char(hex2char(addr[27:24]));
   tb_master_uart.write_char(hex2char(addr[23:20]));
   tb_master_uart.write_char(hex2char(addr[19:16]));
   tb_master_uart.write_char(hex2char(addr[15:12]));
   tb_master_uart.write_char(hex2char(addr[11:8]));
   tb_master_uart.write_char(hex2char(addr[7:4]));
   tb_master_uart.write_char(hex2char(addr[3:0]));
   tb_master_uart.write_char("\n");
   // Wait for sucess command
   flag = 0;
   i = 0;
   while(flag == 0)
   begin
      tb_master_uart.read_char2(read_data,flag);
         //$write ("%d:%c",i,read_data);
           case (i)
           8'd10 : data[31:28] = char2hex(read_data);
           8'd11 : data[27:24] = char2hex(read_data);
           8'd12 : data[23:20] = char2hex(read_data);
           8'd13 : data[19:16] = char2hex(read_data);
           8'd14 : data[15:12] = char2hex(read_data);
           8'd15 : data[11:8]  = char2hex(read_data);
           8'd16 : data[7:4]   = char2hex(read_data);
           8'd17 : data[3:0]   = char2hex(read_data);
      endcase
	  i = i+1;
   $display("received Data: 0x%x",data);
   end

end
endtask

// Single Burst Read check

task uartm_reg_read_check;
input [31:0] addr;
input [31:0] exp_data;
reg [31:0] rxd_data;
reg [7:0] read_data;
reg flag;
integer i;
begin
   tb_master_uart.write_char("r");
   tb_master_uart.write_char("m");
   tb_master_uart.write_char(" ");
   tb_master_uart.write_char(hex2char(addr[31:28]));
   tb_master_uart.write_char(hex2char(addr[27:24]));
   tb_master_uart.write_char(hex2char(addr[23:20]));
   tb_master_uart.write_char(hex2char(addr[19:16]));
   tb_master_uart.write_char(hex2char(addr[15:12]));
   tb_master_uart.write_char(hex2char(addr[11:8]));
   tb_master_uart.write_char(hex2char(addr[7:4]));
   tb_master_uart.write_char(hex2char(addr[3:0]));
   tb_master_uart.write_char("\n");
   // Wait for sucess command
   flag = 0;
   i = 0;
   while(flag == 0)
   begin
      tb_master_uart.read_char2(read_data,flag);
      //$write ("%d:%c",i,read_data);
        case (i)
        8'd0 : rxd_data[31:28] = char2hex(read_data);
        8'd1 : rxd_data[27:24] = char2hex(read_data);
        8'd2 : rxd_data[23:20] = char2hex(read_data);
        8'd3 : rxd_data[19:16] = char2hex(read_data);
        8'd4 : rxd_data[15:12] = char2hex(read_data);
        8'd5 : rxd_data[11:8]  = char2hex(read_data);
        8'd6 : rxd_data[7:4]   = char2hex(read_data);
        8'd7 : rxd_data[3:0]   = char2hex(read_data);
        endcase
    i = i+1;
   end
   if(rxd_data == exp_data) begin
      $display("STATUS: ADDRESS: 0x%x RXD: 0x%x", addr,rxd_data);
   end else begin
      $display("ERROR:  ADDRESS: 0x%x EXP: %x RXD: 0x%x", addr,exp_data,rxd_data);
      test_fail = 1;
   end


end
endtask


// Three Burst Read check
task uartm_three_burst_reg_read_check;
input [31:0] addr;
input [31:0] exp_data1;
input [31:0] exp_data2;
input [31:0] exp_data3;
reg [31:0]   rxd_data1;
reg [31:0]   rxd_data2;
reg [31:0]   rxd_data3;
reg [7:0] read_data;
reg flag;
integer i;
begin
   tb_master_uart.write_char("b");
   tb_master_uart.write_char("r");
   tb_master_uart.write_char(" ");
   tb_master_uart.write_char(hex2char(addr[31:28]));
   tb_master_uart.write_char(hex2char(addr[27:24]));
   tb_master_uart.write_char(hex2char(addr[23:20]));
   tb_master_uart.write_char(hex2char(addr[19:16]));
   tb_master_uart.write_char(hex2char(addr[15:12]));
   tb_master_uart.write_char(hex2char(addr[11:8]));
   tb_master_uart.write_char(hex2char(addr[7:4]));
   tb_master_uart.write_char(hex2char(addr[3:0]));
   tb_master_uart.write_char(" ");
   tb_master_uart.write_char("3");
   tb_master_uart.write_char("\n");
   // Wait for sucess command
   flag = 0;
   i = 0;
   while(flag == 0)
   begin
      tb_master_uart.read_char2(read_data,flag);
      //$write ("%d:%c",i,read_data);
        case (i)
        8'd0  : rxd_data1[31:28] = char2hex(read_data);
        8'd1  : rxd_data1[27:24] = char2hex(read_data);
        8'd2  : rxd_data1[23:20] = char2hex(read_data);
        8'd3  : rxd_data1[19:16] = char2hex(read_data);
        8'd4  : rxd_data1[15:12] = char2hex(read_data);
        8'd5  : rxd_data1[11:8]  = char2hex(read_data);
        8'd6  : rxd_data1[7:4]   = char2hex(read_data);
        8'd7  : rxd_data1[3:0]   = char2hex(read_data);

        8'd9  : rxd_data2[31:28] = char2hex(read_data);
        8'd10 : rxd_data2[27:24] = char2hex(read_data);
        8'd11 : rxd_data2[23:20] = char2hex(read_data);
        8'd12 : rxd_data2[19:16] = char2hex(read_data);
        8'd13 : rxd_data2[15:12] = char2hex(read_data);
        8'd14 : rxd_data2[11:8]  = char2hex(read_data);
        8'd15 : rxd_data2[7:4]   = char2hex(read_data);
        8'd16 : rxd_data2[3:0]   = char2hex(read_data);

        8'd18 : rxd_data3[31:28] = char2hex(read_data);
        8'd19 : rxd_data3[27:24] = char2hex(read_data);
        8'd20 : rxd_data3[23:20] = char2hex(read_data);
        8'd21 : rxd_data3[19:16] = char2hex(read_data);
        8'd22 : rxd_data3[15:12] = char2hex(read_data);
        8'd23 : rxd_data3[11:8]  = char2hex(read_data);
        8'd24 : rxd_data3[7:4]   = char2hex(read_data);
        8'd25 : rxd_data3[3:0]   = char2hex(read_data);
        endcase
    i = i+1;
   end
   if(rxd_data1 == exp_data1) begin
      $display("STATUS: ADDRESS: 0x%x RXD: 0x%x", addr,rxd_data1);
   end else begin
      $display("ERROR:  ADDRESS: 0x%x EXP: %x RXD: 0x%x", addr,exp_data1,rxd_data1);
      test_fail = 1;
   end

   if(rxd_data2 == exp_data2) begin
      $display("STATUS: ADDRESS: 0x%x RXD: 0x%x", addr+4,rxd_data2);
   end else begin
      $display("ERROR:  ADDRESS: 0x%x EXP: %x RXD: 0x%x", addr+4,exp_data2,rxd_data2);
      test_fail = 1;
   end

   if(rxd_data3 == exp_data3) begin
      $display("STATUS: ADDRESS: 0x%x RXD: 0x%x", addr+8,rxd_data3);
   end else begin
      $display("ERROR:  ADDRESS: 0x%x EXP: %x RXD: 0x%x", addr+8,exp_data3,rxd_data3);
      test_fail = 1;
   end
end
endtask

// Character to hex number
function [3:0] char2hex;
input [7:0] data_in;
case (data_in)
     8'h30:	char2hex = 4'h0; // character '0' 
     8'h31:	char2hex = 4'h1; // character '1'
     8'h32:	char2hex = 4'h2; // character '2'
     8'h33:	char2hex = 4'h3; // character '3'
     8'h34:	char2hex = 4'h4; // character '4' 
     8'h35:	char2hex = 4'h5; // character '5'
     8'h36:	char2hex = 4'h6; // character '6'
     8'h37:	char2hex = 4'h7; // character '7'
     8'h38:	char2hex = 4'h8; // character '8'
     8'h39:	char2hex = 4'h9; // character '9'
     8'h41:	char2hex = 4'hA; // character 'A'
     8'h42:	char2hex = 4'hB; // character 'B'
     8'h43:	char2hex = 4'hC; // character 'C'
     8'h44:	char2hex = 4'hD; // character 'D'
     8'h45:	char2hex = 4'hE; // character 'E'
     8'h46:	char2hex = 4'hF; // character 'F'
     8'h61:	char2hex = 4'hA; // character 'a'
     8'h62:	char2hex = 4'hB; // character 'b'
     8'h63:	char2hex = 4'hC; // character 'c'
     8'h64:	char2hex = 4'hD; // character 'd'
     8'h65:	char2hex = 4'hE; // character 'e'
     8'h66:	char2hex = 4'hF; // character 'f'
      default :  char2hex = 4'hF;
   endcase 
endfunction

// Hex to Asci Character 
function [7:0] hex2char;
input [3:0] data_in;
case (data_in)
     4'h0:	hex2char = 8'h30; // character '0' 
     4'h1:	hex2char = 8'h31; // character '1'
     4'h2:	hex2char = 8'h32; // character '2'
     4'h3:	hex2char = 8'h33; // character '3'
     4'h4:	hex2char = 8'h34; // character '4' 
     4'h5:	hex2char = 8'h35; // character '5'
     4'h6:	hex2char = 8'h36; // character '6'
     4'h7:	hex2char = 8'h37; // character '7'
     4'h8:	hex2char = 8'h38; // character '8'
     4'h9:	hex2char = 8'h39; // character '9'
     4'hA:	hex2char = 8'h41; // character 'A'
     4'hB:	hex2char = 8'h42; // character 'B'
     4'hC:	hex2char = 8'h43; // character 'C'
     4'hD:	hex2char = 8'h44; // character 'D'
     4'hE:	hex2char = 8'h45; // character 'E'
     4'hF:	hex2char = 8'h46; // character 'F'
   endcase 
endfunction
