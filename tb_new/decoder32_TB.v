`timescale 1ns/1ps
module Decoder32_TB;
reg  [31:0] instr;
wire [6:0]  opcode;
wire [4:0]  rd;
wire [2:0]  funct3;
wire [4:0]  rs1;
wire [4:0]  rs2;
wire [6:0]  funct7;
wire [31:0] imm;
wire        reg_write;
wire        mem_read;
wire        mem_write;
wire        branch;
wire        jump;
wire        mem_to_reg;
wire        alu_src;
wire [3:0]  alu_op;
integer i;
reg [31:0] instrucciones[0:6];
Decoder32 decoder(
  .instr(instr),
  .opcode(opcode),
  .rd(rd),
  .funct3(funct3),
  .rs1(rs1),
  .rs2(rs2),
  .funct7(funct7),
  .imm(imm),
  .reg_write(reg_write),
  .mem_read(mem_read),
  .mem_write(mem_write),
  .branch(branch),
  .jump(jump),
  .mem_to_reg(mem_to_reg),
  .alu_src(alu_src),
  .alu_op(alu_op)
);
initial begin
  $dumpfile("decoder32_TB.vcd");
  $dumpvars(0,Decoder32_TB);
  instrucciones[0] = 32'h003100b3;
  instrucciones[1] = 32'h403100b3;
  instrucciones[2] = 32'h00f08893;
  instrucciones[3] = 32'h00f0b093;
  instrucciones[4] = 32'h0040a083;
  instrucciones[5] = 32'h0040a123;
  instrucciones[6] = 32'h00308163;
  for (i = 0; i < 7; i = i + 1) begin
    instr = instrucciones[i];
    #10;
  end
  #20;
  $finish;
end
endmodule
