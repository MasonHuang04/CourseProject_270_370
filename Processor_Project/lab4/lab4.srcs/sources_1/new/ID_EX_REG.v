`timescale 1ns/1ps

module ID_EX_REG(
    input clock,
    input [31:0] curPC,
    input [31:0] nxtPC,
    input RegWrite,
    input MemToReg,
    input Branch,
    input MemRead,
    input MemWrite,
    input ALUSrc,
    input [1:0] ALUOP,
    input if_Jump,
    input [31:0] ImmGen_res,
    input [3:0] ins_30_14_12,
    input [6:0] opcode,  // add opcode input
    input [4:0] writeReg_idx,
    input [31:0] ReadData1,
    input [31:0] ReadData2,
    input [4:0] RegisterRs1,
    input [4:0] RegisterRs2,
    
    
    output reg [31:0] curPC_out,
    output reg [31:0] nxtPC_out,
    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg Branch_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg ALUSrc_out,
    output reg [1:0] ALUOP_out,
    output reg if_Jump_out,
    output reg [31:0] ImmGen_res_out,
    output reg [3:0] ins_30_14_12_out,
    output reg [6:0] opcode_out,  // add opcode output
    output reg [4:0] writeReg_idx_out,
    output reg [31:0] ReadData1_out,
    output reg [31:0] ReadData2_out,
    output reg [4:0] RegisterRs1_out,
    output reg [4:0] RegisterRs2_out
);

initial begin
    curPC_out = 0;
    nxtPC_out = 0;
    RegWrite_out = 0;
    MemToReg_out = 0;
    Branch_out = 0;
    MemRead_out = 0;
    MemWrite_out = 0;
    ALUSrc_out = 0;
    ALUOP_out = 2'b00;
    if_Jump_out = 0;
    ImmGen_res_out = 0;
    ins_30_14_12_out = 4'b0000;
    opcode_out = 7'b0000000;  // Initialize opcode output
    writeReg_idx_out = 5'b00000;
    ReadData1_out = 0;
    ReadData2_out = 0;
    RegisterRs1_out = 5'b00000;  // Initialize RegisterRs1_out
    RegisterRs2_out = 5'b00000;  // Initialize RegisterRs2_out
end

always @(posedge clock) begin
    curPC_out <= curPC;
    nxtPC_out <= nxtPC;
    RegWrite_out <= RegWrite;
    MemToReg_out <= MemToReg;
    Branch_out <= Branch;
    MemRead_out <= MemRead;
    MemWrite_out <= MemWrite;
    ALUSrc_out <= ALUSrc;
    ALUOP_out <= ALUOP;
    if_Jump_out <= if_Jump;
    ImmGen_res_out <= ImmGen_res;
    ins_30_14_12_out <= ins_30_14_12;
    opcode_out <= opcode;  // Pass opcode
    writeReg_idx_out <= writeReg_idx;
    ReadData1_out <= ReadData1;
    ReadData2_out <= ReadData2;
    RegisterRs1_out <= RegisterRs1;  // Assign RegisterRs1
    RegisterRs2_out <= RegisterRs2;  // Assign RegisterRs2
end

endmodule