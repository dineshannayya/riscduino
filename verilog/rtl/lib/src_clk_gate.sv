/*****************************************************
           Source clock Gate:
******************************************************/
module src_clk_gate (
        input  logic         reset_n   ,
        input  logic         clk_in    ,
        input  logic [1:0]   cfg_mode  ,
        input  logic         dst_idle  , // 1 - indicate destination is ideal
        input  logic         src_req   , // 1 - Source Request

        output logic         clk_enb   , // clock enable indication
        output logic         clk_out   // clock output
     
       );

parameter NCLK_GATE   = 2'b00 ;// No clock gate
parameter DYCLK_GATE  = 2'b01 ;// Dynamic clock gate
parameter FOCLK_GATE  = 2'b10 ;// Force   clock gate


logic dst_idle_r,idle_his;
logic [3:0] hcnt;

//-----------------------------------------------
// Synchronize the target idle indicate
//  Extended the clock-removal by 8 cycle
//-----------------------------------------------
always@(negedge reset_n or posedge clk_in)
begin
   if(reset_n == 1'b0) begin
      dst_idle_r  <= 1'b0;
      idle_his    <= 1'b1; // Idle removal histersis
      hcnt        <= 'h7;
   end else begin
      dst_idle_r  <= dst_idle;
      if(src_req || dst_idle == 0) begin
         hcnt        <= 'h7;
         idle_his    <= 1'b1;
      end else begin
         if(hcnt == 'h0) begin // Extend the clock de-assertion by 8 cycle
            idle_his    <= 1'b0;
         end else begin
             hcnt        <= hcnt-1;
         end
      end
         
   
   end
end

//----------------------------------------------
// Double Sync the config signal to match clock skew 
//----------------------------------------------
logic [1:0] cfg_mode_ss;

double_sync_high  #(.WIDTH(2)) u_dsync(
              .in_data    ( cfg_mode     ),
              .out_clk    ( clk_in       ),
              .out_rst_n  ( reset_n      ),
              .out_data   ( cfg_mode_ss  )
          );


always_comb begin
   case(cfg_mode_ss)
      // No clock gating 
      NCLK_GATE:   clk_enb = 1'b1;

      // Dynamic Clock gating
      DYCLK_GATE:  clk_enb = (src_req     == 1'b1) ? 1'b1 :
                             (dst_idle_r  == 1'b0) ? 1'b1 : 
                             (idle_his    == 1'b1) ? 1'b1 : 1'b0;
      // Force Clock Gating
      FOCLK_GATE:   clk_enb = 1'b0;
      default   :   clk_enb = 1;
   endcase
end


// Clock Gating

ctech_clk_gate u_clkgate (.GATE (clk_enb), . CLK(clk_in), .GCLK(clk_out));



endmodule


