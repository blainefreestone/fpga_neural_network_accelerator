module clamp #(
    parameter WIDTH_IN = 8, // Width of the input signal
    parameter WIDTH_OUT = 8 // Width of the output signal
) (
    input wire signed [WIDTH_IN - 1:0] in, // Signed input signal
    output reg signed [WIDTH_OUT - 1:0] out // Signed output signal
);
    
    localparam T_MAX = (1 << (WIDTH_OUT - 1)) - 1; // Maximum value for the output signal
    localparam T_MIN = -T_MAX - 1; // Minimum value for the output signal

    always @* begin
        if (in > T_MAX) begin
            out = T_MAX; // Clamp the output to T_MAX if input is greater
        end else if (in < T_MIN) begin
            out = T_MIN; // Clamp the output to T_MIN if input is lesser
        end else begin
            out = in; // Pass the input to output if within range
        end
    end
endmodule