module hazard_unit #(parameter ENABLE = 1)
                    (input        RegWriteM,
                     input        RegWriteW,
                     input  [1:0] ResultSrcE,
                     input        PCSrcE,
                     input        UsesRs1D,
                     input        UsesRs2D,
                     input  [4:0] Rs1D,
                     input  [4:0] Rs2D,
                     input  [4:0] Rs1E,
                     input  [4:0] Rs2E,
                     input  [4:0] RdE,
                     input  [4:0] RdM,
                     input  [4:0] RdW,
                     output reg [1:0] ForwardAE,
                     output reg [1:0] ForwardBE,
                     output reg       StallF,
                     output reg       StallD,
                     output reg       FlushD,
                     output reg       FlushE);

  wire lwStallD;

  // Load-use stall
  assign lwStallD = (ResultSrcE == 2'b01) &&
                    (((Rs1D == RdE) && UsesRs1D && (Rs1D != 5'b0)) ||
                     ((Rs2D == RdE) && UsesRs2D && (Rs2D != 5'b0)));

  // Hazard controls
  always @* begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;
    StallF    = 1'b0;
    StallD    = 1'b0;
    FlushD    = 1'b0;
    FlushE    = 1'b0;

    if (ENABLE) begin
      // Forwarding
      if ((Rs1E != 5'b0) && (Rs1E == RdM) && RegWriteM)
        ForwardAE = 2'b10;
      else if ((Rs1E != 5'b0) && (Rs1E == RdW) && RegWriteW)
        ForwardAE = 2'b01;

      if ((Rs2E != 5'b0) && (Rs2E == RdM) && RegWriteM)
        ForwardBE = 2'b10;
      else if ((Rs2E != 5'b0) && (Rs2E == RdW) && RegWriteW)
        ForwardBE = 2'b01;

      // Stall and flush
      StallF = lwStallD;
      StallD = lwStallD;
      FlushD = PCSrcE;
      FlushE = lwStallD | PCSrcE;
    end
  end
endmodule
