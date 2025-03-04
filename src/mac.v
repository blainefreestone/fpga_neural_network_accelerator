// multiplier accumulator
module mac #(
    parameter WIDTH = 8,            // determines the width of the inputs
    parameter ACCUMULATIONS = 3,    // determines the number of accumulations that will fit in the output (in the worst case)
    parameter INT_BITS = 2
) (
    input wire reset, clk, enable,
    input wire signed [WIDTH - 1:0] a, b,
    output reg signed [WIDTH - 1:0] out    // the output width is the sum of the input widths plus extra bits for accumulations
);
    parameter FRAC_BITS = WIDTH - INT_BITS;
    wire signed [2 * WIDTH:0] product;                                  // stores the product of a and b
    reg signed [2 * WIDTH + $clog2(ACCUMULATIONS) - 1:0] sum_reg;       // stores the accumulated sum
    wire signed [WIDTH - 1:0] relu_out;                                 // wire to connect the relu output to the output register
    wire signed [2 * WIDTH + $clog2(ACCUMULATIONS) - 1:0] clamp_in;     // wire to connect clamp input to the sum_reg
    wire signed [WIDTH - 1:0] clamp_out;                                // wire to connect clamp output to the relu input

    assign product = (a * b) >>> FRAC_BITS;

    // connect clamp input to the sum
    assign clamp_in = sum_reg;

    // instantiate the clamp and relu modules
    clamp #(
        .WIDTH_IN(2 * WIDTH + $clog2(ACCUMULATIONS)),
        .WIDTH_OUT(WIDTH)
    ) clamp_inst (
        .in(clamp_in),
        .out(clamp_out)
    );

    relu #(
        .WIDTH(WIDTH)
    ) relu_inst (
        .in(clamp_out),
        .out(relu_out)
    );

    // sequential logic for accumulation and output
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset the accumulated sum and the output register
            sum_reg <= 0;
            out <= 0;
        end else if (enable) begin
            // calculate the product and add it to the existing sum
            sum_reg <= sum_reg + product;
            // pass the clamped output through the relu and assign to output
            out <= relu_out;
        end
    end

endmodule