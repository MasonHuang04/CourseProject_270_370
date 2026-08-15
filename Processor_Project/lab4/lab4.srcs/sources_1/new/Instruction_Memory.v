`timescale 1ns / 1ps

module InstructionMemory (
    input [31:0] pc,            
    output [31:0] instruction 
);
    reg [7:0] rom[79:0];      // 20 instructions * 4 bytes = 80 bytes
    integer i;
    
    initial begin
        for(i=0;i<80;i=i+1)begin
            rom[i] = 8'b0000_0000;
        end
        // Lab4 test case instructions - directly from Lab4_testcase.txt
        {rom[3],rom[2],rom[1],rom[0]} = 32'b00111001100100000000001100010011;     // 0: addi t1 x0 0x399
        {rom[7],rom[6],rom[5],rom[4]} = 32'b00000000011000000010001000100011;     // 1: sw t1 4(x0)
        {rom[11],rom[10],rom[9],rom[8]} = 32'b00000000010000000000001010000011;    // 2: lb t0 4(x0)
        {rom[15],rom[14],rom[13],rom[12]} = 32'b00000000010100000010000000100011;   // 3: sw t0 0(x0)
        {rom[19],rom[18],rom[17],rom[16]} = 32'b00000010000000110000000001100011;   // 4: beq t1 x0 wrong_branch
        {rom[23],rom[22],rom[21],rom[20]} = 32'b00000000000000000010111000000011;   // 5: lw t3 0(x0)
        {rom[27],rom[26],rom[25],rom[24]} = 32'b00000001110000101001110001100011;   // 6: bne t0 t3 wrong_branch
        {rom[31],rom[30],rom[29],rom[28]} = 32'b00000001110000101000001110110011;   // 7: add t2 t0 t3
        {rom[35],rom[34],rom[33],rom[32]} = 32'b00000001110000111111001100110011;   // 8: and t1 t2 t3
        {rom[39],rom[38],rom[37],rom[36]} = 32'b00000000000000111111001100010011;   // 9: andi t1 t2 0
        {rom[43],rom[42],rom[41],rom[40]} = 32'b01000000000000110000001010110011;   // 10: sub t0 t1 x0
        {rom[47],rom[46],rom[45],rom[44]} = 32'b00000000011000101101010001100011;   // 11: bge t0 t1 right_branch
        {rom[51],rom[50],rom[49],rom[48]} = 32'b00000000000000000000001110110011;   // 12: add t2 x0 x0 (wrong_branch)
        {rom[55],rom[54],rom[53],rom[52]} = 32'b00000000110000000000000011101111;   // 13: jal x1 jump_test (right_branch)
        {rom[59],rom[58],rom[57],rom[56]} = 32'b00000001010000000000000011101111;   // 14: jal x1 Exit
        {rom[63],rom[62],rom[61],rom[60]} = 32'b00000000000000000000111000110011;   // 15: add t3 x0 x0
        {rom[67],rom[66],rom[65],rom[64]} = 32'b00000000011111100110111000110011;   // 16: or t3 t3 t2 (jump_test)
        {rom[71],rom[70],rom[69],rom[68]} = 32'b00000000000000001000000001100111;   // 17: jalr x0 x1 0
        {rom[75],rom[74],rom[73],rom[72]} = 32'b00000100100000000000001100010011;   // 18: addi t1 x0 0x48 (Exit)
        {rom[79],rom[78],rom[77],rom[76]} = 32'b00001010110000000000001010010011;   // 19: addi t0 x0 0xac
    end
    
    wire [31:0] word_addr;
    assign word_addr = pc; // PC is already word-aligned address
    
    // Add boundary check to prevent out-of-range access
    assign instruction = (word_addr < 80) ? {rom[word_addr+3], rom[word_addr+2], rom[word_addr+1], rom[word_addr]} : 32'h00000013; // Return NOP if out of range

endmodule
