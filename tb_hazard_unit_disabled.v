`timescale 1ns/1ps

module tb_hazard_unit_disabled;
  reg clk;
  reg reset;

  // Forwarding case without hazard unit
  riscv_pipeline #(
    .ENABLE_HAZARD_UNIT(0),
    .IMEM_FILE("C:/Users/Lenovo/Downloads/Multicycle/Multicycle/simulation/programa2_forwarding.mem")
  ) dut_forwarding (
    .clk(clk), .reset(reset),
    .PCF(), .InstrF(), .InstrD(), .InstrE(), .InstrM(), .InstrW(),
    .ALUResultM(), .WriteDataM(), .ReadDataW(), .ResultW(),
    .MemWriteM(), .RegWriteW(), .StallF(), .StallD(), .FlushD(), .FlushE(),
    .ForwardAE(), .ForwardBE()
  );

  // Stalling case without hazard unit
  riscv_pipeline #(
    .ENABLE_HAZARD_UNIT(0),
    .IMEM_FILE("C:/Users/Lenovo/Downloads/Multicycle/Multicycle/simulation/programa3_stalling.mem")
  ) dut_stalling (
    .clk(clk), .reset(reset),
    .PCF(), .InstrF(), .InstrD(), .InstrE(), .InstrM(), .InstrW(),
    .ALUResultM(), .WriteDataM(), .ReadDataW(), .ResultW(),
    .MemWriteM(), .RegWriteW(), .StallF(), .StallD(), .FlushD(), .FlushE(),
    .ForwardAE(), .ForwardBE()
  );

  // Flushing case without hazard unit
  riscv_pipeline #(
    .ENABLE_HAZARD_UNIT(0),
    .IMEM_FILE("C:/Users/Lenovo/Downloads/Multicycle/Multicycle/simulation/programa4_flushing.mem")
  ) dut_flushing (
    .clk(clk), .reset(reset),
    .PCF(), .InstrF(), .InstrD(), .InstrE(), .InstrM(), .InstrW(),
    .ALUResultM(), .WriteDataM(), .ReadDataW(), .ResultW(),
    .MemWriteM(), .RegWriteW(), .StallF(), .StallD(), .FlushD(), .FlushE(),
    .ForwardAE(), .ForwardBE()
  );

  // Clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    reset = 1'b1;
    $dumpfile("tb_hazard_unit_disabled.vcd");
    $dumpvars(0, tb_hazard_unit_disabled);

    #12 reset = 1'b0;
    repeat (70) @(posedge clk);
    #1;

    $display("Sin hazard unit - forwarding: x5=%h mem[1]=%h, correcto seria 0000000e",
             dut_forwarding.rf.rf[5], dut_forwarding.data_memory.RAM[1]);
    $display("Sin hazard unit - stalling: x3=%h x4=%h x5=%h, correcto seria 2a, 2b, 55",
             dut_stalling.rf.rf[3], dut_stalling.rf.rf[4], dut_stalling.rf.rf[5]);
    $display("Sin hazard unit - flushing: x20=%h x21=%h x22=%h x23=%h, correcto seria todo 0",
             dut_flushing.rf.rf[20], dut_flushing.rf.rf[21],
             dut_flushing.rf.rf[22], dut_flushing.rf.rf[23]);

    $finish;
  end
endmodule
