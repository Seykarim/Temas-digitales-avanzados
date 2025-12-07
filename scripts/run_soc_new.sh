#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p build sim
rm -f build/* sim/*.vcd
iverilog -g2012 -Wall -o build/SOC_flash_tb_new rtl_new/core32.v rtl_new/bram32.v rtl_new/SOC_flash.v tb_new/SOC_flash_TB.v
vvp build/SOC_flash_tb_new
mv SOC_flash_TB.vcd sim/ || true
