`timescale 1ns/1ps

module IF_ID_stateReg(
    input clock,
    input IF_ID_Write,          // Control signal from hazard detection unit
    input [31:0] curPC,
    input [31:0] nxtPC,
    input [31:0] instruc,
    output reg [31:0] curPC_out,        
    output reg [31:0] nxtPC_out,        
    output reg [31:0] instruc_out       
);

initial begin
    curPC_out = 0; 
    nxtPC_out = 0; 
    instruc_out = 0;
end

always @(posedge clock) begin
    if (IF_ID_Write) begin  // Only update when IF_ID_Write is high
        curPC_out <= curPC;
        nxtPC_out <= nxtPC;
        instruc_out <= instruc;
    end
    // When IF_ID_Write is low (stall), keep previous values
end

endmodule
