`timescale 1ns / 1ps

module DataMemory(
    input clk,
    input [31:0] addr,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    input [2:0] func3,  // instruction[14:12] for memory operations
    output reg [31:0] read_data
);

    reg [7:0] regs [0:1023];  // Expand memory to 1024 bytes
    
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            regs[i] = 8'h00;
    end
    
    always @(posedge clk) begin
        if (mem_write) begin
            case(func3)
                3'b000: begin // sb (store byte)
                    regs[addr] <= write_data[7:0];
                end
                3'b010: begin // sw (store word)
                    regs[addr + 0] <= write_data[7:0];
                    regs[addr + 1] <= write_data[15:8];
                    regs[addr + 2] <= write_data[23:16];
                    regs[addr + 3] <= write_data[31:24];
                end
                default: begin // default to sw
                    regs[addr + 0] <= write_data[7:0];
                    regs[addr + 1] <= write_data[15:8];
                    regs[addr + 2] <= write_data[23:16];
                    regs[addr + 3] <= write_data[31:24];
                end
            endcase
        end
    end
    
    always @(*) begin
        if (mem_read) begin
            case(func3)
                3'b000: begin // lb (load byte, sign-extended)
                    read_data = {{24{regs[addr][7]}}, regs[addr]};
                end
                3'b010: begin // lw (load word)
                    read_data = {regs[addr + 3], regs[addr + 2], regs[addr + 1], regs[addr]};
                end
                3'b100: begin // lbu (load byte unsigned, zero-extended)
                    read_data = {24'h000000, regs[addr]};
                end
                default: begin // default to lw
                    read_data = {regs[addr + 3], regs[addr + 2], regs[addr + 1], regs[addr]};
                end
            endcase
        end else begin
            read_data = 32'h00000000;
        end
    end

endmodule

// module LW_SW_Hazard (
//     input [4:0] MWM_WB_Rd,
//     input [4:0] EX_MEM_Rs2,
//     input MEM_WB_MEMRead,
//     input EX_MEM_MemWrite,
//     output MemSrc
// );

//     // MemSrc = 1 when:
//     // (MEM/WB.Rd == EX/MEM.Rs2) and MEM/WB.MemRead and EX/MEM.MemWrite
//     assign MemSrc = (MWM_WB_Rd == EX_MEM_Rs2) && 
//                     (MWM_WB_Rd != 5'b00000) &&  // Don't forward for register x0
//                     MEM_WB_MEMRead && 
//                     EX_MEM_MemWrite;
    
// endmodule