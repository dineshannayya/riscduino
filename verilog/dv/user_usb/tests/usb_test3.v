`define usbbfm  tb_top.u_usb_agent
task usb_test3;

reg [6:0] address;
reg [3:0] endpt;
reg [3:0] Status;
reg [31:0] ByteCount;
reg [31:0] ReadData;
integer    i,j,k;


reg [1:0] data_bit        ;
reg	  stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg	  stick_parity    ; // 1: force even parity
reg	  parity_en       ; // parity enable
reg	  even_odd_parity ; // 0: odd parity; 1: even parity
reg [15:0] divisor        ;	// divided by (n+1) * 16
reg [15:0] timeout        ;// wait time limit
reg 	fifo_enable       ;	// fifo mode disable

reg [7:0] write_data [0:39];
reg [15:0] rx_nu;
reg [15:0] tx_nu;


parameter  MYACK   = 4'b0000,
           MYNAK   = 4'b0001,
           MYSTALL = 4'b0010,
           MYTOUT  = 4'b0011,
           MYIVRES = 4'b0100,
           MYCRCER = 4'b0101;

     begin
     address = 7'b000_0001;
     endpt   = 4'b0000;

    $display("%0d: USB Reset  -----", $time);
    `usbbfm.usbhw_reset;

    /*********************************************************
    *          HOST                            DEVICE
    *  1.  0x2D,0x00, 0x00    
    *  2.  0xC3,0x00,0x05,0x01,
    *      0x00,0x00,0x00,0x00,
    *      0x00,0xEB,0x25
    *  3.                                      0xD2
    *  4.  0x69,0x00, 0x10  
    *  5.                                      0x4B, 0x00  
    *  6.  0xD2
    **********************************************************/
    $display("%0d: Set Address = 1 -----", $time);
    `usbbfm.SetAddress (address);
    `usbbfm.setup(7'h00, 4'h0, Status);
    `usbbfm.printstatus(Status, MYACK);
    `usbbfm.status_IN(7'h00, endpt, Status);
    `usbbfm.printstatus(Status, MYACK);

    #5000;
    /*********************************************************
    *          HOST                            DEVICE
    *  1.  0x2D,0x01, 0xE8    
    *  2.  0xC3,0x00,0x09,0x01,
    *      0x00,0x00,0x00,0x00,
    *      0x00,0x27,0x25
    *  3.                                      0xD2
    *  4.  0x69,0x01, 0xE8  
    *  5.                                      0x4B, 0x00  
    *  6.  0xD2
    **********************************************************/
  
    $display("%0d: Set configuration  -----", $time);
    `usbbfm.SetConfiguration(2'b01);
    `usbbfm.setup(address, 4'b0000, Status);
    `usbbfm.printstatus(Status, MYACK);
    `usbbfm.status_IN(address, 4'b0000, Status);
    `usbbfm.printstatus(Status, MYACK);
    #2000;

    $display("%0d: Configuration done !!!!!!", $time);
     
   // write UART  registers through USB
	
     //////////////////////////////////////////////////////////////////
      data_bit        = 2'b11;
      stop_bits       = 0; // 0: 1 stop bit; 1: 2 stop bit;
      stick_parity    = 0; // 1: force even parity
      parity_en       = 1; // parity enable
      even_odd_parity = 1; // 0: odd parity; 1: even parity
      divisor        = 15;	// divided by (n+1) * 16
      timeout        = 500;// wait time limit
      fifo_enable       = 0;	// fifo mode disable
	
    tb_top.u_uart_agent.uart_init;
    /*********************************************************
    *          HOST                            DEVICE
    *  1.  0x2D,0x01, 0xE8    
    *  2.  0xC3,0x40,0x10,0x00,
    *      0x00,0x00,0x00,0x04,
    *      0x00,0xA8,0xC5
    *  3.                                      0xD2
    *  4.  0xE1,0x01, 0xE8  
    *  5.  0x4B,0x00,0x00,0x00                 
    *      0x17,0xBF,0xD5
    *  6                                       0xD2
    *  7.  0x69,0x01,0xE8
    *  8.                                      0x4B,0x00
    *  9.   0xD2
    **********************************************************/
    `usbbfm.VenRegWordWr (address, 32'h0, {27'h0,2'b10,1'b1,1'b1,1'b1});  
    /*********************************************************
    *          HOST                            DEVICE
    *  1.  0x2D,0x01, 0xE8    
    *  2.  0xC3,0x40,0x10,0x00,
    *      0x00,0x00,0x08,0x04,
    *      0x00,0x29,0x07
    *  3.                                      0xD2
    *  4.  0xE1,0x01, 0xE8  
    *  5.  0x4B,0x00,0x00,0x00                 
    *      0x0E,0x7E,0x1F
    *  6                                       0xD2
    *  7.  0x69,0x01,0xE8
    *  8.                                      0x4B,0x00
    *  9.   0xD2
    **********************************************************/
    // Baud Clock 16x,  Master Clock/ (2+cfg_value)
    `usbbfm.VenRegWordWr (address, 32'h8, divisor-1);  
    tb_top.u_uart_agent.control_setup (data_bit, stop_bits, parity_en, even_odd_parity, stick_parity, timeout, divisor, fifo_enable);
	
    for (i=0; i<40; i=i+1)
	write_data[i] = $random;

   fork
   begin
      for (i=0; i<40; i=i+1)
      begin
        $display ("\n... Writing char %d ...", write_data[i]);
         tb_top.u_uart_agent.write_char (write_data[i]);
	 #20000;
      end
   end

   begin
      for (j=0; j<40; j=j+1)
      begin
        tb_top.u_uart_agent.read_char_chk(write_data[j]);
      end
   end

   // Read through the USB and check the UART RX Fifo Status;
   // If Available, then loop it back
   begin
      for (k=0; k<40; k=k+1)
      begin
        ReadData[1]= 1'b1;
        while(ReadData[1] == 1'b1 ) begin // Check for UART RX fifo not empty
           $display ("\n... Reading the UART Status: %x ...", ReadData);
          /*********************************************************
          *          HOST                            DEVICE
          *  1.  0x2D,0x01, 0xE8    
          *  2.  0xC3,0xC0,0x11,0x00,
          *      0x00,0x00,0x0C,0x04,
          *      0x00,0x70,0x66
          *  3.                                      0xD2
          *  4.  0x69,0x01, 0xE8  
	  *  5.                                      0x4B,00
	  *  6.  0xD2
	  *  7.  0xE1,0x01,0xE8
	  *  8.  0x4B,0x00, 0x00
          *  9                                       0xD2
          **********************************************************/
          `usbbfm.VenRegWordRd (address, 32'hC, ReadData);  
       end
          `usbbfm.VenRegWordRd (address, 32'h14, ReadData);  // Read the UART RXD Data
          `usbbfm.VenRegWordWr (address, 32'h10, ReadData);   // Write Back to UART TXD
      end
   end
   join

   #100
   tb_top.u_uart_agent.report_status(rx_nu, tx_nu);
end
endtask
