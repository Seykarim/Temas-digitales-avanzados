#!/bin/bash
set -e
cd "$(dirname "$0")/../femtoRV"
mkdir -p build sim
rm -f build/femto_tb sim/femto_TB.vcd
iverilog -g2012 -Wall -o build/femto_tb \
  femto_TB.v femto.v \
  cores/sim_spi_flash/spiflash.v \
  cores/sim_spi_ram/spiram.v
vvp build/femto_tb
mv femto_TB.vcd sim/ || true
