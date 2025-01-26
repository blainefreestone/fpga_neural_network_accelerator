// quantize
module quantize #(
    parameter WIDTH_IN = 8,
    parameter WIDTH_OUT = 8
) (
    input wire [WIDTH_IN - 1:0] in,
    output wire [WIDTH_OUT - 1:0] out
);
    assign out = in[WIDTH_OUT - 1:0];     // truncate the input to the output width by keeping the least significant bits

endmodule