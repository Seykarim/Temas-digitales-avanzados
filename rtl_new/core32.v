`timescale 1ns/1ps
module Core32(
  input clk,
  input reset,
  output [31:0] instr_addr,
  input  [31:0] instr_rdata,
  output [31:0] data_addr,
  output [31:0] data_wdata,
  input  [31:0] data_rdata,
  output data_we
);
reg [31:0] pc;
always @(posedge clk) begin
  if (reset) pc <= 32'd0;
  else pc <= pc + 32'd4;
end
assign instr_addr = pc;
assign data_addr = 32'd0;
assign data_wdata = 32'd0;
assign data_we = 1'b0;
endmodule
