`timescale 1ns/1ps
module SOC_flash(
  input clk,
  input reset,
  output [31:0] pc_out,
  output [31:0] instr_out
);
wire [31:0] instr_addr;
wire [31:0] instr_rdata;
wire [31:0] data_addr;
wire [31:0] data_wdata;
wire [31:0] data_rdata;
wire data_we;
Core32 core(
  .clk(clk),
  .reset(reset),
  .instr_addr(instr_addr),
  .instr_rdata(instr_rdata),
  .data_addr(data_addr),
  .data_wdata(data_wdata),
  .data_rdata(data_rdata),
  .data_we(data_we)
);
Bram32 #(
  .ADDR_WIDTH(10)
) instr_mem(
  .clk(clk),
  .we(1'b0),
  .addr(instr_addr[11:2]),
  .din(32'd0),
  .dout(instr_rdata)
);
assign data_rdata = 32'd0;
assign pc_out = instr_addr;
assign instr_out = instr_rdata;
endmodule
