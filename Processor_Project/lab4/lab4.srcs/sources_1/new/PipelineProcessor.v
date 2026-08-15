`timescale 1ns / 1ps

module PipelineProcessor(
    input clk,
    input reset
);

    // IF Stage signals
    wire [31:0] PC_cs, PC_ns, PC_plus4, PC_branch;
    wire [31:0] Inst;
    wire PCSrc;
    
    // IF/ID Pipeline Register signals
    wire [31:0] IFID_PC_out, IFID_PC_plus4_out, IFID_Inst_out;
    
    // ID Stage signals
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] imm_extended;
    wire Branch, MemRead, MemWrite, ALUSrc, RegWrite, MemToReg, if_Jump;
    wire [1:0] ALUOp;
    
    // ID/EX Pipeline Register signals
    wire [31:0] IDEX_PC_out, IDEX_PC_plus4_out;
    wire IDEX_RegWrite_out, IDEX_MemToReg_out, IDEX_Branch_out;
    wire IDEX_MemRead_out, IDEX_MemWrite_out, IDEX_ALUSrc_out, IDEX_if_Jump_out;
    wire [1:0] IDEX_ALUOp_out;
    wire [31:0] IDEX_imm_out, IDEX_rs1_data_out, IDEX_rs2_data_out;
    wire [3:0] IDEX_func_out;
    wire [6:0] IDEX_opcode_out;  // Opcode output signal
    wire [4:0] IDEX_rd_addr_out;
    
    // EX Stage signals
    wire [31:0] ALU_input1, ALU_input2, ALU_result;
    wire [3:0] ALU_control;
    wire Zero;
    wire [31:0] EX_result_mux_out;  // EX stage MUX output
    
    // Forwarding Unit signals
    wire [1:0] data_hazard_A, data_hazard_B;
    wire [4:0] IDEX_rs1_addr_out, IDEX_rs2_addr_out;
    
    // EX/MEM Pipeline Register signals
    wire EXMEM_RegWrite_out, EXMEM_MemToReg_out, EXMEM_Branch_out;
    wire EXMEM_MemRead_out, EXMEM_MemWrite_out, EXMEM_if_Jump_out;
    wire [31:0] EXMEM_PC_branch_out, EXMEM_PC_plus4_out;
    wire EXMEM_Zero_out;
    wire [31:0] EXMEM_ALU_result_out, EXMEM_rs2_data_out;
    wire [4:0] EXMEM_rd_addr_out;
    wire [4:0] EXMEM_rs2_addr_out;  // Add rs2 address output
    wire [2:0] EXMEM_func3_out;
    
    // MEM Stage signals
    wire [31:0] mem_read_data;
    wire branch_result;
    reg branch_condition;  
    
    // MEM/WB Pipeline Register signals
    wire MEMWB_RegWrite_out, MEMWB_MemToReg_out;
    wire [31:0] MEMWB_mem_data_out, MEMWB_ALU_result_out;
    wire [4:0] MEMWB_rd_addr_out;
    
    // WB Stage signals
    wire [31:0] rd_write_data;
    
    // Hazard Detection signals
    wire Hazard, PCWRITE, IF_ID_Write;
    
    // Control Hazard signals
    wire branch_taken, IF_Flush;
    wire ctrl_IF_ID_Write;  // Control hazard IF_ID_Write signal
    wire load_IF_ID_Write;  // Load hazard IF_ID_Write signal
    wire final_IF_ID_Write; // Final combined IF_ID_Write signal
    
    // PC Logic
    reg [31:0] PC_reg;
    assign PC_cs = PC_reg;
    
    // Branch/Jump target address calculation in ID stage
    wire [31:0] PC_branch_target;
    wire [31:0] mux_jump_input;
    
    // JALR detection signal
    wire is_jalr_id;
    
    // MUX to select between PC (for JAL/Branch) or rs1 (for JALR)
    mux mux_jump_base(
        .input1(IFID_PC_out),     // JAL/Branch: use PC
        .input2(rs1_data),        // JALR: use rs1
        .sel(is_jalr_id),
        .result(mux_jump_input)
    );
    
    // Single adder for all branch/jump target calculations
    AddSum branch_jump_adder(
        .input1(mux_jump_input),  // PC for JAL/Branch, rs1 for JALR
        .input2(imm_extended),    // immediate value
        .result(PC_branch_target)
    );
    
    // PC selection logic: use calculated target for jumps/branches
    assign PC_branch = PC_branch_target;
    
    initial begin
        PC_reg = 32'h00000000;
    end
    
    always @(posedge clk) begin
        if (reset)
            PC_reg <= 32'h00000000;
        else if (PCWRITE) begin  // Only update PC when PCWRITE is high
            PC_reg <= PC_ns;
        end
        // When PCWRITE is low (stall), keep current PC value
    end
    
    // ==================== IF Stage ====================
    
    // PC Adder - single adder for PC+4
    // assign PC_plus4 = PC_cs + 32'd4;
    mux Mux_IF(
        .input1(PC_plus4),
        .input2(PC_branch),
        .sel(PCSrc),
        .result(PC_ns)
    );

    AddSum Adder_IF(
        .input1(PC_cs),
        .input2(32'd4),
        .result(PC_plus4)
    );
    
    // Instruction Memory
    InstructionMemory InstMem (
        .pc(PC_cs),
        .instruction(Inst)
    );
    
    // ==================== IF/ID Pipeline Register ====================
    
    IF_ID_stateReg IFID_Reg (
        .clock(clk),
        .IF_ID_Write(final_IF_ID_Write),
        .curPC(PC_cs),
        .nxtPC(PC_plus4),
        .instruc(IF_Flush ? 32'h00000013 : Inst), // Insert NOP when flushing
        .curPC_out(IFID_PC_out),
        .nxtPC_out(IFID_PC_plus4_out),
        .instruc_out(IFID_Inst_out)
    );
    
    // ==================== ID Stage ====================
    
    // Control Unit
    Control_instruction_1_6 Ctrl (
        .opcode(IFID_Inst_out[6:0]),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .if_Jump(if_Jump),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .is_jalr(is_jalr_id)
    );
    
    // Register File
    wire [31:0] rs1_data_raw;
    RegFile RF (
        .clk(clk),
        .rs1_addr(IFID_Inst_out[19:15]),
        .rs2_addr(IFID_Inst_out[24:20]),
        .rd_addr(MEMWB_rd_addr_out),
        .write_data(rd_write_data),
        .reg_write(MEMWB_RegWrite_out),
        .rs1_data(rs1_data_raw),
        .rs2_data(rs2_data)
    );
    
    // JALR前递逻辑 - 使用合并后的Forwarding_unit
    wire [31:0] jalr_rs1_data;
    assign rs1_data = jalr_rs1_data;
    
    // Immediate Generator
    ImmGen IG (
        .input_instr(IFID_Inst_out),
        .output_instr(imm_extended)
    );
    
    // Branch condition evaluation (in ID stage)
    satisfy_branch branch_eval (
        .RegRes1(rs1_data),
        .RegRes2(rs2_data),
        .ins_30_14_12({IFID_Inst_out[30], IFID_Inst_out[14:12]}),
        .aluop(ALUOp),
        .if_Jump(if_Jump),
        .branch_taken(branch_taken)
    );
    
    // Control Hazard Detection
    Control_Hazard ctrl_hazard (
        .clk(clk),
        .branch_taken(branch_taken),
        .Branch(Branch),
        .if_Jump(if_Jump),
        .ID_opcode(IFID_Inst_out[6:0]),      // Current instruction opcode in ID stage
        .EX_opcode(IDEX_opcode_out),         // Next instruction opcode in EX stage
        .EX_if_Jump(IDEX_if_Jump_out),       // Jump signal from EX stage
        .IF_Flush(IF_Flush),
        .PCSrc(PCSrc),
        .IF_ID_Write(ctrl_IF_ID_Write)
    );
    
    // Data Hazard Detection Unit (Load-Use hazard)
    Data_Hazard_Control Hazard_Unit (
        .ID_EX_RegRd(IDEX_rd_addr_out),
        .ID_EX_MemRead(IDEX_MemRead_out),
        .EX_MEM_RegRd(EXMEM_rd_addr_out),
        .EX_MEM_MemRead(EXMEM_MemRead_out),
        .Rs1_Rd(IFID_Inst_out[19:15]),
        .Rs2_Rd(IFID_Inst_out[24:20]),
        .IsBranch(Branch),
        .Hazard(Hazard),
        .PCWRITE(PCWRITE),
        .IF_ID_Write(load_IF_ID_Write)
    );
    
    // Combine IF_ID_Write signals: both control and load hazard must allow writes
    assign final_IF_ID_Write = ctrl_IF_ID_Write & load_IF_ID_Write;
    
    // ==================== ID/EX Pipeline Register ====================
    
    ID_EX_REG IDEX_Reg (
        .clock(clk),
        .curPC(IFID_PC_out),
        .nxtPC(IFID_PC_plus4_out),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ALUOP(ALUOp),
        .if_Jump(if_Jump),
        .ImmGen_res(imm_extended),
        .ins_30_14_12({IFID_Inst_out[30], IFID_Inst_out[14:12]}),
        .opcode(IFID_Inst_out[6:0]),  // Pass opcode
        .writeReg_idx(IFID_Inst_out[11:7]),
        .ReadData1(rs1_data),
        .ReadData2(rs2_data),
        .RegisterRs1(IFID_Inst_out[19:15]),
        .RegisterRs2(IFID_Inst_out[24:20]),
        
        .curPC_out(IDEX_PC_out),
        .nxtPC_out(IDEX_PC_plus4_out),
        .RegWrite_out(IDEX_RegWrite_out),
        .MemToReg_out(IDEX_MemToReg_out),
        .Branch_out(IDEX_Branch_out),
        .MemRead_out(IDEX_MemRead_out),
        .MemWrite_out(IDEX_MemWrite_out),
        .ALUSrc_out(IDEX_ALUSrc_out),
        .ALUOP_out(IDEX_ALUOp_out),
        .if_Jump_out(IDEX_if_Jump_out),
        .ImmGen_res_out(IDEX_imm_out),
        .ins_30_14_12_out(IDEX_func_out),
        .opcode_out(IDEX_opcode_out),  // Receive opcode output
        .writeReg_idx_out(IDEX_rd_addr_out),
        .ReadData1_out(IDEX_rs1_data_out),
        .ReadData2_out(IDEX_rs2_data_out),
        .RegisterRs1_out(IDEX_rs1_addr_out),
        .RegisterRs2_out(IDEX_rs2_addr_out)
    );
    
    // ==================== EX Stage ====================
    
    // Forwarding Unit (合并后的版本)
    Forwarding_unit FU (
        // 原有接口 - 用于EX阶段ALU前递
        .EX_MEM_RegWrite(EXMEM_RegWrite_out),
        .MEM_WB_RegWrite(MEMWB_RegWrite_out),
        .EX_MEM_RegRd(EXMEM_rd_addr_out),
        .MEM_WB_RegRd(MEMWB_rd_addr_out),
        .ID_EX_RegRs1(IDEX_rs1_addr_out),
        .ID_EX_RegRs2(IDEX_rs2_addr_out),
        .data_hazard_A(data_hazard_A),
        .data_hazard_B(data_hazard_B),
        
        // 新增接口 - 用于ID阶段JALR前递
        .ifid_inst(IFID_Inst_out),
        .idex_opcode(IDEX_opcode_out),
        .idex_rd_addr(IDEX_rd_addr_out),
        .idex_pc_plus4(IDEX_PC_plus4_out),
        .exmem_if_jump(EXMEM_if_Jump_out),
        .exmem_rd_addr(EXMEM_rd_addr_out),
        .exmem_pc_plus4(EXMEM_PC_plus4_out),
        .rs1_data_raw(rs1_data_raw),
        .rs1_data(jalr_rs1_data)
    );
    
    // Forwarding Mux for ALU input A (rs1)
    Mux_double mux_forward_A (
        .input1(IDEX_rs1_data_out),      // 00: no forwarding
        .input2(rd_write_data),          // 01: forward from MEM/WB
        .input3(EXMEM_ALU_result_out),   // 10: forward from EX/MEM
        .sel(data_hazard_A),
        .res_sel(ALU_input1)
    );
    
    // Forwarding Mux for ALU input B (rs2 or immediate)
    wire [31:0] ALU_input2_forwarded;
    Mux_double mux_forward_B (
        .input1(IDEX_rs2_data_out),      // 00: no forwarding
        .input2(rd_write_data),          // 01: forward from MEM/WB
        .input3(EXMEM_ALU_result_out),   // 10: forward from EX/MEM
        .sel(data_hazard_B),
        .res_sel(ALU_input2_forwarded)
    );
    
    // EX stage writeback data MUX: select PC+4 for JAL/JALR, ALU result for other instructions
    mux mux_EX_result(
        .input1(ALU_result),
        .input2(IDEX_PC_plus4_out),
        .sel(IDEX_if_Jump_out),
        .result(EX_result_mux_out)
    );
    
    // ALU Input B Mux (select between forwarded rs2 or immediate)
    mux Muxdata(
        .input1(ALU_input2_forwarded),   // Use forwarded rs2 data
        .input2(IDEX_imm_out),
        .result(ALU_input2),
        .sel(IDEX_ALUSrc_out)
    );
    
    // ALU Control
    ALU_control ALU_Ctrl (
        .ALUOP(IDEX_ALUOp_out),
        .i_30(IDEX_func_out[3]),
        .func3(IDEX_func_out[2:0]),
        .alu_control(ALU_control)
    );
    
    // ALU
    ALU ALU_Unit (
        .input_data1(ALU_input1),        // Use forwarded data
        .input_data2(ALU_input2),
        .alu_control_sig(ALU_control),
        .result(ALU_result),
        .zero_flag(Zero)
    );
    
    // ==================== EX/MEM Pipeline Register ====================
    
    Reg_Ex_Mem EXMEM_Reg (
        .clock(clk),
        .RegWrite(IDEX_RegWrite_out),
        .MemToReg(IDEX_MemToReg_out),
        .Branch(IDEX_Branch_out),
        .MemRead(IDEX_MemRead_out),
        .MemWrite(IDEX_MemWrite_out),
        .if_Jump(IDEX_if_Jump_out),
        .NxtPC(IDEX_PC_plus4_out),
        .PC_RES_MUX(32'h0),  // Not used anymore since jump/branch address calculated in ID stage
        .if_zero(Zero),
        .ALU_Res(EX_result_mux_out),  // Use EX stage MUX output
        .ReadData2(ALU_input2_forwarded),  // Use forwarded rs2 data for store instructions
        .WriReg(IDEX_rd_addr_out),
        .func3(IDEX_func_out[2:0]),
        .RegRs2(IDEX_rs2_addr_out),  // rs2 address input (last input)
        
        .RegWrite_out(EXMEM_RegWrite_out),
        .RegRs2_out(EXMEM_rs2_addr_out),  // rs2 address output (second output)
        .MemToReg_out(EXMEM_MemToReg_out),
        .Branch_out(EXMEM_Branch_out),
        .MemRead_out(EXMEM_MemRead_out),
        .MemWrite_out(EXMEM_MemWrite_out),
        .if_Jump_out(EXMEM_if_Jump_out),
        .NxtPC_out(EXMEM_PC_plus4_out),
        .PC_RES_MUX_out(EXMEM_PC_branch_out),
        .if_zero_out(EXMEM_Zero_out),
        .ALU_Res_out(EXMEM_ALU_result_out),
        .ReadData2_out(EXMEM_rs2_data_out),
        .WriReg_out(EXMEM_rd_addr_out),
        .func3_out(EXMEM_func3_out)
    );
    
    // ==================== MEM Stage ====================
    
    // Memory Address Hazard Detection and Forwarding
    wire mem_forward_select;
    wire [31:0] mem_forwarded_data;
    wire load_to_store_forward;
    wire [31:0] load_forwarded_data;
    
    Memory_Address_Hazard mem_hazard_unit (
        // Store-Load Forwarding (MEM to MEM)
        .prev_mem_addr(32'h0),           
        .curr_mem_addr(EXMEM_ALU_result_out),
        .prev_write_data(32'h0),         
        .prev_mem_write(1'b0),           
        .curr_mem_read(EXMEM_MemRead_out),
        
        // Load-Store Forwarding (MEM to EX)
        .mem_wb_mem_data(MEMWB_mem_data_out),
        .mem_wb_rd(MEMWB_rd_addr_out),
        .mem_wb_mem_to_reg(MEMWB_MemToReg_out),
        .mem_wb_reg_write(MEMWB_RegWrite_out),
        .ex_mem_rs2(EXMEM_rs2_addr_out),  // Use actual rs2 address
        .ex_mem_mem_write(EXMEM_MemWrite_out),
        
        .MemSrc(mem_forward_select),
        .forwarded_data(mem_forwarded_data),
        .LoadToStoreForward(load_to_store_forward),
        .load_forwarded_data(load_forwarded_data)
    );
    
    // Data Memory with Load-Store Forwarding
    wire [31:0] store_data_final;
    
    // MUX to select store data: use forwarded load data or normal rs2 data
    mux mux_store_data(
        .input1(EXMEM_rs2_data_out),     // Normal rs2 data
        .input2(load_forwarded_data),    // Forwarded load data
        .sel(load_to_store_forward),
        .result(store_data_final)
    );
    
    DataMemory DataMem (
        .clk(clk),
        .addr(EXMEM_ALU_result_out),
        .write_data(store_data_final),    // Use forwarded store data
        .mem_read(EXMEM_MemRead_out),
        .mem_write(EXMEM_MemWrite_out),
        .func3(EXMEM_func3_out),
        .read_data(mem_read_data)
    );

    // MEM stage writeback data selection: Jump instructions select PC+4, others select ALU result
    wire [31:0] MEM_writedata_out;
    mux mux_MEM(
        .input1(EXMEM_ALU_result_out),
        .input2(EXMEM_PC_plus4_out),
        .sel(EXMEM_if_Jump_out),
        .result(MEM_writedata_out)
    );
    
    // ==================== MEM/WB Pipeline Register ====================
    
    MEM_WB_Reg MEMWB_Reg (
        .clock(clk),
        .RegWrite(EXMEM_RegWrite_out),
        .MemToReg(EXMEM_MemToReg_out),
        .Read_Mem_Data(mem_read_data),         // Use original memory data
        .PcNxt_AluRes_Mux(MEM_writedata_out),  // Use MEM stage MUX output
        .WriteReg(EXMEM_rd_addr_out),
        
        .RegWrite_out(MEMWB_RegWrite_out),
        .MemToReg_out(MEMWB_MemToReg_out),
        .Read_Mem_Data_out(MEMWB_mem_data_out),
        .PcNxt_AluRes_Mux_out(MEMWB_ALU_result_out),
        .WriteReg_out(MEMWB_rd_addr_out)
    );
    
    // ==================== WB Stage ====================
    
    // Write Back Mux
    mux mux_WB(
        .input1(MEMWB_ALU_result_out),     // MemToReg=0: select ALU result
        .input2(MEMWB_mem_data_out),       // MemToReg=1: select memory data
        .sel(MEMWB_MemToReg_out),
        .result(rd_write_data)
    );

endmodule
