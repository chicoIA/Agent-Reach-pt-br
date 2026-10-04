#!/usr/bin/env bash
# Gera o pacote da skill pronto para importar: pt-br/agent-reach-skill-pt-br.zip
# Estrutura do zip:  agent-reach/SKILL.md  +  agent-reach/references/*.md
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$DIR/agent-reach-skill-pt-br.zip"

rm -f "$OUT"
cd "$DIR/skill"
if command -v zip >/dev/null 2>&1; then
  zip -rqX "$OUT" agent-reach -x '*.DS_Store'
else
  python3 - "$OUT" <<'PY'
import os, sys, zipfile
out = sys.argv[1]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk("agent-reach"):
        for f in sorted(files):
            if f != ".DS_Store":
                z.write(os.path.join(root, f))
PY
fi
echo "Pacote gerado: $OUT"
