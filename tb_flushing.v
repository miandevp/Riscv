`timescale 1ns/1ps

module tb_flushing;
  reg clk;
  reg reset;
  integer errors;
  integer saw_flush;

  // DUT
  riscv_pipeline #(
    .ENABLE_HAZARD_UNIT(0),
    .IMEM_FILE("C:/Users/romez/OneDrive/Documentos/proyectos/PipelineC/simulation/programa4_flushing.mem")
  ) dut (
    .clk(clk),
    .reset(reset),
    .PCF(),
    .InstrF(),
    .InstrD(),
    .InstrE(),
    .InstrM(),
    .InstrW(),
    .ALUResultM(),
    .WriteDataM(),
    .ReadDataW(),
    .ResultW(),
    .MemWriteM(),
    .RegWriteW(),
    .StallF(),
    .StallD(),
    .FlushD(),
    .FlushE(),
    .ForwardAE(),
    .ForwardBE()
  );

  // Clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Flush monitor
  always @(posedge clk) begin
    if (dut.FlushD || dut.FlushE)
      saw_flush = 1;
  end

  // Test sequence
  initial begin
    errors = 0;
    saw_flush = 0;
    reset = 1'b1;
    $dumpfile("tb_flushing.vcd");
    $dumpvars(0, tb_flushing);

    #12 reset = 1'b0;
    repeat (45) @(posedge clk);
    #1;

    check_reg(20, 32'd0);
    check_reg(21, 32'd0);
    check_reg(22, 32'd0);
    check_reg(23, 32'd0);
    check_reg(31, 32'd1);

    if (!saw_flush) begin
      $display("FAIL: no se observo FlushD/FlushE activo");
      errors = errors + 1;
    end

    finish_test("tb_flushing");
  end

  // Register check
  task check_reg;
    input [4:0] idx;
    input [31:0] expected;
    begin
      if (dut.rf.rf[idx] !== expected) begin
        $display("FAIL: x%0d = %h, esperado %h", idx, dut.rf.rf[idx], expected);
        errors = errors + 1;
      end
    end
  endtask

  // Test result
  task finish_test;
    input [8*64:1] name;
    begin
      if (errors == 0)
        $display("PASS: %0s", name);
      else begin
        $display("FAIL: %0s con %0d errores", name, errors);
        $stop;
      end
      $finish;
    end
  endtask
endmodule
