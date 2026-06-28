// Combinational controller for the 5-stage RV32I pipeline.
module controller(input  [6:0] op,
                  input  [2:0] funct3,
                  input        funct7b5,
                  output [2:0] ImmSrc,
                  output [3:0] ALUControl,
                  output reg   ALUSrc,
                  output reg [1:0] ResultSrc,
                  output reg   RegWrite,
                  output reg   MemWrite,
                  output reg   Branch,
                  output reg   Jump,
                  output reg   Jalr,
                  output reg   UsesRs1,
                  output reg   UsesRs2);

  // Opcodes
  localparam OP_RTYPE  = 7'b0110011;
  localparam OP_ITYPE  = 7'b0010011;
  localparam OP_LOAD   = 7'b0000011;
  localparam OP_STORE  = 7'b0100011;
  localparam OP_BRANCH = 7'b1100011;
  localparam OP_JAL    = 7'b1101111;
  localparam OP_JALR   = 7'b1100111;
  localparam OP_LUI    = 7'b0110111;

  // Decoders
  instrdec id(op, ImmSrc);
  aludec   ad(op, funct3, funct7b5, ALUControl);

  // Main control
  always @* begin
    ALUSrc    = 1'b0;
    ResultSrc = 2'b00;
    RegWrite  = 1'b0;
    MemWrite  = 1'b0;
    Branch    = 1'b0;
    Jump      = 1'b0;
    Jalr      = 1'b0;
    UsesRs1   = 1'b0;
    UsesRs2   = 1'b0;

    case (op)
      OP_RTYPE: begin
        RegWrite = 1'b1;
        UsesRs1  = 1'b1;
        UsesRs2  = 1'b1;
      end
      OP_ITYPE: begin
        ALUSrc   = 1'b1;
        RegWrite = 1'b1;
        UsesRs1  = 1'b1;
      end
      OP_LOAD: begin
        ALUSrc    = 1'b1;
        ResultSrc = 2'b01;
        RegWrite  = 1'b1;
        UsesRs1   = 1'b1;
      end
      OP_STORE: begin
        ALUSrc   = 1'b1;
        MemWrite = 1'b1;
        UsesRs1  = 1'b1;
        UsesRs2  = 1'b1;
      end
      OP_BRANCH: begin
        Branch  = 1'b1;
        UsesRs1 = 1'b1;
        UsesRs2 = 1'b1;
      end
      OP_JAL: begin
        ResultSrc = 2'b10;
        RegWrite  = 1'b1;
        Jump      = 1'b1;
      end
      OP_JALR: begin
        ALUSrc    = 1'b1;
        ResultSrc = 2'b10;
        RegWrite  = 1'b1;
        Jump      = 1'b1;
        Jalr      = 1'b1;
        UsesRs1   = 1'b1;
      end
      OP_LUI: begin
        ALUSrc   = 1'b1;
        RegWrite = 1'b1;
      end
      default: begin
        ALUSrc    = 1'b0;
        ResultSrc = 2'b00;
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        Jump      = 1'b0;
        Jalr      = 1'b0;
        UsesRs1   = 1'b0;
        UsesRs2   = 1'b0;
      end
    endcase
  end
endmodule
