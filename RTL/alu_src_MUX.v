module alu_src_MUX (
    
    input [15:0] Rs2_data,      // 2nd register input
    input [8:0] imm,            // Immediate from control unit
    input alu_src,              // Select signal

    // Output of MUX, second input to ALU
    output reg [15:0] out
);


    
endmodule