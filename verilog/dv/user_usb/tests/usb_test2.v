`define usbbfm  u_usb_agent
task usb_test2;

reg [6:0] address;
reg [3:0] endpt;
reg [3:0] Status;

  integer    i,j;
  reg [7:0]  startbyte;
  reg [15:0] mask;
  integer    MaxPktSize;
  reg [3:0]  PackType;


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

    $display("%0d: Set Address = 1 -----", $time);
    `usbbfm.SetAddress (address);
    `usbbfm.setup(7'h00, 4'h0, Status);
    `usbbfm.printstatus(Status, MYACK);
    `usbbfm.status_IN(7'h00, endpt, Status);
    `usbbfm.printstatus(Status, MYACK);
    #5000;
  
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
	
	
    // register word write
    $display("%0d: Performing Register Word Write------------", $time);
    `usbbfm.VenRegWordWr (address, 32'h0,  32'h11223344);
    `usbbfm.VenRegWordWr (address, 32'h4,  32'h22334455);
    `usbbfm.VenRegWordWr (address, 32'h8,  32'h33445566);
    `usbbfm.VenRegWordWr (address, 32'hC,  32'h44556677);
    `usbbfm.VenRegWordWr (address, 32'h10, 32'h55667788);
    `usbbfm.VenRegWordWr (address, 32'h14, 32'h66778899);
    `usbbfm.VenRegWordWr (address, 32'h18, 32'h778899AA);
    `usbbfm.VenRegWordWr (address, 32'h1C, 32'h8899AABB);
    `usbbfm.VenRegWordWr (address, 32'h20, 32'h99AABBCC);
    `usbbfm.VenRegWordWr (address, 32'h24, 32'hAABBCCDD);
    `usbbfm.VenRegWordWr (address, 32'h28, 32'hBBCCDDEE);
    `usbbfm.VenRegWordWr (address, 32'h2C, 32'hCCDDEEFF);
    #500;

    // register word Read
    $display("%0d: Performing Register Word Read------------", $time);
    `usbbfm.VenRegWordRdCmp (address, 32'h0 , 32'h11223344);
    `usbbfm.VenRegWordRdCmp (address, 32'h4 , 32'h22334455);
    `usbbfm.VenRegWordRdCmp (address, 32'h8 , 32'h33445566);
    `usbbfm.VenRegWordRdCmp (address, 32'hC , 32'h44556677);
    `usbbfm.VenRegWordRdCmp (address, 32'h10, 32'h55667788);
    `usbbfm.VenRegWordRdCmp (address, 32'h14, 32'h66778899);
    `usbbfm.VenRegWordRdCmp (address, 32'h18, 32'h778899AA);
    `usbbfm.VenRegWordRdCmp (address, 32'h1C, 32'h8899AABB);
    `usbbfm.VenRegWordRdCmp (address, 32'h20, 32'h99AABBCC);
    `usbbfm.VenRegWordRdCmp (address, 32'h24, 32'hAABBCCDD);
    `usbbfm.VenRegWordRdCmp (address, 32'h28, 32'hBBCCDDEE);
    `usbbfm.VenRegWordRdCmp (address, 32'h2C, 32'hCCDDEEFF);
    #500


  
    $display ("USB doing register writes and reads to USB block end \n");

    test_control.finish_test;
  end

endtask
