// matrix vector multiplier
module mvm #(
    parameter MATRIX_ROWS = 6,     // determines the number of ROWS in the matrix
    parameter SHARED_DIM = 3      // determines the number of columns in the matrix and rows in the vector
) (
    input wire clk, reset,
    input wire [MATRIX_ROWS * SHARED_DIM * 8 - 1:0] matrix,
    input wire [MATRIX_ROWS - 1:0] vector
);

    reg [SHARED_DIM - 1:0] shared_idx;   // keeps track of current column in the matrix and current row in the vector
    
endmodule