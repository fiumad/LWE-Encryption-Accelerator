`timescale 1ns/1ps

module tb_novel_mod_operator;

  // Parameter for bit width (should match the module's parameter)
  parameter N = 32;
  
  // Declare inputs to the DUT
  logic clk;
  logic rst;
  logic start;
  logic [N-1:0] A, B;
  
  // Outputs from the DUT
  logic [N-1:0] result;
  logic done;

  // Instantiate the novel_mod_operator module
  novel_mod_operator #(.N(N)) uut (
      .clk(clk),
      .rst(rst),
      .start(start),
      .A(A),
      .B(B),
      .result(result),
      .done(done)
  );

  // Clock generation: 10 ns period (100MHz clock)
  initial clk = 0;
  always #5 clk = ~clk;
  
  // Apply test vectors
  initial begin
      // Dump waveforms for simulation (optional)
      $dumpfile("tb_novel_mod_operator.vcd");
      $dumpvars(0, tb_novel_mod_operator);
      
      // Initialize signals
      rst = 1;
      start = 0;
      A = '0;
      B = '0;
      
      // Hold reset for a few cycles then release
      #10;
      rst = 0;
      
      // -------------------------------
      // Test Case 1: A = 100, B = 3 (Expected remainder: 100 mod 3 = 1)
      // -------------------------------
      A = 100;
      B = 3;
      start = 1;
      #10;
      start = 0;
      
      // Wait for done to be asserted
      wait(done);
      $display("Test 1: A = %0d, B = %0d, remainder = %0d (expected = 1)", A, B, result);
      #20;
      
      // -------------------------------
      // Test Case 2: A = 256, B = 16 (Expected remainder: 256 mod 16 = 0)
      // -------------------------------
      A = 256;
      B = 16;
      start = 1;
      #10;
      start = 0;
      wait(done);
      $display("Test 2: A = %0d, B = %0d, remainder = %0d (expected = 0)", A, B, result);
      #20;
      
      // -------------------------------
      // Test Case 3: A = 123456, B = 789 
      // Expected remainder: 123456 mod 789 = 372  (since 789*156 = 123084, 123456-123084 = 372)
      // -------------------------------
      A = 123456;
      B = 789;
      start = 1;
      #10;
      start = 0;
      wait(done);
      $display("Test 3: A = %0d, B = %0d, remainder = %0d (expected = 372)", A, B, result);
      #20;
      
      // -------------------------------
      // Test Case 4: A = 0, B = 15 (Expected remainder: 0 mod 15 = 0)
      // -------------------------------
      A = 0;
      B = 15;
      start = 1;
      #10;
      start = 0;
      wait(done);
      $display("Test 4: A = %0d, B = %0d, remainder = %0d (expected = 0)", A, B, result);
      #20;
      
      // -------------------------------
      // Test Case 5: A = 15, B = 0 
      // With B=0, the result is undefined. This test is just to demonstrate the behavior.
      // -------------------------------
      A = 15;
      B = 0;
      start = 1;
      #10;
      start = 0;
      wait(done);
      $display("Test 5: A = %0d, B = %0d, remainder = %0d (undefined since B is 0)", A, B, result);
      #20;
     
      // -------------------------------
      // Test Case 6: A = 668, B = 7 
      // With B=0, the result is undefined. This test is just to demonstrate the behavior.
      // -------------------------------
      A = 668;
      B = 7;
      start = 1;
      #10;
      start = 0;
      wait(done);
      $display("Test 6: A = %0d, B = %0d, remainder = %0d (expected 3)", A, B, result);
      #20;

      $finish;
  end

endmodule
