
// GPIO Interrupt Generation
module gpio_intr_gen (
   input  logic         mclk                     ,// System clk
   input  logic         h_reset_n                ,// system reset
   input  logic [31:0]  gpio_prev_indata         ,// previously captured GPIO I/P pins data
   input  logic [31:0]  cfg_gpio_data_in         ,// GPIO I/P pins data captured into this
   input  logic [31:0]  cfg_gpio_out_data        ,// GPIO statuc O/P data from config reg
   input  logic [31:0]  cfg_gpio_dir_sel         ,// decides on GPIO pin is I/P or O/P at pad level
   input  logic [31:0]  cfg_gpio_posedge_int_sel ,// select posedge interrupt
   input  logic [31:0]  cfg_gpio_negedge_int_sel ,// select negedge interrupt
   
   
   output logic [31:0]  pad_gpio_out             ,// GPIO O/P to the gpio cfg reg
   output logic [31:0]  gpio_int_event            // to the cfg interrupt status reg 
 
);


integer i;
//-----------------------------------------------------------------------
// Logic for interrupt detection 
//-----------------------------------------------------------------------

reg [31:0]  local_gpio_int_event;             // to the cfg interrupt status reg 
always_comb
begin
   for (i=0; i<32; i=i+1)
   begin 
   // looking for rising edge int 
      local_gpio_int_event[i] = ((cfg_gpio_posedge_int_sel[i] & ~gpio_prev_indata[i] 
                                   &  cfg_gpio_data_in[i]) | 
                                 (cfg_gpio_negedge_int_sel[i] & gpio_prev_indata[i] & 
                                     ~cfg_gpio_data_in[i]));
                                // looking for falling edge int 
   end
end

assign gpio_int_event   = local_gpio_int_event[31:0]; // goes as O/P to the cfg reg 

assign pad_gpio_out     = cfg_gpio_out_data[31:0]     ;// O/P on the GPIO bus

endmodule
