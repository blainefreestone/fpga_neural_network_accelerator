module mac (
    input reset, clk,
    input wire [7:0] a, b, 
    output reg [23:0] out
);
    reg [15:0] product_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            product_reg <= 16'b0;
            out <= 24'b0;
        end else begin
            product_reg  <= a * b;
            out <= out + product_reg;
        end
    end

endmodule