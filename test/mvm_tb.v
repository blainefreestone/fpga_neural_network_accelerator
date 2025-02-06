`timescale 1ns / 1ps

module test_mvm;

    // Parameters
    localparam MATRIX_ROWS = 3;
    localparam SHARED_DIM = 3;
    localparam WIDTH = 8;

    // Inputs
    reg clk;
    reg reset;
    reg start;
    reg [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] matrix;
    reg [SHARED_DIM * WIDTH - 1:0] vector;

    // Outputs
    wire [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] result_vector;

    // Instantiate the Unit Under Test (UUT)
    mvm #(
        .MATRIX_ROWS(MATRIX_ROWS),
        .SHARED_DIM(SHARED_DIM),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .matrix(matrix),
        .vector(vector),
        .result_vector(result_vector)
    );

    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        start = 0;
        matrix = 0;
        vector = 0;

        // Wait for global reset
        #110;

        // Test 1: State machine test
        reset = 1;
        #10;
        reset = 0;
        matrix = 72'h010203040506070809;
        vector = 24'h010203;
        start = 1;
        #100;
        $finish;
    end

endmodule