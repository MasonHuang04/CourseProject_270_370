`timescale 1ns / 1ps

module Memory_Address_Hazard (
    // Store-Load Forwarding (MEM to MEM)
    input [31:0] prev_mem_addr,       // Previous instruction memory address
    input [31:0] curr_mem_addr,       // Current instruction memory address  
    input [31:0] prev_write_data,     // Previous instruction write data
    input prev_mem_write,             // Previous instruction was memory write
    input curr_mem_read,              // Current instruction is memory read
    
    // Load-Store Forwarding (MEM to EX)
    input [31:0] mem_wb_mem_data,     // Memory data from MEM/WB stage
    input [4:0] mem_wb_rd,            // Destination register from MEM/WB stage
    input mem_wb_mem_to_reg,          // MEM/WB stage is load instruction
    input mem_wb_reg_write,           // MEM/WB stage writes to register
    input [4:0] ex_mem_rs2,           // EX/MEM stage rs2 (for store instructions)
    input ex_mem_mem_write,           // EX/MEM stage is store instruction
    
    output MemSrc,                    // Select forwarded data for load
    output [31:0] forwarded_data,     // Forwarded write data
    output LoadToStoreForward,        // Load-to-store forwarding needed
    output [31:0] load_forwarded_data // Forwarded load data for store
);

    // Store-Load Forwarding (same address):
    // When store instruction writes to memory address X, and immediately 
    // following load instruction reads from the same address X
    assign MemSrc = prev_mem_write && curr_mem_read && 
                    (prev_mem_addr == curr_mem_addr);
    
    // Forward the store data to load
    assign forwarded_data = prev_write_data;

    // Load-Store Forwarding (load result to store source):
    // When load instruction writes to register R, and immediately
    // following store instruction reads from register R
    assign LoadToStoreForward = mem_wb_mem_to_reg && mem_wb_reg_write && 
                                ex_mem_mem_write && 
                                (mem_wb_rd == ex_mem_rs2) && 
                                (mem_wb_rd != 5'b00000);
    
    // Forward the load data to store
    assign load_forwarded_data = mem_wb_mem_data;

endmodule
