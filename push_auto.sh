#!/usr/bin/env bash
set -euo pipefail
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
MSG="${1:-chore: sync $(date '+%Y-%m-%d %H:%M:%S')}"
echo "→ Agregando cambios…"
git add -A
echo "→ Commit: $MSG"
git commit -m "$MSG" || echo "· No hay cambios para commitear."
echo "→ Sincronizando (pull --rebase origin $BRANCH)…"
git pull --rebase origin "$BRANCH" || { echo "· Rebase con conflictos. Resuélvelos y vuelve a correr el script."; exit 1; }
echo "→ Subiendo (push origin $BRANCH)…"
git push origin "$BRANCH"
echo "✓ Listo."
