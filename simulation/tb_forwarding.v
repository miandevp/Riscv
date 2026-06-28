`timescale 1ns/1ps

module tb_forwarding;
  reg clk;
  reg reset;
  integer errors;
  integer saw_forwarding;

  // DUT
  riscv_pipeline #(
    .ENABLE_HAZARD_UNIT(0),
    .IMEM_FILE("C:/Users/romez/OneDrive/Documentos/proyectos/PipelineC/simulation/programa2_forwarding.mem")
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

  // Forwarding monitor
  always @(posedge clk) begin
    if ((dut.ForwardAE != 2'b00) || (dut.ForwardBE != 2'b00))
      saw_forwarding = 1;
  end

  // Test sequence
  initial begin
    errors = 0;
    saw_forwarding = 0;
    reset = 1'b1;
    $dumpfile("tb_forwarding.vcd");
    $dumpvars(0, tb_forwarding);

    #12 reset = 1'b0;
    repeat (35) @(posedge clk);
    #1;

    check_reg(1, 32'd5);
    check_reg(2, 32'd7);
    check_reg(3, 32'd12);
    check_reg(4, 32'd19);
    check_reg(5, 32'd14);
    check_reg(31, 32'd1);

    if (dut.data_memory.RAM[1] !== 32'd14) begin
      $display("FAIL: mem[1] = %h, esperado 0000000e", dut.data_memory.RAM[1]);
      errors = errors + 1;
    end

    if (!saw_forwarding) begin
      $display("FAIL: no se observo ForwardAE/ForwardBE activo");
      errors = errors + 1;
    end

    finish_test("tb_forwarding");
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
