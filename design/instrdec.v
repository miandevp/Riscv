// Immediate source decoder for RV32I instruction formats.
module instrdec(input  [6:0] op,
                output reg [2:0] ImmSrc);

  // Immediate formats
  localparam IMM_I = 3'b000;
  localparam IMM_S = 3'b001;
  localparam IMM_B = 3'b010;
  localparam IMM_J = 3'b011;
  localparam IMM_U = 3'b100;

  // Immediate select
  always @* begin
    case (op)
      7'b0010011: ImmSrc = IMM_I;
      7'b0000011: ImmSrc = IMM_I;
      7'b1100111: ImmSrc = IMM_I;
      7'b0100011: ImmSrc = IMM_S;
      7'b1100011: ImmSrc = IMM_B;
      7'b1101111: ImmSrc = IMM_J;
      7'b0110111: ImmSrc = IMM_U;
      default:    ImmSrc = IMM_I;
    endcase
  end
endmodule
