`timescale 1ns/1ps
module Bram32 #(
  parameter ADDR_WIDTH = 10
)(
  input clk,
  input we,
  input [ADDR_WIDTH-1:0] addr,
  input [31:0] din,
  output reg [31:0] dout
);
reg [31:0] mem[0:(1<<ADDR_WIDTH)-1];
initial begin
  $readmemh("program.mem", mem);
end
always @(posedge clk) begin
  if (we) mem[addr] <= din;
  dout <= mem[addr];
end
endmodule
