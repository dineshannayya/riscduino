module scr1_top_wb (core_clk,
    cpu_rst_n,
    pwrup_rst_n,
    rst_n,
    rtc_clk,
    soft_irq,
    test_mode,
    test_rst_n,
    wb_clk,
    wb_rst_n,
    wbd_dmem_ack_i,
    wbd_dmem_err_i,
    wbd_dmem_stb_o,
    wbd_dmem_we_o,
    wbd_imem_ack_i,
    wbd_imem_err_i,
    wbd_imem_stb_o,
    wbd_imem_we_o,
    VPWR,
    VGND,
    fuse_mhartid,
    irq_lines,
    wbd_dmem_adr_o,
    wbd_dmem_dat_i,
    wbd_dmem_dat_o,
    wbd_dmem_sel_o,
    wbd_imem_adr_o,
    wbd_imem_dat_i,
    wbd_imem_dat_o,
    wbd_imem_sel_o);
 input core_clk;
 input cpu_rst_n;
 input pwrup_rst_n;
 input rst_n;
 input rtc_clk;
 input soft_irq;
 input test_mode;
 input test_rst_n;
 input wb_clk;
 input wb_rst_n;
 input wbd_dmem_ack_i;
 input wbd_dmem_err_i;
 output wbd_dmem_stb_o;
 output wbd_dmem_we_o;
 input wbd_imem_ack_i;
 input wbd_imem_err_i;
 output wbd_imem_stb_o;
 output wbd_imem_we_o;
 input VPWR;
 input VGND;
 input [31:0] fuse_mhartid;
 input [15:0] irq_lines;
 output [31:0] wbd_dmem_adr_o;
 input [31:0] wbd_dmem_dat_i;
 output [31:0] wbd_dmem_dat_o;
 output [3:0] wbd_dmem_sel_o;
 output [31:0] wbd_imem_adr_o;
 input [31:0] wbd_imem_dat_i;
 output [31:0] wbd_imem_dat_o;
 output [3:0] wbd_imem_sel_o;

endmodule
