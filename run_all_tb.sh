#!/usr/bin/env bash
set -euo pipefail
REPO="$(pwd)"
SRC_DIRS=(src src/rtl rtl hw src_verilog verilog)  # carpetas típicas
TB_DIRS=(tb testbench sim tb_verilog)              # carpetas típicas de TB
BLD_DIR="${REPO}/build"
mkdir -p "$BLD_DIR"

# Recolecta fuentes .v/.sv
SV_SRC=()
V_SRC=()
for d in "${SRC_DIRS[@]}"; do
  [ -d "$d" ] || continue
  while IFS= read -r -d '' f; do SV_SRC+=("$f"); done < <(find "$d" -maxdepth 3 -type f -name '*.sv' -print0 2>/dev/null || true)
  while IFS= read -r -d '' f; do V_SRC+=("$f");  done < <(find "$d" -maxdepth 3 -type f -name '*.v'  -print0 2>/dev/null || true)
done

# Detecta testbenches: archivo que defina un módulo que empiece por tb_
TB_FILES=()
for d in "${TB_DIRS[@]}"; do
  [ -d "$d" ] || continue
  while IFS= read -r -d '' f; do TB_FILES+=("$f"); done < <(find "$d" -maxdepth 3 -type f \( -name '*.sv' -o -name '*.v' \) -print0 2>/dev/null || true)
done

# Filtra por módulo tb_*
declare -A TBMAP
for f in "${TB_FILES[@]:-}"; do
  MOD=$(grep -E '^\s*module\s+tb_[A-Za-z0-9_]+' "$f" -o | awk '{print $2}' | head -n1 || true)
  [ -n "${MOD:-}" ] && TBMAP["$f"]="$MOD"
done

if [ ${#TBMAP[@]} -eq 0 ]; then
  echo "⚠️  No encontré testbenches con módulos tb_*."
  echo "   - Busca módulos con:  grep -R \"^\\s*module\\s\\+tb_\" -n ."
  echo "   - Módulos disponibles (no TB):"
  grep -R "^\s*module\s\+[A-Za-z0-9_]\+" -n . | sed -E 's/:.*module\s+([A-Za-z0-9_]+).*/:\1/' | awk -F: '{print $2}' | sort -u | sed 's/^/     · /'
  echo
  echo "👉 Crea un testbench mínimo 'tb_auto.sv' así (ajusta TOP_REAL):"
  cat <<'EOT'
module tb_auto;
  // Instancia del DUT (cambia TOP_REAL por el nombre real de tu top)
  // TOP_REAL dut();
  initial begin
    $dumpfile("build/tb_auto.vcd");
    $dumpvars(0, tb_auto);
    #1000 $finish;
  end
endmodule
EOT
  exit 1
fi

echo "➡️  Testbenches detectados:"
for k in "${!TBMAP[@]}"; do printf "   · %s   (top TB: %s)\n" "$k" "${TBMAP[$k]}"; done

# Compila y simula cada TB, generando un VCD por TB
for TB in "${!TBMAP[@]}"; do
  TOP_TB="${TBMAP[$TB]}"
  BASENAME="$(basename "$TB")"
  NAME="${BASENAME%.*}"
  VVP="${BLD_DIR}/${NAME}.vvp"
  VCD="${BLD_DIR}/${NAME}.vcd"
  echo "=== Compilando: $TB  (TOP_TB=$TOP_TB) ==="

  iverilog -g2012 -I . $(for d in "${SRC_DIRS[@]}" "${TB_DIRS[@]}"; do [ -d "$d" ] && printf -- "-I %s " "$d"; done) \
    -o "$VVP" -s "$TOP_TB" "$TB" "${SV_SRC[@]}" "${V_SRC[@]}"

  # Limpia VCD por defecto si TB usa 'waves.vcd'
  rm -f "$VCD" "${BLD_DIR}/waves.vcd"

  vvp "$VVP" || echo "[WARN] Simulación con código != 0"

  # Renombra VCD si se generó como waves.vcd
  [ -f "${BLD_DIR}/waves.vcd" ] && mv "${BLD_DIR}/waves.vcd" "$VCD" || true

  if [ -f "$VCD" ]; then
    echo "→ VCD: $VCD"
  else
    echo "[WARN] No se generó $VCD. Asegúrate de tener \$dumpfile/\$dumpvars en $TB"
  fi
done

echo
echo "✅ Listo. Abre el que quieras en GTKWave, por ejemplo:"
ls -1 ${BLD_DIR}/*.vcd 2>/dev/null | sed 's/^/   gtkwave /' | head -n 5
