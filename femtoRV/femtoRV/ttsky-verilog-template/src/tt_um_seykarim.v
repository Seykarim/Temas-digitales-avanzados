`timescale 1ns/1ps

// Módulo mínimo para TinyTapeout con la interfaz estándar.
// Por ahora, solo hace una operación sencilla sobre ui_in
// para que podamos simular y ver algo en GTKWave.
module tt_um_seykarim (
    input  wire        clk,     // reloj global
    input  wire        rst_n,   // reset activo en 0
    input  wire        ena,     // enable del tile
    input  wire [7:0]  ui_in,   // entradas de usuario
    output reg  [7:0]  uo_out,  // salidas de usuario
    input  wire [7:0]  uio_in,  // IO bidireccional - entradas
    output wire [7:0]  uio_out, // IO bidireccional - salidas
    output wire [7:0]  uio_oe   // IO bidireccional - enable de salida
);

    // En este ejemplo, no usamos los uio_*,
    // así que los dejamos en high-Z (no manejados).
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    // Lógica sencilla de ejemplo:
    // - Mientras rst_n=0: uo_out = 0
    // - Cuando rst_n=1 y ena=1: salida = ui_in + 1
    // Puedes cambiar esto luego por tu multiplicador o lo que quieras.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uo_out <= 8'h00;
        end else if (ena) begin
            uo_out <= ui_in + 8'h01;
        end else begin
            uo_out <= uo_out; // mantiene valor
        end
    end

endmodule
