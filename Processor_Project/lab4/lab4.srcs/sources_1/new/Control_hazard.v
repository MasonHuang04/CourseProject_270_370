`timescale 1ns/1ps

module Control_Hazard(
    input clk,                   // Add clock input for state tracking
    input branch_taken,          // Input from satisfy_branch module
    input Branch,                // Branch signal from control unit
    input if_Jump,               // Jump signal from control unit
    input [6:0] ID_opcode,       // Current instruction opcode in ID stage
    input [6:0] EX_opcode,       // Next instruction opcode in EX stage
    input EX_if_Jump,            // Jump signal from EX stage
    output reg IF_Flush,         // Flush IF/ID pipeline register (synchronous)
    output reg PCSrc,            // PC source selection (1: branch/jump target, 0: PC+4)
    output reg IF_ID_Write       // Control IF/ID register write (0: stall, 1: normal)
);

    reg branch_taken_prev;       // Track previous branch state
    
    // Detect if this is a new jump instruction (different from what's in EX stage)
    // or if no jump is currently in EX stage
    wire is_new_jump_sequence = !EX_if_Jump || (ID_opcode != EX_opcode);
    
    initial begin
        branch_taken_prev = 1'b0;
    end
    
    always @(posedge clk) begin
        branch_taken_prev <= (Branch && branch_taken) || if_Jump;
   end

    always @(*) begin
        // Default values - normal operation
        IF_Flush = 1'b0;
        PCSrc = 1'b0;
        IF_ID_Write = 1'b1;
        
        // Check if branch is taken or jump instruction
        if ((Branch && branch_taken) || if_Jump) begin
            // Branch taken or unconditional jump
            if (!branch_taken_prev || is_new_jump_sequence) begin
                // Allow jump if: 
                // 1. No previous jump was taken, OR
                // 2. This is a new jump sequence (different instruction or no jump in EX)
                IF_Flush = 1'b1;        // Flush the IF/ID pipeline register
                PCSrc = 1'b1;           // Select branch/jump target as next PC
                IF_ID_Write = 1'b0;     // Prevent IF/ID register update (insert bubble)
            end else begin
                // Subsequent cycles of same jump sequence - resume normal operation
                IF_Flush = 1'b0;
                PCSrc = 1'b0;
                IF_ID_Write = 1'b1;
            end
        end
    end

endmodule
