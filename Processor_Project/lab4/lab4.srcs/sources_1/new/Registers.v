// Register file module
module RegFile (
    input clk,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr,         // WB writeback target address
    input [31:0] write_data,     // WB writeback data
    input reg_write,             // WB write enable
    output [31:0] rs1_data,
    output [31:0] rs2_data
);

    reg [31:0] regs [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
        regs[2] = 32'h00000100;  // sp initial value
    end

    // Async write - immediate effect
    always @(*) begin
        if (reg_write && rd_addr != 0)
            regs[rd_addr] = write_data;
    end

    // Simplified async read
    assign rs1_data = (rs1_addr == 0) ? 32'b0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 32'b0 : regs[rs2_addr];

endmodule

module satisfy_branch (
    input [31:0] RegRes1,        // rs1 register data
    input [31:0] RegRes2,        // rs2 register data
    input [3:0] ins_30_14_12,    // instruction[30,14-12]
    input [1:0] aluop,           // ALU operation code
    input if_Jump,               // Jump instruction indicator (jal, jalr)
    output reg branch_taken
);

    always @(*) begin
        // Default: no branch taken
        branch_taken = 1'b0;
        
        // Check if it's a jump instruction (jal, jalr)
        if (if_Jump) begin
            branch_taken = 1'b1;  // Unconditional jump
        end
        // Check if it's a branch instruction (aluop == 2'b01 for branch)
        else if (aluop == 2'b01) begin
            case (ins_30_14_12[2:0])  // func3 = instruction[14:12]
                3'b000: begin // beq (branch if equal)
                    branch_taken = (RegRes1 == RegRes2);
                end
                3'b001: begin // bne (branch if not equal)
                    branch_taken = (RegRes1 != RegRes2);
                end
                3'b100: begin // blt (branch if less than, signed)
                    branch_taken = ($signed(RegRes1) < $signed(RegRes2));
                end
                3'b101: begin // bge (branch if greater than or equal, signed)
                    branch_taken = ($signed(RegRes1) >= $signed(RegRes2));
                end
                default: begin
                    branch_taken = 1'b0;
                end
            endcase
        end
    end

endmodule