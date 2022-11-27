
`define TOP user_usb_tb

module usb_agent;

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------

// Response values
`define USB_RES_OK      8'h0
`define USB_RES_NAK     8'hFF
`define USB_RES_STALL   8'hFE
`define USB_RES_TIMEOUT 8'hFD


// USB PID values
`define PID_OUT        8'hE1
`define PID_IN         8'h69
`define PID_SOF        8'hA5
`define PID_SETUP      8'h2D

`define PID_DATA0      8'hC3
`define PID_DATA1      8'h4B

`define PID_ACK        8'hD2
`define PID_NAK        8'h5A
`define PID_STALL      8'h1E

// Standard requests (via SETUP packets)
`define REQ_GET_STATUS        8'h00
`define REQ_CLEAR_FEATURE     8'h01
`define REQ_SET_FEATURE       8'h03
`define REQ_SET_ADDRESS       8'h05
`define REQ_GET_DESCRIPTOR    8'h06
`define REQ_SET_DESCRIPTOR    8'h07
`define REQ_GET_CONFIGURATION 8'h08
`define REQ_SET_CONFIGURATION 8'h09
`define REQ_GET_INTERFACE     8'h0A
`define REQ_SET_INTERFACE     8'h0B
`define REQ_SYNC_FRAME        8'h0C

// Descriptor types
`define DESC_DEVICE           8'h01
`define DESC_CONFIGURATION    8'h02
`define DESC_STRING           8'h03
`define DESC_INTERFACE        8'h04
`define DESC_ENDPOINT         8'h05
`define DESC_DEV_QUALIFIER    8'h06
`define DESC_OTHER_SPEED_CONF 8'h07
`define DESC_IF_POWER         8'h08

// Device class
`define DEV_CLASS_RESERVED      8'h00
`define DEV_CLASS_AUDIO         8'h01
`define DEV_CLASS_COMMS         8'h02
`define DEV_CLASS_HID           8'h03
`define DEV_CLASS_MONITOR       8'h04
`define DEV_CLASS_PHY_IF        8'h05
`define DEV_CLASS_POWER         8'h06
`define DEV_CLASS_PRINTER       8'h07
`define DEV_CLASS_STORAGE       8'h08
`define DEV_CLASS_HUB           8'h09
`define DEV_CLASS_TMC           8'hFE
`define DEV_CLASS_VENDOR_CUSTOM 8'hFF

// Device Requests (bmRequestType)
`define REQDIR_HOSTTODEVICE        (0 << 7)
`define REQDIR_DEVICETOHOST        (1 << 7)
`define REQTYPE_STANDARD           (0 << 5)
`define REQTYPE_CLASS              (1 << 5)
`define REQTYPE_VENDOR             (2 << 5)
`define REQREC_DEVICE              (0 << 0)
`define REQREC_INTERFACE           (1 << 0)
`define REQREC_ENDPOINT            (2 << 0)
`define REQREC_OTHER               (3 << 0)

