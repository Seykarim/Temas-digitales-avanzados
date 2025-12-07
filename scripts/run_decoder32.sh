#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p build sim
rm -f build/decoder32_tb sim/decoder32_TB.vcd
iverilog -g2012 -Wall -o build/decoder32_tb rtl_new/decoder32.v tb_new/decoder32_TB.v
vvp build/decoder32_tb
mv decoder32_TB.vcd sim/ || true
