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
#   ├── skills/<plugin-name>/agents/openai.yaml
#   └── README.md
#
# And appends entries to:
#   .claude-plugin/marketplace.json
#   .agents/plugins/marketplace.json
#
# ── 설계 노트 (CLAUDE.md CRITICAL #1 · #5) ──
# 사용자 입력($DESCRIPTION)은 **셸 heredoc 에 절대 직접 박지 않는다.** 큰따옴표·
# 백슬래시·개행이 들어오면 plugin.json / openai.yaml / SKILL.md 프론트매터가
# 파싱 불가 상태로 생성된다 (2026-05-14 회귀). 모든 파일 생성과 marketplace
# 등록은 아래 단일 Python 블록이 담당하고, 값은 오직 argv 로만 전달된다.
# 구조적 컨텍스트(JSON/YAML)에는 json.dumps 로 인코딩해 넣는다.
#
# Python 3 는 선택이 아니라 **전제조건**이다. 없으면 아무것도 만들지 않고
# exit 1 한다 — 예전엔 경고만 찍고 exit 0 이라 "디렉토리는 있는데 marketplace
# 에는 없는" 좀비 플러그인이 생겼다.

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

# --- require Python 3 (CRITICAL #5: silent skip 금지) -------------------
PY=""
for cand in python3 python py; do
  if command -v "$cand" >/dev/null 2>&1 \
     && "$cand" -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    PY="$cand"
    break
  fi
done
if [[ -z "$PY" ]]; then
  {
    echo "Error: Python 3 가 필요합니다 (marketplace.json 등록과 안전한 매니페스트 생성에 사용)."
    echo "  Python 없이 진행하면 디렉토리만 생기고 두 marketplace 에는 등록되지 않는"
    echo "  좀비 플러그인이 만들어집니다. 아무것도 생성하지 않고 중단합니다."
  } >&2
  exit 1
fi

# --- scaffold (모든 사용자 입력은 argv 경유) ----------------------------
"$PY" - "$REPO_ROOT" "$PLUGIN_NAME" "$DESCRIPTION" <<'PYEOF'
import json
import os
import shutil
import sys

# 한국어 Windows 콘솔은 기본 인코딩이 cp949 라, 한글·기호를 그대로 쓰면
# UnicodeEncodeError 로 죽는다 — 성공 메시지가 스크립트를 실패시키고,
# 에러 경로에서는 진짜 에러 대신 인코딩 트레이스백이 뜬다.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, ValueError):  # Python < 3.7 또는 리다이렉트된 스트림
        pass

repo_root, name, description = sys.argv[1], sys.argv[2], sys.argv[3]

# 산문 컨텍스트(마크다운 본문)용: 개행·연속 공백을 한 칸으로 정규화.
# 구조적 컨텍스트(JSON/YAML)에는 원본을 json.dumps 로 인코딩해 넣으므로
# 개행이 있어도 안전하다.
prose = " ".join(description.split()) or "TODO: describe this plugin"

claude_market = os.path.join(repo_root, ".claude-plugin", "marketplace.json")
codex_market = os.path.join(repo_root, ".agents", "plugins", "marketplace.json")
plugin_dir = os.path.join(repo_root, name)


def die(msg):
    sys.stderr.write("Error: %s\n" % msg)
    sys.exit(1)


def yaml_str(value):
    """YAML 이중따옴표 스칼라. JSON 문자열 문법은 YAML 의 부분집합이라
    json.dumps 출력이 그대로 유효한 YAML 스칼라가 된다."""
    return json.dumps(value, ensure_ascii=False)


def dump_json(obj):
    return json.dumps(obj, ensure_ascii=False, indent=2) + "\n"


# ── 선행 검증: 아무것도 만들기 전에 전부 확인 ──
if not os.path.isfile(claude_market):
    die("Claude marketplace.json 없음: %s\n       pneumora-plugins 레포에서 실행하고 있나요?" % claude_market)

if os.path.exists(plugin_dir):
    die("%s 가 이미 존재합니다" % plugin_dir)

with open(claude_market, "r", encoding="utf-8") as f:
    claude_data = json.load(f)

if os.path.isfile(codex_market):
    with open(codex_market, "r", encoding="utf-8") as f:
        codex_data = json.load(f)
else:
    codex_data = {"name": "pneumora-plugins",
                  "interface": {"displayName": "Pneumora Plugins"},
                  "plugins": []}

for data, label in ((claude_data, "Claude"), (codex_data, "Codex")):
    if any(p.get("name") == name for p in data.get("plugins", [])):
        die("%s marketplace.json 에 '%s' 가 이미 등록돼 있습니다" % (label, name))

# ── 파일 내용 구성 ──
claude_manifest = {
    "name": name,
    "description": description,
    "version": "0.1.0",
    "author": {"name": "Pneumora"},
    "repository": "https://github.com/team-pneumora/pneumora-plugins",
}

