module MUX4_1(clk, A, B, C, D, S1, S0, out);

input clk, A, B, C, D, S1, S0;
output out;

always @ (posedge clk)      // At positive edge of clock
begin

    // 00 -> A, 01 -> B, 10 -> C, 11 -> D
    if (~S1 && ~S0) begin
        out <= A;
    end else if (~S1 && S0) begin
        out <= B;
    
    end else if (S1 && ~S0) begin
        oiut <= C;
    
    end else if (S1 && S0) begin
        out <= D;
    end

end

endmodule