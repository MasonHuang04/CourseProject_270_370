`timescale 1ns / 1ps

// Simple 32-bit adder module
module AddSum(
    input [31:0] input1,
    input [31:0] input2,
    output [31:0] result
);
    assign result = input1 + input2;

endmodule
