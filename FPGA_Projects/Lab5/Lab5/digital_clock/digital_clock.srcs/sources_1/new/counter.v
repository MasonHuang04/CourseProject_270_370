`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/15 01:09:14
// Design Name: 
// Module Name: counter
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


module counter(clk, reset, a1, a2);
input clk, reset;
output reg [3:0] a1, a2;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        a1 <= 4'b0000;
        a2 <= 4'b0000;
    end
    else begin
        if (a1 == 4'b1001) begin
            a1 <= 4'b0000;
            if (a2 == 4'b0101) begin
                a2 <= 4'b0000;
            end else begin
                a2 <= a2 + 1;
            end
        end 
        else begin
            a1 <= a1 + 1;
        end
    end
end
endmodule