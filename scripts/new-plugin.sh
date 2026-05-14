#!/usr/bin/env bash
# new-plugin.sh — scaffold a dual Claude Code / Codex plugin inside pneumora-plugins
#
# Usage:
#   scripts/new-plugin.sh <plugin-name> "<description>"
#
# Example:
#   scripts/new-plugin.sh my-cool-skill "내 멋진 스킬 설명"
#
# Creates:
#   <plugin-name>/
#   ├── .claude-plugin/plugin.json
#   ├── .codex-plugin/plugin.json
#   ├── skills/<plugin-name>/SKILL.md
#   └── README.md
#
# And appends entries to:
#   .claude-plugin/marketplace.json
#   .agents/plugins/marketplace.json

set -euo pipefail

# --- args ---------------------------------------------------------------
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <plugin-name> [description]" >&2
  exit 1
fi

PLUGIN_NAME="$1"
DESCRIPTION="${2:-TODO: describe this plugin}"

# kebab-case 검증
if ! [[ "$PLUGIN_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Error: plugin name must be kebab-case (lowercase, digits, hyphens). Got: $PLUGIN_NAME" >&2
  exit 1
fi

# --- locate repo root ---------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_MARKETPLACE_FILE="$REPO_ROOT/.claude-plugin/marketplace.json"
CODEX_MARKETPLACE_FILE="$REPO_ROOT/.agents/plugins/marketplace.json"

if [[ ! -f "$CLAUDE_MARKETPLACE_FILE" ]]; then
  echo "Error: Claude marketplace.json not found at $CLAUDE_MARKETPLACE_FILE" >&2
  echo "Are you running this from the pneumora-plugins repo?" >&2
  exit 1
fi

if [[ ! -f "$CODEX_MARKETPLACE_FILE" ]]; then
  mkdir -p "$(dirname "$CODEX_MARKETPLACE_FILE")"
  cat > "$CODEX_MARKETPLACE_FILE" <<'EOF'
{
  "name": "pneumora-plugins",
  "interface": {
    "displayName": "Pneumora Plugins"
  },
  "plugins": []
}
EOF
fi

PLUGIN_DIR="$REPO_ROOT/$PLUGIN_NAME"
if [[ -e "$PLUGIN_DIR" ]]; then
  echo "Error: $PLUGIN_DIR already exists" >&2
  exit 1
fi

# --- create structure ---------------------------------------------------
mkdir -p "$PLUGIN_DIR/.claude-plugin"
mkdir -p "$PLUGIN_DIR/.codex-plugin"
mkdir -p "$PLUGIN_DIR/skills/$PLUGIN_NAME"

# Claude Code plugin.json
cat > "$PLUGIN_DIR/.claude-plugin/plugin.json" <<EOF
{
  "name": "$PLUGIN_NAME",
  "description": "$DESCRIPTION",
  "version": "0.1.0",
  "author": {
    "name": "Pneumora"
  },
  "repository": "https://github.com/team-pneumora/pneumora-plugins"
}
EOF

# Codex plugin.json
cat > "$PLUGIN_DIR/.codex-plugin/plugin.json" <<EOF
{
  "name": "$PLUGIN_NAME",
  "version": "0.1.0",
  "description": "$DESCRIPTION",
  "author": {
    "name": "Pneumora",
    "url": "https://github.com/team-pneumora"
  },
  "homepage": "https://github.com/team-pneumora/pneumora-plugins/tree/main/$PLUGIN_NAME",
  "repository": "https://github.com/team-pneumora/pneumora-plugins",
  "license": "MIT",
  "keywords": [
    "codex",
    "claude",
    "$PLUGIN_NAME"
  ],
  "skills": "./skills/",
  "interface": {
    "displayName": "$PLUGIN_NAME",
    "shortDescription": "$DESCRIPTION",
    "longDescription": "$DESCRIPTION",
    "developerName": "Pneumora",
    "category": "Productivity",
    "capabilities": [
      "Read",
      "Write"
    ],
    "websiteURL": "https://github.com/team-pneumora/pneumora-plugins",
    "defaultPrompt": [
      "Use \$$PLUGIN_NAME to help with this project."
    ]
  }
}
EOF

# SKILL.md
cat > "$PLUGIN_DIR/skills/$PLUGIN_NAME/SKILL.md" <<EOF
---
name: $PLUGIN_NAME
description: $DESCRIPTION. TODO — 트리거 키워드와 사용 맥락을 구체적으로 적어야 자동 로드가 잘 된다.
---

# $PLUGIN_NAME

> $DESCRIPTION

## 핵심 원칙

TODO — 이 스킬이 따라야 할 원칙.

## 실행 절차

### 1단계

TODO

### 2단계

TODO

## 주의사항

TODO
EOF

# Codex skill UI metadata
mkdir -p "$PLUGIN_DIR/skills/$PLUGIN_NAME/agents"
cat > "$PLUGIN_DIR/skills/$PLUGIN_NAME/agents/openai.yaml" <<EOF
interface:
  display_name: "$PLUGIN_NAME"
  short_description: "$DESCRIPTION"
  default_prompt: "Use \$$PLUGIN_NAME to help with this project."

policy:
  allow_implicit_invocation: true
EOF

# README.md
cat > "$PLUGIN_DIR/README.md" <<EOF
# $PLUGIN_NAME

$DESCRIPTION

## 설치

### Claude Code

\`\`\`bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install $PLUGIN_NAME@pneumora-plugins
\`\`\`

### Codex

이 플러그인은 \`.codex-plugin/plugin.json\`과 \`skills/$PLUGIN_NAME/SKILL.md\`를 포함합니다. Codex에서 이 저장소를 플러그인 marketplace로 불러오거나, 스킬만 직접 쓰려면 \`skills/$PLUGIN_NAME/\`를 \`\$CODEX_HOME/skills/\`로 복사하세요.

## 사용법

Claude Code 또는 Codex에서 관련 요청을 하면 자동으로 트리거됩니다.

## 라이선스

MIT
EOF

# --- update marketplace.json -------------------------------------------
find_python() {
  if command -v python >/dev/null 2>&1; then
    echo python
  elif command -v python3 >/dev/null 2>&1; then
    echo python3
  else
    return 1
  fi
}

update_claude_marketplace() {
  local py="$1"
  "$py" - "$CLAUDE_MARKETPLACE_FILE" "$PLUGIN_NAME" "$DESCRIPTION" <<'PYEOF'
import json, sys
path, name, desc = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)
plugins = data.setdefault("plugins", [])
if any(p.get("name") == name for p in plugins):
    print(f"warn: {name} already in Claude marketplace.json, skipping update", file=sys.stderr)
    sys.exit(0)
plugins.append({
    "name": name,
    "source": f"./{name}",
    "description": desc,
})
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")
PYEOF
}

update_codex_marketplace() {
  local py="$1"
  "$py" - "$CODEX_MARKETPLACE_FILE" "$PLUGIN_NAME" <<'PYEOF'
import json, sys
path, name = sys.argv[1], sys.argv[2]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)
data.setdefault("name", "pneumora-plugins")
data.setdefault("interface", {}).setdefault("displayName", "Pneumora Plugins")
plugins = data.setdefault("plugins", [])
if any(p.get("name") == name for p in plugins):
    print(f"warn: {name} already in Codex marketplace.json, skipping update", file=sys.stderr)
    sys.exit(0)
plugins.append({
    "name": name,
    "source": {
        "source": "local",
        "path": f"./{name}",
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL",
    },
    "category": "Productivity",
})
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")
PYEOF
}

if PY="$(find_python)"; then
  update_claude_marketplace "$PY"
  echo "✓ Claude marketplace.json 업데이트됨"
  update_codex_marketplace "$PY"
  echo "✓ Codex marketplace.json 업데이트됨"
else
  echo "⚠ python이 없어 marketplace.json 자동 업데이트 실패" >&2
  echo "  수동으로 $CLAUDE_MARKETPLACE_FILE 와 $CODEX_MARKETPLACE_FILE 를 업데이트하세요." >&2
fi

# --- summary ------------------------------------------------------------
echo ""
echo "✓ dual-compatible 플러그인 생성 완료: $PLUGIN_NAME"
echo ""
echo "  $PLUGIN_DIR/"
echo "  ├── .claude-plugin/plugin.json"
echo "  ├── .codex-plugin/plugin.json"
echo "  ├── skills/$PLUGIN_NAME/SKILL.md"
echo "  └── README.md"
echo ""
echo "다음 할 일:"
echo "  1. skills/$PLUGIN_NAME/SKILL.md 의 TODO 채우기"
echo "  2. .codex-plugin/plugin.json interface 설명 다듬기"
echo "  3. README.md 업데이트"
echo "  4. git add/commit/push"
