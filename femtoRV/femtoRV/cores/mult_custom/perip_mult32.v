`timescale 1ns / 1ps

module perip_mult32 #(
  parameter ADDR_WIDTH = 4,
  parameter DATA_WIDTH = 32
)(
  input  wire                   clk,
  input  wire                   rst,

  // interfaz tipo bus simple
  input  wire                   we,      // write enable
  input  wire                   re,      // read enable
  input  wire [ADDR_WIDTH-1:0]  addr,    // dirección de registro
  input  wire [DATA_WIDTH-1:0]  wdata,   // dato a escribir
  output reg  [DATA_WIDTH-1:0]  rdata,   // dato leído

  output wire                   busy,
  output wire                   done
);

  // direcciones de registros
  localparam ADDR_A       = 4'h0;
  localparam ADDR_B       = 4'h1;
  localparam ADDR_CTRL    = 4'h2;
  localparam ADDR_RES_LO  = 4'h3;
  localparam ADDR_RES_HI  = 4'h4;
  localparam ADDR_STATUS  = 4'h5;

  // registros internos
  reg [DATA_WIDTH-1:0]   reg_a;
  reg [DATA_WIDTH-1:0]   reg_b;
  reg [2*DATA_WIDTH-1:0] reg_result;

  // wires internos de mult32_iter
  wire [2*DATA_WIDTH-1:0] mult_result;
  wire                    mult_busy;
  wire                    mult_done;

  // pulso de start de un ciclo
  reg start_pulse;

  // escritura de registros y generación de start
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      reg_a      <= {DATA_WIDTH{1'b0}};
      reg_b      <= {DATA_WIDTH{1'b0}};
      reg_result <= {2*DATA_WIDTH{1'b0}};
      start_pulse<= 1'b0;
    end else begin
      start_pulse <= 1'b0; // por defecto

      if (we) begin
        case (addr)
          ADDR_A: begin
            reg_a <= wdata;
          end
          ADDR_B: begin
            reg_b <= wdata;
          end
          ADDR_CTRL: begin
            // bit0 = start, sólo si no está ocupado
            if (wdata[0] && !mult_busy)
              start_pulse <= 1'b1;
          end
        endcase
      end

      // cuando el multiplicador termina, se captura el resultado
      if (mult_done) begin
        reg_result <= mult_result;
      end
    end
  end

  // lectura de registros
  always @(*) begin
    rdata = {DATA_WIDTH{1'b0}};
    if (re) begin
      case (addr)
        ADDR_A:      rdata = reg_a;
        ADDR_B:      rdata = reg_b;
        ADDR_CTRL:   rdata = { {DATA_WIDTH-1{1'b0}}, 1'b0 }; // sin flags especiales
        ADDR_RES_LO: rdata = reg_result[31:0];
        ADDR_RES_HI: rdata = reg_result[63:32];
        ADDR_STATUS: rdata = { {DATA_WIDTH-2{1'b0}}, mult_busy, mult_done };
        default:     rdata = {DATA_WIDTH{1'b0}};
      endcase
    end
  end

  // instancia del núcleo iterativo
  mult32_iter #(
    .WIDTH(DATA_WIDTH)
  ) u_mult32_iter (
    .clk    (clk),
    .rst    (rst),
    .start  (start_pulse),
    .a      (reg_a),
    .b      (reg_b),
    .result (mult_result),
    .busy   (mult_busy),
    .done   (mult_done)
  );

  assign busy = mult_busy;
  assign done = mult_done;

endmodule
