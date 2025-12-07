#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p build sim
rm -f build/alu32_tb sim/alu32_TB.vcd
iverilog -g2012 -Wall -o build/alu32_tb rtl_new/alu32.v tb_new/alu32_TB.v
vvp build/alu32_tb
mv alu32_TB.vcd sim/ || true
