`timescale 1ns/1ps

module MEM_WB_Reg(
    input clock,
    input RegWrite,
    input MemToReg,
    input [31:0] Read_Mem_Data,
    input [31:0] PcNxt_AluRes_Mux,
    input [4:0] WriteReg,
    
    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg [31:0] Read_Mem_Data_out,
    output reg [31:0] PcNxt_AluRes_Mux_out,
    output reg [4:0] WriteReg_out
);

initial begin
    RegWrite_out = 0;
    MemToReg_out = 0;
    Read_Mem_Data_out = 0;
    PcNxt_AluRes_Mux_out = 0;
    WriteReg_out = 5'b00000;
end

always @(posedge clock) begin
    RegWrite_out <= RegWrite;
    MemToReg_out <= MemToReg;
    Read_Mem_Data_out <= Read_Mem_Data;
    PcNxt_AluRes_Mux_out <= PcNxt_AluRes_Mux;
    WriteReg_out <= WriteReg;
end

endmodule