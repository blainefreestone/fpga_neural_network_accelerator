`timescale 1ns/1ps

module mac_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg enable;
    reg signed [7:0] a;
    reg signed [7:0] b;
    wire signed [23:0] out;

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
        a = 8'sd15;
        b = 8'sd10;
        #10;

        // Test vector 2
        a = 8'sd25;
        b = 8'sd20;
        #10;

        // Test vector 3
        enable = 0; // Disable MAC
        a = 8'sd50;
        b = 8'sd30;
        #10;

        // Test vector 4
        enable = 1; // Enable MAC
        a = 8'sd100;
        b = 8'sd50;
        #10;

        // Apply reset
        reset = 1;
        a = 0;
        b = 0;
        #10;
        reset = 0;

        // Test vector 5
        enable = 1;
        a = 8'sd-100;
        b = 8'sd-50;
        #10;

        // Test vector 6
        a = 8'sd-128;
        b = 8'sd127;
        #10;

        // Apply reset
        reset = 0;

        // Finish simulation
        #100;
        $finish;
    end

    // Monitor the output
    initial begin
        $monitor("At time %t, a = %d, b = %d, out = %d, enable = %b", $time, a, b, out, enable);
    end

endmodule