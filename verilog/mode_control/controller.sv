module mode_controller(
  input logic clk, rst,
  input logic [1:0] mode, 
  output logic keygen_on,
  output logic encryption_on,
  output logic decryption_on,
  output logic rng_on,
  output logic mod_on
);

// mode 0 = keygen
// mode 1 = encryption 
// mode 2 = decryption
// mode 3 = storing public key (for encryption)

always @(posedge clk) begin
  if (rst) begin
    keygen_on <= 0;
    encryption_on <= 0;
    decryption_on <= 0;
    rng_on <= 0;
    mod_on <= 0;
  end
  else begin
    case (mode)
      2'b00: begin
        keygen_on <= 1;
        encryption_on <= 0;
        decryption_on <= 0;
        rng_on <= 1;
        mod_on <= 1;
      end
      2'b01: begin
        keygen_on <= 0;
        encryption_on <= 1;
        decryption_on <= 0;
        rng_on <= 1;
        mod_on <= 1;
      end
      2'b10: begin
        keygen_on <= 0;
        encryption_on <= 0;
        decryption_on <= 1;
        rng_on <= 0;
        mod_on <= 0;
      end
      2'b10: begin
        keygen_on <= 0;
        encryption_on <= 0;
        decryption_on <= 0;
        rng_on <= 0;
        mod_on <= 0;
      end
      default:
        keygen_on <= 0;
        encryption_on <= 0;
        decryption_on <= 0;
        rng_on <= 0;
        mod_on <= 0;
      endcase
  end
end

endmodule
