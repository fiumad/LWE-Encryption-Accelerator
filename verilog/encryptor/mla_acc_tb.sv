`timescale 1ns/1ps

module tb_mla_accumulator;

  // Simulation parameters:
  localparam DATA_WIDTH = 12;
  localparam ACC_WIDTH  = 32;
  localparam NUM_STREAMS = 4; // Four cache columns
  
  // Inputs
  logic                     clk;
  logic                     rst;
  logic signed   [2:0]      r;       // 3-bit signed multiplier
  logic [NUM_STREAMS*DATA_WIDTH-1:0] row_in;   // Packed cache row: {col4, col3, col2, col1}
  logic [DATA_WIDTH-1:0]    sum_val; // Additional stream input
  
  // Outputs
  logic [ACC_WIDTH-1:0]     acc_col1;
  logic [ACC_WIDTH-1:0]     acc_col2;
  logic [ACC_WIDTH-1:0]     acc_col3;
  logic [ACC_WIDTH-1:0]     acc_col4;
  logic [ACC_WIDTH-1:0]     acc_sum;
  
  // Instantiate the DUT.
  mla_accumulator #(
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
  ) dut (
    .clk(clk),
    .rst(rst),
    .r(r),
    .row_in(row_in),
    .sum_val(sum_val),
    .acc_col1(acc_col1),
    .acc_col2(acc_col2),
    .acc_col3(acc_col3),
    .acc_col4(acc_col4),
    .acc_sum(acc_sum)
  );
  
  // Clock generation: 10 ns period.
  initial clk = 0;
  always #5 clk = ~clk;
  
  // Test stimulus.
  initial begin
    integer i;
    
    // Initialize the dump file for waveform viewing.
    $dumpfile("tb_mla_accumulator.vcd");
    $dumpvars(0, tb_mla_accumulator);
    
    // Initialize inputs.
    rst      = 1;
    r        = 0;
    row_in   = '0;
    sum_val  = '0;
    
    // Hold reset for a few cycles.
    #15;
    rst = 0;
    
    // First test phase: use positive r.
    // For 10 clock cycles, apply r = 3 and update row_in and sum_val.
    for (i = 0; i < 10; i = i + 1) begin
      @(posedge clk);
      // Set r (3-bit signed). Here r = 3.
      r = 3;
      // Construct row_in as {col4, col3, col2, col1}.
      // For example, col1 = i+1, col2 = i+2, col3 = i+3, col4 = i+4.
      row_in = { 12'(i+4), 12'(i+3), 12'(i+2), 12'(i+1) };
      // Set sum_val to i+5.
      sum_val = 12'(i+5);
      
      // Optionally display the stimulus and current accumulators.
      $display("[Cycle %0d] r=%0d, row_in=%h, sum_val=%h || acc_col1=%h, acc_col2=%h, acc_col3=%h, acc_col4=%h, acc_sum=%h",
               i, r, row_in, sum_val, acc_col1, acc_col2, acc_col3, acc_col4, acc_sum);
    end
    
    // Second test phase: use negative r.
    // For 5 clock cycles, set r = -2.
    for (i = 0; i < 5; i = i + 1) begin
      @(posedge clk);
      r = -2;
      // Change the row pattern for variety.
      row_in = { 12'(i+10), 12'(i+11), 12'(i+12), 12'(i+13) };
      sum_val = 12'(i+14);
      
      $display("[Cycle %0d] r=%0d, row_in=%h, sum_val=%h || acc_col1=%h, acc_col2=%h, acc_col3=%h, acc_col4=%h, acc_sum=%h",
               10+i, r, row_in, sum_val, acc_col1, acc_col2, acc_col3, acc_col4, acc_sum);
    end
    
    // Wait a few more cycles to capture the final accumulator values.
    #50;
    $display("Final values: acc_col1=%h, acc_col2=%h, acc_col3=%h, acc_col4=%h, acc_sum=%h",
             acc_col1, acc_col2, acc_col3, acc_col4, acc_sum);
    
    $finish;
  end

endmodule
