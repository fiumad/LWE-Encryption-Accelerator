module mla_accumulator #(
    parameter integer DATA_WIDTH = 12,
    // ACC_WIDTH should be large enough to hold many accumulated products.
    // For example, if the maximum product is (2^DATA_WIDTH-1)^2 then ACC_WIDTH
    // should be set wide enough (e.g. DATA_WIDTH*2 or wider) to prevent overflow.
    parameter integer ACC_WIDTH  = 32 
)(
    input  logic                             clk,
    input  logic                             rst,
    input  logic signed [2:0]     r,        // Multiplier input r.
    // Row input: packed with 4 columns.
    input  logic [(4*DATA_WIDTH)-1:0] row_in,
    input  logic [DATA_WIDTH-1:0]    sum_val,  // The additional input for the extra MLA stream.
    // Five accumulated outputs:
    output logic [ACC_WIDTH-1:0]     acc_col1,
    output logic [ACC_WIDTH-1:0]     acc_col2,
    output logic [ACC_WIDTH-1:0]     acc_col3,
    output logic [ACC_WIDTH-1:0]     acc_col4,
    output logic [ACC_WIDTH-1:0]     acc_sum,
);

    //-------------------------------------------------------------------------
    // Extract each column from the cache row.
    // We assume that row_in packs 4 columns as follows:
    // { col4 (MSB), col3, col2, col1 (LSB) }
    // If your cache packs the data differently, change these assignments.
    //-------------------------------------------------------------------------
    logic [DATA_WIDTH-1:0] col1, col2, col3, col4;
    assign col1 = row_in[DATA_WIDTH-1:0];
    assign col2 = row_in[(2*DATA_WIDTH)-1:DATA_WIDTH];
    assign col3 = row_in[(3*DATA_WIDTH)-1:(2*DATA_WIDTH)];
    assign col4 = row_in[(4*DATA_WIDTH)-1:(3*DATA_WIDTH)];

    //-------------------------------------------------------------------------
    // Multiply and Accumulate Operation
    // For every clock cycle, the module multiplies r by each input stream:
    // - For the cache: col1, col2, col3, and col4.
    // - For the extra stream: sum_val.
    // The products are accumulated in five separate registers.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_col1 <= '0;
            acc_col2 <= '0;
            acc_col3 <= '0;
            acc_col4 <= '0;
            acc_sum  <= '0;
        end else begin
            acc_col1 <= acc_col1 + (r * col1);
            acc_col2 <= acc_col2 + (r * col2);
            acc_col3 <= acc_col3 + (r * col3);
            acc_col4 <= acc_col4 + (r * col4);
            acc_sum  <= acc_sum  + (r * sum_val);
        end
    end

endmodule

