// ALU decoder for the RV32I pipeline used in Proyecto 2 - Parte 1.
module aludec(input  [6:0] op,
              input  [2:0] funct3,
              input        funct7b5,
              output reg [3:0] ALUControl);

  // Opcodes
  localparam OP_RTYPE  = 7'b0110011;
  localparam OP_ITYPE  = 7'b0010011;
  localparam OP_LOAD   = 7'b0000011;
  localparam OP_STORE  = 7'b0100011;
  localparam OP_BRANCH = 7'b1100011;
  localparam OP_JALR   = 7'b1100111;
  localparam OP_LUI    = 7'b0110111;
  

  // ALU codes
  localparam ALU_ADD   = 4'b0000;
  localparam ALU_SUB   = 4'b0001;
  localparam ALU_SLL   = 4'b0010;
  localparam ALU_XOR   = 4'b0011;
  localparam ALU_SRL   = 4'b0100;
  localparam ALU_SRA   = 4'b0101;
  localparam ALU_OR    = 4'b0110;
  localparam ALU_AND   = 4'b0111;
  localparam ALU_PASSB = 4'b1000;
  localparam ALU_SLT   = 4'b1001;

  // ALU decode
  always @* begin
    case (op)
      OP_RTYPE,
      OP_ITYPE: begin
        case (funct3)
            3'b000: ALUControl = (op == OP_RTYPE && funct7b5) ? ALU_SUB : ALU_ADD;
            3'b001: ALUControl = ALU_SLL;
            3'b010: ALUControl = ALU_SLT;   // slt y slti
            3'b100: ALUControl = ALU_XOR;
            3'b101: ALUControl = funct7b5 ? ALU_SRA : ALU_SRL;
            3'b110: ALUControl = ALU_OR;
            3'b111: ALUControl = ALU_AND;
          default: ALUControl = ALU_ADD;
        endcase
      end
      OP_LOAD,
      OP_STORE,
      OP_JALR:   ALUControl = ALU_ADD;
      OP_BRANCH: ALUControl = ALU_SUB;
      OP_LUI:    ALUControl = ALU_PASSB;
      default:   ALUControl = ALU_ADD;
    endcase
  end
endmodule
