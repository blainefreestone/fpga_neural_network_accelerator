`timescale 1ns/1ps

module mac_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg enable;
    reg signed [7:0] a;
    reg signed [7:0] b;
    wire signed [7:0] out;

    // Instantiate the MAC module
    mac uut (
        .reset(reset),
        .clk(clk),
        .enable(enable),
        .a(a),
        .b(b),
        .out(out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock period (10ns)
    end

    // Test procedure
    initial begin
        // Initialize inputs
        reset = 1;
        enable = 0;
        a = 0;
        b = 0;

        // Apply reset
        #10;
        reset = 0;

        // Test 1 (basic floating point multiplication and accumulation)
        // Test vector 1
        enable = 1;
        a = 8'sb00010101;   // 0.328125
        b = 8'sb00101010;   // 0.65625
        #10;

        // Test vector 2
        a = 8'sb00100001;   // 0.515625
        b = 8'sb00101010;   // 0.65625
        #10;

        // Test vector 3
        a = 8'sb00010000;   // 0.25
        b = 8'sb00101010;   // 0.65625
        $display("Test 1, Vector 1: output = %b, expected = 00001101, %s", out, (out == 8'sb00001101) ? "PASS" : "FAIL");

        #10;
        $display("Test 1, Vector 2: output = %b, expected = 00100010, %s", out, (out == 8'sb00100010) ? "PASS" : "FAIL");

        #10;
        $display("Test 1, Vector 3: output = %b, expected = 00101100, %s", out, (out == 8'sb00101100) ? "PASS" : "FAIL");

        // Apply reset
        #10;
        reset = 1;
        #10;
        reset = 0;

        // Test 2 (negative clamping)
        // Test vector 1
        a = 8'sb00001100;   // 0.1875
        b = 8'sb00000010;   // 0.03125
        #10;

        // Test vector 2
        a = 8'sb00001100;   // 0.1875
        b = 8'sb11000000;   // -1.0
        #10;

        // Test vector 3
        a = 8'sb00001100;   // 0.1875
        b = 8'sb01111111;   // 1.984375
        $display("Test 2, Vector 1: output = %b, expected = 00000000, %s", out, (out == 8'sb00000000) ? "PASS" : "FAIL");

        #10;
        $display("Test 2, Vector 2: output = %b, expected = 00000000, %s", out, (out == 8'sb00000000) ? "PASS" : "FAIL");

        #10;
        $display("Test 2, Vector 3: output = %b, expected = 00001011, %s", out, (out == 8'sb00001011) ? "PASS" : "FAIL");

        // Apply reset
        #10;
        reset = 1;
        #10;
        reset = 0;

        // Test 3 (positive clamping)
        // Test vector 1, 2, and 3
        a = 8'sb01000000;   // 1.0
        b = 8'sb00110000;   // 0.75
        #10;

        #10;

        $display("Test 3, Vector 1: output = %b, expected = 00110000, %s", out, (out == 8'sb00110000) ? "PASS" : "FAIL");
        #10;

        $display("Test 3, Vector 2: output = %b, expected = 01100000, %s", out, (out == 8'sb01100000) ? "PASS" : "FAIL");
        #10;

        $display("Test 3, Vector 3: output = %b, expected = 01111111, %s", out, (out == 8'sb01111111) ? "PASS" : "FAIL");

        // Finish simulation
        $finish;
    end

endmodule