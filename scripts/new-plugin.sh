#!/usr/bin/env bash
# new-plugin.sh — scaffold a new plugin inside pneumora-plugins marketplace
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
#   ├── skills/<plugin-name>/SKILL.md
#   └── README.md
#
# And appends the new plugin entry to .claude-plugin/marketplace.json

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
MARKETPLACE_FILE="$REPO_ROOT/.claude-plugin/marketplace.json"

if [[ ! -f "$MARKETPLACE_FILE" ]]; then
  echo "Error: marketplace.json not found at $MARKETPLACE_FILE" >&2
  echo "Are you running this from the pneumora-plugins repo?" >&2
  exit 1
fi

PLUGIN_DIR="$REPO_ROOT/$PLUGIN_NAME"
if [[ -e "$PLUGIN_DIR" ]]; then
  echo "Error: $PLUGIN_DIR already exists" >&2
  exit 1
fi

# --- create structure ---------------------------------------------------
mkdir -p "$PLUGIN_DIR/.claude-plugin"
mkdir -p "$PLUGIN_DIR/skills/$PLUGIN_NAME"

# plugin.json
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

# README.md
cat > "$PLUGIN_DIR/README.md" <<EOF
# $PLUGIN_NAME

$DESCRIPTION

## 설치

\`\`\`bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install $PLUGIN_NAME@pneumora-plugins
\`\`\`

## 사용법

Claude Code에서 관련 요청을 하면 자동으로 트리거됩니다.

## 라이선스

MIT
EOF

# --- update marketplace.json -------------------------------------------
# python이 있으면 python으로, 없으면 node로, 둘 다 없으면 수동 안내
update_marketplace() {
  if command -v python >/dev/null 2>&1; then
    PY=python
  elif command -v python3 >/dev/null 2>&1; then
    PY=python3
  else
    return 1
  fi

  "$PY" - "$MARKETPLACE_FILE" "$PLUGIN_NAME" "$DESCRIPTION" <<'PYEOF'
import json, sys
path, name, desc = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)
plugins = data.setdefault("plugins", [])
if any(p.get("name") == name for p in plugins):
    print(f"warn: {name} already in marketplace.json, skipping update", file=sys.stderr)
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

if update_marketplace; then
  echo "✓ marketplace.json 업데이트됨"
else
  echo "⚠ python이 없어 marketplace.json 자동 업데이트 실패" >&2
  echo "  수동으로 $MARKETPLACE_FILE 의 plugins 배열에 다음을 추가하세요:" >&2
  echo "    { \"name\": \"$PLUGIN_NAME\", \"source\": \"./$PLUGIN_NAME\", \"description\": \"$DESCRIPTION\" }" >&2
fi

# --- summary ------------------------------------------------------------
echo ""
echo "✓ 플러그인 생성 완료: $PLUGIN_NAME"
echo ""
echo "  $PLUGIN_DIR/"
echo "  ├── .claude-plugin/plugin.json"
echo "  ├── skills/$PLUGIN_NAME/SKILL.md"
echo "  └── README.md"
echo ""
echo "다음 할 일:"
echo "  1. skills/$PLUGIN_NAME/SKILL.md 의 TODO 채우기"
echo "  2. README.md 업데이트"
echo "  3. git add/commit/push"
