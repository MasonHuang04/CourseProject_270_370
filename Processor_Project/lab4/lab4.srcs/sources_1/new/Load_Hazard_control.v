`timescale 1ns/1ps

module Data_Hazard_Control(
    input[4:0] ID_EX_RegRd,
    input ID_EX_MemRead,
    input [4:0] EX_MEM_RegRd,
    input EX_MEM_MemRead,
    input [4:0] Rs1_Rd,
    input [4:0] Rs2_Rd,
    input IsBranch,  // Signal indicating if current instruction in ID stage is a branch
    output reg Hazard,
    output reg PCWRITE,
    output reg IF_ID_Write
);

    always @(*) begin
        // Default values - no hazard, allow normal operation
        Hazard = 1'b0;
        PCWRITE = 1'b1;      // PC can be written (updated)
        IF_ID_Write = 1'b1;  // IF/ID register can be written (updated)
        
        // Load-Use Hazard Detection
        // Check if there's a load instruction in EX stage (ID_EX_MemRead = 1)
        // and the destination register matches either source register
        if (ID_EX_MemRead && 
            ((ID_EX_RegRd == Rs1_Rd && Rs1_Rd != 5'b00000) || 
             (ID_EX_RegRd == Rs2_Rd && Rs2_Rd != 5'b00000))) begin
            
            // Hazard detected - stall the pipeline
            Hazard = 1'b1;
            PCWRITE = 1'b0;      // Prevent PC from updating (stall IF stage)
            IF_ID_Write = 1'b0;  // Prevent IF/ID register from updating (stall ID stage)
        end
        
        // Branch Hazard Detection
        // Check if current instruction is a branch and there's a data dependency
        // with load instructions in EX or MEM stage
        if (IsBranch) begin
            // Check dependency with load instruction in EX stage
            if (ID_EX_MemRead && 
                ((ID_EX_RegRd == Rs1_Rd && Rs1_Rd != 5'b00000) || 
                 (ID_EX_RegRd == Rs2_Rd && Rs2_Rd != 5'b00000))) begin
                
                // Branch-Load Hazard detected - stall the pipeline
                Hazard = 1'b1;
                PCWRITE = 1'b0;      // Prevent PC from updating (stall IF stage)
                IF_ID_Write = 1'b0;  // Prevent IF/ID register from updating (stall ID stage)
            end
            
            // Check dependency with load instruction in MEM stage
            else if (EX_MEM_MemRead && 
                     ((EX_MEM_RegRd == Rs1_Rd && Rs1_Rd != 5'b00000) || 
                      (EX_MEM_RegRd == Rs2_Rd && Rs2_Rd != 5'b00000))) begin
                
                // Branch-Load Hazard detected - stall the pipeline
                Hazard = 1'b1;
                PCWRITE = 1'b0;      // Prevent PC from updating (stall IF stage)
                IF_ID_Write = 1'b0;  // Prevent IF/ID register from updating (stall ID stage)
            end
        end
    end

endmodule