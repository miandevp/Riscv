module imem #(parameter MEM_FILE = "")
(
    input  [31:0] a,
    output [31:0] rd
);

  reg [31:0] RAM[0:255];
  integer i;

  initial begin
    for (i = 0; i < 256; i = i + 1)
      RAM[i] = 32'h00000013;

    if (MEM_FILE != "") begin
      $readmemh(MEM_FILE, RAM);
      $display("IMEM: archivo cargado = %s", MEM_FILE);
    end
  end

  // Ignorar solamente el bit 0
  assign rd = RAM[a[31:2]];

endmodule