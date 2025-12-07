`timescale 1ns/1ps
module ALU32_TB;
reg [31:0] a;
reg [31:0] b;
reg [3:0] alu_op;
wire [31:0] y;
wire zero;
wire carry;
wire negative;
wire overflow;
integer i;
ALU32 dut(
  .a(a),
  .b(b),
  .alu_op(alu_op),
  .y(y),
  .zero(zero),
  .carry(carry),
  .negative(negative),
  .overflow(overflow)
);
initial begin
  $dumpfile("alu32_TB.vcd");
  $dumpvars(0,ALU32_TB);
  a = 32'd10; b = 32'd5;
  alu_op = 4'b0000; #10;
  alu_op = 4'b0001; #10;
  alu_op = 4'b0010; #10;
  alu_op = 4'b0011; #10;
  alu_op = 4'b0100; #10;
  alu_op = 4'b0101; #10;
  alu_op = 4'b0110; #10;
  alu_op = 4'b0111; #10;
  alu_op = 4'b1000; #10;
  alu_op = 4'b1001; #10;
  a = 32'h80000000; b = 32'd1;
  alu_op = 4'b0000; #10;
  alu_op = 4'b0001; #10;
  #100;
  $finish;
end
endmodule
