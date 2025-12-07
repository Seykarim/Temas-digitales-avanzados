`timescale 1ns / 1ps

module tb_perip_mult32;

  localparam WIDTH = 32;

  reg                   clk   = 0;
  reg                   rst   = 0;
  reg                   start = 0;
  reg  [WIDTH-1:0]      a     = 0;
  reg  [WIDTH-1:0]      b     = 0;
  wire [2*WIDTH-1:0]    result;
  wire                  busy;
  wire                  done;

  // DUT: tu multiplicador iterativo
  mult32_iter #(
    .WIDTH(WIDTH)
  ) dut (
    .clk   (clk),
    .rst   (rst),
    .start (start),
    .a     (a),
    .b     (b),
    .result(result),
    .busy  (busy),
    .done  (done)
  );

  // reloj 100 MHz (10 ns)
  always #5 clk = ~clk;

  // tarea para correr un caso de prueba
  task run_case(input [WIDTH-1:0] aa, input [WIDTH-1:0] bb);
    reg [2*WIDTH-1:0] expected;
  begin
    expected = aa * bb;

    // lanzar operación
    @(negedge clk);
    a     <= aa;
    b     <= bb;
    start <= 1'b1;

    @(negedge clk);
    start <= 1'b0;

    // esperar a que termine
    wait(done == 1'b1);
    @(negedge clk);

    // verificar
    if (result === expected)
      $display("[%0t] OK: %0d * %0d = %0d", $time, aa, bb, result);
    else
      $display("[%0t] ERROR: %0d * %0d -> result = %0d, esperado = %0d",
               $time, aa, bb, result, expected);
  end
  endtask

  initial begin
    // VCD
    $dumpfile("perip_mult32_tb.vcd");
    $dumpvars(0, tb_perip_mult32);

    // reset
    rst = 1'b1;
    #40;
    rst = 1'b0;

    // casos de prueba
    run_case(32'd0,   32'd0);
    run_case(32'd1,   32'd7);
    run_case(32'd3,   32'd5);
    run_case(32'd10,  32'd20);
    run_case(32'd123, 32'd456);
    run_case(32'd255, 32'd255);

    #100;
    $display("=== Fin de testbench mult32_iter ===");
    $finish;
  end

endmodule
