module riscv_pipeline #(parameter ENABLE_HAZARD_UNIT = 1,
                        parameter IMEM_FILE = "",
                        parameter DMEM_FILE = "")
                       (input         clk,
                        input         reset,
                        output reg [31:0] PCF,
                        output     [31:0] InstrF,
                        output reg [31:0] InstrD,
                        output reg [31:0] InstrE,
                        output reg [31:0] InstrM,
                        output reg [31:0] InstrW,
                        output reg [31:0] ALUResultM,
                        output reg [31:0] WriteDataM,
                        output reg [31:0] ReadDataW,
                        output     [31:0] ResultW,
                        output reg        MemWriteM,
                        output reg        RegWriteW,
                        output            StallF,
                        output            StallD,
                        output            FlushD,
                        output            FlushE,
                        output     [1:0]  ForwardAE,
                        output     [1:0]  ForwardBE);

  localparam NOP = 32'h00000013; // addi x0, x0, 0

  // IF stage
  wire [31:0] PCNextF;
  wire [31:0] PCTargetE;
  wire        PCSrcE;
  wire [31:0] PCPlus4F;
  wire [31:0] PCIncF;

    assign PCIncF = 32'd4;

  assign PCPlus4F = PCF + PCIncF;

  always @(posedge clk or posedge reset) begin
    if (reset)
      PCF <= 32'b0;
    else if (!StallF)
      PCF <= PCNextF;
  end


