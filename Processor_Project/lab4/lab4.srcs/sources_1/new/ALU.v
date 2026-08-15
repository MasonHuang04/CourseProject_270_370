module ALU(
    input [31:0] input_data1,
    input [31:0] input_data2,
    input [3:0] alu_control_sig,
    output reg [31:0] result,
    output reg zero_flag
    );
    
always @(*) begin
    case (alu_control_sig)
        // SLL - shift left logical
        4'b0001: begin
            result = input_data1 << input_data2[4:0];
        end
        // ADD - arithmetic add
        4'b0010: begin
            result = input_data1 + input_data2;
        end
        // SRL - shift right logical
        4'b0101: begin
            result = input_data1 >> input_data2[4:0];
        end
        // OR - bitwise or
        4'b0110: begin
            result = input_data1 | input_data2;
        end
        // AND - bitwise and
        4'b0111: begin
            result = input_data1 & input_data2;
        end
        // SUB - for sub, beq comparison
        4'b1000: begin
            result = input_data1 - input_data2;
        end
        // SUB_NEQ - for bne comparison
        4'b1001: begin
            result = input_data1 - input_data2;
        end
        // SUB_BLT - for blt comparison
        4'b1100: begin
            result = input_data1 - input_data2;
        end
        // SRA - shift right arithmetic
        4'b1101: begin
            result = $signed(input_data1) >>> input_data2[4:0];
        end
        // SUB_BGE - for bge comparison
        4'b1110: begin
            result = input_data1 - input_data2;
        end
        default: begin
            result = 32'h00000000;
        end
    endcase
    
    // Zero flag logic based on operation type
    case (alu_control_sig)
        4'b1000: begin // beq: zero when equal
            zero_flag = (result == 32'h00000000) ? 1'b1 : 1'b0;
        end
        4'b1001: begin // bne: zero when not equal  
            zero_flag = (result == 32'h00000000) ? 1'b0 : 1'b1;
        end
        4'b1100: begin // blt: zero when rs1 < rs2
            zero_flag = ($signed(result) < 0) ? 1'b1 : 1'b0;
        end
        4'b1110: begin // bge: zero when rs1 >= rs2
            zero_flag = ($signed(result) >= 0) ? 1'b1 : 1'b0;
        end
        default: begin // All other operations
            zero_flag = 1'b0;
        end
    endcase
end

endmodule