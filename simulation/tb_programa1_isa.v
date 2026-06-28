`timescale 1ns/1ps

module tb_programa1_isa;
  reg clk;
  reg reset;
  integer errors;

  // DUT
  riscv_pipeline #(
    .ENABLE_HAZARD_UNIT(1),
    .IMEM_FILE("C:/Users/romez/OneDrive/Documentos/proyectos/PipelineC/simulation/programa1_isa_sin_dependencias.mem")
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

  // Test sequence
  initial begin
    errors = 0;
    reset = 1'b1;
    $dumpfile("tb_programa1_isa.vcd");
    $dumpvars(0, tb_programa1_isa);

    #12 reset = 1'b0;
    repeat (90) @(posedge clk);
    #1;

    check_reg(3,  32'd8);
    check_reg(4,  32'd2);
    check_reg(5,  32'd6);
    check_reg(6,  32'd6);
    check_reg(7,  32'd6);
    check_reg(11, 32'hfffffffc);
    check_reg(12, 32'd7);
    check_reg(13, 32'd1);
    check_reg(14, 32'd15);
    check_reg(15, 32'd12);
    check_reg(16, 32'd2);
    check_reg(17, 32'd3);
    check_reg(18, 32'hfffffffe);
    check_reg(19, 32'd13);
    check_reg(20, 32'd8);
    check_reg(21, 32'h12345000);
    check_reg(22, 32'd15);
    check_reg(23, 32'h00000080);
    check_reg(25, 32'h00000088);
    check_reg(29, 32'd0);
    check_reg(30, 32'd0);
    check_reg(31, 32'd1);

    if (dut.data_memory.RAM[0] !== 32'd15) begin
      $display("FAIL: mem[0] = %h, esperado 0000000f", dut.data_memory.RAM[0]);
      errors = errors + 1;
    end

    finish_test("tb_programa1_isa");
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
