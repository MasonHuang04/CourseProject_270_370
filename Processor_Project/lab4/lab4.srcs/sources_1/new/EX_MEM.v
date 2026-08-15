`timescale 1ns/1ps

module Reg_Ex_Mem (
input clock,
    input RegWrite,
    input MemToReg,
    input Branch,
    input MemRead,
    input MemWrite,
    input if_Jump,
    input [31:0] NxtPC,
    input [31:0] PC_RES_MUX,
    input if_zero,
    input [31:0] ALU_Res,
    input [31:0] ReadData2,
    input [4:0] WriReg,
    input [2:0] func3,
    input [4:0] RegRs2,
    
    output reg RegWrite_out,
    output reg [4:0] RegRs2_out,
    output reg MemToReg_out,
    output reg Branch_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg if_Jump_out,
    output reg [31:0] NxtPC_out,
    output reg [31:0] PC_RES_MUX_out,
    output reg if_zero_out,
    output reg [31:0] ALU_Res_out,
    output reg [31:0] ReadData2_out,
    output reg [4:0] WriReg_out,
    output reg [2:0] func3_out
);
    initial begin
        RegWrite_out = 0;
        MemToReg_out = 0;
        Branch_out = 0;
        MemRead_out = 0;
        MemWrite_out = 0;
        if_Jump_out = 0;
        NxtPC_out = 0;
        PC_RES_MUX_out = 0;
        RegRs2_out = 5'b00000;
        if_zero_out = 0;
        ALU_Res_out = 0;
        ReadData2_out = 0;
        WriReg_out = 5'b00000;
        func3_out = 3'b000;
    end

    always @(posedge clock) begin
        RegWrite_out <= RegWrite;
        MemToReg_out <= MemToReg;
        Branch_out <= Branch;
        RegRs2_out <= RegRs2;
        MemRead_out <= MemRead;
        MemWrite_out <= MemWrite;
        if_Jump_out <= if_Jump;
        NxtPC_out <= NxtPC;
        PC_RES_MUX_out <= PC_RES_MUX;
        if_zero_out <= if_zero;
        ALU_Res_out <= ALU_Res;
        ReadData2_out <= ReadData2;
        WriReg_out <= WriReg;
        func3_out <= func3;
    end
endmodule