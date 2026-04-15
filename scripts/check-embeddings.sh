#!/usr/bin/env bash
# Read GitNexus meta.json from stdin and print the embeddings count.
# Usage: cat .gitnexus/meta.json | bash scripts/check-embeddings.sh
set -euo pipefail
python3 - <<'EOF'
import sys, json
d = json.load(sys.stdin)
print('embeddings:', d.get('stats', {}).get('embeddings', '?'))
EOF
