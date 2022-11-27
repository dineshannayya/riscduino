/*********************************************
  Bus Repeater SOUTH
**********************************************/
wire          wb_clk_int_i;
wire          wb_rst_int_i ;      
wire          wbs_ack_int_o ;     
wire          wbs_cyc_int_i ;     
wire          wbs_stb_int_i ;     
wire          wbs_we_int_i  ;    
wire   [3:0]  wbs_sel_int_i;      
wire   [31:0] wbs_adr_int_i; 
wire   [31:0] wbs_dat_int_i; 
wire   [31:0] wbs_dat_int_o;

wire   [17:0] la_data_in_rp;

wire [123:0] ch_in_south = {
                    la_data_in[0],
                    la_data_in[1],
                    la_data_in[2],
                    la_data_in[3],
                    la_data_in[4],
                    la_data_in[5],
                    la_data_in[6],
                    la_data_in[7],
                    la_data_in[8],
                    la_data_in[9],
                    la_data_in[10],
                    la_data_in[11],
                    la_data_in[12],
                    la_data_in[13],
                    la_data_in[14],
                    la_data_in[15],
                    la_data_in[16],
                    la_data_in[17],
                    wb_clk_i           ,  // 105
                    wb_rst_i           ,  // 
                    wbs_ack_int_o      ,  // 103
                    wbs_cyc_i          ,
                    wbs_stb_i          ,
                    wbs_we_i           ,
                    wbs_adr_i[0]       ,
                    wbs_dat_i[0]       ,
                    wbs_dat_int_o[0]   , // 97
                    wbs_sel_i[0]       , 
                    wbs_adr_i[1]       ,
                    wbs_dat_i[1]       ,
                    wbs_dat_int_o[1]   , // 93
                    wbs_sel_i[1]       ,
                    wbs_adr_i[2]       ,
                    wbs_dat_i[2]       ,
                    wbs_dat_int_o[2]   , // 89
                    wbs_sel_i[2]       , 
                    wbs_adr_i[3]       , 
                    wbs_dat_i[3]       ,
                    wbs_dat_int_o[3]   , // 85
                    wbs_sel_i[3]       ,
                    wbs_adr_i[4]       ,
                    wbs_dat_i[4]       ,
                    wbs_dat_int_o[4]   , // 81
                    wbs_adr_i[5]       ,
                    wbs_dat_i[5]       ,
                    wbs_dat_int_o[5]   , // 78
                    wbs_adr_i[6]       ,
                    wbs_dat_i[6]       ,
                    wbs_dat_int_o[6]   , // 75
                    wbs_adr_i[7]       ,
                    wbs_dat_i[7]       ,
                    wbs_dat_int_o[7]   , // 72
                    wbs_adr_i[8]       ,
                    wbs_dat_i[8]       ,
                    wbs_dat_int_o[8]   , // 69
                    wbs_adr_i[9]       ,
                    wbs_dat_i[9]       ,
                    wbs_dat_int_o[9]   , // 66
                    wbs_adr_i[10]      ,
                    wbs_dat_i[10]      ,
                    wbs_dat_int_o[10]  , // 63
                    wbs_adr_i[11]      ,
                    wbs_dat_i[11]      ,
                    wbs_dat_int_o[11]  , // 60
                    wbs_adr_i[12]      ,
                    wbs_dat_i[12]      ,
                    wbs_dat_int_o[12]  , // 57
                    wbs_adr_i[13]      ,
                    wbs_dat_i[13]      ,
                    wbs_dat_int_o[13]  , // 54
                    wbs_adr_i[14]      ,
                    wbs_dat_i[14]      ,
                    wbs_dat_int_o[14]  , // 51
                    wbs_adr_i[15]      ,
                    wbs_dat_i[15]      ,
                    wbs_dat_int_o[15]  , // 48
                    wbs_adr_i[16]      ,
                    wbs_dat_i[16]      ,
                    wbs_dat_int_o[16]  , // 45
                    wbs_adr_i[17]      ,
                    wbs_dat_i[17]      ,
                    wbs_dat_int_o[17]  , // 42
                    wbs_adr_i[18]      ,
                    wbs_dat_i[18]      ,
                    wbs_dat_int_o[18]  , // 39
                    wbs_adr_i[19]      ,
                    wbs_dat_i[19]      ,
                    wbs_dat_int_o[19]  , // 36
                    wbs_adr_i[20]      ,
                    wbs_dat_i[20]      ,
                    wbs_dat_int_o[20]  , // 33
                    wbs_adr_i[21]      ,
                    wbs_dat_i[21]      ,
                    wbs_dat_int_o[21]  , // 30
                    wbs_adr_i[22]      ,
                    wbs_dat_i[22]      ,
                    wbs_dat_int_o[22]  , // 27
                    wbs_adr_i[23]      ,
                    wbs_dat_i[23]      ,
                    wbs_dat_int_o[23]  , // 24
                    wbs_adr_i[24]      ,
                    wbs_dat_i[24]      ,
                    wbs_dat_int_o[24]  , // 21
                    wbs_adr_i[25]      ,
                    wbs_dat_i[25]      ,
                    wbs_dat_int_o[25]  , // 18
                    wbs_adr_i[26]      ,
                    wbs_dat_i[26]      ,
                    wbs_dat_int_o[26]  , // 15
                    wbs_adr_i[27]      ,
                    wbs_dat_i[27]      ,
                    wbs_dat_int_o[27]  , // 12
                    wbs_adr_i[28]      ,
                    wbs_dat_i[28]      ,
                    wbs_dat_int_o[28]  , // 9
                    wbs_adr_i[29]      ,
                    wbs_dat_i[29]      ,
                    wbs_dat_int_o[29]  , // 6
                    wbs_adr_i[30]      ,
                    wbs_dat_i[30]      ,
                    wbs_dat_int_o[30]  , // 3
                    wbs_adr_i[31]      ,
                    wbs_dat_i[31]      ,
                    wbs_dat_int_o[31]        
            };
