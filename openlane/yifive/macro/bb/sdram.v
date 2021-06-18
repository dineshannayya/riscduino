module sdrc_top (cfg_sdr_en,
    sdr_cas_n,
    sdr_cke,
    sdr_cs_n,
    sdr_den_n,
    sdr_dqm,
    sdr_init_done,
    sdr_ras_n,
    sdr_we_n,
    sdram_clk,
    sdram_pad_clk,
    sdram_resetn,
    wb_ack_o,
    wb_clk_i,
    wb_cyc_i,
    wb_rst_i,
    wb_stb_i,
    wb_we_i,
    VPWR,
    VGND,
    cfg_colbits,
    cfg_req_depth,
    cfg_sdr_cas,
    cfg_sdr_mode_reg,
    cfg_sdr_rfmax,
    cfg_sdr_rfsh,
    cfg_sdr_tras_d,
    cfg_sdr_trcar_d,
    cfg_sdr_trcd_d,
    cfg_sdr_trp_d,
    cfg_sdr_twr_d,
    cfg_sdr_width,
    pad_sdr_din,
    sdr_addr,
    sdr_ba,
    sdr_dout,
    wb_addr_i,
    wb_cti_i,
    wb_dat_i,
    wb_dat_o,
    wb_sel_i);
 input cfg_sdr_en;
 output sdr_cas_n;
 output sdr_cke;
 output sdr_cs_n;
 output sdr_den_n;
 output sdr_dqm;
 output sdr_init_done;
 output sdr_ras_n;
 output sdr_we_n;
 input sdram_clk;
 input sdram_pad_clk;
 input sdram_resetn;
 output wb_ack_o;
 input wb_clk_i;
 input wb_cyc_i;
 input wb_rst_i;
 input wb_stb_i;
 input wb_we_i;
 input VPWR;
 input VGND;
 input [1:0] cfg_colbits;
 input [1:0] cfg_req_depth;
 input [2:0] cfg_sdr_cas;
 input [12:0] cfg_sdr_mode_reg;
 input [2:0] cfg_sdr_rfmax;
 input [11:0] cfg_sdr_rfsh;
 input [3:0] cfg_sdr_tras_d;
 input [3:0] cfg_sdr_trcar_d;
 input [3:0] cfg_sdr_trcd_d;
 input [3:0] cfg_sdr_trp_d;
 input [3:0] cfg_sdr_twr_d;
 input [1:0] cfg_sdr_width;
 input [7:0] pad_sdr_din;
 output [12:0] sdr_addr;
 output [1:0] sdr_ba;
 output [7:0] sdr_dout;
 input [31:0] wb_addr_i;
 input [2:0] wb_cti_i;
 input [31:0] wb_dat_i;
 output [31:0] wb_dat_o;
 input [3:0] wb_sel_i;

endmodule