imem #(.MEM_FILE(IMEM_FILE))
instruction_memory(PCF, InstrF);



  // IF/ID register
  reg [31:0] PCD;
  reg [31:0] PCPlus4D;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      InstrD   <= NOP;
      PCD      <= 32'b0;
      PCPlus4D <= 32'b0;
    end else if (FlushD) begin
      InstrD   <= NOP;
      PCD      <= 32'b0;
      PCPlus4D <= 32'b0;
    end else if (!StallD) begin
    InstrD <= InstrF;
      PCD      <= PCF;
      PCPlus4D <= PCPlus4F;
    end
  end

  // ID stage
  wire [6:0] opD;
  wire [2:0] funct3D;
  wire       funct7b5D;
  wire [4:0] Rs1D;
  wire [4:0] Rs2D;
  wire [4:0] RdD;
  wire [2:0] ImmSrcD;
  wire [3:0] ALUControlD;
  wire       ALUSrcD;
  wire [1:0] ResultSrcD;
  wire       RegWriteD;
  wire       MemWriteD;
  wire       BranchD;
  wire       JumpD;
  wire       JalrD;
  wire       UsesRs1D;
  wire       UsesRs2D;
  wire [31:0] RD1D;
  wire [31:0] RD2D;
  wire [31:0] ImmExtD;

  assign opD       = InstrD[6:0];
  assign funct3D   = InstrD[14:12];
  assign funct7b5D = InstrD[30];
  assign Rs1D      = InstrD[19:15];
  assign Rs2D      = InstrD[24:20];
  assign RdD       = InstrD[11:7];

  controller control_unit(opD, funct3D, funct7b5D, ImmSrcD, ALUControlD,
                          ALUSrcD, ResultSrcD, RegWriteD, MemWriteD,
                          BranchD, JumpD, JalrD, UsesRs1D, UsesRs2D);

  reg [4:0] RdW;

  regfile rf(clk, RegWriteW, Rs1D, Rs2D, RdW, ResultW, RD1D, RD2D);
  immext  immediate_extender(InstrD, ImmSrcD, ImmExtD);

  // ID/EX register
  reg        RegWriteE;
  reg [1:0]  ResultSrcE;
  reg        MemWriteE;
  reg        BranchE;
  reg        JumpE;
  reg        JalrE;
  reg        ALUSrcE;
  reg [3:0]  ALUControlE;
  reg [2:0]  BranchTypeE;
  reg [31:0] RD1E;
  reg [31:0] RD2E;
  reg [31:0] PCE;
  reg [31:0] ImmExtE;
  reg [31:0] PCPlus4E;
  reg [4:0]  Rs1E;
  reg [4:0]  Rs2E;
  reg [4:0]  RdE;

  always @(posedge clk or posedge reset) begin
    if (reset || FlushE) begin
      InstrE      <= NOP;
      RegWriteE   <= 1'b0;
      ResultSrcE  <= 2'b00;
      MemWriteE   <= 1'b0;
      BranchE     <= 1'b0;
      JumpE       <= 1'b0;
      JalrE       <= 1'b0;
      ALUSrcE     <= 1'b0;
      ALUControlE <= 4'b0000;
      BranchTypeE <= 3'b000;
      RD1E        <= 32'b0;
      RD2E        <= 32'b0;
      PCE         <= 32'b0;
      ImmExtE     <= 32'b0;
      PCPlus4E    <= 32'b0;
      Rs1E        <= 5'b0;
      Rs2E        <= 5'b0;
      RdE         <= 5'b0;
    end else begin
      InstrE      <= InstrD;
      RegWriteE   <= RegWriteD;
      ResultSrcE  <= ResultSrcD;
      MemWriteE   <= MemWriteD;
      BranchE     <= BranchD;
      JumpE       <= JumpD;
      JalrE       <= JalrD;
      ALUSrcE     <= ALUSrcD;
      ALUControlE <= ALUControlD;
      BranchTypeE <= funct3D;
      RD1E        <= RD1D;
      RD2E        <= RD2D;
      PCE         <= PCD;
      ImmExtE     <= ImmExtD;
      PCPlus4E    <= PCPlus4D;
      Rs1E        <= Rs1D;
      Rs2E        <= Rs2D;
      RdE         <= RdD;
    end
  end

  // EX stage
  wire [31:0] ResultM;
  wire [31:0] ForwardedAE;
  wire [31:0] ForwardedBE;
  wire [31:0] SrcBE;
  wire [31:0] ALUResultE;
  wire        ALUZeroE;
  reg         BranchTakenE;

  assign ResultM = (ResultSrcM == 2'b10) ? PCPlus4M : ALUResultM;

  assign ForwardedAE = (ForwardAE == 2'b10) ? ResultM :
                       (ForwardAE == 2'b01) ? ResultW : RD1E;

  assign ForwardedBE = (ForwardBE == 2'b10) ? ResultM :
                       (ForwardBE == 2'b01) ? ResultW : RD2E;

  assign SrcBE = ALUSrcE ? ImmExtE : ForwardedBE;

  alu alu_unit(ForwardedAE, SrcBE, ALUControlE, ALUResultE, ALUZeroE);

  always @* begin
    case (BranchTypeE)
      3'b000: BranchTakenE = (ForwardedAE == ForwardedBE); // beq
      3'b001: BranchTakenE = (ForwardedAE != ForwardedBE); // bne
      3'b100: BranchTakenE = ($signed(ForwardedAE) < $signed(ForwardedBE)); // blt
      3'b101: BranchTakenE = ($signed(ForwardedAE) >= $signed(ForwardedBE)); // bge
      default: BranchTakenE = 1'b0;
    endcase
  end

  assign PCSrcE = (BranchE && BranchTakenE) || JumpE;
  assign PCTargetE = JalrE ? ((ForwardedAE + ImmExtE) & 32'hfffffffe)
                           : (PCE + ImmExtE);
  assign PCNextF = PCSrcE ? PCTargetE : PCPlus4F;

  // EX/MEM register
  reg        RegWriteM;
  reg [1:0]  ResultSrcM;
  reg [31:0] PCPlus4M;
  reg [4:0]  RdM;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      InstrM      <= NOP;
      RegWriteM   <= 1'b0;
      ResultSrcM  <= 2'b00;
      MemWriteM   <= 1'b0;
      ALUResultM  <= 32'b0;
      WriteDataM  <= 32'b0;
      PCPlus4M    <= 32'b0;
      RdM         <= 5'b0;
    end else begin
      InstrM      <= InstrE;
      RegWriteM   <= RegWriteE;
      ResultSrcM  <= ResultSrcE;
      MemWriteM   <= MemWriteE;
      ALUResultM  <= ALUResultE;
      WriteDataM  <= ForwardedBE;
      PCPlus4M    <= PCPlus4E;
      RdM         <= RdE;
    end
  end

  // MEM stage
  wire [31:0] ReadDataM;

  dmem #(.MEM_FILE(DMEM_FILE)) data_memory(clk, MemWriteM, ALUResultM,
                                           WriteDataM, ReadDataM);

  // MEM/WB register
  reg [1:0]  ResultSrcW;
  reg [31:0] ALUResultW;
  reg [31:0] PCPlus4W;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      InstrW     <= NOP;
      RegWriteW  <= 1'b0;
      ResultSrcW <= 2'b00;
      ALUResultW <= 32'b0;
      ReadDataW  <= 32'b0;
      PCPlus4W   <= 32'b0;
      RdW        <= 5'b0;
    end else begin
      InstrW     <= InstrM;
      RegWriteW  <= RegWriteM;
      ResultSrcW <= ResultSrcM;
      ALUResultW <= ALUResultM;
      ReadDataW  <= ReadDataM;
      PCPlus4W   <= PCPlus4M;
      RdW        <= RdM;
    end
  end

  assign ResultW = (ResultSrcW == 2'b00) ? ALUResultW :
                   (ResultSrcW == 2'b01) ? ReadDataW :
                   (ResultSrcW == 2'b10) ? PCPlus4W :
                   ALUResultW;

  // Hazard unit
  hazard_unit #(.ENABLE(ENABLE_HAZARD_UNIT)) hazards(
    RegWriteM, RegWriteW, ResultSrcE, PCSrcE, UsesRs1D, UsesRs2D,
    Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
    ForwardAE, ForwardBE, StallF, StallD, FlushD, FlushE);
endmodule
