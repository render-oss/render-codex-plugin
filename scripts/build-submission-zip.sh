#!/usr/bin/env bash
set -euo pipefail

# The OpenAI plugin portal identifies this plugin by its assigned ID, and its
# ZIP upload rejects `apps`/`.app.json` and MCP `oauth` settings. Codex installs
# from this repo still need all three, so they are rewritten only in the ZIP.
PLUGIN_NAME="app-6a624c56bfe081918f7544f7d58f6faf"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      PLUGIN_NAME="$2"
      shift 2
      ;;
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

VERSION="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$REPO_ROOT/.codex-plugin/plugin.json")"
OUTPUT="${OUTPUT:-$REPO_ROOT/dist/render-codex-plugin-$VERSION.zip}"
mkdir -p "$(dirname "$OUTPUT")"
OUTPUT="$(cd "$(dirname "$OUTPUT")" && pwd)/$(basename "$OUTPUT")"

if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
  echo "Warning: uncommitted changes are not included; the ZIP is built from HEAD." >&2
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
STAGE="$TMPDIR/plugin"
mkdir -p "$STAGE"

git -C "$REPO_ROOT" archive HEAD -- . ':!.github' ':!.gitignore' | tar -x -C "$STAGE"

python3 - "$STAGE" "$PLUGIN_NAME" <<'EOF'
import json
import os
import sys

stage, name = sys.argv[1], sys.argv[2]
manifest_path = os.path.join(stage, ".codex-plugin", "plugin.json")
mcp_path = os.path.join(stage, ".mcp.json")

with open(manifest_path) as f:
    manifest = json.load(f)
manifest["name"] = name
manifest.pop("apps", None)
with open(manifest_path, "w") as f:
    json.dump(manifest, f, indent=2)
    f.write("\n")

with open(mcp_path) as f:
    mcp = json.load(f)
for server in mcp["mcpServers"].values():
    server.pop("oauth", None)
with open(mcp_path, "w") as f:
    json.dump(mcp, f, indent=2)
    f.write("\n")

app_path = os.path.join(stage, ".app.json")
if os.path.exists(app_path):
    os.remove(app_path)
EOF

rm -f "$OUTPUT"
(cd "$STAGE" && zip -qr -X "$OUTPUT" .)

echo "Built $OUTPUT ($PLUGIN_NAME $VERSION)"
