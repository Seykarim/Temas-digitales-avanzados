`timescale 1ns/1ps
module tb_auto;
  // TODO: cambia TOP_REAL por el nombre del módulo top de tu diseño
  // TOP_REAL dut();

  initial begin
    $dumpfile("build/tb_auto.vcd");
    $dumpvars(0, tb_auto);
    #1000 $finish;
  end
endmodule
