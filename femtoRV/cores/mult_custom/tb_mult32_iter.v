`timescale 1ns / 1ps

module tb_mult32_iter;

    localparam N = 32;

    reg              clk = 0;
    reg              rst = 0;
    reg              start = 0;
    reg  [N-1:0]     a = 0;
    reg  [N-1:0]     b = 0;
    wire             busy;
    wire             done;
    wire [2*N-1:0]   result;

    // DUT
    mult32_iter #(
        .N(N)
    ) dut (
        .clk    (clk),
        .rst    (rst),
        .start  (start),
        .a      (a),
        .b      (b),
        .busy   (busy),
        .done   (done),
        .result (result)
    );

    // Reloj 100MHz (10ns periodo)
    always #5 clk = ~clk;

    integer i;
    reg [2*N-1:0] expected;

    task run_test(input [N-1:0] aa, input [N-1:0] bb);
    begin
        // Aplicar inputs
        a = aa;
        b = bb;
        expected = aa * bb;

        // Generar pulso de start
        @(negedge clk);
        start = 1;
        @(negedge clk);
        start = 0;

        // Esperar a que done se ponga en 1
        wait(done == 1'b1);
        @(posedge clk); // capturamos resultado

        if (result !== expected) begin
            $display("ERROR: a=%0d (0x%08h), b=%0d (0x%08h) -> result=0x%016h, expected=0x%016h",
                     aa, aa, bb, bb, result, expected);
            $fatal(1, "Fallo en multiplicador");
        end else begin
            $display("OK: a=%0d, b=%0d, result=%0d (0x%016h)", aa, bb, result, result);
        end

        // Esperamos a que DONE baje (vuelve a IDLE)
        @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("mult32_iter_tb.vcd");
        $dumpvars(0, tb_mult32_iter);

        // Reset
        rst = 1;
        #50;
        rst = 0;

        // Casos básicos
        run_test(0, 0);
        run_test(0, 123);
        run_test(1, 98765);
        run_test(2, 3);
        run_test(10, 20);
        run_test(1234, 5678);
        run_test(32'hFFFF_FFFF, 2);
        run_test(32'h0000_FFFF, 32'h0000_FFFF);

        // Algunos aleatorios
        for (i = 0; i < 20; i = i + 1) begin
            run_test($random, $random);
        end

        $display("TODAS LAS PRUEBAS PASARON.");
        $finish;
    end

endmodule

