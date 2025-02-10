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
    wire [MATRIX_ROWS * WIDTH - 1:0] result_vector;

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

    // Test cases
    reg [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] test_matrices [0:2];
    reg [SHARED_DIM * WIDTH - 1:0] test_vectors [0:2];
    reg [MATRIX_ROWS * WIDTH - 1:0] expected_results [0:2];
    integer i;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        start = 0;
        matrix = 0;
        vector = 0;
        
        // Test Cases:
        
        // Test 0: Basic
        test_matrices[0] = 72'h010203040506070809;
        test_vectors[0] = 24'h010203;
        expected_results[0] = 24'h0E2032;
        
        // Test 1: Almost Overflow
        test_matrices[1] = 72'h0A0B0C0D0E0F101111;
        test_vectors[1] = 24'h040506;
        expected_results[1] = 24'hA7D4FB;
        
        // Test 2: Overflow
//        test_matrices[2] = 72'h131415161718191A1B;
//        test_vectors[2] = 24'h070809;
//        expected_results[2] = 24'hC4C6C8;

        // Wait for global reset
        #115;
        
        for (i = 0; i < 3; i = i + 1) begin
            // Apply test case
            reset = 1;
            #10;
            reset = 0;
            matrix = test_matrices[i];
            vector = test_vectors[i];
            start = 1;
            #10;
            start = 0;
            #55;

            // Check result
            if (result_vector !== expected_results[i]) begin
                $display("Test %0d failed: expected %h, got %h", i, expected_results[i], result_vector);
            end else begin
                $display("Test %0d passed: expected %h, got %h", i, expected_results[i], result_vector);
            end

            #5;
        end

        $finish;
    end

endmodule