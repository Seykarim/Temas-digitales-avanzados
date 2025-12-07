`timescale 1ns / 1ps

module tb_test;

initial begin
  $dumpfile("TEST.vcd");
  $dumpvars(0, tb_test);

  $display("TB funcionando.");
  #10;
  $finish;
end

endmodule
