module vsm #(
    SIZE = 6
) (
    input wire clk,
    input wire reset,
    input wire [8 * SIZE-1:0] a,
    input wire [7:0] b,
    output wire [8 * SIZE-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < SIZE; i = i + 1) begin : mac_gen
            mac mac_i (
                .reset(reset),
                .clk(clk),
                .a(a[8 * i +: 8]),
                .b(b),
                .out(out[8 * i +: 8])
            );
        end
    endgenerate
    
endmodule