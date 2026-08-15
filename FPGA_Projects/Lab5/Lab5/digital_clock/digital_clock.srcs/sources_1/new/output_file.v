`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/15 00:31:07
// Design Name: 
// Module Name: output_file
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


module output_file(number, display);
input [3:0] number;
output [6:0] display;
reg[6:0]  display;
always @(*) begin
    case (number)
        4'b0000: display = 7'b0000001; 
        4'b0001: display = 7'b1001111;
        4'b0010: display= 7'b0010010;
        4'b0011: display= 7'b0000110; 
        4'b0100: display= 7'b1001100; 
        4'b0101: display= 7'b0100100;
        4'b0110: display= 7'b0100000;
        4'b0111: display= 7'b0001111;
        4'b1000: display= 7'b0000000; 
        4'b1001: display= 7'b0000100;
        default: display = 7'b1111111;
    endcase
    
end

endmodule
