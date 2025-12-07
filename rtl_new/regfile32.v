`timescale 1ns/1ps
module RegFile32(
  input         clk,
  input         reset,
  input         write_enable,
  input  [4:0]  write_address,
  input  [31:0] write_data,
  input  [4:0]  read_address_1,
  input  [4:0]  read_address_2,
  output [31:0] read_data_1,
  output [31:0] read_data_2
);
reg [31:0] registers[31:0];
integer i;
always @(posedge clk) begin
  if (reset) begin
    for (i = 0; i < 32; i = i + 1) begin
      registers[i] <= 32'd0;
    end
  end else begin
    if (write_enable && (write_address != 5'd0)) begin
      registers[write_address] <= write_data;
    end
    registers[0] <= 32'd0;
  end
end
assign read_data_1 = (read_address_1 == 5'd0) ? 32'd0 : registers[read_address_1];
assign read_data_2 = (read_address_2 == 5'd0) ? 32'd0 : registers[read_address_2];
endmodule
