`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/30 21:03:14
// Design Name: 
// Module Name: Counter
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


module Counter(
    input wire clk,
    input wire reset,
    input wire up_down,
    output reg [3:0] count = 4'b0000
    );
    
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            count <= 4'b0000;
        else if (up_down)
            count <= count + 1;
        else
            count <= count - 1;
    end
endmodule

module SSD(
    input wire [3:0] binary_in,
    output reg [6:0] ssd_out
    );
    
    always @(*) 
    begin
        case (binary_in)
            4'h0: ssd_out = 7'b1000000; // 0
            4'h1: ssd_out = 7'b1111001; // 1
            4'h2: ssd_out = 7'b0100100; // 2
            4'h3: ssd_out = 7'b0110000; // 3
            4'h4: ssd_out = 7'b0011001; // 4
            4'h5: ssd_out = 7'b0010010; // 5
            4'h6: ssd_out = 7'b0000010; // 6
            4'h7: ssd_out = 7'b1111000; // 7
            4'h8: ssd_out = 7'b0000000; // 8
            4'h9: ssd_out = 7'b0010000; // 9
            4'hA: ssd_out = 7'b0001000; // A
            4'hB: ssd_out = 7'b0000011; // B
            4'hC: ssd_out = 7'b1000110; // C
            4'hD: ssd_out = 7'b0100001; // D
            4'hE: ssd_out = 7'b0000110; // E
            4'hF: ssd_out = 7'b0001110; // F
            default: ssd_out = 7'b1111111; // Blank
        endcase
    end
endmodule

module main(
    input wire clk,
    input wire reset,
    input wire up_down,
    output wire [3:0] led_out,
    output wire [6:0] ssd_out
    );
    
    wire [3:0] count;
    
    Counter A (
        .clk(clk),
        .reset(reset),
        .up_down(up_down),
        .count(count)
    );
    
    assign led_out = count;
    
    SSD B (
        .binary_in(count),
        .ssd_out(ssd_out)
    );
    
endmodule 