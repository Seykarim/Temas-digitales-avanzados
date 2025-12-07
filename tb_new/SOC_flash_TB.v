`timescale 1ns/1ps
module SOC_flash_TB;
reg clk = 0;
reg reset = 1;
wire [31:0] pc_out;
wire [31:0] instr_out;
always #5 clk = ~clk;
SOC_flash dut(
  .clk(clk),
  .reset(reset),
  .pc_out(pc_out),
  .instr_out(instr_out)
);
integer i;
initial begin
  $dumpfile("SOC_flash_TB.vcd");
  $dumpvars(0,SOC_flash_TB);
  for (i = 0; i < 256; i = i + 1) begin
    dut.instr_mem.mem[i] = i;
  end
  #20 reset = 0;
  #2000 $finish;
end
endmodule
