#!/usr/bin/env bash
# harness-lint.sh — CLAUDE.md/AGENTS.md 하네스 구조 점검
#
# 사용: bash harness-lint.sh [CLAUDE.md|AGENTS.md] [프로젝트 루트]
# 환경변수로 예산 조정: ROOT_BUDGET / MODULE_BUDGET / LEAF_BUDGET (토큰 근사치)
#
# 검사 항목:
#   1. 계층별 토큰 예산 초과 (근사: UTF-8 바이트 / 3)
#   2. 빈 섹션 (## 헤더 아래 내용 없음)
#   3. 계층 간 중복 라인 (DRY 위반)
#   4. 루트 디렉토리 맵 ↔ 실제 파일 불일치
set -u

TARGET="${1:-CLAUDE.md}"
ROOT_DIR="${2:-.}"
ROOT_BUDGET="${ROOT_BUDGET:-800}"
MODULE_BUDGET="${MODULE_BUDGET:-600}"
LEAF_BUDGET="${LEAF_BUDGET:-400}"

cd "$ROOT_DIR" || { echo "❌ 디렉토리 없음: $ROOT_DIR"; exit 1; }

FILES="$(find . -name "$TARGET" -not -path "*/node_modules/*" -not -path "*/.git/*" | sort)"
if [ -z "$FILES" ]; then
  echo "✅ $TARGET 없음 — 점검할 것 없음"
  exit 0
fi

WARN=0
warn() { echo "  ⚠️  $1"; WARN=$((WARN + 1)); }

echo "── 1. 토큰 예산 (근사: bytes/3) ──"
while IFS= read -r f; do
  [ -z "$f" ] && continue
  bytes=$(wc -c < "$f" | tr -d ' ')
  lines=$(wc -l < "$f" | tr -d ' ')
  tokens=$((bytes / 3))
  depth=$(printf '%s' "${f#./}" | awk -F/ '{print NF - 1}')
  case "$depth" in
    0) budget=$ROOT_BUDGET;   level="Root"   ;;
    1) budget=$MODULE_BUDGET; level="Module" ;;
    *) budget=$LEAF_BUDGET;   level="Leaf"   ;;
  esac
  printf '  %-7s %5d tokens %4d lines  %s\n' "$level" "$tokens" "$lines" "$f"
  if [ "$tokens" -gt "$budget" ]; then
    warn "$f — $level 예산 ${budget}토큰 초과 (현재 ~${tokens}). 하위 분산 또는 압축 패스 필요"
  fi
done <<< "$FILES"

echo "── 2. 빈 섹션 ──"
EMPTY="$(while IFS= read -r f; do
  [ -z "$f" ] && continue
  awk -v file="$f" '
    /^## / { if (pending != "") print file "\t" pending; pending = $0; next }
    NF > 0 { pending = "" }
    END    { if (pending != "") print file "\t" pending }
  ' "$f"
done <<< "$FILES")"
if [ -n "$EMPTY" ]; then
  while IFS=$'\t' read -r file head; do
    [ -z "$file" ] && continue
    warn "$file — 빈 섹션: $head"
  done <<< "$EMPTY"
else
  echo "  통과"
fi

echo "── 3. 계층 간 중복 라인 (DRY) ──"
# 20자 이상이고 헤더/테이블/코드펜스가 아닌 라인이 서로 다른 파일에 중복되면 보고
DUP="$(while IFS= read -r f; do
  [ -z "$f" ] && continue
  sed -e 's/[[:space:]]*$//' "$f" | awk -v file="$f" '
    length($0) >= 20 && $0 !~ /^#/ && $0 !~ /^\|/ && $0 !~ /^```/ { print $0 "\t" file }
  '
done <<< "$FILES" | sort | awk -F'\t' '
  $1 == prev && $2 != prevfile { print $1 "\t" prevfile " ↔ " $2 }
  { prev = $1; prevfile = $2 }
' | sort -u)"
if [ -n "$DUP" ]; then
  while IFS=$'\t' read -r line files; do
    [ -z "$line" ] && continue
    warn "중복: \"$line\" ($files)"
  done <<< "$DUP"
else
  echo "  통과"
fi

echo "── 4. 루트 디렉토리 맵 동기화 ──"
ROOT_FILE="./$TARGET"
if [ -f "$ROOT_FILE" ]; then
  MAP_OK=1
  # 루트가 참조하는 하위 instruction 파일이 실존하는지
  REFS="$(grep -oE '[A-Za-z0-9_./-]+/'"$TARGET" "$ROOT_FILE" 2>/dev/null | sed 's|^\./||' | sort -u || true)"
  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    if [ ! -f "$ref" ]; then
      warn "루트 $TARGET 가 참조하는 $ref 가 존재하지 않음 (맵 불일치)"
      MAP_OK=0
    fi
  done <<< "$REFS"
  # 실존하는 하위 파일이 루트 맵에 등록돼 있는지
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel="${f#./}"
    [ "$rel" = "$TARGET" ] && continue
    if ! grep -qF "$rel" "$ROOT_FILE"; then
      warn "$rel 이 루트 $TARGET 디렉토리 맵에 없음"
      MAP_OK=0
    fi
  done <<< "$FILES"
  [ "$MAP_OK" -eq 1 ] && echo "  통과"
else
  echo "  루트 $TARGET 없음 — 스킵"
fi

echo
if [ "$WARN" -eq 0 ]; then
  echo "✅ harness 점검 통과 — 경고 0건"
  exit 0
else
  echo "⚠️  경고 ${WARN}건 — 위 항목 검토 필요"
  exit 1
fi
