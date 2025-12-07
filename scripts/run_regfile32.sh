#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p build sim
rm -f build/regfile32_tb sim/regfile32_TB.vcd
iverilog -g2012 -Wall -o build/regfile32_tb rtl_new/regfile32.v tb_new/regfile32_TB.v
vvp build/regfile32_tb
mv regfile32_TB.vcd sim/ || true
