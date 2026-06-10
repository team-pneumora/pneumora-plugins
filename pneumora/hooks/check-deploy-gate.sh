#!/usr/bin/env bash
# check-deploy-gate.sh — git push 직전 좀비 파일 차단 게이트 (PreToolUse:Bash hook)
#
# /pneumora:check-deploy 의 핵심 차단 규칙을 hook 으로 기계 강제한다:
# 미추적(??) plugin.json / SKILL.md / .codex-plugin 이 있는 상태로 push 하면
# Codex 쪽 플러그인이 좀비 상태가 되므로 push 를 차단한다.
#
# stdin: PreToolUse JSON ({"tool_name":"Bash","tool_input":{"command":"..."}, ...})
# exit 0 = 통과, exit 2 = 차단 (stderr 가 Claude 에게 전달됨)
set -u

INPUT="$(cat)"

# tool_input.command 추출 — jq > python > 원문 fallback
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

# git push 명령이 아니면 통과
printf '%s' "$CMD" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+push([[:space:]]|$)' || exit 0

# git 레포가 아니면 통과
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# 미추적 배포 필수 파일 검사
# -uall: 미추적 디렉토리도 내부 파일 단위로 나열 (디렉토리명만 나와서 SKILL.md 를 놓치는 것 방지)
ZOMBIES="$(git status --porcelain -uall 2>/dev/null | grep -E '^\?\?' | grep -E '(plugin\.json|SKILL\.md|\.codex-plugin)' || true)"

if [ -n "$ZOMBIES" ]; then
  {
    echo "[pneumora:check-deploy-gate] git push 차단 — 미추적 배포 필수 파일 발견:"
    echo "$ZOMBIES"
    echo "이 상태로 push 하면 마켓플레이스에서 플러그인이 좀비 상태가 됩니다."
    echo "git add 로 추적 후 커밋하고 다시 push 하세요. 의도된 제외라면 .gitignore 에 추가하세요."
  } >&2
  exit 2
fi

exit 0
