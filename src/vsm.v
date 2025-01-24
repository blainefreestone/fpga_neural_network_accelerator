// vector scaler multiplier
module vsm #(
    parameter SIZE = 6,
    parameter WIDTH = 8,
    parameter ACCUMULATIONS = 3
) (
    input wire reset, clk, enable,
    input wire [8 * SIZE-1:0] a,
    input wire [7:0] b,
    output reg [8 * SIZE-1:0] out
);

    wire [8 * SIZE-1:0] cur_out;

    genvar i;
    generate
        for (i = 0; i < SIZE; i = i + 1) begin : mac_gen
            mac #(
                .WIDTH(WIDTH),
                .ACCUMULATIONS(ACCUMULATIONS)
            ) mac_i (
                .reset(reset),
                .clk(clk),
                .enable(enable),
                .a(a[8 * i +: 8]),
                .b(b),
                .out(cur_out[8 * i +: 8])
            );
        end
    endgenerate

    always @(negedge clk or negedge reset) begin
        if (reset) begin
            out <= 0;
        end else if (enable) begin
            out <= cur_out;
        end
    end
    
endmodule