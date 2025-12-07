`timescale 1ns/1ps
module Decoder32(
  input  [31:0] instr,
  output [6:0]  opcode,
  output [4:0]  rd,
  output [2:0]  funct3,
  output [4:0]  rs1,
  output [4:0]  rs2,
  output [6:0]  funct7,
  output [31:0] imm,
  output reg    reg_write,
  output reg    mem_read,
  output reg    mem_write,
  output reg    branch,
  output reg    jump,
  output reg    mem_to_reg,
  output reg    alu_src,
  output reg [3:0] alu_op
);
localparam OPC_LUI     = 7'b0110111;
localparam OPC_AUIPC   = 7'b0010111;
localparam OPC_JAL     = 7'b1101111;
localparam OPC_JALR    = 7'b1100111;
localparam OPC_BRANCH  = 7'b1100011;
localparam OPC_LOAD    = 7'b0000011;
localparam OPC_STORE   = 7'b0100011;
localparam OPC_OP_IMM  = 7'b0010011;
localparam OPC_OP      = 7'b0110011;
assign opcode = instr[6:0];
assign rd     = instr[11:7];
assign funct3 = instr[14:12];
assign rs1    = instr[19:15];
assign rs2    = instr[24:20];
assign funct7 = instr[31:25];
reg [31:0] imm_reg;
always @* begin
  case (opcode)
    OPC_LUI,
    OPC_AUIPC: imm_reg = {instr[31:12], 12'b0};
    OPC_JAL:   imm_reg = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    OPC_JALR,
    OPC_LOAD,
    OPC_OP_IMM: imm_reg = {{20{instr[31]}}, instr[31:20]};
    OPC_BRANCH: imm_reg = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    OPC_STORE:  imm_reg = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    default:    imm_reg = 32'd0;
  endcase
end
assign imm = imm_reg;
always @* begin
  reg_write  = 1'b0;
  mem_read   = 1'b0;
  mem_write  = 1'b0;
  branch     = 1'b0;
  jump       = 1'b0;
  mem_to_reg = 1'b0;
  alu_src    = 1'b0;
  alu_op     = 4'b0000;
  case (opcode)
    OPC_OP: begin
      reg_write = 1'b1;
      alu_src   = 1'b0;
      case (funct3)
        3'b000: alu_op = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000;
        3'b111: alu_op = 4'b0010;
        3'b110: alu_op = 4'b0011;
        3'b100: alu_op = 4'b0100;
        3'b010: alu_op = 4'b0101;
        3'b011: alu_op = 4'b0110;
        3'b001: alu_op = 4'b0111;
        3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b1001 : 4'b1000;
        default: alu_op = 4'b0000;
      endcase
    end
    OPC_OP_IMM: begin
      reg_write = 1'b1;
      alu_src   = 1'b1;
      case (funct3)
        3'b000: alu_op = 4'b0000;
        3'b111: alu_op = 4'b0010;
        3'b110: alu_op = 4'b0011;
        3'b100: alu_op = 4'b0100;
        3'b010: alu_op = 4'b0101;
        3'b011: alu_op = 4'b0110;
        3'b001: alu_op = 4'b0111;
        3'b101: alu_op = (funct7[5] == 1'b1) ? 4'b1001 : 4'b1000;
        default: alu_op = 4'b0000;
      endcase
    end
    OPC_LOAD: begin
      reg_write  = 1'b1;
      mem_read   = 1'b1;
      mem_to_reg = 1'b1;
      alu_src    = 1'b1;
      alu_op     = 4'b0000;
    end
    OPC_STORE: begin
      mem_write  = 1'b1;
      alu_src    = 1'b1;
      alu_op     = 4'b0000;
    end
    OPC_BRANCH: begin
      branch  = 1'b1;
      alu_src = 1'b0;
      alu_op  = 4'b0001;
    end
    OPC_JAL,
    OPC_JALR: begin
      jump      = 1'b1;
      reg_write = 1'b1;
      alu_src   = 1'b1;
      alu_op    = 4'b0000;
    end
    OPC_LUI,
    OPC_AUIPC: begin
      reg_write = 1'b1;
      alu_src   = 1'b1;
      alu_op    = 4'b0000;
    end
    default: begin
      reg_write  = 1'b0;
      mem_read   = 1'b0;
      mem_write  = 1'b0;
      branch     = 1'b0;
      jump       = 1'b0;
      mem_to_reg = 1'b0;
      alu_src    = 1'b0;
      alu_op     = 4'b0000;
    end
  endcase
end
endmodule
