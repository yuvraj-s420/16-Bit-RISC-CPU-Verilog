`timescale 1ns / 1ps

module ALU_tb();

reg signed [15:0] a, b;
wire signed [15:0] out;
reg [2:0] alu_op;
wire overflow, zero;

ALU U1(.alu_OP(alu_op), .in1(a), .in2(b), .out(out), .overflow_f(overflow), .zero_f(zero));

initial begin 

    // Test regular
    a = 16'd255;     // 255
    b = -16'd12;     // -12
    
    alu_op = 3'b001;
    repeat (7) begin
        #10 $display("alu_op: %d, \tout: %d \t z_flag: %d \t overflow_flag: %d", alu_op, out, zero, overflow);
        alu_op = alu_op + 1;
    end
    #10
    
    // Test zero flag
    a = 16'd1000;     
    b = 16'd1000;    
    alu_op = 3'b001;
    repeat (7) begin
        #10 $display("alu_op: %d, \tout: %d \t z_flag: %d \t overflow_flag: %d", alu_op, out, zero, overflow);
        alu_op = alu_op + 1;
    end
    #10
    
    // Test overflow
    a = 16'h7FFF;
    b = 16'h7FFF;
    alu_op = 3'b001;
    repeat (7) begin
        #10 $display("alu_op: %d, \tout: %d \t z_flag: %d \t overflow_flag: %d", alu_op, out, zero, overflow);
        alu_op = alu_op + 1;
    end
    #10
    
    #10 $finish;
end


endmodule
