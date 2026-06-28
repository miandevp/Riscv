module dmem #(parameter MEM_FILE = "")
             (input         clk,
              input         we,
              input  [31:0] a,
              input  [31:0] wd,
              output [31:0] rd);

  // Data memory
  reg [31:0] RAM[0:255];
  integer i;

  // Initial load
  initial begin
    for (i = 0; i < 256; i = i + 1)
      RAM[i] = 32'b0;

    if (MEM_FILE != "")
      $readmemh(MEM_FILE, RAM);
  end

  // Write port
  always @(posedge clk) begin
    if (we)
      RAM[a[31:2]] <= wd;
  end

  // Read port
  assign rd = RAM[a[31:2]];
endmodule
