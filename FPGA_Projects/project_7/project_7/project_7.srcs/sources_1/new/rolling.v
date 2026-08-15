module rolling(input M, input P, input clock_2hz, input clock, output reg [3:0] number1, output reg [3:0] number2, output reg [3:0] number3, output reg [3:0] number4, output reg is1, output reg is2, output reg is3, output reg is4);
parameter [47:0] S1 = 48'h523370910126;
reg [30 : 0] t1 = 0;
parameter [47:0] S2 = 48'h523370910151;

reg [47:0] shift_data1 = S1;
reg [47:0] shift_data2 = S2;

reg state;

always @(posedge clock_2hz) begin
    if (t1 >= 4) begin
        shift_data1 = S1 << ((t1-3) * 4);
        shift_data2 = S2 << ((t1-3) * 4);
    end
    if (shift_data1 == 0) begin
        shift_data1 = S1;
    end
    if (shift_data2 == 0) begin
        shift_data2 = S2;
    end
    if (t1 == 15) begin
        t1 <= 0;
        is1 <= 0;
        is2 <= 0;
        is3 <= 0;
        is4 <= 0;
    end
    else if (M == 1) begin
        t1 <= 0;
        is1 <= 0;
        is2 <= 0;
        is3 <= 0;
        is4 <= 0;
        shift_data1 <= S1;
        shift_data2 <= S2; 
    end
    else if ((P == 1'b1) && (state == 0)) begin
        t1 <= 0;
        is1 <= 0;
        is2 <= 0;
        is3 <= 0;
        is4 <= 0;
        state <= 1;
        shift_data1 <= S1;
        shift_data2 <= S2;
    end
    else if ((P == 1'b0) && (state == 1)) begin
        t1 <= 0;
        is1 <= 0;
        is2 <= 0;
        is3 <= 0;
        is4 <= 0;
        state <= 0;
        shift_data1 <= S1;
        shift_data2 <= S2;
    end
    else begin
        if (P == 1'b1) begin
            if (t1 == 14) begin
                number4 <= shift_data1[47:44];
                is1 <= 0;
                is2 <= 0;
                is3 <= 0;
                is4 <= 1;
                state <= 1;
            end
            else if (t1 == 13) begin
                number4 <= shift_data1[47:44];
                number3 <= shift_data1[43:40];
                is1 <= 0;
                is2 <= 0;
                is3 <= 1;
                is4 <= 1;
                state <= 1;
            end
            else if (t1 == 12) begin
                number4 <= shift_data1[47:44];
                number3 <= shift_data1[43:40];
                number2 <= shift_data1[39:36];
                is1 <= 0;
                is2 <= 1;
                is3 <= 1;
                is4 <= 1;
                state <= 1;
            end
            else if (t1 >= 3 && t1 <= 11) begin
                number4 <= shift_data1[47:44];
                number3 <= shift_data1[43:40];
                number2 <= shift_data1[39:36];
                number1 <= shift_data1[35:32];
                is1 <= 1;
                is2 <= 1;
                is3 <= 1;
                is4 <= 1;
                state <= 1;
            end
            else if (t1 == 0) begin
                number1 <= S1[47:44];
                is1 <= 1;
                is2 <= 0;
                is3 <= 0;
                is4 <= 0;
                state <= 1;
            end
            else if (t1 == 1) begin
                number2 <= S1[47:44];
                number1 <= S1[43:40];
                is1 <= 1;
                is2 <= 1;
                is3 <= 0;
                is4 <= 0;
                state <= 1;
            end
            else if (t1 == 2) begin
                number3 <= S1[47:44];
                number2 <= S1[43:40];
                number1 <= S1[39:36];
                is1 <= 1;
                is2 <= 1;
                is3 <= 1;
                is4 <= 0;
                state <= 1;
            end
        end
        
        else if (P == 1'b0) begin
            if (t1 == 14) begin
                number4 <= shift_data2[47:44];
                is1 <= 0;
                is2 <= 0;
                is3 <= 0;
                is4 <= 1;
                state <= 0;
            end
            else if (t1 == 13) begin
                number4 <= shift_data2[47:44];
                number3 <= shift_data2[43:40];
                is1 <= 0;
                is2 <= 0;
                is3 <= 1;
                is4 <= 1;
                state <= 0;
            end
            else if (t1 == 12) begin
                number4 <= shift_data2[47:44];
                number3 <= shift_data2[43:40];
                number2 <= shift_data2[39:36];
                is1 <= 0;
                is2 <= 1;
                is3 <= 1;
                is4 <= 1;
                state <= 0;
            end
            else if (t1 >= 3 && t1 <= 11) begin
                number4 <= shift_data2[47:44];
                number3 <= shift_data2[43:40];
                number2 <= shift_data2[39:36];
                number1 <= shift_data2[35:32];
                is1 <= 1;
                is2 <= 1;
                is3 <= 1;
                is4 <= 1;
                state <= 0;
            end
            else if (t1 == 0) begin
                number1 <= S2[47:44];
                is1 <= 1;
                is2 <= 0;
                is3 <= 0;
                is4 <= 0;
                state <= 0;
            end
            else if (t1 == 1) begin
                number2 <= S2[47:44];
                number1 <= S2[43:40];
                is1 <= 1;
                is2 <= 1;
                is3 <= 0;
                is4 <= 0;
                state <= 0;
            end
            else if (t1 == 2) begin
                number3 <= S2[47:44];
                number2 <= S2[43:40];
                number1 <= S2[39:36];
                is1 <= 1;
                is2 <= 1;
                is3 <= 1;
                is4 <= 0;
                state <= 0;
            end
        end
        
        t1 = t1 + 1;
        
    end
end

endmodule