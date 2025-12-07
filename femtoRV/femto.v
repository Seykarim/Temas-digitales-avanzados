`timescale 1ns / 1ps

// Top mínimo para que femto_TB.v pueda compilar y generar VCD.
// Más adelante se puede reemplazar por el femto completo del profesor.
module femto (
    input  wire CLK,       // reloj del TB
    input  wire RESET,     // reset del TB (activo en alto o en bajo según tu TB)
    input  wire RXD,       // UART RX desde el testbench
    output wire TXD,       // UART TX hacia el testbench
    output wire [7:0] LEDS, // LEDs hacia el testbench

    // Pines SPI hacia los modelos de spiflash / spiram en el testbench
    output wire spi_clk,
    output wire spi_cs_n,
    input  wire spi_miso,
    output wire spi_mosi
);

    // ----------------------------------------------------------------
    // IMPLEMENTACIÓN "DUMMY"
    // ----------------------------------------------------------------
    // Por ahora, solo generamos algo sencillo y visible:
    //  - Un contador en los LEDs
    //  - TXD en '1'
    //  - SPI en valores constantes
    // Esto permite:
    //  - Compilar
    //  - Ver actividad en femto_TB.vcd
    // Más adelante puedes reemplazarlo por el SoC completo.
    // ----------------------------------------------------------------

    reg [31:0] counter;
    reg [7:0] leds_reg;

    assign LEDS = leds_reg;

    // UART TX siempre en reposo (nivel alto para línea idle)
    assign TXD = 1'b1;

    // SPI en valores fijos (para que TB vea señales válidas)
    assign spi_clk  = 1'b0;
    assign spi_cs_n = 1'b1; // deseleccionado
    assign spi_mosi = 1'b0;

    // Contador simple para ver movimiento en los LEDs
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            counter  <= 32'd0;
            leds_reg <= 8'h00;
        end else begin
            counter <= counter + 1;
            // por ejemplo, mostrar los bits [27:20] del contador
            leds_reg <= counter[27:20];
        end
    end

endmodule

