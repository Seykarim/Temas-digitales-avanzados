#!/usr/bin/env bash
set -euo pipefail
mkdir -p logs

timestamp() { date '+%Y-%m-%d_%H-%M-%S'; }

echo "==> Inicio run_all $(timestamp)" | tee -a logs/run_all.log

# Python
if command -v python3 >/dev/null 2>&1; then
  if [ -f "requirements.txt" ]; then
    echo "[PY] Creando venv..." | tee -a logs/run_all.log
    python3 -m venv .venv || true
    source .venv/bin/activate
    pip install --upgrade pip >/dev/null 2>&1 || true
    pip install -r requirements.txt | tee -a logs/run_all.log || true
  fi
  if [ -f "main.py" ]; then
    echo "[PY] Ejecutando main.py" | tee -a logs/run_all.log
    (python3 main.py) > "logs/python_main_$(timestamp).log" 2>&1 || echo "[PY] main.py terminó con código no cero" | tee -a logs/run_all.log
  elif [ -f "app.py" ]; then
    echo "[PY] Ejecutando app.py" | tee -a logs/run_all.log
    (python3 app.py) > "logs/python_app_$(timestamp).log" 2>&1 || echo "[PY] app.py terminó con código no cero" | tee -a logs/run_all.log
  fi
fi

# MATLAB
if command -v matlab >/dev/null 2>&1; then
  if [ -f "main.m" ]; then
    echo "[MATLAB] Ejecutando main.m" | tee -a logs/run_all.log
    matlab -batch "try, run('main.m'); catch ME, disp(getReport(ME,'extended')); exit(1); end; exit(0);" \
      > "logs/matlab_main_$(timestamp).log" 2>&1 || echo "[MATLAB] Error en main.m" | tee -a logs/run_all.log
  elif [ -f "run.m" ]; then
    echo "[MATLAB] Ejecutando run.m" | tee -a logs/run_all.log
    matlab -batch "try, run('run.m'); catch ME, disp(getReport(ME,'extended')); exit(1); end; exit(0);" \
      > "logs/matlab_run_$(timestamp).log" 2>&1 || echo "[MATLAB] Error en run.m" | tee -a logs/run_all.log
  fi
fi

# Make
if [ -f "Makefile" ] || [ -f "makefile" ]; then
  echo "[MAKE] Ejecutando make" | tee -a logs/run_all.log
  (make -j) > "logs/make_$(timestamp).log" 2>&1 || echo "[MAKE] Error en make" | tee -a logs/run_all.log
fi

# Bash scripts
if [ -d "scripts" ]; then
  echo "[BASH] Ejecutando scripts/*.sh (si son ejecutables)" | tee -a logs/run_all.log
  for s in scripts/*.sh; do
    [ -f "$s" ] || continue
    chmod +x "$s" || true
    echo "  -> $s" | tee -a logs/run_all.log
    ("$s") > "logs/$(basename "$s")_$(timestamp).log" 2>&1 || echo "[BASH] Error en $s" | tee -a logs/run_all.log
  done
fi

echo "==> Fin run_all $(timestamp)" | tee -a logs/run_all.log
