/// Copyright by Syntacore LLC © 2016-2020. See LICENSE for details
/// @file       <scr1_top_tb_runtests.sv>
/// @brief      SCR1 testbench run tests
///

//-------------------------------------------------------------------------------
// Run tests
//-------------------------------------------------------------------------------

initial begin
    //$value$plusargs("imem_pattern=%h", imem_req_ack_stall);
    //$value$plusargs("dmem_pattern=%h", dmem_req_ack_stall);

    //$display("imem_pattern:%x",imem_req_ack_stall);
    //$display("dmem_pattern:%x",dmem_req_ack_stall);
`ifdef SIGNATURE_OUT
    $value$plusargs("test_name=%s", s_testname);
    b_single_run_flag = 1;
`else // SIGNATURE_OUT

    $value$plusargs("test_info=%s", s_info);
    $value$plusargs("test_results=%s", s_results);

    f_info      = $fopen(s_info, "r");
    f_results   = $fopen(s_results, "a");
`endif // SIGNATURE_OUT



end
/***
// Debug message - dinesh A
 logic [`SCR1_DMEM_AWIDTH-1:0]           core2imem_addr_o_r;           // DMEM address
 logic [`SCR1_DMEM_AWIDTH-1:0]           core2dmem_addr_o_r;           // DMEM address
 logic                                   core2dmem_cmd_o_r;
 
 `define RISC_CORE  i_top.i_core_top_0
 
 always@(posedge `RISC_CORE.clk) begin
     if(`RISC_CORE.imem2core_req_ack_i && `RISC_CORE.core2imem_req_o)
           core2imem_addr_o_r <= `RISC_CORE.core2imem_addr_o;
 
     if(`RISC_CORE.dmem2core_req_ack_i && `RISC_CORE.core2dmem_req_o) begin
           core2dmem_addr_o_r <= `RISC_CORE.core2dmem_addr_o;
           core2dmem_cmd_o_r  <= `RISC_CORE.core2dmem_cmd_o;
     end
 
     if(`RISC_CORE.imem2core_resp_i !=0)
           $display("RISCV-DEBUG => IMEM ADDRESS: %x Read Data : %x Resonse: %x", core2imem_addr_o_r,`RISC_CORE.imem2core_rdata_i,`RISC_CORE.imem2core_resp_i);
     if((`RISC_CORE.dmem2core_resp_i !=0) && core2dmem_cmd_o_r)
           $display("RISCV-DEBUG => DMEM ADDRESS: %x Write Data: %x Resonse: %x", core2dmem_addr_o_r,`RISC_CORE.core2dmem_wdata_o,`RISC_CORE.dmem2core_resp_i);
     if((`RISC_CORE.dmem2core_resp_i !=0) && !core2dmem_cmd_o_r)
           $display("RISCV-DEBUG => DMEM ADDRESS: %x READ Data : %x Resonse: %x", core2dmem_addr_o_r,`RISC_CORE.dmem2core_rdata_i,`RISC_CORE.dmem2core_resp_i);
 end
**/
/***
  logic [31:0] test_count;
 `define RISC_CORE  u_top.u_riscv_top.i_core_top_0
 `define RISC_EXU  u_top.u_riscv_top.i_core_top.i_pipe_top.i_pipe_exu

 initial begin
	 test_count = 0;
 end

 
 always@(posedge `RISC_CORE.clk) begin
	 if(`RISC_EXU.pc_curr_upd) begin
            $display("RISCV-DEBUG => Cnt: %x PC: %x", test_count,`RISC_EXU.pc_curr_ff);
               test_count <= test_count+1;
	  end
 end
***/

wire [31:0] pc_curr_ff         = u_top.u_riscv_top.i_core_top_0.i_pipe_top.i_pipe_exu.pc_curr_ff         ;
wire [31:0] exu2pipe_pc_curr_o = u_top.u_riscv_top.i_core_top_0.i_pipe_top.i_pipe_exu.exu2pipe_pc_curr_o ;
wire [31:0] mprf_int_10        = u_top.u_riscv_top.i_core_top_0.i_pipe_top.i_pipe_mprf.mprf_int[10]      ;

always @(posedge clk) begin
    bit test_pass;
    int unsigned                            f_test;
    int unsigned                            f_test_ram;
    if (test_running) begin
        test_pass = 1;
        rst_init <= 1'b0;
	if(pc_curr_ff === 32'hxxxx_xxxx) begin
	   $display("ERROR: CURRENT PC Counter State is Known");
	   $finish;
	end
        if ((exu2pipe_pc_curr_o == YCR1_SIM_EXIT_ADDR) & ~rst_init & &rst_cnt) begin

            `ifdef VERILATOR
                logic [255:0] full_filename;
                full_filename = test_file;
            `else // VERILATOR
                string full_filename;
                full_filename = test_file;
            `endif // VERILATOR

            if (is_compliance(test_file)) begin
                logic [31:0] tmpv, start, stop, ref_data, test_data;
                integer fd;
                `ifdef VERILATOR
                logic [2047:0] tmpstr;
                `else // VERILATOR
                string tmpstr;
                `endif // VERILATOR

	        // Flush the content of dcache for signature validation at app
	        // memory	
	        force u_top.u_riscv_top.u_intf.u_dcache.cfg_force_flush = 1'b1;
	        wait(u_top.u_riscv_top.u_intf.u_dcache.force_flush_done == 1'b1);
	        release u_top.u_riscv_top.u_intf.u_dcache.cfg_force_flush;
	        repeat (2000) @(posedge clock); // wait data to flush in pipe
		$display("STATUS: Checking Complaince Test Status .... ");
                test_running <= 1'b0;
                test_pass = 1;

                $sformat(tmpstr, "riscv64-unknown-elf-readelf -s %s | grep 'begin_signature\\|end_signature' | awk '{print $2}' > elfinfo", get_filename(test_file));
                fd = $fopen("script.sh", "w");
                if (fd == 0) begin
                    $write("Can't open script.sh\n");
                    $display("ERRIR:Can't open script.sh\n");
                    test_pass = 0;
                end
                $fwrite(fd, "%s", tmpstr);
                $fclose(fd);

                $system("sh script.sh");

                fd = $fopen("elfinfo", "r");
                if (fd == 0) begin
                    $write("Can't open elfinfo\n");
                    $display("ERROR: Can't open elfinfo\n");
                    test_pass = 0;
                end
                if ($fscanf(fd,"%h\n%h", start, stop) != 2) begin
                    $write("Wrong elfinfo data\n");
                    $display("ERROR:Wrong elfinfo data: start: %x stop: %x\n",start,stop);
                    test_pass = 0;
                end
                if (start > stop) begin
                    tmpv = start;
                    start = stop;
                    stop = tmpv;
                end
                $fclose(fd);
		start = start & 32'h07FF_FFFF;
	        stop  = stop & 32'h07FF_FFFF;
		$display("Complaince Signature Start Address: %x End Address:%x",start,stop);

		//if((start & 32'h1FFF) > 512)
		//	$display("ERROR: Start address is more than 512, Start: %x",start & 32'h1FFF);
		//if((stop & 32'h1FFF) > 512)
		//	$display("ERROR: Stop address is more than 512, Start: %x",stop & 32'h1FFF);

                `ifdef SIGNATURE_OUT

                    $sformat(tmpstr, "%s.signature.output", s_testname);
`ifdef VERILATOR
                    tmpstr = remove_trailing_whitespaces(tmpstr);
`endif
                    fd = $fopen(tmpstr, "w");
                    while ((start != stop)) begin
                        //test_data = u_top.u_sram0_2kb.mem[(start & 32'h1FFF)];
                        test_data = {u_sram.memory[start+3], u_sram.memory[start+2], u_sram.memory[start+1], u_sram.memory[start]};
                        $fwrite(fd, "%x", test_data);
                        $fwrite(fd, "%s", "\n");
                        start += 4;
                    end
                    $fclose(fd);
                `else //SIGNATURE_OUT
                    $sformat(tmpstr, "riscv_compliance/ref_data/%s", get_ref_filename(test_file));
`ifdef VERILATOR
                tmpstr = remove_trailing_whitespaces(tmpstr);
`endif
                    fd = $fopen(tmpstr,"r");
                    if (fd == 0) begin
                        $write("Can't open reference_data file: %s\n", tmpstr);
                        $display("ERROR: Can't open reference_data file: %s\n", tmpstr);
                        test_pass = 0;
                    end
                    while (!$feof(fd) && (start != stop)) begin
                        $fscanf(fd, "0x%h,\n", ref_data);
			//----------------------------------------------------
			// Assumed all signaure are with-in first 512 location of memory, 
			// other-wise need to switch bank
			// --------------------------------------------------
		        //$writememh("sram0_out.hex",u_top.u_tsram0_2kb.mem,0,511);
                        //test_data = u_top.u_sram0_2kb.mem[((start >> 2) & 32'h1FFF)];
                        test_data = {u_sram.memory[start+3], u_sram.memory[start+2], u_sram.memory[start+1], u_sram.memory[start]};
			//$display("Compare Addr: %x ref_data : %x, test_data: %x",start,ref_data,test_data);
                        test_pass &= (ref_data == test_data);
			if(ref_data != test_data)
			   $display("ERROR: Compare Addr: %x Mem Addr: %x ref_data : %x, test_data: %x",start,start & 32'h1FFF,ref_data,test_data);
			else
			   $display("STATUS: Compare Addr: %x Mem Addr: %x ref_data : %x",start,start & 32'h1FFF,ref_data);
                        start += 4;
                    end
                    $fclose(fd);
                    tests_total += 1;
                    tests_passed += test_pass;
                    if (test_pass) begin
                        $write("\033[0;32mTest passed\033[0m\n");
                    end else begin
                        $write("\033[0;31mTest failed-2\033[0m\n");
                    end
                `endif  // SIGNATURE_OUT
            end else begin // Non compliance mode
                test_running <= 1'b0;
		if(mprf_int_10 != 0)
		   $display("ERROR: mprf_int[10]: %x not zero",mprf_int_10);

                test_pass = (mprf_int_10 == 0);
                tests_total     += 1;
                tests_passed    += test_pass;
                `ifndef SIGNATURE_OUT
                    if (test_pass) begin
                        $write("\033[0;32mTest passed\033[0m\n");
                    end else begin
                        $write("\033[0;31mTest failed\033[0m\n");
                    end
                `endif //SIGNATURE_OUT
            end
            $fwrite(f_results, "%s\t\t%s\t%s\n", test_file, "OK" , (test_pass ? "PASS" : "__FAIL"));
        end
    end else begin
`ifdef VERILATOR
    `ifdef SIGNATURE_OUT
        if ((s_testname.len() != 0) && (b_single_run_flag)) begin
            $sformat(test_file, "%s.bin", s_testname);
    `else //SIGNATURE_OUT
        if ($fgets(test_file,f_info)) begin
            test_file = test_file >> 8; // < Removing trailing LF symbol ('\n')
    `endif //SIGNATURE_OUT
`else // VERILATOR
        if (!$feof(f_info)) begin
            $fscanf(f_info, "%s\n", test_file);
`endif // VERILATOR
            f_test = $fopen(test_file,"r");
            if (f_test != 0) begin
            // Launch new test
                `ifdef YCR1_TRACE_LOG_EN
                    u_top.u_riscv_top.i_core_top_0.i_pipe_top.i_tracelog.test_name = test_file;
                `endif // SCR1_TRACE_LOG_EN
                //i_memory_tb.test_file = test_file;
                //i_memory_tb.test_file_init = 1'b1;
                `ifndef SIGNATURE_OUT
                    $write("\033[0;34m---Test: %s\033[0m\n", test_file);
                `endif //SIGNATURE_OUT
                test_running <= 1'b1;
                rst_init <= 1'b1;
                `ifdef SIGNATURE_OUT
                    b_single_run_flag = 0;
                `endif
            end else begin
                $fwrite(f_results, "%s\t\t%s\t%s\n", test_file, "__FAIL", "--------");
            end
        end else begin
            // Exit
            `ifndef SIGNATURE_OUT
                $display("\n#--------------------------------------");
                $display("# Summary: %0d/%0d tests passed", tests_passed, tests_total);
                $display("#--------------------------------------\n");
                $fclose(f_info);
                $fclose(f_results);
            `endif
            $finish();
        end
    end
end


        `ifdef VERILATOR
        function bit is_compliance (logic [255:0] testname);
            bit res;
            logic [79:0] pattern;
        begin
            pattern = 80'h636f6d706c69616e6365; // compliance
            res = 0;
            for (int i = 0; i<= 176; i++) begin
                if(testname[i+:80] == pattern) begin
                    return ~res;
                end
            end
            `ifdef SIGNATURE_OUT
                return ~res;
            `else
                return res;
            `endif
        end
        endfunction : is_compliance
        
        function logic [255:0] get_filename (logic [255:0] testname);
        logic [255:0] res;
        int i, j;
        begin
            testname[7:0] = 8'h66;
            testname[15:8] = 8'h6C;
            testname[23:16] = 8'h65;
        
            for (i = 0; i <= 248; i += 8) begin
                if (testname[i+:8] == 0) begin
                    break;
                end
            end
            i -= 8;
            for (j = 255; i >= 0;i -= 8) begin
                res[j-:8] = testname[i+:8];
                j -= 8;
            end
            for (; j >= 0;j -= 8) begin
                res[j-:8] = 0;
            end
        
            return res;
        end
        endfunction : get_filename
        
        function logic [255:0] get_ref_filename (logic [255:0] testname);
        logic [255:0] res;
        int i, j;
        logic [79:0] pattern;
        begin
            pattern = 80'h636f6d706c69616e6365; // compliance
        
            for(int i = 0; i <= 176; i++) begin
                if(testname[i+:80] == pattern) begin
                    testname[(i-8)+:88] = 0;
                    break;
                end
            end
        
            for(i = 32; i <= 248; i += 8) begin
                if(testname[i+:8] == 0) break;
            end
            i -= 8;
            for(j = 255; i > 24; i -= 8) begin
                res[j-:8] = testname[i+:8];
                j -= 8;
            end
            for(; j >=0;j -= 8) begin
                res[j-:8] = 0;
            end
        
            return res;
        end
        endfunction : get_ref_filename
        
        function logic [2047:0] remove_trailing_whitespaces (logic [2047:0] str);
        int i;
        begin
            for (i = 0; i <= 2040; i += 8) begin
                if (str[i+:8] != 8'h20) begin
                    break;
                end
            end
            str = str >> i;
            return str;
        end
        endfunction: remove_trailing_whitespaces
        
        `else // VERILATOR
        function bit is_compliance (string testname);
        begin
            return (testname.substr(0, 9) == "compliance");
        end
        endfunction : is_compliance
        
        function string get_filename (string testname);
        int length;
        begin
            length = testname.len();
            testname[length-1] = "f";
            testname[length-2] = "l";
            testname[length-3] = "e";
        
            return testname;
        end
        endfunction : get_filename
        
        function string get_ref_filename (string testname);
        begin
            return testname.substr(11, testname.len() - 5);
        end
        endfunction : get_ref_filename
        
        `endif // VERILATOR

