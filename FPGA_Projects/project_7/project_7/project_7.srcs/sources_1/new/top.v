`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 16:44:35
// Design Name: 
// Module Name: top
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


module top(input M, input P, input [3:0] numInput, input clock, input button, output [3:0] AN, output [6:0] CA, output overflow);
    wire clock_2hz;
    wire clock_500hz;
    wire [3:0] last_num;
    wire [3:0] number1;
    wire [3:0] number2;
    wire [3:0] number3;
    wire [3:0] number4;
    wire is1, is2, is3, is4;

clock_2hz clockseperate(
    .clock(clock),
    .clock_2hz(clock_2hz),
    .clock_500hz(clock_500hz)
);

rolling rnow(
    .M(M),
    .P(P),
    .clock_2hz(clock_2hz),
    .clock(clock),
    .number1(number1),
    .number2(number2),
    .number3(number3),
    .number4(number4),
    .is1(is1),
    .is2(is2),
    .is3(is3),
    .is4(is4)
);

adder add(
    .M(M),
    .P(P),
    .numInput(numInput),
    .clock(clock),
    .button(button),
    .last_num(last_num),
    .overflow(overflow)
);


display_adder display_inst(
        .M(M),
        .last_num(last_num),
        .clock(clock),
        .clock_500hz(clock_500hz),
        .AAN(AN),
        .CCA(CA),
        .number1(number1),
        .number2(number2),
        .number3(number3),
        .number4(number4),
        .is1(is1),
        .is2(is2),
        .is3(is3),
        .is4(is4)
    );
endmodule