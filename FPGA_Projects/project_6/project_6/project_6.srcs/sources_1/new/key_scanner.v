// Register module with proper load control
module register(
    input wire clk,
    input wire load,
    input reset,
    input wire [3:0] d,
    output reg [3:0] q
);
initial q = 4'b0;
always @(posedge clk, posedge reset) begin
    if(reset) q<=0;
    else
        if(load) q <= d;
        else q <= q;
    // else no need to do anything
end

endmodule


// SSD module for displaying digits
module SSD(
    input [3:0] hex_in,
    output reg [6:0] ssd_out
);

always @(hex_in) begin
    case (hex_in)
//        4'b0000: ssd_out = 7'b0000110; // 0
//        4'b0001: ssd_out = 7'b0001111; // 1
//        4'b0010: ssd_out = 7'b1100000; // 2
//        4'b0011: ssd_out = 7'b0111000; // 3
//        4'b0100: ssd_out = 7'b0010010; // 4
//        4'b0101: ssd_out = 7'b0100000; // 5
//        4'b0110: ssd_out = 7'b0001000; // 6
//        4'b0111: ssd_out = 7'b0110000; // 7
//        4'b1000: ssd_out = 7'b1001111; // 8
//        4'b1001: ssd_out = 7'b0100100; // 9
//        4'b1010: ssd_out = 7'b0000100; // A
//        4'b1011: ssd_out = 7'b1000010; // B
//        4'b1100: ssd_out = 7'b0000001; // C
//        4'b1101: ssd_out = 7'b1001100; // D
//        4'b1110: ssd_out = 7'b0000000; // E
//        4'b1111: ssd_out = 7'b0110001; // F
        
        4'b0000: ssd_out = 7'b0000001; // 0
        4'b0100: ssd_out = 7'b1001111; // 1
        4'b1000: ssd_out = 7'b0010010; // 2
        4'b1100: ssd_out = 7'b0000110; // 3
        4'b0001: ssd_out = 7'b1001100; // 4
        4'b0101: ssd_out = 7'b0100100; // 5
        4'b1001: ssd_out = 7'b0100000; // 6
        4'b1101: ssd_out = 7'b0001111; // 7
        4'b0010: ssd_out = 7'b0000000; // 8
        4'b0110: ssd_out = 7'b0000100; // 9
        4'b1010: ssd_out = 7'b0001000; // A
        4'b1110: ssd_out = 7'b1100000; // B
        4'b0011: ssd_out = 7'b0110001; // C
        4'b0111: ssd_out = 7'b1000010; // D
        4'b1011: ssd_out = 7'b0110000; // E
        4'b1111: ssd_out = 7'b0111000; // F
        default: ssd_out = 7'b1111111; // blank
    endcase
end

endmodule


// Scanner module for handling keypad scan and register load
module scanner(
    input wire clk,
    input wire reset,
    input wire [3:0] row,
    output reg [3:0] col,
    output wire [3:0] anode,
    output wire [6:0] ssd_out
);

reg [3:0] state;
reg [3:0] code;
wire clock;

// Generate a stable clock signal 



parameter STATE0 = 4'b0000,
          STATE1 = 4'b0001,
          STATE2 = 4'b0010,
          STATE3 = 4'b0011,
          STATE4 = 4'b0100,
          STATE5 = 4'b0101,
          STATE6 = 4'b0110,
          STATE7 = 4'b0111,
          STATE8 = 4'b1000,
          STATE9 = 4'b1001;

// Next state logic and state anode
reg reg_load;
reg [3:0] next_state;

initial begin
    state = STATE0;
    reg_load = 0;
end
clock_divider cd(clk,reset,clock);
// State update logic
always @(posedge clock or posedge reset) begin
    if (reset)
        state <= STATE0;
    else
        state <= next_state;
end

// State transition and output logic
always @(*) begin
    case (state)
        STATE0: begin
            col = 4'b1111;
            if (|row)
                next_state = STATE1;
            else
                next_state = STATE0;
        end
        STATE1: begin
            col = 4'b0001;
            if (|row) next_state = STATE5;
            else next_state = STATE2;
        end
        STATE2: begin
            col = 4'b0010;
            if (|row) next_state = STATE6;
            else next_state = STATE3;
        end
        STATE3: begin
            col = 4'b0100;
            if (|row) next_state = STATE7;
            else next_state = STATE4;
        end
        STATE4: begin
            col = 4'b1000;
            if (|row) next_state = STATE8;
            else next_state = STATE0;
        end
        STATE5: begin
            col = 4'b0001;
            case (row)
                4'b0001 : code <= 4'b0000;
                4'b0010 : code <= 4'b0100;
                4'b0100 : code <= 4'b1000;
                4'b1000 : code <= 4'b1100;
            endcase
            reg_load = 1;
            next_state = STATE9;
        end      
        STATE6: begin
            col = 4'b0010;
            case (row)
                4'b0001 : code <= 4'b0001;
                4'b0010 : code <= 4'b0101;
                4'b0100 : code <= 4'b1001;
                4'b1000 : code <= 4'b1101;
            endcase
            reg_load = 1;
            next_state = STATE9;
        end
        STATE7: begin
            col = 4'b0100;
            case (row)
                4'b0001 : code <= 4'b0010;
                4'b0010 : code <= 4'b0110;
                4'b0100 : code <= 4'b1010;
                4'b1000 : code <= 4'b1110;
            endcase
            reg_load = 1;
            next_state = STATE9;
        end
        STATE8: begin
            col = 4'b1000;
            case (row)
                4'b0001 : code <= 4'b0011;
                4'b0010 : code <= 4'b0111;
                4'b0100 : code <= 4'b1011;
                4'b1000 : code <= 4'b1111;
            endcase
            reg_load = 1;
            next_state = STATE9;
        end
        STATE9: begin
            col = 4'b1111;
            reg_load = 0;
            if ((!(|row)))
                next_state = STATE0;
            else
                next_state = STATE9;
        end
        default: next_state = STATE0;
    endcase
end

// Instantiate the register and SSD modules
wire [3:0] q;

register R (clk, reg_load, reset, code, q);   // Register to store code
SSD S (q, ssd_out);                     // SSD to display the value

assign anode = 4'b1110;  // Display anode control (which display is active)

endmodule
