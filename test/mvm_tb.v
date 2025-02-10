`timescale 1ns / 1ps

module test_mvm;

    // Parameters for different sizes
    localparam MATRIX_ROWS_1 = 3;
    localparam SHARED_DIM_1 = 3;
    localparam WIDTH_1 = 8;

    localparam MATRIX_ROWS_2 = 6;
    localparam SHARED_DIM_2 = 3;
    localparam WIDTH_2 = 8;

    // Inputs
    reg clk;
    reg reset;
    reg start;
    reg [MATRIX_ROWS_1 * SHARED_DIM_1 * WIDTH_1 - 1:0] matrix_1;
    reg [SHARED_DIM_1 * WIDTH_1 - 1:0] vector_1;
    reg [MATRIX_ROWS_2 * SHARED_DIM_2 * WIDTH_2 - 1:0] matrix_2;
    reg [SHARED_DIM_2 * WIDTH_2 - 1:0] vector_2;

    // Outputs
    wire [MATRIX_ROWS_1 * WIDTH_1 - 1:0] result_vector_1;
    wire [MATRIX_ROWS_2 * WIDTH_2 - 1:0] result_vector_2;

    // Instantiate the Unit Under Test (UUT) for size 1
    mvm #(
        .MATRIX_ROWS(MATRIX_ROWS_1),
        .SHARED_DIM(SHARED_DIM_1),
        .WIDTH(WIDTH_1)
    ) uut_1 (
        .clk(clk),
        .reset(reset),
        .start(start),
        .matrix(matrix_1),
        .vector(vector_1),
        .result_vector(result_vector_1)
    );

    // Instantiate the Unit Under Test (UUT) for size 2
    mvm #(
        .MATRIX_ROWS(MATRIX_ROWS_2),
        .SHARED_DIM(SHARED_DIM_2),
        .WIDTH(WIDTH_2)
    ) uut_2 (
        .clk(clk),
        .reset(reset),
        .start(start),
        .matrix(matrix_2),
        .vector(vector_2),
        .result_vector(result_vector_2)
    );

    always #5 clk = ~clk;

    // Test cases for size 1
    reg [MATRIX_ROWS_1 * SHARED_DIM_1 * WIDTH_1 - 1:0] test_matrices_1 [0:2];
    reg [SHARED_DIM_1 * WIDTH_1 - 1:0] test_vectors_1 [0:2];
    reg [MATRIX_ROWS_1 * WIDTH_1 - 1:0] expected_results_1 [0:2];

    // Test cases for size 2
    reg [MATRIX_ROWS_2 * SHARED_DIM_2 * WIDTH_2 - 1:0] test_matrices_2 [0:2];
    reg [SHARED_DIM_2 * WIDTH_2 - 1:0] test_vectors_2 [0:2];
    reg [MATRIX_ROWS_2 * WIDTH_2 - 1:0] expected_results_2 [0:2];

    integer i;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        start = 0;
        matrix_1 = 0;
        vector_1 = 0;
        matrix_2 = 0;
        vector_2 = 0;

        // Test Cases for size 1:
        // Test 0: No Overflow
        test_matrices_1[0] = 72'h010203040506070809;
        test_vectors_1[0] = 24'h010203;
        expected_results_1[0] = 24'h0E2032;

        // Test 1: Almost Overflow
        test_matrices_1[1] = 72'h0A0B0C0D0E0F101111;
        test_vectors_1[1] = 24'h040506;
        expected_results_1[1] = 24'hA7D4FB;
        
        // Test 2: Overflow
//        test_matrices[2] = 72'h131415161718191A1B;
//        test_vectors[2] = 24'h070809;
//        expected_results[2] = 24'hC4C6C8;

        // Test Cases for size 2
        test_matrices_2[0] = 144'h0102030405060708090A0B0C0D0E0F101112;
        test_vectors_2[0] = 32'h010203;
        expected_results_2[0] = 48'h0E2032445668;

        // Wait for global reset
        #115;

        // Run tests for size 1
        for (i = 0; i < 3; i = i + 1) begin
            // Apply test case
            reset = 1;
            #10;
            reset = 0;
            matrix_1 = test_matrices_1[i];
            vector_1 = test_vectors_1[i];
            start = 1;
            #10;
            start = 0;
            #55;

            // Check result
            if (result_vector_1 !== expected_results_1[i]) begin
                $display("Test %0d for size 1 failed: expected %h, got %h", i, expected_results_1[i], result_vector_1);
            end else begin
                $display("Test %0d for size 1 passed: expected %h, got %h", i, expected_results_1[i], result_vector_1);
            end

            #5;
        end

        // Run tests for size 2
        for (i = 0; i < 3; i = i + 1) begin
            // Apply test case
            reset = 1;
            #10;
            reset = 0;
            matrix_2 = test_matrices_2[i];
            vector_2 = test_vectors_2[i];
            start = 1;
            #10;
            start = 0;
            #55;

            // Check result
            if (result_vector_2 !== expected_results_2[i]) begin
                $display("Test %0d for size 2 failed: expected %h, got %h", i, expected_results_2[i], result_vector_2);
            end else begin
                $display("Test %0d for size 2 passed: expected %h, got %h", i, expected_results_2[i], result_vector_2);
            end

            #5;
        end

        $finish;
    end

endmodule