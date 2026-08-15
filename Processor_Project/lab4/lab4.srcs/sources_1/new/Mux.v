module mux (
    
    input [31:0] input1,
    input [31:0] input2,
    input sel,
    output [31:0] result
);
    assign result = sel ? input2 : input1;
endmodule

module Mux_double (
    input [31:0] input1,
    input [31:0] input2,
    input [31:0] input3,
    input[1:0] sel,
    output reg [31:0] res_sel
);

    always @(*) begin
       case (sel)
        2'b00: res_sel = input1;
        2'b01: res_sel = input2;
        2'b10: res_sel = input3;
        default: res_sel = input1;
       endcase 
    end
    
endmodule