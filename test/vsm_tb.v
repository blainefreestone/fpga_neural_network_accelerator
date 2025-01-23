`timescale 1ns / 1ps

module test_vsm;

    // Parameters
    localparam SIZE = 6;

    // Inputs
    reg clk;
    reg reset;
    reg [8 * SIZE-1:0] a;
    reg [7:0] b;

    // Outputs
    wire [8 * SIZE-1:0] out;

    // Instantiate the Unit Under Test (UUT)
    vsm #(
        .SIZE(SIZE)
    ) uut (
        .clk(clk),
        .reset(reset),
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
        a = 0;
        b = 0;

        // Wait for global reset
        #10;
        
        // Test vector 1
        reset = 1;
        #10;
        reset = 0;
        a = 48'h010203040506;
        b = 8'hFF;
        #20;

        // Test vector 2
        reset = 1;
        #10;
        reset = 0;
        a = 48'hA1B2C3D4E5F6;
        b = 8'h0F;
        #20;

        a = 48'h123456789ABC;
        b = 8'hAA;
        #20;

        // Test vector 3
        reset = 1;
        #10;
        reset = 0;
        a = 48'hFEDCBA987654;
        b = 8'h55;
        #20;

        a = 48'h000000000000;
        b = 8'hFF;
        #20;

        // Test vector 4
        reset = 1;
        #10;
        reset = 0;
        a = 48'h112233445566;
        b = 8'h33;
        #20;

        a = 48'hAABBCCDDEEFF;
        b = 8'h77;
        #20;

        // Test vector 5
        reset = 1;
        #10;
        reset = 0;
        a = 48'h000000000000;
        b = 8'hFF;
        #20;

        // Test vector 6
        reset = 1;
        #10;
        reset = 0;
        a = 48'hFFFFFFFFFFFF;
        b = 8'h00;
        #20;

        // Finish simulation
        $finish;
    end
      
endmodule