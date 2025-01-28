`timescale 1ns / 1ps

module test_vsmac;

    // Parameters
    localparam SIZE = 3;
    localparam WIDTH = 16;

    // Inputs
    reg clk;
    reg reset;
    reg enable;
    reg [8 * SIZE-1:0] a;
    reg [7:0] b;

    // Outputs
    wire [8 * SIZE-1:0] out;

    // Instantiate the Unit Under Test (UUT)
    vsmac #(
        .SIZE(SIZE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .a(a),
        .b(b),
        .out(out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        enable = 0;
        a = 0;
        b = 0;

        // Wait for global reset
        #110;
        
        // Test 1: 3 vectors, with enable
        // Test vector 1 (with reset)
        // vector = [0x01, 0x04, 0x07]
        // scalar = 0x01
        // output should be [0x01, 0x04, 0x07]
        reset = 1;
        #10;
        reset = 0;
        enable = 1;
        a = 24'h010407;
        b = 8'h01;
        #10;
        
        // Test vector 2 (with accumulation)
        // vector = [0x02, 0x05, 0x08]
        // scalar = 0x02
        // output should be [0x05, 0x0E, 0x17]
        a = 24'h020508;
        b = 8'h02;
        #10;

        // Test vector 3 (with accumulation)
        // vector = [0x03, 0x06, 0x09]
        // scalar = 0x03
        // output should be [0x0E, 0x20, 0x32]
        a = 24'h030609;
        b = 8'h03;
        #10;
        $display("Test 1, Vector 1: output = %h, expected = 010407, %s", out, (out == 24'h010407) ? "PASS" : "FAIL");
        
        // wait for propogation delay
        a = 0;
        b = 0;
        #10

        $display("Test 2, Vector 2: output = %h, expected = 050E17, %s", out, (out == 24'h050E17) ? "PASS" : "FAIL");

        #10

        $display("Test 3, Vector 3: output = %h, expected = 0E2032, %s", out, (out == 24'h0E2032) ? "PASS" : "FAIL");
        enable = 0;
        
        #10

        // Test 2: 3 vectors, pause in between
        // Test vector 1 (with reset)
        // vector = [0x01, 0x04, 0x07]
        // scalar = 0x01
        // output should be [0x01, 0x04, 0x07]
        reset = 1;
        #10;
        reset = 0;
        enable = 1;
        a = 24'h010407;
        b = 8'h01;
        #10;

        enable = 0;
        #10;
        enable = 1;
        
        // Test vector 2 (with accumulation)
        // vector = [0x02, 0x05, 0x08]
        // scalar = 0x02
        // output should be [0x05, 0x0E, 0x17]
        a = 24'h020508;
        b = 8'h02;
        #10;

        enable = 0;
        #10;
        enable = 1;

        // Test vector 3 (with accumulation)
        // vector = [0x03, 0x06, 0x09]
        // scalar = 0x03
        // output should be [0x0E, 0x20, 0x32]
        a = 24'h030609;
        b = 8'h03;
        #10;
        $display("Test 2, Vector 1: output = %h, expected = 010407, %s", out, (out == 24'h010407) ? "PASS" : "FAIL");
        
        // wait for propogation delay
        a = 0;
        b = 0;
        #10

        $display("Test 2, Vector 2: output = %h, expected = 050E17, %s", out, (out == 24'h050E17) ? "PASS" : "FAIL");

        #10

        $display("Test 3, Vector 3: output = %h, expected = 0E2032, %s", out, (out == 24'h0E2032) ? "PASS" : "FAIL");
        enable = 0;
        
        #10

        // Finish simulation
        $finish;
    end
      
endmodule