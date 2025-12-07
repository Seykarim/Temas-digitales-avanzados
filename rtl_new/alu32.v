`timescale 1ns/1ps
module ALU32(
  input  [31:0] a,
  input  [31:0] b,
  input  [3:0]  alu_op,
  output reg [31:0] y,
  output zero,
  output carry,
  output negative,
  output overflow
);
reg c_internal;
reg v_internal;
wire [31:0] b_neg;
assign b_neg = ~b + 32'd1;
always @* begin
  c_internal = 1'b0;
  v_internal = 1'b0;
  case (alu_op)
    4'b0000: begin
      {c_internal,y} = {1'b0,a} + {1'b0,b};
      v_internal = (a[31] == b[31]) && (y[31] != a[31]);
    end
    4'b0001: begin
      {c_internal,y} = {1'b0,a} + {1'b0,b_neg};
      v_internal = (a[31] != b[31]) && (y[31] != a[31]);
    end
    4'b0010: y = a & b;
    4'b0011: y = a | b;
    4'b0100: y = a ^ b;
    4'b0101: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
    4'b0110: y = (a < b) ? 32'd1 : 32'd0;
    4'b0111: y = a << b[4:0];
    4'b1000: y = a >> b[4:0];
    4'b1001: y = $signed(a) >>> b[4:0];
    default: y = 32'd0;
  endcase
end
assign zero = (y == 32'd0);
assign negative = y[31];
assign carry = c_internal;
assign overflow = v_internal;
endmodule
