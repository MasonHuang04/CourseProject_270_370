`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 17:03:06
// Design Name: 
// Module Name: adder
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


module adder(input M, input P, input [3:0] numInput, input clock, input button, output reg [3:0] last_num, output reg overflow);
reg button_pre = 0;
reg [3:0] last_num_pre = 0;
always @(posedge clock) begin
    if (M == 1) begin
        if(button == 1 && button_pre == 0) begin
            last_num_pre = last_num;
            last_num = numInput + last_num;
            if ((last_num[3] == 1 && last_num_pre[3] == 0 && numInput[3] == 0) || (last_num[3] == 0 && last_num_pre[3] == 1 && numInput[3] == 1)) begin
                overflow = 1;
            end
            else begin
                overflow = 0;
            end
        end
        button_pre <= button;
    end
    if (M == 0) begin
        last_num <= 0;
        button_pre <= button;
        last_num_pre <= 0;
        overflow <= 0;
    end
end

endmodule
