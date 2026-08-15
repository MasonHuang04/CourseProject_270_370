`timescale 1ns / 1ps

module Control_instruction_1_6(
    input [6:0] opcode,
    output reg Branch, MemRead, MemWrite, ALUSrc, if_Jump, RegWrite, MemToReg,
    output reg [1:0] ALUOp,
    output reg is_jalr
);

    always @(*) begin
        // Default values
        Branch = 0;
        MemToReg = 0;
        RegWrite = 0;
        MemRead = 0;
        MemWrite = 0;
        ALUSrc = 0;
        if_Jump = 0;
        ALUOp = 2'b00;
        is_jalr = 0;
        
        case (opcode)
            //I-type,load
            7'b0000011: begin Branch = 0; ALUSrc = 1; ALUOp = 2'b00; MemWrite = 0; MemRead = 1; MemToReg = 1; if_Jump = 0; RegWrite = 1; is_jalr = 0; end 
            //I-type,Imm
            7'b0010011: begin Branch = 0; ALUSrc = 1; ALUOp = 2'b11; MemWrite = 0; MemRead = 0; MemToReg = 0; if_Jump = 0; RegWrite = 1; is_jalr = 0; end 
            //S-type,save
            7'b0100011: begin Branch = 0; ALUSrc = 1; ALUOp = 2'b00; MemWrite = 1; MemRead = 0; MemToReg = 0; if_Jump = 0; RegWrite = 0; is_jalr = 0; end 
//          7'b0110111: 
            //R-type,calc
            7'b0110011: begin Branch = 0; ALUSrc = 0; ALUOp = 2'b10; MemWrite = 0; MemRead = 0; MemToReg = 0; if_Jump = 0; RegWrite = 1; is_jalr = 0; end 
            //B-type,brnch
            7'b1100011: begin Branch = 1; ALUSrc = 0; ALUOp = 2'b01; MemWrite = 0; MemRead = 0; MemToReg = 0; if_Jump = 0; RegWrite = 0; is_jalr = 0; end 
            //I-type,jalr
            7'b1100111: begin Branch = 0; ALUSrc = 1; ALUOp = 2'b00; MemWrite = 0; MemRead = 0; MemToReg = 0; if_Jump = 1; RegWrite = 1; is_jalr = 1; end 
            //J-type,jal
            7'b1101111: begin Branch = 0; ALUSrc = 0; ALUOp = 2'b00; MemWrite = 0; MemRead = 0; MemToReg = 0; if_Jump = 1; RegWrite = 1; is_jalr = 0; end 
            default:    begin Branch = 0; ALUSrc = 0; ALUOp = 2'b00; MemWrite = 0; MemRead = 0; MemToReg = 0; if_Jump = 0; RegWrite = 0; is_jalr = 0; end 
        endcase 
    end
endmodule