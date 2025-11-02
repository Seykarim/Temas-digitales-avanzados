#!/usr/bin/env bash
set -euo pipefail
mkdir -p logs

echo "==> Información del sistema" | tee logs/status.log
uname -a | tee -a logs/status.log
echo | tee -a logs/status.log

echo "==> Git: rama, remoto, estado" | tee -a logs/status.log
( git rev-parse --abbrev-ref HEAD || true ) | tee -a logs/status.log
( git remote -v || true ) | tee -a logs/status.log
( git status || true ) | tee -a logs/status.log
echo | tee -a logs/status.log

echo "==> Últimos 15 commits" | tee -a logs/status.log
( git log --oneline -n 15 || true ) | tee -a logs/status.log
echo | tee -a logs/status.log

echo "==> Conteo de archivos por extensión" | tee -a logs/status.log
if command -v cloc >/dev/null 2>&1; then
  cloc . --quiet | tee -a logs/status.log || true
else
  find . -type f \
    | grep -E '\.(m|mlx|slx|py|ipynb|c|cpp|h|hpp|java|js|ts|sh|bash|mk|make|tex|bib|md|yml|yaml|json|m|v|sv|sdc|tcl)$' \
    | sed 's/.*\.//' | sort | uniq -c | sort -nr | tee -a logs/status.log || true
fi
echo | tee -a logs/status.log

echo "==> Archivos relevantes detectados" | tee -a logs/status.log
echo "- Python:" | tee -a logs/status.log
( ls -1 **/*.py 2>/dev/null || true ) | tee -a logs/status.log
( ls -1 requirements.txt pyproject.toml setup.py 2>/dev/null || true ) | sed 's/^/  /' | tee -a logs/status.log

echo "- MATLAB/Simulink:" | tee -a logs/status.log
( ls -1 **/*.m **/*.mlx **/*.slx 2>/dev/null || true ) | tee -a logs/status.log

echo "- C/C++ y Make:" | tee -a logs/status.log
( ls -1 **/*.[ch] **/*.[ch]pp **/Makefile **/makefile 2>/dev/null || true ) | tee -a logs/status.log

echo "- LaTeX / Docs:" | tee -a logs/status.log
( ls -1 **/*.tex **/*.bib **/*.md 2>/dev/null || true ) | tee -a logs/status.log

echo "- Otros (Docker/CI):" | tee -a logs/status.log
( ls -1 Dockerfile **/*.dockerfile **/.github/workflows/*.y*ml 2>/dev/null || true ) | tee -a logs/status.log
echo | tee -a logs/status.log

echo "==> Puntos de entrada potenciales" | tee -a logs/status.log
ENTRY_POINTS=()
# Python
if ls -1 main.py 2>/dev/null >/dev/null; then ENTRY_POINTS+=("python:main.py"); fi
if ls -1 app.py 2>/dev/null >/dev/null; then ENTRY_POINTS+=("python:app.py"); fi
# MATLAB
if ls -1 main.m 2>/dev/null >/dev/null; then ENTRY_POINTS+=("matlab:main.m"); fi
if ls -1 run.m 2>/dev/null >/dev/null; then ENTRY_POINTS+=("matlab:run.m"); fi
# Make
if ls -1 Makefile makefile 2>/dev/null >/dev/null; then ENTRY_POINTS+=("make:default"); fi
# Bash
if ls -1 scripts/*.sh 2>/dev/null >/dev/null; then ENTRY_POINTS+=("bash:scripts"); fi

printf "%s\n" "${ENTRY_POINTS[@]:-<none>}" | tee -a logs/status.log
echo

# Genera REPORTE_AVANCE.md
{
  echo "# REPORTE DE AVANCE – $(date '+%Y-%m-%d %H:%M')"
  echo
  echo "## Resumen Git"
  echo
  echo "**Rama actual:** $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/D')"
  echo
  echo "### Remotos"
  git remote -v 2>/dev/null || true
  echo
  echo "### Últimos 10 commits"
  git log --oneline -n 10 2>/dev/null || true
  echo
  echo "## Estructura (nivel 1)"
  echo
  ls -lah
  echo
  echo "## Tecnologías detectadas y archivos relevantes"
  echo
  echo "### Python"
  ls -1 **/*.py 2>/dev/null || true
  echo
  echo "### MATLAB/Simulink"
  ls -1 **/*.m **/*.mlx **/*.slx 2>/dev/null || true
  echo
  echo "### C/C++ / Make"
  ls -1 **/*.[ch] **/*.[ch]pp **/Makefile **/makefile 2>/dev/null || true
  echo
  echo "### LaTeX / Docs"
  ls -1 **/*.tex **/*.bib **/*.md 2>/dev/null || true
  echo
  echo "### CI / Docker"
  ls -1 Dockerfile **/*.dockerfile **/.github/workflows/*.y*ml 2>/dev/null || true
  echo
  echo "## Conteo de líneas por lenguaje"
  if command -v cloc >/dev/null 2>&1; then
    echo '```'
    cloc . --quiet || true
    echo '```'
  else
    echo "_Instala \`cloc\` para un conteo más detallado (sudo apt install cloc)._"
  fi
  echo
  echo "## Puntos de entrada potenciales"
  printf "%s\n" "${ENTRY_POINTS[@]:-<none>}"
  echo
  echo "> Log completo en: logs/status.log"
} > REPORTE_AVANCE.md

echo "==> REPORTE_AVANCE.md generado."
