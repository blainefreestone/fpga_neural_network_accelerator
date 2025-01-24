// multiplier accumulator
module mac #(
    parameter WIDTH = 8,            // determines the width of the inputs
    parameter ACCUMULATIONS = 3     // determines the number of accumulations will fit in the output (in the worst case)
) (
    input wire reset, clk, enable,
    input wire [WIDTH - 1:0] a, b,
    output reg [WIDTH + $clog2(ACCUMULATIONS) - 1:0] out    // the output width is the sum of the input widths plus extra bits for accumulations
);
    reg [2 * WIDTH:0] product_reg;      // stores the product of a and b

    always @(posedge clk or posedge reset) begin
        if (reset) begin        // reset the output and the product register
            product_reg <= 0;
            out <= 0;
        end else if (enable) begin          // calculate the product and add it to the existing output
            product_reg  <= a * b;
            out <= out + product_reg;
        end
    end

endmodule