`timescale 1ns / 1ps

module mult32_iter #(
  parameter WIDTH = 32
)(
  input  wire                  clk,
  input  wire                  rst,
  input  wire                  start,
  input  wire [WIDTH-1:0]      a,
  input  wire [WIDTH-1:0]      b,
  output reg  [2*WIDTH-1:0]    result,
  output reg                   busy,
  output reg                   done
);

  // registros internos
  reg [WIDTH-1:0]      multiplicand;
  reg [WIDTH-1:0]      multiplier;
  reg [2*WIDTH-1:0]    acc;
  reg [$clog2(WIDTH):0] count;

  // FSM simple: 0 = IDLE, 1 = RUN
  localparam IDLE = 1'b0;
  localparam RUN  = 1'b1;

  reg state;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state        <= IDLE;
      busy         <= 1'b0;
      done         <= 1'b0;
      acc          <= 0;
      multiplicand <= 0;
      multiplier   <= 0;
      count        <= 0;
      result       <= 0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            busy         <= 1'b1;
            multiplicand <= a;
            multiplier   <= b;
            acc          <= 0;
            count        <= WIDTH;
            state        <= RUN;
          end
        end

        RUN: begin
          if (multiplier[0])
            acc <= acc + {{WIDTH{1'b0}}, multiplicand};

          multiplicand <= multiplicand << 1;
          multiplier   <= multiplier   >> 1;

          if (count == 0) begin
            result <= acc;
            busy   <= 1'b0;
            done   <= 1'b1;
            state  <= IDLE;
          end else begin
            count <= count - 1;
          end
        end
      endcase
    end
  end

endmodule
