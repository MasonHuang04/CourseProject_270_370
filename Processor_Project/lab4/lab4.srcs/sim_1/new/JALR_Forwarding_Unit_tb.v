`timescale 1ns / 1ps

module JALR_Forwarding_Unit_tb;

    // Inputs
    reg [31:0] ifid_inst;
    reg [6:0] idex_opcode;
    reg [4:0] idex_rd_addr;
    reg [31:0] idex_pc_plus4;
    reg exmem_if_jump;
    reg [4:0] exmem_rd_addr;
    reg [31:0] exmem_pc_plus4;
    reg [31:0] rs1_data_raw;
    
    // Output
    wire [31:0] rs1_data;
    
    // Instantiate the Unit Under Test (UUT)
    JALR_Forwarding_Unit uut (
        .ifid_inst(ifid_inst),
        .idex_opcode(idex_opcode),
        .idex_rd_addr(idex_rd_addr),
        .idex_pc_plus4(idex_pc_plus4),
        .exmem_if_jump(exmem_if_jump),
        .exmem_rd_addr(exmem_rd_addr),
        .exmem_pc_plus4(exmem_pc_plus4),
        .rs1_data_raw(rs1_data_raw),
        .rs1_data(rs1_data)
    );
    
    // Clock generation
    reg clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end
    
    // Test procedure
    initial begin
        // Initialize Inputs
        ifid_inst = 0;
        idex_opcode = 0;
        idex_rd_addr = 0;
        idex_pc_plus4 = 0;
        exmem_if_jump = 0;
        exmem_rd_addr = 0;
        exmem_pc_plus4 = 0;
        rs1_data_raw = 0;
        
        // Wait for global reset
        #100;
        
        // ---- Test Case 1: No hazard, normal rs1_data ----
        $display("Test Case 1: No Hazard");
        ifid_inst = {12'b0, 5'd1, 3'b000, 5'd5, 7'b1100111}; // JALR with rs1=1
        idex_opcode = 7'b0110011; // Not a JAL
        idex_rd_addr = 5'd2;
        idex_pc_plus4 = 32'h1000;
        exmem_if_jump = 0;
        exmem_rd_addr = 5'd3;
        exmem_pc_plus4 = 32'h2000;
        rs1_data_raw = 32'hAABBCCDD;
        
        #10;
        $display("rs1_data = %h (expected: %h)", rs1_data, rs1_data_raw);
        
        // ---- Test Case 2: Hazard from EX stage JAL ----
        $display("Test Case 2: EX Stage JAL Hazard");
        ifid_inst = {12'b0, 5'd5, 3'b000, 5'd10, 7'b1100111}; // JALR with rs1=5
        idex_opcode = 7'b1101111; // JAL
        idex_rd_addr = 5'd5; // Writing to rs1 of JALR
        idex_pc_plus4 = 32'h3004;
        exmem_if_jump = 0;
        exmem_rd_addr = 5'd6;
        exmem_pc_plus4 = 32'h4000;
        rs1_data_raw = 32'h12345678;
        
        #10;
        $display("rs1_data = %h (expected: %h)", rs1_data, idex_pc_plus4);
        
        // ---- Test Case 3: Hazard from MEM stage JAL ----
        $display("Test Case 3: MEM Stage JAL Hazard");
        ifid_inst = {12'b0, 5'd6, 3'b000, 5'd10, 7'b1100111}; // JALR with rs1=6
        idex_opcode = 7'b0010011; // Not a JAL
        idex_rd_addr = 5'd7;
        idex_pc_plus4 = 32'h5000;
        exmem_if_jump = 1; // JAL in MEM stage
        exmem_rd_addr = 5'd6; // Writing to rs1 of JALR
        exmem_pc_plus4 = 32'h6004;
        rs1_data_raw = 32'h87654321;
        
        #10;
        $display("rs1_data = %h (expected: %h)", rs1_data, exmem_pc_plus4);
        
        // ---- Test Case 4: Not a JALR instruction ----
        $display("Test Case 4: Not a JALR Instruction");
        ifid_inst = {12'b0, 5'd6, 3'b000, 5'd10, 7'b0010011}; // ADDI, not JALR
        idex_opcode = 7'b1101111; // JAL
        idex_rd_addr = 5'd6;
        idex_pc_plus4 = 32'h7000;
        exmem_if_jump = 1; // JAL in MEM stage
        exmem_rd_addr = 5'd6;
        exmem_pc_plus4 = 32'h8000;
        rs1_data_raw = 32'hDEADBEEF;
        
        #10;
        $display("rs1_data = %h (expected: %h)", rs1_data, rs1_data_raw);
        
        // ---- Test Case 5: Register 0 as destination (no forwarding needed) ----
        $display("Test Case 5: Register 0 as Destination");
        ifid_inst = {12'b0, 5'd0, 3'b000, 5'd10, 7'b1100111}; // JALR with rs1=0
        idex_opcode = 7'b1101111; // JAL
        idex_rd_addr = 5'd0; // Writing to r0 (should be ignored)
        idex_pc_plus4 = 32'h9000;
        exmem_if_jump = 1; 
        exmem_rd_addr = 5'd0; // Writing to r0 (should be ignored)
        exmem_pc_plus4 = 32'hA000;
        rs1_data_raw = 32'h11223344;
        
        #10;
        $display("rs1_data = %h (expected: %h)", rs1_data, rs1_data_raw);
        
        // ---- Test Case 6: Multiple hazards (EX takes priority) ----
        $display("Test Case 6: Multiple Hazards (EX takes priority)");
        ifid_inst = {12'b0, 5'd8, 3'b000, 5'd10, 7'b1100111}; // JALR with rs1=8
        idex_opcode = 7'b1101111; // JAL
        idex_rd_addr = 5'd8; // Writing to rs1 of JALR
        idex_pc_plus4 = 32'hB004;
        exmem_if_jump = 1; // JAL in MEM stage
        exmem_rd_addr = 5'd8; // Writing to rs1 of JALR
        exmem_pc_plus4 = 32'hC004;
        rs1_data_raw = 32'h55667788;
        
        #10;
        $display("rs1_data = %h (expected: %h)", rs1_data, idex_pc_plus4);
        
        $finish;
    end

endmodule
