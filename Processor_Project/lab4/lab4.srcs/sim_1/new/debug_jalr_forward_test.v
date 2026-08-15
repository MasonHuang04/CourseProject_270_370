`timescale 1ns / 1ps

module debug_jalr_forward_test();
    // Clock and reset
    reg clk;
    reg reset;
    
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
    
    // Test sequence
    initial begin
        // Reset processor
        reset = 1;
        #20;
        reset = 0;
        
        // Let simulation run for a reasonable time
        #1000;
        
        // End simulation
        $finish;
    end
    
    // Monitoring JALR forwarding
    always @(posedge clk) begin
        // Check for JALR instruction
        if (processor.is_jalr_id) begin
            $display("Time %0t: JALR detected!", $time);
            $display("  rs1_data_raw = %h", processor.rs1_data_raw);
            $display("  rs1_data (final) = %h", processor.rs1_data);
            
            // Check if forwarding occurred
            if (processor.jalr_forward.ex_jal_hazard) begin
                $display("  *** EX JAL Hazard detected! Forwarding PC+4 = %h", processor.IDEX_PC_plus4_out);
            end
            else if (processor.jalr_forward.mem_jal_hazard) begin
                $display("  *** MEM JAL Hazard detected! Forwarding PC+4 = %h", processor.EXMEM_PC_plus4_out);
            end
        end
    end
    
    // Monitor register file writes (useful to see JAL/JALR behavior)
    always @(posedge clk) begin
        if (processor.MEMWB_RegWrite_out) begin
            $display("Time %0t: Writing register x%0d = %h", $time, processor.MEMWB_rd_addr_out, processor.rd_write_data);
        end
    end
    
    // Monitor PC updates
    always @(posedge clk) begin
        if (~reset) begin
            $display("Time %0t: PC = %h, Instruction = %h", $time, processor.PC_cs, processor.Inst);
            
            // If branch or jump taken
            if (processor.PCSrc) begin
                $display("  *** Branch/Jump taken to PC = %h", processor.PC_branch);
            end
        end
    end

endmodule
