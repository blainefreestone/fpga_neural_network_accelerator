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

        // Test vector 1
        enable = 1;
        a = 8'sd1;
        b = 8'sd5;
        #10;

        // Test vector 2
        a = 8'sd4;
        b = 8'sd10;
        #10;

        // Test vector 3
        a = 8'sd12;
        b = 8'sd2;
        #10;

        // Test vector 4
        a = 8'sd2;
        b = 8'sd3;
        #20;
        enable = 0;
        #40;
        reset = 1;
        #10;
        reset = 0;

        // Test vector 5
        enable = 1;
        a = 8'sd1;
        b = -8'sd1;
        #10

        a = -8'sd1;
        b = 8'sd1;
        #10;

        a = -8'sd1;
        b = -8'sd2;
        #10;

        a = -8'sd20;
        b = 8'sd2;
        #10;

        a = -8'sd7;
        b = -8'sd2;
        #20;
        enable = 0;
        #40;
        reset = 1;
        #10;
        reset = 0;
        #10;

        // Finish simulation
        $finish;
    end

    // Monitor the output
    initial begin
        $monitor("At time %t, a = %d, b = %d, out = %d, enable = %b", $time, a, b, out, enable);
    end

endmodule