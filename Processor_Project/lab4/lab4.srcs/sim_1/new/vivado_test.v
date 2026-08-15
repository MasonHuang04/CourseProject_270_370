`timescale 1ns / 1ps

module vivado_test;
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
        // Add monitor for debugging
        $monitor("Time=%0t, PC=%h, x1=%h, t0=%h, t2=%h, t3=%h", 
                 $time, cpu.PC_cs, cpu.RF.regs[1], cpu.RF.regs[5], cpu.RF.regs[7], cpu.RF.regs[28]);
        
        $display("*** VIVADO SIMULATION STARTED ***");
        
        // Reset the processor
        reset = 1;
        #20;
        reset = 0;
        
        $display("*** RESET COMPLETED, EXECUTION STARTING ***");
        
        // Run simulation for enough cycles
        #1200;
        
        $display("*** EXECUTION COMPLETED ***");
        $display("*** FINAL RESULTS ***");
        $display("x1(ra)  = 0x%08X", cpu.RF.regs[1]);
        $display("x5(t0)  = 0x%08X", cpu.RF.regs[5]);
        $display("x7(t2)  = 0x%08X", cpu.RF.regs[7]);
        $display("x28(t3) = 0x%08X", cpu.RF.regs[28]);
        
        $display("*** EXPECTED VALUES ***");
        $display("x1(ra)  = 0x0000003c");
        $display("x5(t0)  = 0x000000ac");
        $display("x7(t2)  = 0xffffff32");
        $display("x28(t3) = 0xffffffbb");
        
        $display("*** VERIFICATION ***");
        if (cpu.RF.regs[1] == 32'h0000003c) $display("x1: PASS"); else $display("x1: FAIL");
        if (cpu.RF.regs[5] == 32'h000000ac) $display("t0: PASS"); else $display("t0: FAIL");
        if (cpu.RF.regs[7] == 32'hffffff32) $display("t2: PASS"); else $display("t2: FAIL");
        if (cpu.RF.regs[28] == 32'hffffffbb) $display("t3: PASS"); else $display("t3: FAIL");
        
        $display("*** SIMULATION FINISHED ***");
        $finish;
    end
    
endmodule
