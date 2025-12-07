#!/bin/bash
set -e
cd "$(dirname "$0")/.."

cd femtoRV
mkdir -p build sim
rm -f build/* sim/*.vcd
iverilog -g2012 -Wall -o build/femto_tb femto_TB.v femto.v cores/sim_spi_flash/spiflash.v cores/sim_spi_ram/spiram.v
vvp build/femto_tb
mv *.vcd sim/ || true

cd ../TemasAvanzadosDigital
mkdir -p build sim
rm -f build/* sim/*.vcd
iverilog -g2012 -Wall -o build/soc_tb SOC_flash_TB.v SOC_flash.v ../femtoRV/femto.v ../femtoRV/cores/sim_spi_flash/spiflash.v ../femtoRV/cores/sim_spi_ram/spiram.v
vvp build/soc_tb
mv *.vcd sim/ || true

cd ../VLSI
mkdir -p build sim
rm -f build/* sim/*.vcd
iverilog -g2012 -Wall -o build/femtorv_soc_tb \
  reference/ttsky25b-femtorv-soc/test/tb.v \
  reference/ttsky25b-femtorv-soc/test/tb_dump.v \
  $(find reference/ttsky25b-femtorv-soc/src -maxdepth 5 -name '*.v' -print)
vvp build/femtorv_soc_tb
mv *.vcd sim/ || true
