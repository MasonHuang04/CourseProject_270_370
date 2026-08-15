`timescale 1ns / 1ps

module simple_test;
    reg clk, reset;
    
    PipelineProcessor cpu(.clk(clk), .reset(reset));
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        $display("Test starting...");
        reset = 1; #20; reset = 0;
        #1200;
        $display("ra=%h t0=%h t2=%h t3=%h", cpu.RF.regs[1], cpu.RF.regs[5], cpu.RF.regs[7], cpu.RF.regs[28]);
        
        // Check JALR forwarding status
        $display("\nJALR Forwarding Analysis:");
        $display("JALR ex_jal_hazard = %b", cpu.jalr_forward.ex_jal_hazard);
        $display("JALR mem_jal_hazard = %b", cpu.jalr_forward.mem_jal_hazard);
        
        $finish;
    end
    
    // Simple trace for debugging
    always @(posedge clk) begin
        if (~reset && cpu.is_jalr_id) begin
            $display("JALR detected at PC=%h, rs1_data=%h", cpu.IFID_PC_out, cpu.rs1_data);
        end
    end
endmodule
