`timescale 1ns/1ps

module Forwarding_unit (
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    input [4:0] EX_MEM_RegRd,
    input [4:0] MEM_WB_RegRd,
    input [4:0] ID_EX_RegRs1,
    input [4:0] ID_EX_RegRs2,
    output reg [1:0] data_hazard_A,
    output reg [1:0] data_hazard_B,
    input [31:0] ifid_inst,
    input [6:0] idex_opcode,
    input [4:0] idex_rd_addr,
    input [31:0] idex_pc_plus4,
    input exmem_if_jump,
    input [4:0] exmem_rd_addr,
    input [31:0] exmem_pc_plus4,
    input [31:0] rs1_data_raw,
    output [31:0] rs1_data
);

    // JALR前递逻辑
    wire is_jalr;
    wire ex_jal_hazard;
    wire mem_jal_hazard;
    wire [4:0] rs1_addr;
    
    assign rs1_addr = ifid_inst[19:15];
    assign is_jalr = (ifid_inst[6:0] == 7'b1100111);
    assign ex_jal_hazard = (idex_opcode == 7'b1101111) && (idex_rd_addr == rs1_addr) && (idex_rd_addr != 5'd0) && is_jalr;
    assign mem_jal_hazard = exmem_if_jump && (exmem_rd_addr == rs1_addr) && (exmem_rd_addr != 5'd0) && is_jalr;
    
    assign rs1_data = ex_jal_hazard ? idex_pc_plus4 :
                     mem_jal_hazard ? exmem_pc_plus4 :
                     rs1_data_raw;

    always @(*) begin
        // Default values - no forwarding
        data_hazard_A = 2'b00;
        data_hazard_B = 2'b00;
        
        // ForwardA logic
        // EX hazard for Rs1
        if (EX_MEM_RegWrite && (EX_MEM_RegRd != 5'b00000) && (EX_MEM_RegRd == ID_EX_RegRs1)) begin
            data_hazard_A = 2'b10;
        end
        // MEM hazard for Rs1 (not EX hazard)
        else if (MEM_WB_RegWrite && (MEM_WB_RegRd != 5'b00000) && (MEM_WB_RegRd == ID_EX_RegRs1) && !((EX_MEM_RegWrite && (EX_MEM_RegRd != 5'b00000) && (EX_MEM_RegRd == ID_EX_RegRs1)))) begin
            data_hazard_A = 2'b01;
        end
        
        // ForwardB logic  
        // EX hazard for Rs2
        if (EX_MEM_RegWrite && (EX_MEM_RegRd != 5'b00000) && (EX_MEM_RegRd == ID_EX_RegRs2)) begin
            data_hazard_B = 2'b10;
        end
        // MEM hazard for Rs2 (not EX hazard)
        else if (MEM_WB_RegWrite && (MEM_WB_RegRd != 5'b00000) && (MEM_WB_RegRd == ID_EX_RegRs2) && !((EX_MEM_RegWrite && (EX_MEM_RegRd != 5'b00000) && (EX_MEM_RegRd == ID_EX_RegRs2)))) begin
            data_hazard_B = 2'b01;
        end
    end

endmodule
