// multiplier accumulator
module mac #(
    parameter WIDTH = 8,            // determines the width of the inputs
    parameter ACCUMULATIONS = 3     // determines the number of accumulations will fit in the output (in the worst case)
) (
    input wire reset, clk, enable,
    input wire [WIDTH - 1:0] a, b,
    output reg [WIDTH - 1:0] out    // the output width is the sum of the input widths plus extra bits for accumulations
);
    wire [2 * WIDTH:0] product;                                  // stores the product of a and b
    reg [2 * WIDTH + $clog2(ACCUMULATIONS) - 1:0] sum_reg;          // stores the output of the sum
    wire [2 * WIDTH + $clog2(ACCUMULATIONS) - 1:0] quantize_in;     // wire to connect quantizer input to the output register
    wire [WIDTH - 1:0] quantize_out;                                // wire to connect quantizer output to the output register

    // calculate the product of a and b
    assign product = a * b;

    // connect quantizer input to the sum
    assign quantize_in = sum_reg;
    
    // instantiate the quantizer
    quantize #(
        .WIDTH_IN(2 * WIDTH + $clog2(ACCUMULATIONS)),
        .WIDTH_OUT(WIDTH)
    ) quantizer (
        .in(quantize_in),
        .out(quantize_out)
    );

    // sequential logic for accumulation and output
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset the output and the product register
            sum_reg <= 0;
            out <= 0;
        end else if (enable) begin
            // calculate the product and add it to the existing output
            sum_reg <= sum_reg + product;
            // quantize the output
            out <= quantize_out;
        end
    end

endmodule