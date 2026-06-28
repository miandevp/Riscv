module regfile(input         clk,
               input         we3,
               input  [4:0]  a1,
               input  [4:0]  a2,
               input  [4:0]  a3,
               input  [31:0] wd3,
               output [31:0] rd1,
               output [31:0] rd2);

  // Register array
  reg [31:0] rf[31:0];
  integer i;

  initial begin
    for (i = 0; i < 32; i = i + 1)
      rf[i] = 32'b0;
  end

  // Write port
  always @(posedge clk) begin
    if (we3 && (a3 != 5'b0))
      rf[a3] <= wd3;
  end

  // Read ports
  assign rd1 = (a1 == 5'b0) ? 32'b0 : rf[a1];
  assign rd2 = (a2 == 5'b0) ? 32'b0 : rf[a2];
endmodule
