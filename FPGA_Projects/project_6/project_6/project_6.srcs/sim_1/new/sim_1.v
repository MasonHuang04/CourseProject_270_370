module tb_scanner;

    // Testbench signals
    reg clk;
    reg reset;
    reg [3:0] row;
    wire [3:0] col;
    wire [3:0] anode;
    wire [6:0] ssd_out;

    // Instantiate the scanner module (uut = Unit Under Test)
    scanner uut (
        .clk(clk),
        .reset(reset),
        .row(row),
        .col(col),
        .anode(anode),
        .ssd_out(ssd_out)
    );

    // Clock generation: period = 10 time units
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Initial block for reset and stimulus
    initial begin
        // Initial reset
        reset = 0;
        #10 reset = 1;  // Apply reset for 10 time units
        #10 reset = 0;  // Release reset
        
        // Test row inputs for various states
        #10 row = 4'b0001; // Test first row
        #10 row = 4'b0010; // Test second row
        #10 row = 4'b0100; // Test third row
        #10 row = 4'b1000; // Test fourth row
        #50 row = 4'b0000; // All rows inactive
        
        // Additional test stimulus
        #50 row = 4'b0010;
        #10 row = 4'b0000;
        #50 row = 4'b1000;
        #10 row = 4'b0000;

        // Test row inputs for different combinations
        #20 row = 4'b0001;
        #20 row = 4'b0010;
        #20 row = 4'b0100;
        #20 row = 4'b1000;
        #20 row = 4'b0000;

        // Wait for some time and stop the simulation
        #100 $stop;
    end

endmodule
