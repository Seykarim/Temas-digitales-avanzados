SRC_DIRS ?= src rtl verilog src_verilog
TB_DIRS  ?= tb testbench sim tb_verilog
BLD_DIR  ?= build

SV_SRC := $(foreach d,$(SRC_DIRS),$(wildcard $(d)/*.sv))
V_SRC  := $(foreach d,$(SRC_DIRS),$(wildcard $(d)/*.v))
TB_ALL := $(foreach d,$(TB_DIRS),$(wildcard $(d)/*.sv) $(wildcard $(d)/*.v))

# Detecta primer testbench con módulo que empiece por tb_
TB_DETECTED := $(shell grep -R "^[[:space:]]*module[[:space:]]\\+tb_[A-Za-z0-9_]\\+" $(TB_ALL) -l 2>/dev/null | head -n1)
TOP_TB      := $(shell [ -n "$(TB_DETECTED)" ] && grep -E "^[[:space:]]*module[[:space:]]+tb_[A-Za-z0-9_]+" "$(TB_DETECTED)" -o | awk '{print $$2}' | head -n1)

TB_FILE ?= $(TB_DETECTED)
TOP     ?= $(TOP_TB)
VVP     := $(BLD_DIR)/$(notdir $(basename $(TB_FILE))).vvp
VCD     := $(BLD_DIR)/$(notdir $(basename $(TB_FILE))).vcd

.PHONY: all sim waves clean
all: sim

$(BLD_DIR):
	mkdir -p $(BLD_DIR)

sim: $(BLD_DIR)
	@if [ -z "$(TB_FILE)" ] || [ -z "$(TOP)" ]; then \
	  echo "No se detectó testbench tb_* automáticamente."; \
	  echo "Usa: make sim TB_FILE=tb/mi_tb.sv TOP=tb_mi_tb"; \
	  exit 1; \
	fi
	iverilog -g2012 $(foreach d,$(SRC_DIRS) $(TB_DIRS),-I $(d)) -o $(VVP) -s $(TOP) $(TB_FILE) $(SV_SRC) $(V_SRC)
	@rm -f $(BLD_DIR)/waves.vcd
	vvp $(VVP)

waves: sim
	@if [ -f $(BLD_DIR)/waves.vcd ]; then mv $(BLD_DIR)/waves.vcd $(VCD); fi
	@if [ -f $(VCD) ]; then gtkwave $(VCD) & else echo "No hay VCD. Asegura $dumpfile/$dumpvars en el TB."; fi

clean:
	rm -rf $(BLD_DIR)
