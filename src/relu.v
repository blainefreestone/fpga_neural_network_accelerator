module relu #(
    parameter WIDTH = 8 // Parameter to define the width of the input and output
) (
    input wire signed [WIDTH - 1:0] in, // Signed input with defined width
    output wire signed [WIDTH - 1:0] out // Signed output with defined width
);
    assign out = (in > 0) ? in : 0; // If input is greater than 0, output is input; otherwise, output is 0
endmodule