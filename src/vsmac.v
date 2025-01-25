// vector scaler multiplier accumulator
module vsmac #(
    parameter SIZE = 6,
    parameter WIDTH = 8,
    parameter ACCUMULATIONS = 3
) (
    input wire reset, clk, enable,
    input wire [8 * SIZE-1:0] a,
    input wire [7:0] b,
    output reg [8 * SIZE-1:0] out,
    output wire done
);

    wire [8 * SIZE-1:0] cur_out;
    reg [$clog2(ACCUMULATIONS * 2) - 1:0] accumulation_counter;

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
            accumulation_counter <= 0;
        end else if (enable) begin
            accumulation_counter <= accumulation_counter + 1;
            out <= cur_out;
        end
    end

    assign done = (accumulation_counter == ACCUMULATIONS * 2 - 1);
    
endmodule