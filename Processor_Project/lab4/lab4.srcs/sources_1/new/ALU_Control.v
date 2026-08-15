`timescale 1ns / 1ps

module ALU_control(
    input [1:0] ALUOP,
    input i_30,
    input [2:0] func3,
    output reg [3:0] alu_control
);
    
    // ALU Control Signals:
    // 0001: SLL, 0010: ADD, 0101: SRL, 0110: OR, 0111: AND
    // 1000: SUB, 1001: sub_neq, 1100: sub_blt, 1101: SRA, 1110: sub_bge
    
    always @(*) begin
        case(ALUOP)
            2'b00: alu_control = 4'b0010; // load, store, jal: add
            2'b01: begin // Branch instructions
                case(func3)
                    3'b000: alu_control = 4'b1000; // beq: subtract
                    3'b001: alu_control = 4'b1001; // bne: sub_neq
                    3'b100: alu_control = 4'b1100; // blt: sub_blt
                    3'b101: alu_control = 4'b1110; // bge: sub_bge
                    default: alu_control = 4'b1000; // default subtract
                endcase
            end
            2'b10: begin // R-type instructions
                case(func3)
                    3'b000: alu_control = (i_30) ? 4'b1000 : 4'b0010; // sub/add
                    3'b001: alu_control = 4'b0001; // sll
                    3'b101: alu_control = (i_30) ? 4'b1101 : 4'b0101; // sra/srl
                    3'b110: alu_control = 4'b0110; // or
                    3'b111: alu_control = 4'b0111; // and
                    default: alu_control = 4'b0010; // default add
                endcase
            end
            2'b11: begin // I-type instructions
                case(func3)
                    3'b000: alu_control = 4'b0010; // addi/jalr: add
                    3'b001: alu_control = 4'b0001; // slli: shift left
                    3'b101: alu_control = (i_30) ? 4'b1101 : 4'b0101; // srai/srli
                    3'b110: alu_control = 4'b0110; // ori: or
                    3'b111: alu_control = 4'b0111; // andi: and
                    default: alu_control = 4'b0010; // default add
                endcase
            end
            default: alu_control = 4'b0010;
        endcase
    end
endmodule