codex_manifest = {
    "name": name,
    "version": "0.1.0",
    "description": description,
    "author": {"name": "Pneumora", "url": "https://github.com/team-pneumora"},
    "homepage": "https://github.com/team-pneumora/pneumora-plugins/tree/main/" + name,
    "repository": "https://github.com/team-pneumora/pneumora-plugins",
    "license": "MIT",
    "keywords": ["codex", "claude", name],
    "skills": "./skills/",
    "interface": {
        "displayName": name,
        "shortDescription": prose,
        "longDescription": description,
        "developerName": "Pneumora",
        "category": "Productivity",
        "capabilities": ["Read", "Write"],
        "websiteURL": "https://github.com/team-pneumora/pneumora-plugins",
        "defaultPrompt": ["Use $%s to help with this project." % name],
    },
}

skill_md = """---
name: %s
description: %s
---

# %s

> %s

## 핵심 원칙

TODO — 이 스킬이 따라야 할 원칙.

## 실행 절차

### 1단계

TODO

### 2단계

TODO

## 주의사항

TODO
""" % (
    name,
    yaml_str(prose + " TODO — 트리거 키워드와 사용 맥락을 한·영 병기로 구체적으로 적어야 자동 로드가 잘 된다."),
    name,
    prose,
)

openai_yaml = """interface:
  display_name: %s
  short_description: %s
  default_prompt: %s

policy:
  allow_implicit_invocation: true
""" % (
    yaml_str(name),
    yaml_str(prose),
    yaml_str("Use $%s to help with this project." % name),
)

readme_md = """# %s

%s

## 설치

### Claude Code

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install %s@pneumora-plugins
```

### Codex

이 플러그인은 `.codex-plugin/plugin.json`과 `skills/%s/SKILL.md`를 포함합니다. Codex에서 이 저장소를 플러그인 marketplace로 불러오거나, 스킬만 직접 쓰려면 `skills/%s/`를 `$CODEX_HOME/skills/`로 복사하세요.

## 사용법

Claude Code 또는 Codex에서 관련 요청을 하면 자동으로 트리거됩니다.

## 라이선스

MIT
""" % (name, prose, name, name, name)

# ── marketplace 갱신 내용 (쓰기 전에 직렬화까지 끝내둔다) ──
claude_data.setdefault("plugins", []).append({
    "name": name,
    "source": "./" + name,
    "description": prose,
})
codex_data.setdefault("name", "pneumora-plugins")
codex_data.setdefault("interface", {}).setdefault("displayName", "Pneumora Plugins")
codex_data.setdefault("plugins", []).append({
    "name": name,
    "source": {"source": "local", "path": "./" + name},
    "policy": {"installation": "AVAILABLE", "authentication": "ON_INSTALL"},
    "category": "Productivity",
})
claude_out = dump_json(claude_data)
codex_out = dump_json(codex_data)

# ── 쓰기 (실패 시 전부 되돌린다) ──
backups = []


def write(path, content):
    parent = os.path.dirname(path)
    if parent and not os.path.isdir(parent):
        os.makedirs(parent)
    prev = None
    if os.path.isfile(path):
        with open(path, "r", encoding="utf-8", newline="") as f:
            prev = f.read()
    backups.append((path, prev))
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)


try:
    write(os.path.join(plugin_dir, ".claude-plugin", "plugin.json"), dump_json(claude_manifest))
    write(os.path.join(plugin_dir, ".codex-plugin", "plugin.json"), dump_json(codex_manifest))
    write(os.path.join(plugin_dir, "skills", name, "SKILL.md"), skill_md)
    write(os.path.join(plugin_dir, "skills", name, "agents", "openai.yaml"), openai_yaml)
    write(os.path.join(plugin_dir, "README.md"), readme_md)
    write(claude_market, claude_out)
    write(codex_market, codex_out)
except Exception as exc:  # noqa: BLE001 — 어떤 실패든 좀비를 남기지 않는다
    for path, prev in reversed(backups):
        try:
            if prev is None:
                if os.path.isfile(path):
                    os.remove(path)
            else:
                with open(path, "w", encoding="utf-8", newline="\n") as f:
                    f.write(prev)
        except OSError:
            pass
    shutil.rmtree(plugin_dir, ignore_errors=True)
    die("생성 실패, 변경사항을 되돌렸습니다: %s" % exc)

print("✓ Claude marketplace.json 업데이트됨")
print("✓ Codex marketplace.json 업데이트됨")
PYEOF

# --- summary ------------------------------------------------------------
echo ""
echo "✓ dual-compatible 플러그인 생성 완료: $PLUGIN_NAME"
echo ""
echo "  $REPO_ROOT/$PLUGIN_NAME/"
echo "  ├── .claude-plugin/plugin.json"
echo "  ├── .codex-plugin/plugin.json"
echo "  ├── skills/$PLUGIN_NAME/SKILL.md"
echo "  ├── skills/$PLUGIN_NAME/agents/openai.yaml"
echo "  └── README.md"
echo ""
echo "다음 할 일:"
echo "  1. skills/$PLUGIN_NAME/SKILL.md 의 TODO 채우기 (description 은 한·영 트리거 병기)"
echo "  2. .codex-plugin/plugin.json 의 longDescription 다듬기"
echo "  3. README.md 업데이트 + 루트 README 표에 행 추가"
echo "  4. bash scripts/validate-plugins.sh 로 검증 후 git add/commit"
