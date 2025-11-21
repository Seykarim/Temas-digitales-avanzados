`timescale 1ns / 1ps

// Testbench mínimo para el módulo tt_um_seykarim
module tb_tt_um_seykarim;

  // Reloj y reset
  reg clk = 0;
  reg rst_n = 0;

  // Entradas/salidas de usuario (ajusta según tu mult.v si hace falta)
  reg  [7:0] ui_in  = 8'h00;   // entradas de usuario
  wire [7:0] uo_out;           // salidas de usuario

  // Señales auxiliares típicas de TT (según plantilla genérica)
  reg  ena = 1'b1;
  reg  [7:0] uio_in  = 8'h00;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Instancia del DUT (tu módulo para TinyTapeout)
  tt_um_seykarim dut (
    .clk    (clk),
    .rst_n  (rst_n),
    .ena    (ena),
    .ui_in  (ui_in),
    .uo_out (uo_out),
    .uio_in (uio_in),
    .uio_out(uio_out),
    .uio_oe (uio_oe)
  );

  // Generación de reloj
  always #5 clk = ~clk;   // 100 MHz (periodo 10 ns)

  // Estímulos
  initial begin
    // VCD
    $dumpfile("tt_um_seykarim.vcd");
    $dumpvars(0, tb_tt_um_seykarim);

    // Reset activo algún tiempo
    rst_n = 0;
    ui_in = 8'h00;
    #50;
    rst_n = 1;

    // Algunos patrones de prueba
    #50 ui_in = 8'h03;
    #50 ui_in = 8'h05;
    #50 ui_in = 8'h0A;
    #50 ui_in = 8'hFF;

    // Espera un rato y termina
    #200;
    $finish;
  end

endmodule
