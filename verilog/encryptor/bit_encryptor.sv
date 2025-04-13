module bit_encryptor (
  input logic clk,
  input logic rst,
  input logic message,
  input logic [31:0] acc_1,
  input logic [31:0] acc_2,
  input logic [31:0] acc_3,
  input logic [31:0] acc_4,
  input logic [31:0] sum_in,

  output logic [31:0] acc_1,
  output logic [31:0] acc_2,
  output logic [31:0] acc_3,
  output logic [31:0] acc_4,
  output logic [31:0] encoded_sum
);
  
endmodule
