`timescale 1ns / 1ps

module ImmGen(
    input [31:0] input_instr,
    output reg [31:0] output_instr
);

    wire [6:0] opcode;
    assign opcode = input_instr[6:0];

    always @(*) begin
        case (opcode)
            7'b0000011: begin // I-type: Load instructions
                output_instr = {{20{input_instr[31]}}, input_instr[31:20]};
            end
            7'b0010011: begin // I-type: Immediate arithmetic
                output_instr = {{20{input_instr[31]}}, input_instr[31:20]};
            end
            7'b0100011: begin // S-type: Store instructions
                output_instr = {{20{input_instr[31]}}, input_instr[31:25], input_instr[11:7]};
            end
            7'b0110011: begin // R-type: Register operations
                output_instr = 32'h00000000; // No immediate
            end
            7'b1100011: begin // B-type: Branch instructions
                // B-type immediate format with imm[0]=0
                output_instr = {{20{input_instr[31]}}, input_instr[7], input_instr[30:25], input_instr[11:8], 1'b0};
            end
            7'b1100111: begin // I-type: JALR instruction
                output_instr = {{20{input_instr[31]}}, input_instr[31:20]};
            end
            7'b1101111: begin // J-type: JAL instruction
                // J-type immediate format
                output_instr = {{12{input_instr[31]}}, input_instr[19:12], input_instr[20], input_instr[30:21], 1'b0};
            end
            default: begin
                output_instr = 32'h00000000;
            end        
        endcase
    end
endmodule