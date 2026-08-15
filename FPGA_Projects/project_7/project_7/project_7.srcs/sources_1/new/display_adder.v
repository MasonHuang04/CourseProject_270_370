`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 19:14:57
// Design Name: 
// Module Name: display_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 0
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module display_adder(input M, input [3:0] last_num, input clock, input clock_500hz, output reg [3:0] AAN, output reg [6:0] CCA, input [3:0] number1,input [3:0] number2, input [3:0] number3,input [3:0] number4, input is1, input is2, input is3, input is4);
reg statenow = 0;
reg [1:0] state2 = 0;
reg [3:0] AN;
reg [6:0] CA;

always @(posedge clock_500hz) begin
    if (state2 == 3) begin
        state2 <= 0;
    end
    else begin
        state2 <= state2 + 1;
    end
    if ((statenow == 0) && (M == 1) && (last_num[3] == 1)) begin
        statenow <= 1;
    end
    else if ((statenow == 1) && (M == 1) && (last_num[3] == 1)) begin
        statenow <= 0;
    end
    else begin
        statenow <= 0;
    end
    AAN <= AN;
    CCA <= CA;
end

always @(posedge clock) begin
    if (M == 1) begin
        if (last_num[3] == 0) begin
            case (last_num)
                4'b0000: CA <= 7'b1000000;
                4'b0001: CA <= 7'b1111001;
                4'b0010: CA <= 7'b0100100;
                4'b0011: CA <= 7'b0110000;
                4'b0100: CA <= 7'b0011001;
                4'b0101: CA <= 7'b0010010;
                4'b0110: CA <= 7'b0000010;
                4'b0111: CA <= 7'b1111000;
                default: CA <= 7'b1111111;
            endcase
            AN <= 4'b1110;
        end
        else begin
            if (statenow == 0) begin
                AN <= 4'b1110;
                case (last_num)
                    4'b1111: CA <= 7'b1111001;
                    4'b1110: CA <= 7'b0100100;
                    4'b1101: CA <= 7'b0110000;
                    4'b1100: CA <= 7'b0011001;
                    4'b1011: CA <= 7'b0010010;
                    4'b1010: CA <= 7'b0000010;
                    4'b1001: CA <= 7'b1111000;
                    4'b1000: CA <= 7'b0000000;
                    default: CA <= 7'b1111111;
                endcase
//                statenow <= 1;
            end
            else if (statenow == 1) begin
                AN <= 4'b1101;
//                statenow <= 0;
                CA <= 7'b0111111;
            end
        end
    end
    else begin
        if (state2 == 0) begin
//            state2 <= 1;
            AN <= 4'b1110;
            if (is1 == 1) begin
                case (number1)
                    4'b0000: CA <= 7'b1000000;
                    4'b0001: CA <= 7'b1111001;
                    4'b0010: CA <= 7'b0100100;
                    4'b0011: CA <= 7'b0110000;
                    4'b0100: CA <= 7'b0011001;
                    4'b0101: CA <= 7'b0010010;
                    4'b0110: CA <= 7'b0000010;
                    4'b0111: CA <= 7'b1111000;
                    4'b1000: CA <= 7'b0000000;
                    4'b1001: CA <= 7'b0010000;
                    default: CA <= 7'b1111111;
                endcase
            end
            else begin
                CA <= 7'b1111111;
            end
        end
        else if (state2 == 1) begin
            AN <= 4'b1101;
//            state2 <= 2;
            if (is2 == 1) begin
                case (number2)
                    4'b0000: CA <= 7'b1000000;
                    4'b0001: CA <= 7'b1111001;
                    4'b0010: CA <= 7'b0100100;
                    4'b0011: CA <= 7'b0110000;
                    4'b0100: CA <= 7'b0011001;
                    4'b0101: CA <= 7'b0010010;
                    4'b0110: CA <= 7'b0000010;
                    4'b0111: CA <= 7'b1111000;
                    4'b1000: CA <= 7'b0000000;
                    4'b1001: CA <= 7'b0010000;
                    default: CA <= 7'b1111111;
                endcase
            end
            else begin
                CA <= 7'b1111111;
            end
        end
        else if (state2 == 2) begin
            AN <= 4'b1011;
//            state2 <= 3;
            if (is3 == 1) begin
                case (number3)
                    4'b0000: CA <= 7'b1000000;
                    4'b0001: CA <= 7'b1111001;
                    4'b0010: CA <= 7'b0100100;
                    4'b0011: CA <= 7'b0110000;
                    4'b0100: CA <= 7'b0011001;
                    4'b0101: CA <= 7'b0010010;
                    4'b0110: CA <= 7'b0000010;
                    4'b0111: CA <= 7'b1111000;
                    4'b1000: CA <= 7'b0000000;
                    4'b1001: CA <= 7'b0010000;
                    default: CA <= 7'b1111111;
                endcase
            end
            else begin
                CA <= 7'b1111111;
            end
        end
        else if (state2 == 3) begin
            AN <= 4'b0111;
//            state2 <= 0;
            if (is4 == 1) begin
                case (number4)
                    4'b0000: CA <= 7'b1000000;
                    4'b0001: CA <= 7'b1111001;
                    4'b0010: CA <= 7'b0100100;
                    4'b0011: CA <= 7'b0110000;
                    4'b0100: CA <= 7'b0011001;
                    4'b0101: CA <= 7'b0010010;
                    4'b0110: CA <= 7'b0000010;
                    4'b0111: CA <= 7'b1111000;
                    4'b1000: CA <= 7'b0000000;
                    4'b1001: CA <= 7'b0010000;
                    default: CA <= 7'b1111111;
                endcase
            end
            else begin
                CA <= 7'b1111111;
            end
        end
    end
end

endmodule