// Endpoints
`define ENDPOINT_DIR_MASK          (1 << 7)
`define ENDPOINT_DIR_IN            (1 << 7)
`define ENDPOINT_DIR_OUT           (0 << 7)
`define ENDPOINT_ADDR_MASK         (8'h7F)
`define ENDPOINT_TYPE_MASK         (8'h3)
`define ENDPOINT_TYPE_CONTROL      (0)
`define ENDPOINT_TYPE_ISO          (1)
`define ENDPOINT_TYPE_BULK         (2)
`define ENDPOINT_TYPE_INTERRUPT    (3)


//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
`define USB_CTRL          8'h0
    `define USB_CTRL_TX_FLUSH                    8
    `define USB_CTRL_TX_FLUSH_SHIFT              8
    `define USB_CTRL_TX_FLUSH_MASK               8'h1

    `define USB_CTRL_PHY_DMPULLDOWN              7
    `define USB_CTRL_PHY_DMPULLDOWN_SHIFT        7
    `define USB_CTRL_PHY_DMPULLDOWN_MASK         8'h1

    `define USB_CTRL_PHY_DPPULLDOWN              6
    `define USB_CTRL_PHY_DPPULLDOWN_SHIFT        6
    `define USB_CTRL_PHY_DPPULLDOWN_MASK         8'h1

    `define USB_CTRL_PHY_TERMSELECT              5
    `define USB_CTRL_PHY_TERMSELECT_SHIFT        5
    `define USB_CTRL_PHY_TERMSELECT_MASK         8'h1

    `define USB_CTRL_PHY_XCVRSELECT_SHIFT        3
    `define USB_CTRL_PHY_XCVRSELECT_MASK         8'h3

    `define USB_CTRL_PHY_OPMODE_SHIFT            1
    `define USB_CTRL_PHY_OPMODE_MASK             8'h3

    `define USB_CTRL_ENABLE_SOF                  0
    `define USB_CTRL_ENABLE_SOF_SHIFT            0
    `define USB_CTRL_ENABLE_SOF_MASK             8'h1

`define USB_STATUS        8'h4
    `define USB_STATUS_SOF_TIME_SHIFT            16
    `define USB_STATUS_SOF_TIME_MASK             16'hffff

    `define USB_STATUS_RX_ERROR                  2
    `define USB_STATUS_RX_ERROR_SHIFT            2
    `define USB_STATUS_RX_ERROR_MASK             8'h1

    `define USB_STATUS_LINESTATE_BITS_SHIFT      0
    `define USB_STATUS_LINESTATE_BITS_MASK       8'h3

`define USB_IRQ_ACK       8'h8
    `define USB_IRQ_ACK_DEVICE_DETECT            3
    `define USB_IRQ_ACK_DEVICE_DETECT_SHIFT      3
    `define USB_IRQ_ACK_DEVICE_DETECT_MASK       8'h1

    `define USB_IRQ_ACK_ERR                      2
    `define USB_IRQ_ACK_ERR_SHIFT                2
    `define USB_IRQ_ACK_ERR_MASK                 8'h1

    `define USB_IRQ_ACK_DONE                     1
    `define USB_IRQ_ACK_DONE_SHIFT               1
    `define USB_IRQ_ACK_DONE_MASK                8'h1

    `define USB_IRQ_ACK_SOF                      0
    `define USB_IRQ_ACK_SOF_SHIFT                0
    `define USB_IRQ_ACK_SOF_MASK                 8'h1

`define USB_IRQ_STS       8'hc
    `define USB_IRQ_STS_DEVICE_DETECT            3
    `define USB_IRQ_STS_DEVICE_DETECT_SHIFT      3
    `define USB_IRQ_STS_DEVICE_DETECT_MASK       8'h1

    `define USB_IRQ_STS_ERR                      2
    `define USB_IRQ_STS_ERR_SHIFT                2
    `define USB_IRQ_STS_ERR_MASK                 8'h1

    `define USB_IRQ_STS_DONE                     1
    `define USB_IRQ_STS_DONE_SHIFT               1
    `define USB_IRQ_STS_DONE_MASK                8'h1

    `define USB_IRQ_STS_SOF                      0
    `define USB_IRQ_STS_SOF_SHIFT                0
    `define USB_IRQ_STS_SOF_MASK                 8'h1

`define USB_IRQ_MASK      8'h10
    `define USB_IRQ_MASK_DEVICE_DETECT           3
    `define USB_IRQ_MASK_DEVICE_DETECT_SHIFT     3
    `define USB_IRQ_MASK_DEVICE_DETECT_MASK      8'h1

    `define USB_IRQ_MASK_ERR                     2
    `define USB_IRQ_MASK_ERR_SHIFT               2
    `define USB_IRQ_MASK_ERR_MASK                8'h1

    `define USB_IRQ_MASK_DONE                    1
    `define USB_IRQ_MASK_DONE_SHIFT              1
    `define USB_IRQ_MASK_DONE_MASK               8'h1

    `define USB_IRQ_MASK_SOF                     0
    `define USB_IRQ_MASK_SOF_SHIFT               0
    `define USB_IRQ_MASK_SOF_MASK                8'h1

`define USB_XFER_DATA     8'h14
    `define USB_XFER_DATA_TX_LEN_SHIFT           0
    `define USB_XFER_DATA_TX_LEN_MASK            16'hffff

`define USB_XFER_TOKEN    8'h18
    `define USB_XFER_TOKEN_START                 31
    `define USB_XFER_TOKEN_START_SHIFT           31
    `define USB_XFER_TOKEN_START_MASK            8'h1

    `define USB_XFER_TOKEN_IN                    30
    `define USB_XFER_TOKEN_IN_SHIFT              30
    `define USB_XFER_TOKEN_IN_MASK               8'h1

    `define USB_XFER_TOKEN_ACK                   29
    `define USB_XFER_TOKEN_ACK_SHIFT             29
    `define USB_XFER_TOKEN_ACK_MASK              8'h1

    `define USB_XFER_TOKEN_PID_DATAX             28
    `define USB_XFER_TOKEN_PID_DATAX_SHIFT       28
    `define USB_XFER_TOKEN_PID_DATAX_MASK        8'h1

    `define USB_XFER_TOKEN_PID_BITS_SHIFT        16
    `define USB_XFER_TOKEN_PID_BITS_MASK         8'hff

    `define USB_XFER_TOKEN_DEV_ADDR_SHIFT        9
    `define USB_XFER_TOKEN_DEV_ADDR_MASK         8'h7f

    `define USB_XFER_TOKEN_EP_ADDR_SHIFT         5
    `define USB_XFER_TOKEN_EP_ADDR_MASK          8'hf

`define USB_RX_STAT       8'h1c
    `define USB_RX_STAT_START_PEND               31
    `define USB_RX_STAT_START_PEND_SHIFT         31
    `define USB_RX_STAT_START_PEND_MASK          8'h1

    `define USB_RX_STAT_CRC_ERR                  30
    `define USB_RX_STAT_CRC_ERR_SHIFT            30
    `define USB_RX_STAT_CRC_ERR_MASK             8'h1

    `define USB_RX_STAT_RESP_TIMEOUT             29
    `define USB_RX_STAT_RESP_TIMEOUT_SHIFT       29
    `define USB_RX_STAT_RESP_TIMEOUT_MASK        8'h1

    `define USB_RX_STAT_IDLE                     28
    `define USB_RX_STAT_IDLE_SHIFT               28
    `define USB_RX_STAT_IDLE_MASK                8'h1

    `define USB_RX_STAT_RESP_BITS_SHIFT          16
    `define USB_RX_STAT_RESP_BITS_MASK           8'hff

    `define USB_RX_STAT_COUNT_BITS_SHIFT         0
    `define USB_RX_STAT_COUNT_BITS_MASK          16'hffff

`define USB_WR_DATA       8'h20
    `define USB_WR_DATA_DATA_SHIFT               0
    `define USB_WR_DATA_DATA_MASK                8'hff

`define USB_RD_DATA       8'h20
    `define USB_RD_DATA_DATA_SHIFT               0
    `define USB_RD_DATA_DATA_MASK                8'hff


task usbhw_reg_write;
input [7:0] addr;
input [31:0] wdata;
begin
    `TOP.wb_user_core_write(`ADDR_SPACE_USB+addr,wdata);
end
endtask

task usbhw_reg_read;
input [7:0] addr;
output [31:0] rdata;
begin
    `TOP.wb_user_core_read(`ADDR_SPACE_USB+addr,rdata);
end
endtask

parameter   XMIT_BUF_SIZE       = 64;    // Xmitbuffer size
parameter   RECV_BUF_SIZE       = 64;    // Recvbuffer size


reg [7:0]   XmitBuffer        [0 : XMIT_BUF_SIZE]; // Xmit buffer
reg [7:0]   RecvBuffer        [0 : RECV_BUF_SIZE]; // Recv buffer

//-----------------------------------------------------------------
// usb_setup_packet: Create & send SETUP packet
//-----------------------------------------------------------------
task usb_setup_packet;
input [7:0]  device_address; 
input [7:0]  request_type;
input [7:0]  request; 
input [15:0] value; 
input [15:0] index; 
input [15:0] length;
output[7:0]  status;
reg   [7:0]  status;
integer idx;
begin

    // bmRequestType:
    //  D7 Data Phase Transfer Direction
    //  0 = Host to Device
    //  1 = Device to Host
    //  D6..5 Type
    //  0 = Standard
    //  1 = Class
    //  2 = Vendor
    //  3 = Reserved
    //  D4..0 Recipient
    //  0 = Device
    //  1 = Interface
    //  2 = Endpoint
    //  3 = Other
    // 
    idx = 0;
    XmitBuffer[idx] = request_type;           idx = idx+1;
    XmitBuffer[idx] = request;                idx = idx+1;
    XmitBuffer[idx] = (value >> 0)  & 8'hFF;  idx = idx+1;
    XmitBuffer[idx] = (value >> 8)  & 8'hFF;  idx = idx+1;
    XmitBuffer[idx] = (index >> 0)  & 8'hFF;  idx = idx+1;
    XmitBuffer[idx] = (index >> 8)  & 8'hFF;  idx = idx+1;
    XmitBuffer[idx] = (length >> 0) & 8'hFF;  idx = idx+1;
    XmitBuffer[idx] = (length >> 8) & 8'hFF;  idx = idx+1;

    // Send SETUP token + DATA0 (always DATA0)
    usbhw_transfer_out(`PID_SETUP, device_address, 0, 1, `PID_DATA0, idx,status);

end
endtask

//-----------------------------------------------------------------
// SetAddress: Set device address
//-----------------------------------------------------------------
task setup;
input [7:0] device_address;
input  [3:0] endpoint;
output [7:0]status;
begin
    //$display("USB: Set device address %d\n", device_address);
    // Send SETUP token + DATA0 (always DATA0)
    usbhw_transfer_out(`PID_SETUP, device_address, endpoint, 1, `PID_DATA0, 8,status);
    // Device has 50mS to apply the address
    usbhw_timer_sleep(50);
end
endtask

task printstatus;
   input [3:0] RecvdStatus;
   input [3:0] ExpStatus;
begin
  $display("");
  $display("    #######################################################");
  if(RecvdStatus !== ExpStatus ) begin
     -> `TOP.test_control.error_detected;
     $display("    ERROR: Expected Status and Observed Status didn't match at %0d", $time);
     if(ExpStatus==4'b0000)
        $display("    Expected Status is ACK at %0d", $time);
     else if(ExpStatus==4'b0001)
        $display("    Expected Status is NACK at %0d", $time);
     else if(ExpStatus==4'b0010)
        $display("    Expected Status is STALL at %0d", $time);
     else if(ExpStatus==4'b0011)
        $display("    Expected Status is TIMEOUT at %0d", $time);
     else if(ExpStatus==4'b0100)
        $display("    Expected Status is INVALID RESPONSE at %0d", $time);
     else if(ExpStatus==4'b0101)
        $display("    Expected Status is CRC ERROR at %0d", $time);
  end

  if(RecvdStatus==4'b0000)
     $display("    Received Status is ACK at %0d", $time);
  else if(RecvdStatus==4'b0001)
     $display("    Received Status is NACK at %0d", $time);
  else if(RecvdStatus==4'b0010)
     $display("    Received Status is STALL at %0d", $time);
  else if(RecvdStatus==4'b011)
     $display("    Received Status is TIMEOUT at %0d", $time);
  else if(RecvdStatus==4'b0100)
     $display("    Received Status is INVALID RESPONSE at %0d", $time);
  else if(RecvdStatus==4'b0101)
     $display("    Received Status is CRC ERROR at %0d", $time);
  $display("    #######################################################");
  $display("");
end
endtask
//-----------------------------------------------------------------
// usbhw_reset: Perform USB reset
//-----------------------------------------------------------------
task usbhw_reset;
reg  bflag;
begin
    $display("HW: Applying USB Reset \n");
    // Assert SE0 / reset
    usbhw_hub_reset;

    $display("HW: Reset Wait time Started \n");
    // Wait for some time
    usbhw_timer_sleep(11);

    $display("HW: Reset Wait time Over \n");

    // Stop asserting SE0, set data lines to Hi-Z
    usbhw_hub_enable(0);
    usbhw_timer_sleep(3);

    $display("HW: Waiting for device insertion\n");

    // Wait for device detect
    usbhw_hub_device_detected(bflag);
    while (!bflag)begin
       usbhw_hub_device_detected(bflag);
    end

    $display("HW: Device detected\n");

    // Enable SOF
    usbhw_hub_enable(1);
end
endtask
//-----------------------------------------------------------------
// usbhw_hub_reset: Put bus into SE0 state (reset)
//-----------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////
//
//  SendReset : asserts a SE0 on the USB for the number of bit times specified
//              by ResetTime.
//  Input     : ResetTime, number of bit times for which to drive a reset on
//              the USB
//
////////////////////////////////////////////////////////////////////////////////

task usbhw_hub_reset;
reg [7:0] val;
begin
    $display("HW: Enter USB bus reset\n");

    // Power-up / SE0
    val = 0;
    val = val | (0 << `USB_CTRL_PHY_XCVRSELECT_SHIFT);
    val = val | (0 << `USB_CTRL_PHY_TERMSELECT_SHIFT);
    val = val | (2 << `USB_CTRL_PHY_OPMODE_SHIFT);
    val = val | (1 << `USB_CTRL_PHY_DPPULLDOWN_SHIFT);
    val = val | (1 << `USB_CTRL_PHY_DMPULLDOWN_SHIFT);
    usbhw_reg_write(`USB_CTRL, val);

end
endtask


//-----------------------------------------------------------------
// usbhw_timer_sleep: Perform Sleep
//-----------------------------------------------------------------

task usbhw_timer_sleep;
input [7:0] ResetTime;
reg [7:0] tskResetTime;
reg [7:0] tskResetTimeCounter;
begin
   tskResetTimeCounter = 0;
   tskResetTime = ResetTime;
   forever @(posedge `TOP.usb_48mhz_clk) begin
      tskResetTimeCounter = tskResetTimeCounter + 1'b1;
      if (tskResetTimeCounter > tskResetTime) begin
            @(posedge `TOP.usb_48mhz_clk);
            @(posedge `TOP.usb_48mhz_clk);
            disable usbhw_timer_sleep;
      end
   end
end
endtask 


//-----------------------------------------------------------------
// usbhw_hub_enable: Enable root hub (drive data lines to HiZ)
//                   and optionally start SOF periods
//-----------------------------------------------------------------
task usbhw_hub_enable;
input enable_sof;
reg [7:0] val;
begin
    $display("HW: Enable root hub\n");

    // Host Full Speed
    val = 0;
    val = val | (1 << `USB_CTRL_PHY_XCVRSELECT_SHIFT);
    val = val | (1 << `USB_CTRL_PHY_TERMSELECT_SHIFT);
    val = val | (0 << `USB_CTRL_PHY_OPMODE_SHIFT);
    val = val | (1 << `USB_CTRL_PHY_DPPULLDOWN_SHIFT);
    val = val | (1 << `USB_CTRL_PHY_DMPULLDOWN_SHIFT);
    val = val | (1 << `USB_CTRL_TX_FLUSH_SHIFT);

    // Enable SOF
    if (enable_sof)
        val = val | (1 << `USB_CTRL_ENABLE_SOF_SHIFT);

    usbhw_reg_write(`USB_CTRL, val);
end
endtask


//-----------------------------------------------------------------
// usbhw_hub_device_detected: Detect device inserted
//-----------------------------------------------------------------
task usbhw_hub_device_detected;
output bflag;
reg _usb_fs_device;
reg [31:0] status;
reg    bflag;
begin
    // Get line state
    usbhw_reg_read(`USB_STATUS,status);
    status = status >> `USB_STATUS_LINESTATE_BITS_SHIFT;
    status = status & `USB_STATUS_LINESTATE_BITS_MASK;

    // FS: D+ pulled high
    // LS: D- pulled high
    _usb_fs_device = (status & 1);
    if(status != 1) begin
       $display("ERROR: USB Pull Up Status is not 1, Only Full Seed Supported");
    end else begin
       $display("STATUS: USB Full Speed Detected");
    end

    bflag = (status != 0);
end
endtask

task status_IN;
input [7:0] device_addr;
input [3:0] endpoint;
output [7:0] exit_code;
reg    [7:0] exit_code;
reg   [7:0] status;
reg    [7:0] rx_count;
begin
  usbhw_transfer_in(`PID_IN, device_addr, endpoint, status,exit_code,rx_count);
end
endtask

task status_OUT;
input [7:0] device_addr;
input [3:0] endpoint;
output [7:0] status;
begin
  usbhw_transfer_out(`PID_OUT, device_addr, endpoint, 1, `PID_OUT, 0,status);
end
endtask

task control_OUT;
input [7:0] device_addr;
input [3:0] endpoint;
input [7:0] ByteCount;
output [7:0] status;
begin
  usbhw_transfer_out(`PID_OUT, device_addr, endpoint, 1, `PID_DATA1, ByteCount,status);
end
endtask

task control_IN;
input [7:0] device_addr;
input [3:0] endpoint;
input [7:0] ByteCount;
output [7:0] exit_code;
reg    [7:0] exit_code;
reg    [7:0] status;
reg    [7:0] rx_count;
begin
  usbhw_transfer_in(`PID_IN, device_addr, endpoint, status,exit_code,rx_count);
end
endtask

task SetAddress;
  input [6:0] address;
begin
    XmitBuffer[0] = 8'b0000_0000;
    XmitBuffer[1] = 8'b0000_0101; // SetAddress
    XmitBuffer[2] = {1'b0, address};
    XmitBuffer[3] = 8'b0000_0000;
    XmitBuffer[4] = 8'b0000_0000;
    XmitBuffer[5] = 8'b0000_0000;
    XmitBuffer[6] = 8'b0000_0000;
    XmitBuffer[7] = 8'b0000_0000;
end
endtask


task SetConfiguration;
  input [1:0] cfg_val;
begin
    XmitBuffer[0] = 8'b0000_0000;
    XmitBuffer[1] = 8'b0000_1001; // Set Configuration
    XmitBuffer[2] = {6'b000_000, cfg_val};
    XmitBuffer[3] = 8'b0000_0000;
    XmitBuffer[4] = 8'b0000_0000;
    XmitBuffer[5] = 8'b0000_0000;
    XmitBuffer[6] = 8'b0000_0000;
    XmitBuffer[7] = 8'b0000_0000;
end
endtask

task VenRegWordWr;
  input [6:0] address;
  input [31:0] reg_address;
  input [31:0] dataword;
  reg   [7:0]  Status;
begin
   XmitBuffer[0] = 8'b0100_0000;
   XmitBuffer[1] = 8'b0001_0000;
   XmitBuffer[2] = reg_address[31:24];
   XmitBuffer[3] = reg_address[23:16];
   XmitBuffer[4] = reg_address[15:8];
   XmitBuffer[5] = reg_address[7:0];
   XmitBuffer[6] = 8'b0000_0100;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);

   XmitBuffer[0] = dataword[31:24];
   XmitBuffer[1] = dataword[23:16];
   XmitBuffer[2] = dataword[15:8];
   XmitBuffer[3] = dataword[7:0];

  control_OUT(address, 4'h0, 4, Status);
  status_IN (address, 4'h0, Status);
end
endtask

task VenRegWordRd;
  input [6:0] address;
  input [31:0] reg_address;
  output [31:0] dataword;
  reg  [31:0] ByteCount;
  reg  [7:0]  Status;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = 8'b0001_0001;
   XmitBuffer[2] = reg_address[31:24];
   XmitBuffer[3] = reg_address[23:16];
   XmitBuffer[4] = reg_address[15:8];
   XmitBuffer[5] = reg_address[7:0];
   XmitBuffer[6] = 8'b0000_0100;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);
   control_IN(address, 4'h0, ByteCount, Status);
   if (Status != `PID_ACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if (Status != `PID_ACK)
         control_IN(address, 4'h0, ByteCount, Status);
    dataword[7:0]      = RecvBuffer[3];
    dataword[15:8]     = RecvBuffer[2];
    dataword[23:16]    = RecvBuffer[1];
    dataword[31:24]    = RecvBuffer[0];
    dump_recv_buffer(ByteCount);

   status_OUT (address, 4'h0, Status);
end
endtask

task VenRegWordRdCmp;
  input [6:0] address;
  input [31:0] reg_address;
  input [31:0] dataword;
  reg   [31:0] ByteCount;
  reg   [31:0] ReadData;
  reg    [7:0] Status;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = 8'b0001_0001;
   XmitBuffer[2] = reg_address[31:24];
   XmitBuffer[3] = reg_address[23:16];
   XmitBuffer[4] = reg_address[15:8];
   XmitBuffer[5] = reg_address[7:0];
   XmitBuffer[6] = 8'b0000_0100;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);
   control_IN(address, 4'h0, ByteCount, Status);
   if (Status != `PID_ACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if (Status != `PID_ACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if ((RecvBuffer[3] !== dataword[7:0]) || (RecvBuffer[2] !== dataword[15:8]) 
         || (RecvBuffer[1] !== dataword[23:16]) || (RecvBuffer[0] !== dataword[31:24]))
    begin
      -> `TOP.test_control.error_detected;
       $display( "usb_agent check: ERROR: Register Read Byte Mismatch !!! Address: %x Exp: %x ; Rxd: %x",reg_address,dataword[31:0], {RecvBuffer[0],RecvBuffer[1], RecvBuffer[2],RecvBuffer[3]} );
       dump_recv_buffer(ByteCount);
    end else begin
       $display( "usb_agent check: STATUS: Register Read Byte Match !!! Address: %x ; Rxd: %x",reg_address,{RecvBuffer[0],RecvBuffer[1], RecvBuffer[2],RecvBuffer[3]} );

    end

   status_OUT (address, 4'h0, Status);
end
endtask
task VenRegHalfWordRd;
  input [6:0] address;
  input [21:0] reg_address;
  input [15:0] dataword;
  output [31:0] ByteCount;
  reg    [7:0]  Status;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = {2'b00,reg_address[21:16]};
   XmitBuffer[2] = reg_address[7:0];
   XmitBuffer[3] = reg_address[15:8];
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = 8'b0000_0010;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);
   control_IN(address, 4'h0, ByteCount, Status);
   if (Status != `PID_ACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if (Status != `PID_ACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if ((RecvBuffer[0] !== dataword[7:0]) || (RecvBuffer[1] !== dataword[15:8])) 
    begin
       -> `TOP.test_control.error_detected;
       $display( "usb_agent check: Register Read Byte Mismatch !!!");
       dump_recv_buffer(ByteCount);
    end
   status_OUT (address, 4'h0, Status);
end
endtask

task VenRegByteRd;
  input [6:0] address;
  input [21:0] reg_address;
  input [7:0] dataword;
  output [31:0] ByteCount;
  reg     [7:0] Status;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = {2'b00,reg_address[21:16]};
   XmitBuffer[2] = reg_address[7:0];
   XmitBuffer[3] = reg_address[15:8];
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = 8'b0000_0001;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);
   control_IN(address, 4'h0, ByteCount, Status);
   if (Status != `PID_ACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if (Status != `PID_ACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if ((RecvBuffer[0] !== dataword[7:0]))
    begin
       -> `TOP.test_control.error_detected;
       $display( "usb_agent check: Register Read Byte Mismatch !!!");
       dump_recv_buffer(ByteCount);
    end
   status_OUT (address, 4'h0, Status);
end
endtask

task VenRegWr;
  input [21:0] reg_address;
  input [2:0]  length;
begin
   XmitBuffer[0] = 8'b0100_0000;
   XmitBuffer[1] = {2'b00,reg_address[21:16]};
   XmitBuffer[2] = reg_address[7:0];
   XmitBuffer[3] = reg_address[15:8];
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = {5'b0000_0,length};
   XmitBuffer[7] = 8'b0000_0000;   

end
endtask

task VenRegRd;
  input [21:0] reg_address;
  input [2:0]  length;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = {2'b00,reg_address[21:16]};
   XmitBuffer[2] = reg_address[7:0];
   XmitBuffer[3] = reg_address[15:8];
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = {5'b0000_0,length};
   XmitBuffer[7] = 8'b0000_0000;   
end
endtask

task VenRegWrWordData;
  input [7:0] Byte0;
  input [7:0] Byte1;
  input [7:0] Byte2;
  input [7:0] Byte3;
begin
   XmitBuffer[0] = Byte0;        
   XmitBuffer[1] = Byte1;
   XmitBuffer[2] = Byte2;
   XmitBuffer[3] = Byte3;
end
endtask

task VenRegWrHWordData;
  input [7:0] Byte0;
  input [7:0] Byte1;
begin
   XmitBuffer[0] = Byte0;        
   XmitBuffer[1] = Byte1;
end
endtask

task VenRegWrByteData;
  input [7:0] Byte0;
begin
   XmitBuffer[0] = Byte0;        
end
endtask

task dump_recv_buffer;
  input [31:0] NumBytes;
  integer i;
begin
  for(i=0; i < NumBytes; i=i+1)
    $display("RecvBuffer[%0d]  = %b  : %0d", i, RecvBuffer[i], RecvBuffer[i]);
end
endtask


//-----------------------------------------------------------------
// usbhw_transfer_out: Send token then some DATA to the device
//-----------------------------------------------------------------
task usbhw_transfer_out;
input [7:0]   pid;
input [7:0]   device_addr;
input [3:0]   endpoint; 
input         handshake; 
input [7:0]   request; 
input  [7:0]  tx_length;
output [7:0]  exit_code;

reg    [7:0]  exit_code;

reg  [31:0] tdata;
integer     l;
reg [31:0]  token;
reg [31:0]  ctrl;
reg [31:0]  resp;
reg [31:0]  status;
reg [31:0]  status_chk;
begin
    //$display("USB TOKEN: %s", (pid == `PID_SETUP) ? "SETUP" : (pid == `PID_DATA0) ? "DATA0": (pid == `PID_DATA1) ? "DATA1" : (pid == `PID_IN) ? "IN" : "OUT");
    //$display("USB DEV %d EP %d\n", device_addr, endpoint);

    // Load DATAx transfer into address 0+
    //$display(" USB Tx: %02x", request);
    for (l=0;l<tx_length;l = l + 1) begin
        tdata = XmitBuffer[l];
        //$display("USB TX DATA %02x", tdata);
        usbhw_reg_write(`USB_WR_DATA, tdata);
    end

    // Transfer data length
    usbhw_reg_write(`USB_XFER_DATA, tx_length);

    // Configure transfer for DATAx portion
    ctrl = (1 << `USB_XFER_TOKEN_START_SHIFT);

    // Wait for response or timeout
    ctrl= ctrl | (handshake ? (1 << `USB_XFER_TOKEN_ACK_SHIFT) : 0);

    ctrl= ctrl | ((request == `PID_DATA1) ? (1 << `USB_XFER_TOKEN_PID_DATAX_SHIFT) : (0 << `USB_XFER_TOKEN_PID_DATAX_SHIFT));

    // Setup token details (don't start transfer yet)
    token = (pid<<`USB_XFER_TOKEN_PID_BITS_SHIFT) | (device_addr << `USB_XFER_TOKEN_DEV_ADDR_SHIFT) | (endpoint << `USB_XFER_TOKEN_EP_ADDR_SHIFT);
    usbhw_reg_write(`USB_XFER_TOKEN, token | ctrl);

    // Wait for Tx to start
    usbhw_reg_read(`USB_RX_STAT,status) ;
    status_chk = status & (1 << `USB_RX_STAT_START_PEND_SHIFT);
    while (status_chk) begin
        usbhw_reg_read(`USB_RX_STAT,status) ;
        status_chk = status & (1 << `USB_RX_STAT_START_PEND_SHIFT);
    end

    // No handshaking? We are done
    if (!handshake) begin
	exit_code = `USB_RES_OK;
    end

    // Wait for idle
    usbhw_reg_read(`USB_RX_STAT,status) ;
    status_chk = status & (1 << `USB_RX_STAT_IDLE_SHIFT) ;
    while (!(status_chk)) begin
       usbhw_reg_read(`USB_RX_STAT,status) ;
       status_chk = status & (1 << `USB_RX_STAT_IDLE_SHIFT) ;
    end

    $display("USB RESPONSE: %x",status);

    if (status & (1 << `USB_RX_STAT_RESP_TIMEOUT_SHIFT)) begin
       $display("  USB TIMEOUT\n");
       $display("USB ERROR: OUT timeout\n");
       exit_code = `USB_RES_TIMEOUT;
    end

    // Check for NAK / STALL
    resp = ((status >> `USB_RX_STAT_RESP_BITS_SHIFT) & `USB_RX_STAT_RESP_BITS_MASK);
    if (resp == `PID_ACK) begin
       $display("USB STATUS: ACK\n");
       exit_code = `USB_RES_OK;
    end else if (resp == `PID_NAK) begin
       $display("USB STATUS: NAK\n");
       exit_code = `USB_RES_NAK;
    end else if (resp == `PID_STALL) begin
       $display("USB STATUS:  STALL\n");
       $display("USB ERROR:  OUT STALL\n");
       exit_code = `USB_RES_STALL;
    end else begin
       $display("USB ERROR: Unknown OUT response (%02x)\n", resp);

       // Unknown
       exit_code = `USB_RES_STALL;
    end
end
endtask

//-----------------------------------------------------------------
// usbhw_transfer_in: Perform IN request and expect DATA from device
//-----------------------------------------------------------------
task usbhw_transfer_in;
input [7:0]    pid; 
input [7:0]    device_addr; 
input [7:0]    endpoint; 
output [7:0]   response; 
output [7:0]   exit_code;
output [7:0]   rx_count;

reg  [7:0]     exit_code;
reg  [7:0]     response; 
reg  [7:0]     rx_length;
integer l;
reg  [7:0]     rx_count;
reg [31:0]     token;
reg [31:0]     data;
reg [31:0]     status;
reg [31:0]     status_chk;
begin
    //$display("USB TOKEN: %s", (pid == `PID_SETUP) ? "SETUP" : (pid == `PID_DATA0) ? "DATA0": (pid == `PID_DATA1) ? "DATA1" : (pid == `PID_IN) ? "IN" : "OUT");
    //$display("USB  DEV %d EP %d\n", device_addr, endpoint);    

    // No data to send
    usbhw_reg_write(`USB_XFER_DATA, 0);

    // Configure transfer
    token = (pid<<`USB_XFER_TOKEN_PID_BITS_SHIFT) | (device_addr << `USB_XFER_TOKEN_DEV_ADDR_SHIFT) | (endpoint << `USB_XFER_TOKEN_EP_ADDR_SHIFT);
    token= token |(1 << `USB_XFER_TOKEN_START_SHIFT);
    token= token | (1 << `USB_XFER_TOKEN_IN_SHIFT);
    token= token | (1 << `USB_XFER_TOKEN_ACK_SHIFT);
    //$display("USB TOKEN CONFIG : %x",token);
    usbhw_reg_write(`USB_XFER_TOKEN, token);

    status_chk = status & (1 << `USB_RX_STAT_START_PEND);
    while (status_chk) begin
       usbhw_reg_read(`USB_RX_STAT,status);
       status_chk = status & (1 << `USB_RX_STAT_START_PEND);
    end

    // Wait for rx idle
    usbhw_reg_read(`USB_RX_STAT,status); 
    status_chk = status & (1 << `USB_RX_STAT_IDLE_SHIFT);
    while (!(status_chk)) begin
       usbhw_reg_read(`USB_RX_STAT,status); 
       status_chk = status & (1 << `USB_RX_STAT_IDLE_SHIFT);
    end

    if (status & (1 << `USB_RX_STAT_CRC_ERR_SHIFT)) begin
       $display("USB: CRC ERROR\n");
       exit_code = `USB_RES_TIMEOUT;
    end else if (status & (1 << `USB_RX_STAT_RESP_TIMEOUT_SHIFT)) begin
       $display("USB: IN timeout\n");
       exit_code = `USB_RES_TIMEOUT;
    end else begin

        // Check for NAK / STALL
        response = ((status >> `USB_RX_STAT_RESP_BITS_SHIFT) & `USB_RX_STAT_RESP_BITS_MASK);

        if (response == `PID_NAK) begin
           $display("USB NAK RECEIVED \n");
           exit_code = `USB_RES_NAK;
        end else if (response == `PID_STALL) begin
           $display("USB: IN STALL\n");
           exit_code = `USB_RES_STALL;
        end else begin

         // Check CRC is ok
           if (status & (1 << `USB_RX_STAT_CRC_ERR_SHIFT)) begin
                $display("USB: CRC Error\n");
                exit_code = `USB_RES_STALL;
           end else begin

                // How much data was actually received?
                rx_count = ((status >> `USB_RX_STAT_COUNT_BITS_SHIFT) & `USB_RX_STAT_COUNT_BITS_MASK);

                //$display(" Rx %d (PID=%x):\n", rx_count, response);

                // Assert that user buffer is big enough for the response.
                // NOTE: It's not critical to do this, but we can't easily check CRCs without
                // reading the whole response into a buffer.
                // Hitting this condition may point towards issues with higher level protocol
                // implementation...
                if(rx_length >= rx_count)
                    $display("USB ERROR Difference in rx len:%d and Rx Data Count: %d",rx_length,rx_count);
   
                for (l=0;l<rx_count;l=l+1) begin
                    usbhw_reg_read(`USB_RD_DATA,data);
                    //$display(" USB RX Cnt: %d Data: %02x", l, data);
                    RecvBuffer[l] = data;
                end
		exit_code = `USB_RES_OK;
	   end
	end
    end
end
endtask

endmodule
