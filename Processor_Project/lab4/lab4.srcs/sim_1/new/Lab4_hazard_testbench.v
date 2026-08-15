`timescale 1ns / 1ps

module Lab4_hazard_testbench();

    // Testbench signals
    reg clk;
    reg reset;
    
    // Instantiate the pipeline processor
    PipelineProcessor uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Test instructions memory
    reg [31:0] test_inst_memory [0:31];
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end
    
    // Test procedure
    initial begin
        // Initialize
        reset = 1;
        #20;
        reset = 0;
        
        // Load test instructions into instruction memory
        // Test case from Lab4_testcase.s
        test_inst_memory[0] = 32'h39900313;  // addi t1, x0, 0x399
        test_inst_memory[1] = 32'h00602223;  // sw t1, 4(x0)
        test_inst_memory[2] = 32'h00400283;  // lb t0, 4(x0)
        test_inst_memory[3] = 32'h00502023;  // sw t0, 0(x0)
        test_inst_memory[4] = 32'h00030863;  // beq t1, x0, wrong_branch
        test_inst_memory[5] = 32'h00002e03;  // lw t3, 0(x0)
        test_inst_memory[6] = 32'h01c28c63;  // bne t0, t3, wrong_branch
        test_inst_memory[7] = 32'h01c28393;  // add t2, t0, t3
        test_inst_memory[8] = 32'h01c3f313;  // and t1, t2, t3
        test_inst_memory[9] = 32'h00037313;  // andi t1, t2, 0
        test_inst_memory[10] = 32'h40630283; // sub t0, t1, x0
        test_inst_memory[11] = 32'h00635463; // bge t0, t1, right_branch
        test_inst_memory[12] = 32'h00000393; // add t2, x0, x0 (wrong_branch)
        test_inst_memory[13] = 32'h008000ef; // jal x1, jump_test (right_branch)
        test_inst_memory[14] = 32'h008000ef; // jal x1, Exit
        test_inst_memory[15] = 32'h00000e33; // add t3, x0, x0
        test_inst_memory[16] = 32'h007e6e33; // or t3, t3, t2 (jump_test)
        test_inst_memory[17] = 32'h00008067; // jalr x0, x1, 0
        test_inst_memory[18] = 32'h04800313; // addi t1, x0, 0x48
        test_inst_memory[19] = 32'h0ac00283; // addi t0, x0, 0xac (Exit)
        
        // Copy test instructions to processor's instruction memory
        for (integer i = 0; i < 20; i = i + 1) begin
            processor.IM.instruction_memory[i] = test_inst_memory[i];
        end
        
        // Run simulation
        #500;
        
        // Display final results
        $display("=== Final Register Values ===");
        $display("t0 (x5) = 0x%h", processor.RF.register[5]);
        $display("t1 (x6) = 0x%h", processor.RF.register[6]);
        $display("t2 (x7) = 0x%h", processor.RF.register[7]);
        $display("t3 (x28) = 0x%h", processor.RF.register[28]);
        $display("x1 = 0x%h", processor.RF.register[1]);
        
        $finish;
    end
    
    // Monitor hazard detection signals
    always @(posedge clk) begin
        if (~reset) begin
            // Data hazard monitoring
            if (processor.data_hazard_A != 2'b00 || processor.data_hazard_B != 2'b00) begin
                $display("Time %t: DATA HAZARD DETECTED", $time);
                $display("  Current PC: 0x%h", processor.PC_cs);
                $display("  Current Instruction: 0x%h", processor.IFID_Inst_out);
                $display("  data_hazard_A: %b, data_hazard_B: %b", 
                        processor.data_hazard_A, processor.data_hazard_B);
                $display("  EX/MEM RegRd: %d, MEM/WB RegRd: %d", 
                        processor.EXMEM_rd_addr_out, processor.MEMWB_rd_addr_out);
                $display("  ID/EX RegRs1: %d, ID/EX RegRs2: %d", 
                        processor.IDEX_rs1_addr_out, processor.IDEX_rs2_addr_out);
                $display("  ---");
            end
            
            // Load-use hazard monitoring
            if (processor.Hazard) begin
                $display("Time %t: LOAD-USE HAZARD DETECTED", $time);
                $display("  Current PC: 0x%h", processor.PC_cs);
                $display("  Current Instruction: 0x%h", processor.IFID_Inst_out);
                $display("  ID/EX MemRead: %b, ID/EX RegRd: %d", 
                        processor.IDEX_MemRead_out, processor.IDEX_rd_addr_out);
                $display("  Rs1: %d, Rs2: %d", 
                        processor.IFID_Inst_out[19:15], processor.IFID_Inst_out[24:20]);
                $display("  PCWRITE: %b, IF_ID_Write: %b", 
                        processor.PCWRITE, processor.load_IF_ID_Write);
                $display("  ---");
            end
            
            // Control hazard monitoring
            if (processor.IF_Flush || processor.PCSrc) begin
                $display("Time %t: CONTROL HAZARD DETECTED", $time);
                $display("  Current PC: 0x%h", processor.PC_cs);
                $display("  Current Instruction: 0x%h", processor.IFID_Inst_out);
                $display("  Branch taken: %b, Jump: %b", 
                        processor.branch_taken, processor.if_Jump);
                $display("  IF_Flush: %b, PCSrc: %b", 
                        processor.IF_Flush, processor.PCSrc);
                $display("  Target Address: 0x%h", processor.PC_branch_target);
                $display("  ---");
            end
        end
    end
    
    // Monitor register file writes
    always @(negedge clk) begin
        if (~reset && processor.MEMWB_RegWrite_out && processor.MEMWB_rd_addr_out != 0) begin
            $display("Time %t: Register x%d updated to 0x%h", 
                    $time, processor.MEMWB_rd_addr_out, processor.rd_write_data);
        end
    end

endmodule
