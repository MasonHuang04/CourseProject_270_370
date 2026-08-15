`timescale 1ns / 1ps

module vivado_pipeline_test;
    reg clk;
    reg reset;
    
    // Instantiate the pipeline processor
    PipelineProcessor cpu (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize
        reset = 1;
        #20;
        reset = 0;
        
        // Add some debug output during execution
        $display("Starting pipeline execution...");
        
        // Wait for execution
        repeat(120) begin
            @(posedge clk);
            if ($time % 100 == 0) begin
                $display("Time: %0d, PC: %h", $time, cpu.PC_cs);
            end
        end
        
        // Final results
        $display("=== FINAL RESULTS ===");
        $display("x1(ra) = %h", cpu.RF.regs[1]);
        $display("x5(t0) = %h", cpu.RF.regs[5]);
        $display("x7(t2) = %h", cpu.RF.regs[7]);
        $display("x28(t3) = %h", cpu.RF.regs[28]);
        
        // Expected vs Actual
        $display("=== VERIFICATION ===");
        $display("x1: Expected=3c, Got=%h %s", cpu.RF.regs[1], (cpu.RF.regs[1] == 32'h3c) ? "PASS" : "FAIL");
        $display("t0: Expected=ac, Got=%h %s", cpu.RF.regs[5], (cpu.RF.regs[5] == 32'hac) ? "PASS" : "FAIL");
        $display("t2: Expected=ffffff32, Got=%h %s", cpu.RF.regs[7], (cpu.RF.regs[7] == 32'hffffff32) ? "PASS" : "FAIL");
        $display("t3: Expected=ffffffbb, Got=%h %s", cpu.RF.regs[28], (cpu.RF.regs[28] == 32'hffffffbb) ? "PASS" : "FAIL");
        
        $display("Simulation completed.");
        $finish;
    end
    
endmodule
