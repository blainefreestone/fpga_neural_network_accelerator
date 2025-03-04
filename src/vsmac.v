// vector scaler multiplier accumulator
module vsmac #(
    parameter SIZE = 6,             // determines the number of inputs (and in turn the number of MACs)
    parameter WIDTH = 8,            // determines the width of the inputs
    parameter ACCUMULATIONS = 3,    // determines the number of accumulations it will perform before signalling done
    parameter INT_BITS = 2          // determines the number of integer bits in the inputs
) (
    input wire reset, clk, enable,
    input wire [WIDTH * SIZE-1:0] a,
    input wire [WIDTH - 1:0] b,
    output reg [WIDTH * SIZE-1:0] out
);

    wire signed [WIDTH * SIZE-1:0] cur_out;    // wire to connect MAC outputs to output register

    // generate SIZE MACs
    genvar i;
    generate
        for (i = 0; i < SIZE; i = i + 1) begin : mac_gen
            mac #(
                .WIDTH(WIDTH),
                .ACCUMULATIONS(ACCUMULATIONS),
                .INT_BITS(INT_BITS)
            ) mac_i (
                .reset(reset),
                .clk(clk),
                .enable(enable),
                .a(a[WIDTH * i +: WIDTH]),  // slice a
                .b(b),                      // b is common to all MACs
                .out(cur_out[WIDTH * i +: WIDTH])   // slice out
            );
        end
    endgenerate

    always @(negedge clk or posedge reset) begin
        if (reset) begin
            out <= 0;
        end else if (enable) begin
            out <= cur_out;
        end
    end
endmodule