wire [123:0] ch_out_south ;
assign {
         la_data_in_rp[0]   ,
         la_data_in_rp[1]   ,
         la_data_in_rp[2]   ,
         la_data_in_rp[3]   ,
         la_data_in_rp[4]   ,
         la_data_in_rp[5]   ,
         la_data_in_rp[6]   ,
         la_data_in_rp[7]   ,
         la_data_in_rp[8]   ,
         la_data_in_rp[9]   ,
         la_data_in_rp[10]   ,
         la_data_in_rp[11]   ,
         la_data_in_rp[12]   ,
         la_data_in_rp[13]   ,
         la_data_in_rp[14]   ,
         la_data_in_rp[15]   ,
         la_data_in_rp[16]   ,
         la_data_in_rp[17]   ,
         wb_clk_int_i       ,
         wb_rst_int_i       ,
         wbs_ack_o          ,
         wbs_cyc_int_i      ,
         wbs_stb_int_i      ,
         wbs_we_int_i       ,
         wbs_adr_int_i[0]   ,
         wbs_dat_int_i[0]   ,
         wbs_dat_o[0]       ,
         wbs_sel_int_i[0]   ,
         wbs_adr_int_i[1]   ,
         wbs_dat_int_i[1]   ,
         wbs_dat_o[1]       ,
         wbs_sel_int_i[1]   ,
         wbs_adr_int_i[2]   ,
         wbs_dat_int_i[2]   ,
         wbs_dat_o[2]       ,
         wbs_sel_int_i[2]   ,
         wbs_adr_int_i[3]   ,
         wbs_dat_int_i[3]   ,
         wbs_dat_o[3]       ,
         wbs_sel_int_i[3]   ,
         wbs_adr_int_i[4]   ,
         wbs_dat_int_i[4]   ,
         wbs_dat_o[4]       ,
         wbs_adr_int_i[5]   ,
         wbs_dat_int_i[5]   ,
         wbs_dat_o[5]       ,
         wbs_adr_int_i[6]   ,
         wbs_dat_int_i[6]   ,
         wbs_dat_o[6]       ,
         wbs_adr_int_i[7]   ,
         wbs_dat_int_i[7]   ,
         wbs_dat_o[7]       ,
         wbs_adr_int_i[8]   ,
         wbs_dat_int_i[8]   ,
         wbs_dat_o[8]       ,
         wbs_adr_int_i[9]   ,
         wbs_dat_int_i[9]   ,
         wbs_dat_o[9]       ,
         wbs_adr_int_i[10]  ,
         wbs_dat_int_i[10]  ,
         wbs_dat_o[10]      ,
         wbs_adr_int_i[11]  ,
         wbs_dat_int_i[11]  ,
         wbs_dat_o[11]      ,
         wbs_adr_int_i[12]  ,
         wbs_dat_int_i[12]  ,
         wbs_dat_o[12]      ,
         wbs_adr_int_i[13]  ,
         wbs_dat_int_i[13]  ,
         wbs_dat_o[13]      ,
         wbs_adr_int_i[14]  ,
         wbs_dat_int_i[14]  ,
         wbs_dat_o[14]      ,
         wbs_adr_int_i[15]  ,
         wbs_dat_int_i[15]  ,
         wbs_dat_o[15]      ,
         wbs_adr_int_i[16]  ,
         wbs_dat_int_i[16]  ,
         wbs_dat_o[16]      ,
         wbs_adr_int_i[17]  ,
         wbs_dat_int_i[17]  ,
         wbs_dat_o[17]      ,
         wbs_adr_int_i[18]  ,
         wbs_dat_int_i[18]  ,
         wbs_dat_o[18]      ,
         wbs_adr_int_i[19]  ,
         wbs_dat_int_i[19]  ,
         wbs_dat_o[19]      ,
         wbs_adr_int_i[20]  ,
         wbs_dat_int_i[20]  ,
         wbs_dat_o[20]      ,
         wbs_adr_int_i[21]  ,
         wbs_dat_int_i[21]  ,
         wbs_dat_o[21]      ,
         wbs_adr_int_i[22]  ,
         wbs_dat_int_i[22]  ,
         wbs_dat_o[22]      ,
         wbs_adr_int_i[23]  ,
         wbs_dat_int_i[23]  ,
         wbs_dat_o[23]      ,
         wbs_adr_int_i[24]  ,
         wbs_dat_int_i[24]  ,
         wbs_dat_o[24]      ,
         wbs_adr_int_i[25]  ,
         wbs_dat_int_i[25]  ,
         wbs_dat_o[25]      ,
         wbs_adr_int_i[26]  ,
         wbs_dat_int_i[26]  ,
         wbs_dat_o[26]      ,
         wbs_adr_int_i[27]  ,
         wbs_dat_int_i[27]  ,
         wbs_dat_o[27]      ,
         wbs_adr_int_i[28]  ,
         wbs_dat_int_i[28]  ,
         wbs_dat_o[28]      ,
         wbs_adr_int_i[29]  ,
         wbs_dat_int_i[29]  ,
         wbs_dat_o[29]      ,
         wbs_adr_int_i[30]  ,
         wbs_dat_int_i[30]  ,
         wbs_dat_o[30]      ,
         wbs_adr_int_i[31]  ,
         wbs_dat_int_i[31]  ,
         wbs_dat_o[31]        
            } = ch_out_south;

bus_rep_south  #(
`ifndef SYNTHESIS
.BUS_REP_WD(124)
`endif
      ) u_rp_south(
`ifdef USE_POWER_PINS
    .vccd1                 (vdda1                  ),
    .vssd1                 (vssa1                  ),
`endif
    .ch_in (ch_in_south),
    .ch_out (ch_out_south)
   );
