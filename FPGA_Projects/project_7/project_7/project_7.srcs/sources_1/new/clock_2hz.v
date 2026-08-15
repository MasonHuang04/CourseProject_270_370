`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 18:12:08
// Design Name: 
// Module Name: clock_2hz
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


module clock_2hz (input clock, output reg clock_2hz, output reg clock_500hz);
reg [30 : 0] t1 = 1;
initial begin
    clock_2hz = 1'b1;
    clock_500hz = 1'b1;
end
always @(posedge clock) begin
    if(t1%25000000 == 0) begin
         clock_2hz <= ~clock_2hz;
         t1 <= 1;
    end
    if(t1%100000 == 0) begin 
        clock_500hz <= ~clock_500hz; 
    end
    t1 <= t1 + 1; 
end
endmodule