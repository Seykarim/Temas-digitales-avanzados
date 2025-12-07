`timescale 1ns/1ps
module RegFile32_TB;
reg clk = 0;
reg reset = 1;
reg write_enable;
reg [4:0] write_address;
reg [31:0] write_data;
reg [4:0] read_address_1;
reg [4:0] read_address_2;
wire [31:0] read_data_1;
wire [31:0] read_data_2;
integer i;
RegFile32 banco_registros(
  .clk(clk),
  .reset(reset),
  .write_enable(write_enable),
  .write_address(write_address),
  .write_data(write_data),
  .read_address_1(read_address_1),
  .read_address_2(read_address_2),
  .read_data_1(read_data_1),
  .read_data_2(read_data_2)
);
always #5 clk = ~clk;
task escribir_registro;
  input [4:0] addr;
  input [31:0] data;
  begin
    write_enable   = 1'b1;
    write_address  = addr;
    write_data     = data;
    #10;
    write_enable   = 1'b0;
    write_address  = 5'd0;
    write_data     = 32'd0;
    #10;
  end
endtask
task leer_registros;
  input [4:0] addr1;
  input [4:0] addr2;
  begin
    read_address_1 = addr1;
    read_address_2 = addr2;
    #10;
  end
endtask
initial begin
  $dumpfile("regfile32_TB.vcd");
  $dumpvars(0,RegFile32_TB);
  write_enable   = 0;
  write_address  = 0;
  write_data     = 0;
  read_address_1 = 0;
  read_address_2 = 0;
  #20;
  reset = 0;
  escribir_registro(5'd1, 32'h00000011);
  escribir_registro(5'd2, 32'h00000022);
  escribir_registro(5'd3, 32'h00000033);
  escribir_registro(5'd0, 32'hFFFFFFFF);
  leer_registros(5'd1, 5'd2);
  leer_registros(5'd3, 5'd0);
  for (i = 4; i < 8; i = i + 1) begin
    escribir_registro(i[4:0], {27'd0, i[4:0]});
  end
  leer_registros(5'd4, 5'd5);
  leer_registros(5'd6, 5'd7);
  #50;
  $finish;
end
endmodule
