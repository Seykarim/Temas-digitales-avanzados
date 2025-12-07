`timescale 1ns / 1ps

module tb_perip_mult32_bus;
  localparam ADDR_WIDTH = 4;
  localparam DATA_WIDTH = 32;
  
  reg                   clk   = 0;
  reg                   rst   = 0;
  reg                   we    = 0;
  reg                   re    = 0;
  reg  [ADDR_WIDTH-1:0] addr  = 0;
  reg  [DATA_WIDTH-1:0] wdata = 0;
  wire [DATA_WIDTH-1:0] rdata;
  wire                  busy;
  wire                  done;
  
  // Mapa de registros coherente con perip_mult32
  localparam ADDR_A       = 4'h0;
  localparam ADDR_B       = 4'h1;
  localparam ADDR_CTRL    = 4'h2;
  localparam ADDR_RES_LO  = 4'h3;
  localparam ADDR_RES_HI  = 4'h4;
  localparam ADDR_STATUS  = 4'h5;
  
  // DUT: periférico de multiplicador
  perip_mult32 #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk   (clk),
    .rst   (rst),
    .we    (we),
    .re    (re),
    .addr  (addr),
    .wdata (wdata),
    .rdata (rdata),
    .busy  (busy),
    .done  (done)
  );
  
  // Reloj 100 MHz (10 ns)
  always #5 clk = ~clk;
  
  // ==========================
  //  TAREAS DE BUS
  // ==========================

  task bus_write(input [ADDR_WIDTH-1:0] a, input [DATA_WIDTH-1:0] d);
  begin
    @(posedge clk);
    addr  = a;
    wdata = d;
    we    = 1'b1;
    re    = 1'b0;
    @(posedge clk);
    we    = 1'b0;
    $display("  [%0t] BUS_WRITE: addr=0x%0h, data=0x%08h", $time, a, d);
  end
  endtask
  
  task bus_read(input [ADDR_WIDTH-1:0] a, output [DATA_WIDTH-1:0] d);
  begin
    @(posedge clk);
    addr = a;
    we   = 1'b0;
    re   = 1'b1;
    @(posedge clk);
    d    = rdata;
    re   = 1'b0;
    $display("  [%0t] BUS_READ: addr=0x%0h, data=0x%08h", $time, a, d);
  end
  endtask
  
  // ==========================
  //  CASO DE PRUEBA
  // ==========================

  task run_case(input [DATA_WIDTH-1:0] aa, input [DATA_WIDTH-1:0] bb);
    reg [DATA_WIDTH-1:0] tmp;
    reg [DATA_WIDTH-1:0] res_lo, res_hi;
    reg [2*DATA_WIDTH-1:0] expected, got;
    integer timeout;
  begin
    expected = aa * bb;
    $display("\n[%0t] === Test: %0d × %0d (esperado = %0d) ===", 
             $time, aa, bb, expected);
    
    // Escribir operandos
    bus_write(ADDR_A, aa);
    bus_write(ADDR_B, bb);
    
    // (Opcional) leer A para confirmar
    bus_read(ADDR_A, tmp);
    if (tmp !== aa)
      $display("  WARNING: A readback = %0d (esperado %0d)", tmp, aa);
    
    // Arrancar multiplicación (CTRL bit0 = 1)
    bus_write(ADDR_CTRL, 32'h00000001);
    
    // Esperar done con timeout sencillo
    timeout = 0;
    $display("  [%0t] Esperando done (señal directa)...", $time);
    while (!done && timeout < 500) begin
      @(posedge clk);
      timeout = timeout + 1;
      if (timeout % 50 == 0)
        $display("    Ciclo %0d: busy=%b, done=%b", timeout, busy, done);
    end
    
    if (timeout >= 500) begin
      $display("  [%0t] *** TIMEOUT *** Multiplicación no completó", $time);
      $display("    busy=%b, done=%b, ciclos=%0d", busy, done, timeout);
    end else begin
      $display("  [%0t] Operación completada en %0d ciclos", $time, timeout);
    end
    
    // Leer resultado
    bus_read(ADDR_RES_LO, res_lo);
    bus_read(ADDR_RES_HI, res_hi);
    got = {res_hi, res_lo};
    
    // Verificar
    if (got === expected) begin
      $display("  [%0t] ✓ PASS: %0d × %0d = %0d", $time, aa, bb, got);
    end else begin
      $display("  [%0t] ✗ FAIL: %0d × %0d = %0d (esperado %0d)", 
               $time, aa, bb, got, expected);
      $display("    Diferencia: %0d", $signed(got) - $signed(expected));
    end
    
    // Pausa entre tests
    repeat(5) @(posedge clk);
  end
  endtask
  
  // ==========================
  //  SECUENCIA PRINCIPAL
  // ==========================

  initial begin
    $dumpfile("perip_mult32_bus.vcd");
    $dumpvars(0, tb_perip_mult32_bus);
    
    $display("\n=== Testbench perip_mult32 (Bus Interface) ===");
    $display("ADDR_WIDTH=%0d, DATA_WIDTH=%0d", ADDR_WIDTH, DATA_WIDTH);
    
    // Reset
    $display("\n[%0t] Aplicando reset...", $time);
    rst = 1'b1;
    repeat(10) @(posedge clk);
    rst = 1'b0;
    repeat(5) @(posedge clk);
    
    // Casos de prueba
    run_case(32'd0,     32'd0);
    run_case(32'd1,     32'd1);
    run_case(32'd1,     32'd7);
    run_case(32'd3,     32'd5);
    run_case(32'd10,    32'd20);
    run_case(32'd123,   32'd456);
    run_case(32'd255,   32'd255);
    run_case(32'd1000,  32'd1000);
    run_case(32'd65535, 32'd2);
    
    repeat(20) @(posedge clk);
    $display("\n=== Fin de testbench perip_mult32 (bus) ===");
    $finish;
  end
  
  // Watchdog global
  initial begin
    #1000000;  // 1ms a 100 MHz
    $display("\n*** WATCHDOG TIMEOUT - Test colgado ***");
    $finish;
  end
  
endmodule
