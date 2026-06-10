#!/usr/bin/env bash
# validate-plugins.sh — 듀얼 플러그인 마켓플레이스 무결성 검증
#
# 사용:
#   bash scripts/validate-plugins.sh                  # 전체 검증 (CI/수동)
#   bash scripts/validate-plugins.sh --pre-push-hook  # PreToolUse hook 모드
#                                                     # (stdin JSON 에서 git push 감지 시에만 검증, 실패 시 exit 2 로 차단)
#
# 검사 항목 (CLAUDE.md CRITICAL #2, #3 의 기계 강제):
#   1. 모든 plugin.json + 두 marketplace.json 파싱 가능
#   2. 같은 플러그인의 .claude-plugin ↔ .codex-plugin 버전 동기
#   3. 모든 플러그인 디렉토리가 두 marketplace.json 에 등록
#   4. 미추적 plugin.json / SKILL.md / .codex-plugin 없음 (좀비 방지)
set -u

cd "$(dirname "$0")/.." || exit 1

HOOK_MODE=0
if [ "${1:-}" = "--pre-push-hook" ]; then
  HOOK_MODE=1
  INPUT="$(cat)"
  CMD=""
  if command -v jq >/dev/null 2>&1; then
    CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
  elif command -v python3 >/dev/null 2>&1; then
    CMD="$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)"
  elif command -v python >/dev/null 2>&1; then
    CMD="$(printf '%s' "$INPUT" | python -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)"
  else
    CMD="$INPUT"
  fi
  # git push 가 아니면 즉시 통과
  printf '%s' "$CMD" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+push([[:space:]]|$)' || exit 0
fi

FAIL=0
fail() { echo "❌ $1" >&2; FAIL=1; }
ok()   { [ "$HOOK_MODE" -eq 0 ] && echo "✅ $1"; }

# JSON 파서 (python 우선, jq fallback) — 둘 다 없으면 검증 불가 = 실패 (CRITICAL #5: silent skip 금지)
PY="$(command -v python3 || command -v python || true)"
HAS_JQ=0; command -v jq >/dev/null 2>&1 && HAS_JQ=1
if [ -z "$PY" ] && [ "$HAS_JQ" -eq 0 ]; then
  fail "python/jq 둘 다 없음 — JSON 검증 불가 (silent skip 금지)"
  exit $((HOOK_MODE ? 2 : 1))
fi

json_ok() {
  if [ -n "$PY" ]; then "$PY" -c 'import json,sys; json.load(open(sys.argv[1], encoding="utf-8"))' "$1" 2>/dev/null
  else jq empty "$1" 2>/dev/null; fi
}
json_version() {
  if [ -n "$PY" ]; then "$PY" -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8")).get("version",""))' "$1" 2>/dev/null
  else jq -r '.version // ""' "$1" 2>/dev/null; fi
}

# ── 1+2+3. 플러그인별 매니페스트 검사 ──
CLAUDE_MARKET=".claude-plugin/marketplace.json"
AGENTS_MARKET=".agents/plugins/marketplace.json"

for f in "$CLAUDE_MARKET" "$AGENTS_MARKET"; do
  if [ ! -f "$f" ]; then fail "$f 없음"
  elif ! json_ok "$f"; then fail "$f JSON 파싱 실패"
  else ok "$f 파싱"
  fi
done

for dir in */; do
  p="${dir%/}"
  CM="$p/.claude-plugin/plugin.json"
  XM="$p/.codex-plugin/plugin.json"
  [ -f "$CM" ] || continue

  # 1. 파싱
  json_ok "$CM" || fail "$CM JSON 파싱 실패"
  if [ -f "$XM" ]; then
    json_ok "$XM" || fail "$XM JSON 파싱 실패"
    # 2. 버전 동기
    V1="$(json_version "$CM")"
    V2="$(json_version "$XM")"
    if [ -n "$V1" ] && [ "$V1" = "$V2" ]; then ok "$p 버전 동기 ($V1)"
    else fail "$p 버전 불일치: claude=$V1 codex=$V2 (CRITICAL #2)"
    fi
  else
    fail "$p — .codex-plugin/plugin.json 없음 (듀얼 매니페스트 필수)"
  fi

  # 3. 두 marketplace 등록
  for m in "$CLAUDE_MARKET" "$AGENTS_MARKET"; do
    [ -f "$m" ] || continue
    grep -q "\"$p\"" "$m" || fail "$p 가 $m 에 미등록 (좀비 플러그인)"
  done
done

# ── 4. 미추적 좀비 파일 ──
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ZOMBIES="$(git status --porcelain -uall 2>/dev/null | grep -E '^\?\?' | grep -E '(plugin\.json|SKILL\.md|\.codex-plugin)' || true)"
  if [ -n "$ZOMBIES" ]; then
    fail "미추적 배포 필수 파일 (CRITICAL #3):"
    echo "$ZOMBIES" >&2
  else
    ok "미추적 좀비 파일 없음"
  fi
fi

echo
if [ "$FAIL" -eq 0 ]; then
  [ "$HOOK_MODE" -eq 0 ] && echo "✅ 플러그인 무결성 검증 통과"
  exit 0
else
  if [ "$HOOK_MODE" -eq 1 ]; then
    echo "[validate-plugins] git push 차단 — 위 항목 수정 후 다시 push 하세요." >&2
    exit 2
  fi
  echo "❌ 검증 실패 — 위 항목 수정 필요" >&2
  exit 1
fi
