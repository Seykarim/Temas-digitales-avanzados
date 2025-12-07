`timescale 1ns/1ps
module femto_TB;
reg clk   = 0;
reg reset = 1;
wire [7:0] leds;
always #5 clk = ~clk;
femto uut(
  .CLK(clk),
  .RESET(reset),
  .LEDS(leds)
);
initial begin
  $dumpfile("femto_TB.vcd");
  $dumpvars(0,femto_TB);
  #100;
  reset = 0;
  #100000;
  $finish;
end
endmodule
