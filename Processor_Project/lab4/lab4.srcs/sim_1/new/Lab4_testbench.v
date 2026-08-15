module singleCycleTest;
    reg clk;
    reg reset;
    integer cycle_count;
	PipelineProcessor SCP (clk, reset);
    initial begin
        clk = 0;
        reset = 1;
        cycle_count = 0;
        #10 reset = 0;
        forever #1 clk = ~clk;
    end
    initial begin
        while ($time < 70) @(posedge clk) begin
            $display("===============================================");
            $display("Clock cycle %d, PC = %H", cycle_count, SCP.PC_cs);
            $display("ra = %H, t0 = %H, t1 = %H", SCP.RF.regs[1], SCP.RF.regs[5], SCP.RF.regs[6]);
            $display("t2 = %H, t3 = %H, t4 = %H", SCP.RF.regs[7], SCP.RF.regs[28], SCP.RF.regs[29]);
            $display("===============================================");
            cycle_count = cycle_count + 1;
        end
        $finish();
    end
endmodule