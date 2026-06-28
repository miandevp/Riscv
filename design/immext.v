    module immext(input      [31:0] instr,
                  input      [2:0]  immsrc,
                  output reg [31:0] immext);
    
      // Immediate formats
      localparam IMM_I = 3'b000;
      localparam IMM_S = 3'b001;
      localparam IMM_B = 3'b010;
      localparam IMM_J = 3'b011;
      localparam IMM_U = 3'b100;
    
      // Immediate extension
      always @* begin
        case (immsrc)
          IMM_I: immext = {{20{instr[31]}}, instr[31:20]};
          IMM_S: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
          IMM_B: immext = {{19{instr[31]}}, instr[31], instr[7],
                           instr[30:25], instr[11:8], 1'b0};
          IMM_J: immext = {{11{instr[31]}}, instr[31], instr[19:12],
                           instr[20], instr[30:21], 1'b0};
          IMM_U: immext = {instr[31:12], 12'b0};
          default: immext = 32'b0;
        endcase
      end
    endmodule
