`timescale 1ns / 1ps

module debug_hazard_testbench();
    reg clk, reset;
    
    // 实例化 PipelineProcessor
    PipelineProcessor uut (
        .clk(clk),
        .reset(reset)
    );
    
    // 监控所有关键hazard信号
    always @(posedge clk) begin
        if (!reset) begin
            $display("================================");
            $display("Time: %0t ns, Cycle: %0d", $time, ($time/10));
            $display("PC State:");
            $display("  PC_cs: 0x%h", uut.PC_cs);
            $display("  PC_ns: 0x%h", uut.PC_ns);
            $display("  PCSrc: %b", uut.PCSrc);
            $display("  PCWRITE: %b", uut.PCWRITE);
            
            $display("Pipeline Instructions:");
            $display("  IF: 0x%h", uut.Inst);
            $display("  ID: 0x%h", uut.IFID_Inst_out);
            $display("  EX: opcode=0x%h, rd=%d", uut.IDEX_opcode_out, uut.IDEX_rd_addr_out);
            $display("  MEM: rd=%d, RegWrite=%b", uut.EXMEM_rd_addr_out, uut.EXMEM_RegWrite_out);
            $display("  WB: rd=%d, RegWrite=%b", uut.MEMWB_rd_addr_out, uut.MEMWB_RegWrite_out);
            
            $display("Data Hazard Signals:");
            $display("  data_hazard_A: %b", uut.data_hazard_A);
            $display("  data_hazard_B: %b", uut.data_hazard_B);
            $display("  Load-Use Hazard: %b", uut.Hazard);
            $display("  IDEX_rs1_addr: %d", uut.IDEX_rs1_addr_out);
            $display("  IDEX_rs2_addr: %d", uut.IDEX_rs2_addr_out);
            $display("  EXMEM_rd_addr: %d", uut.EXMEM_rd_addr_out);
            $display("  MEMWB_rd_addr: %d", uut.MEMWB_rd_addr_out);
            
            $display("Control Hazard Signals:");
            $display("  branch_taken: %b", uut.branch_taken);
            $display("  IF_Flush: %b", uut.IF_Flush);
            $display("  if_Jump: %b", uut.if_Jump);
            $display("  is_jalr_id: %b", uut.is_jalr_id);
            $display("  Branch: %b", uut.Branch);
            
            $display("Pipeline Control:");
            $display("  final_IF_ID_Write: %b", uut.final_IF_ID_Write);
            $display("  ctrl_IF_ID_Write: %b", uut.ctrl_IF_ID_Write);
            $display("  load_IF_ID_Write: %b", uut.load_IF_ID_Write);
            
            $display("ALU and Forwarding:");
            $display("  ALU_input1: 0x%h", uut.ALU_input1);
            $display("  ALU_input2: 0x%h", uut.ALU_input2);
            $display("  ALU_result: 0x%h", uut.ALU_result);
            $display("  rs1_data: 0x%h", uut.rs1_data);
            $display("  rs2_data: 0x%h", uut.rs2_data);
            
            // 特殊hazard情况检测
            if (uut.data_hazard_A != 2'b00 || uut.data_hazard_B != 2'b00) begin
                $display("*** DATA FORWARDING DETECTED ***");
                $display("  Forward A: %s", 
                    (uut.data_hazard_A == 2'b10) ? "EX-EX" : 
                    (uut.data_hazard_A == 2'b01) ? "MEM-EX" : "NONE");
                $display("  Forward B: %s", 
                    (uut.data_hazard_B == 2'b10) ? "EX-EX" : 
                    (uut.data_hazard_B == 2'b01) ? "MEM-EX" : "NONE");
            end
            
            if (uut.Hazard) begin
                $display("*** LOAD-USE HAZARD DETECTED - PIPELINE STALLED ***");
            end
            
            if (uut.IF_Flush) begin
                $display("*** CONTROL HAZARD - PIPELINE FLUSHED ***");
            end
            
            if (uut.is_jalr_id) begin
                $display("*** JALR INSTRUCTION DETECTED ***");
                $display("  Base address (rs1): 0x%h", uut.rs1_data);
                $display("  Jump target: 0x%h", uut.PC_branch_target);
            end
            
            $display("================================");
        end
    end
    
    // 时钟生成 - 10ns周期
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 测试序列
    initial begin
        $display("Starting Pipeline Hazard Debug Test");
        $display("Loading instruction sequence from Lab4_testcase.s");
        
        // 复位
        reset = 1;
        #20;
        reset = 0;
        
        // 运行足够长的时间来执行所有指令
        #2000;
        
        $display("Test completed");
        $finish;
    end
    
    // 生成波形文件
    initial begin
        $dumpfile("pipeline_hazard_debug.vcd");
        $dumpvars(0, debug_hazard_testbench);
    end
    
endmodule
