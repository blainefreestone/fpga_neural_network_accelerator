// matrix vector multiplier
module mvm #(
    parameter MATRIX_ROWS = 6,      // determines the number of ROWS in the matrix
    parameter SHARED_DIM = 3        // determines the number of columns in the matrix and rows in the vector
    parameter WIDTH = 8             // determines the width of data inside the matrix and the vector
) (
    input wire clk, reset,
    input wire [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] matrix,
    input wire [MATRIX_ROWS - 1:0] vector
    output wire [MATRIX_ROWS * SHARED_DIM * WIDTH - 1:0] result_vector
);

    reg [SHARED_DIM - 1:0] shared_idx;   // keeps track of current column in the matrix and current row in the vector
    
    wire [SHARED_DIM * WIDTH - 1:0] a, b;   // holds values currently needed for the vector scalar multiplier

    // vector scalar multiplier with proper parameters
    vsm u_vsm #(
        .SIZE(MATRIX_ROWS),
        .WIDTH(WIDTH),
        .ACCUMULATIONS(SHARED_DIM)
    ) (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b)
        .out(out)
    )

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shared_idx <= 0;
        end else begin
            // code to manage where the a and b wires are connected in the matrix or vector at any given time
        end
    end

endmodule