module ShiftR(
    input clk,
    input clear,
    input enable,
    reg [15:0] data
)

always @ (posedge clk) begin

    if (clear) begin
        data <= 16'b0;              // Clear contents of register
    end

    if (toggle) begin
        data <= data >> 1;          // Shift right
    end

end
endmodule


module ShiftL(
    input clk,
    input clear,
    input enable,
    reg [15:0] data
)

always @ (posedge clk) begin

    if (clear) begin
        data <= 16'b0;              // Clear contents of register
    end

    if (toggle) begin
        data <= data << 1;          // Shift left
    end

end
endmodule