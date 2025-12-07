set ::env(DESIGN_NAME) perip_mult32

# Archivos RTL del diseño
set ::env(VERILOG_FILES) "\
  $::env(DESIGN_DIR)/src/perip_mult32.v \
  $::env(DESIGN_DIR)/src/mult32_iter.v \
"

# Puerto de reloj (ajusta si usas otro nombre)
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10.0"   ;# 100 MHz

# Reset asíncrono/síncrono, si quieres fijarlo
set ::env(RESET_PORT) "rst"
set ::env(RESET_ASSERTION_LEVEL) 1

# Parámetros básicos de flujo
set ::env(SYNTH_STRATEGY) "AREA 0"
set ::env(PL_TARGET_DENSITY) 0.50
set ::env(FP_CORE_UTIL) 40
