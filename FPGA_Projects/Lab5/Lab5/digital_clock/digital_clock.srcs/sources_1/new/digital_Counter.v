`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/15 00:23:15
// Design Name: 
// Module Name: digital_Counter
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
//clk_original sw0
//RESET BTND

module digital_Counter(clk_original, reset, anode, cathode);
input clk_original;
input reset;
output [3:0] anode;
output [6:0] cathode;
reg [6:0] cathode;
wire clk_1, clk_1000;

clock_divider #(50000000) div1(clk_original, reset, clk_1);
clock_divider #(100000) div2(clk_original, reset, clk_1000);

wire [3:0] A, B;
counter combine(clk_1, reset, A, B);

wire [6:0] dis1, dis2;

output_file A_dis(A, dis1);
output_file B_dis(B, dis2);

reg [1:0] dis_select = 0;
always @(posedge clk_1000 or posedge reset) begin
    if (reset)
            dis_select <= 0;
    else
        dis_select <= dis_select + 1;
end
assign anode = 4'b1111 ^ (1 << dis_select);

always @(*) begin
    case (dis_select)
        2'b00: cathode = dis1;
        2'b01: cathode = dis2;
        default: cathode = 7'b1111111;
    endcase
end

endmodule