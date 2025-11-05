#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-main}"
MSG="${2:-}"
if [ -z "$MSG" ]; then
  MSG="chore: auto-push $(date '+%Y-%m-%d %H:%M:%S')"
fi

echo ">> Sincronizando con origin/$BRANCH..."
git fetch origin
# Rebase seguro: si falla, aborta y sugiere merge manual
if ! git rebase "origin/$BRANCH"; then
  echo ">> Rebase falló. Haciendo abort."
  git rebase --abort || true
  echo "⚠️  Hay conflictos. Resuélvelos y vuelve a ejecutar."
  exit 1
fi

echo ">> Agregando cambios..."
git add -A

# Si no hay cambios, no comitea
if git diff --cached --quiet; then
  echo "✅ No hay cambios para comitear."
else
  echo ">> Commit: $MSG"
  git commit -m "$MSG"
fi

echo ">> Empujando a origin/$BRANCH..."
git push -u origin "$BRANCH"
echo "✅ Listo."
