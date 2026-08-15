`timescale 1ns / 1ps

module pipeline_test_case();
    // Clock and reset
    reg clk;
    reg reset;
    
    // Cycle counter
    integer cycle_count = 0;
    
    // Memory initialization for test
    reg [31:0] test_inst_memory [0:63];
    integer i;
    
    // Instantiate the processor
    PipelineProcessor processor(
        .clk(clk),
        .reset(reset)
    );
    
    // Generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end
    
    // Initialize test instruction memory
    initial begin
        // Initialize all memory locations to NOP (addi x0, x0, 0)
        for(i = 0; i < 64; i = i + 1) begin
            test_inst_memory[i] = 32'h00000013;
        end
        
        // Test sequence with various instruction types and hazard scenarios
        
        // 1. Basic ALU operations
        test_inst_memory[0] = 32'h00100093;  // addi x1, x0, 1     # x1 = 1
        test_inst_memory[1] = 32'h00200113;  // addi x2, x0, 2     # x2 = 2
        test_inst_memory[2] = 32'h002081b3;  // add x3, x1, x2     # x3 = x1 + x2 = 3 (RAW hazard with x1, x2)
        test_inst_memory[3] = 32'h00318233;  // add x4, x3, x3     # x4 = x3 + x3 = 6 (RAW hazard with x3)
        
        // 2. Load-use hazard
        test_inst_memory[4] = 32'h00300293;  // addi x5, x0, 3     # x5 = 3
        test_inst_memory[5] = 32'h00502023;  // sw x5, 0(x0)       # Mem[0] = 3
        test_inst_memory[6] = 32'h00002303;  // lw x6, 0(x0)       # x6 = Mem[0] = 3
        test_inst_memory[7] = 32'h00630333;  // add x6, x6, x6     # x6 = x6 + x6 = 6 (load-use hazard)
        
        // 3. Branch and control hazards
        test_inst_memory[8] = 32'h00400393;  // addi x7, x0, 4     # x7 = 4
        test_inst_memory[9] = 32'h00038463;  // beq x7, x0, L1     # Branch if x7 == 0 (not taken)
        test_inst_memory[10] = 32'h00500413; // addi x8, x0, 5     # x8 = 5 (executed)
        test_inst_memory[11] = 32'h00000413; // L1: addi x8, x0, 0 # x8 = 0 (not executed due to previous line)
        
        // 4. JAL and JALR hazards (the main focus)
        test_inst_memory[12] = 32'h008005EF; // jal x11, L2        # x11 = PC+4 = 0x34, jump to PC+8 = 0x3C
        test_inst_memory[13] = 32'h00000013; // nop                # (skipped)
        test_inst_memory[14] = 32'h00058067; // L2: jalr x0, 0(x11) # jump to x11 = 0x34 (JALR uses JAL result - hazard)
        test_inst_memory[15] = 32'h00600993; // addi x19, x0, 6    # x19 = 6
        
        // 5. Forwarding from MEM stage
        test_inst_memory[16] = 32'h00700513; // addi x10, x0, 7    # x10 = 7
        test_inst_memory[17] = 32'h00000593; // addi x11, x0, 0    # x11 = 0
        test_inst_memory[18] = 32'h00A58633; // add x12, x11, x10  # x12 = x11 + x10 = 7 (forward x10 from MEM)
        
        // 6. Forwarding from WB stage
        test_inst_memory[19] = 32'h00800713; // addi x14, x0, 8    # x14 = 8
        test_inst_memory[20] = 32'h00000793; // addi x15, x0, 0    # x15 = 0
        test_inst_memory[21] = 32'h00000813; // addi x16, x0, 0    # x16 = 0
        test_inst_memory[22] = 32'h00E80733; // add x14, x16, x14  # x14 = x16 + x14 = 8 (forward x14 from WB)
        
        // Initialize Instruction Memory module with test instructions
        for(i = 0; i < 64; i = i + 1) begin
            processor.InstMem.memory[i] = test_inst_memory[i];
        end
    end
    
    // Test sequence
    initial begin
        // Reset processor
        reset = 1;
        #20;
        reset = 0;
        
        // Run for enough cycles to execute all test instructions
        #1000;
        
        // Print summary
        $display("\n===== SIMULATION SUMMARY =====");
        $display("Total cycles: %d", cycle_count);
        $display("Final PC: 0x%h", processor.PC_cs);
        
        // End simulation
        $finish;
    end
    
    // Count cycles and print execution status
    always @(posedge clk) begin
        if (~reset) begin
            cycle_count = cycle_count + 1;
            
            $display("\n===== CYCLE %d =====", cycle_count);
            $display("PC = 0x%h, Instruction = 0x%h", processor.PC_cs, processor.Inst);
            
            // Check for pipeline hazards
            if (processor.Hazard)
                $display("*** LOAD-USE HAZARD DETECTED! Pipeline stalled.");
            if (processor.jalr_forward.ex_jal_hazard || processor.jalr_forward.mem_jal_hazard)
                $display("*** JALR FORWARDING ACTIVE! rs1_data = 0x%h", processor.rs1_data);
            if (processor.data_hazard_A != 0 || processor.data_hazard_B != 0)
                $display("*** DATA FORWARDING: A=%d, B=%d (0=none, 1=from WB, 2=from MEM)", 
                    processor.data_hazard_A, processor.data_hazard_B);
            if (processor.PCSrc)
                $display("*** CONTROL TRANSFER: target = 0x%h", processor.PC_branch);
        end
    end
    
    // Monitor register file changes
    always @(negedge clk) begin
        if (~reset && processor.MEMWB_RegWrite_out && processor.MEMWB_rd_addr_out != 0) begin
            $display("Register x%d updated to 0x%h", processor.MEMWB_rd_addr_out, processor.rd_write_data);
        end
    end
    
    // Pipeline stage monitor
    always @(posedge clk) begin
        if (~reset) begin
            $display("\nIF/ID: PC=0x%h, Inst=0x%h", processor.IFID_PC_out, processor.IFID_Inst_out);
            $display("ID/EX: PC=0x%h, rs1=x%d(0x%h), rs2=x%d(0x%h), rd=x%d",
                     processor.IDEX_PC_out,
                     processor.IDEX_rs1_addr_out, processor.IDEX_rs1_data_out,
                     processor.IDEX_rs2_addr_out, processor.IDEX_rs2_data_out,
                     processor.IDEX_rd_addr_out);
            $display("EX/MEM: ALU=0x%h, rs2=0x%h, rd=x%d", 
                     processor.EXMEM_ALU_result_out,
                     processor.EXMEM_rs2_data_out,
                     processor.EXMEM_rd_addr_out);
            $display("MEM/WB: Data=0x%h, ALU=0x%h, rd=x%d",
                     processor.MEMWB_mem_data_out,
                     processor.MEMWB_ALU_result_out,
                     processor.MEMWB_rd_addr_out);
        end
    end

endmodule
