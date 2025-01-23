`timescale 1ns/1ps

module mac_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg [7:0] a;
    reg [7:0] b;
    wire [23:0] out;

    // Instantiate the MAC module
    mac uut (
        .reset(reset),
        .clk(clk),
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
        a = 0;
        b = 0;

        // Apply reset
        #10;
        reset = 0;

        // Test vector 1
        a = 8'd15;
        b = 8'd10;
        #10;

        // Test vector 2
        a = 8'd25;
        b = 8'd20;
        #10;

        // Test vector 3
        a = 8'd50;
        b = 8'd30;
        #10;

        // Test vector 4
        a = 8'd100;
        b = 8'd50;
        #10;

        // Apply reset
        reset = 1;
        a = 0;
        b = 0;
        #10;
        reset = 0;

        // Test vector 5
        a = 8'd200;
        b = 8'd100;
        #10;

        // Test vector 6
        a = 8'd255;
        b = 8'd200;
        #10;

        // Apply reset
        reset = 0;

        // Finish simulation
        #100;
        $finish;
    end

    // Monitor the output
    initial begin
        $monitor("At time %t, a = %d, b = %d, out = %d", $time, a, b, out);
    end

endmodule
