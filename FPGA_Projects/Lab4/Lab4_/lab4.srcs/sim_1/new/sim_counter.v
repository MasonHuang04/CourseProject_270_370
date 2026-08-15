`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/30 21:25:17
// Design Name: 
// Module Name: sim_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_counter;
    // Testbench signals
    reg clk;
    reg reset;
    reg up_down;
    wire [3:0] count;
    wire [6:0] ssd_out;
    wire [3:0] led_out;

    // Instantiate the top-level module
    main uut (
        .clk(clk),
        .reset(reset),
        .up_down(up_down),
        .ssd_out(ssd_out),
        .led_out(led_out)
    );

    // Clock signal generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10ns
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 0;
        up_down = 1;  // Set to count up initially

        // Apply reset
        #10 reset = 1;    // Assert reset
        #10 reset = 0;    // Deassert reset

        // Test counting up
        #10 up_down = 1;   // Start counting up
        #100;              // Wait for several clock cycles

        // Test counting down
        up_down = 0;       // Set to count down
        #100;              // Wait for several clock cycles

        // Test reset during counting down
        reset = 1;         // Assert reset
        #10 reset = 0;     // Deassert reset
        #100;              // Wait for several clock cycles

        // End of simulation
        $stop;
    end

    // Monitor the outputs
    initial begin
        $monitor("Time = %0t | clk = %b | reset = %b | up_down = %b | count = %b | ssd_out = %b",
                 $time, clk, reset, up_down, led_out, ssd_out);
    end
endmodule
