`timescale 1ns / 1ps

module test_simple;
    reg clk;
    reg reset;
    
    PipelineProcessor cpu (
        .clk(clk),
        .reset(reset)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $display("TEST STARTING...");
        reset = 1;
        #20;
        reset = 0;
        $display("RESET DONE");
        
        #1200;
        
        $display("RESULTS:");
        $display("x1=%h", cpu.RF.regs[1]);
        $display("t0=%h", cpu.RF.regs[5]);
        $display("t2=%h", cpu.RF.regs[7]);
        $display("t3=%h", cpu.RF.regs[28]);
        $display("TEST DONE");
        
        $finish;
    end
endmodule
