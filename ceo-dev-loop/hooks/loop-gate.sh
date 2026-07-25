#!/usr/bin/env bash
# loop-gate.sh — 자율 루프 강제 Stop hook (ceo-dev-loop v0.8.0)
#
# 프롬프트 레벨 "우회 어휘 차단" 을 하네스 레벨로 격상한다:
# docs/.ceo-loop-active 센티널이 존재하는 동안 Dev 세션의 턴 종료를 차단하고
# 루프 계속(@ceo 재호출) 또는 정당한 정지(센티널 삭제 후 종료)를 지시한다.
#
# 센티널 수명주기 (Dev 가 관리, 프로젝트 루트 기준 경로):
#   - init / start 시 생성 (내용: 0)
#   - 삭제 = 정지 허용: ① [DONE] 종료 절차 ② "사용자 확인 필수" 예외로 질문할 때
#     ③ 사용자의 중단 지시
#
# 센티널 내용: "<연속_무진척_횟수> <마지막으로_본_STATUS.md_mtime> <누적_차단_횟수>"
#   (구버전 "0" 단일 필드, v0.8.0 초기의 2필드 형식도 그대로 읽힌다)
#
# ── 정지 허용 조건 (둘 중 하나라도 충족) ──
#   1. 연속 무진척 >= CEO_LOOP_MAX_CONTINUES (기본 200)
#      docs/STATUS.md 가 갱신되면 = 진척 있음 → 이 카운터만 0으로 리셋.
#      v0.7.0 은 진척과 무관하게 단조 증가시켜, 정상 진행 중인 장기 루프도
#      200턴에서 조용히 멈췄다.
#   2. 누적 차단 >= CEO_LOOP_MAX_TOTAL (기본 1000) — 리셋되지 않는 절대 상한.
#      1번만 있으면 안전밸브가 수학적으로 도달 불가능하다: 이 훅 스스로
#      "매 턴 STATUS.md 를 갱신하라" 고 지시하므로 연속 카운터는 1에 고정되고,
#      STATUS.md 만 계속 고쳐쓰는 무의미 루프를 영원히 못 끊는다.
#
# exit 0 = 정지 허용, exit 2 = 정지 차단 (stderr 가 Claude 에게 전달됨)
set -u

# cwd 가 아니라 프로젝트 루트 기준으로 앵커한다 (cwd 가 하위 디렉토리면
# 센티널을 못 찾아 루프 강제가 조용히 풀리는 fail-open 방지)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SENTINEL="$PROJECT_DIR/docs/.ceo-loop-active"
STATUS="$PROJECT_DIR/docs/STATUS.md"

# stdin(JSON) 은 소비만 한다 — 센티널 존재가 유일한 판단 기준
cat > /dev/null

[ -f "$SENTINEL" ] || exit 0

# ── 센티널 파싱 ──
COUNT=0
PREV_MTIME=0
TOTAL=0
read -r COUNT PREV_MTIME TOTAL < "$SENTINEL" 2>/dev/null || true
case "${COUNT:-}"      in ''|*[!0-9]*) COUNT=0 ;;      esac
case "${PREV_MTIME:-}" in ''|*[!0-9]*) PREV_MTIME=0 ;; esac
case "${TOTAL:-}"      in ''|*[!0-9]*) TOTAL=0 ;;      esac

# ── 한도 (사용자가 직접 타이핑하는 값이므로 반드시 검증) ──
LIMIT="${CEO_LOOP_MAX_CONTINUES:-200}"
HARD="${CEO_LOOP_MAX_TOTAL:-1000}"
case "$LIMIT" in ''|*[!0-9]*) LIMIT=200 ;;  esac
case "$HARD"  in ''|*[!0-9]*) HARD=1000 ;;  esac

# ── 진척 신호: STATUS.md mtime ──
file_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}
CUR_MTIME=0
[ -f "$STATUS" ] && CUR_MTIME="$(file_mtime "$STATUS")"
case "${CUR_MTIME:-}" in ''|*[!0-9]*) CUR_MTIME=0 ;; esac

# STATUS.md 가 갱신됐다 = Dev 가 일을 했다 → 연속 무진척 카운터만 리셋
if [ "$CUR_MTIME" -ne "$PREV_MTIME" ]; then
  COUNT=0
fi

# ── 안전밸브 1: 연속 무진척 ──
if [ "$COUNT" -ge "$LIMIT" ]; then
  {
    echo "[ceo-dev-loop] 연속 무진척 ${LIMIT}회 도달 (docs/STATUS.md 가 그동안 한 번도 갱신되지 않음) — 안전을 위해 정지를 허용합니다."
    echo "- 루프가 헛돌고 있을 가능성이 높습니다. STATUS.md 갱신이 실제로 일어나는지 확인하세요."
    echo "- 재개: /ceo-dev-loop:start (카운터 리셋)"
  } >&2
  exit 0
fi

# ── 안전밸브 2: 누적 차단 절대 상한 (리셋 없음) ──
if [ "$TOTAL" -ge "$HARD" ]; then
  {
    echo "[ceo-dev-loop] 누적 차단 ${HARD}회 도달 — 안전을 위해 정지를 허용합니다."
    echo "- 진척은 있었지만 루프가 비정상적으로 길어졌습니다 (STATUS.md 만 계속 고쳐쓰는 무의미 루프일 수 있음)."
    echo "- docs/GOAL.md 진척과 docs/STATUS.md 최근 작업을 확인한 뒤 재개: /ceo-dev-loop:start (카운터 리셋)"
    echo "- 상한 조정: CEO_LOOP_MAX_TOTAL 환경변수"
  } >&2
  exit 0
fi

echo "$((COUNT + 1)) $CUR_MTIME $((TOTAL + 1))" > "$SENTINEL"

{
  echo "[ceo-dev-loop] 자율 루프 활성 (${SENTINEL} 존재) — 턴 종료 차단 (무진척 ${COUNT}/${LIMIT}, 누적 ${TOTAL}/${HARD})."
  echo "- GOAL 미완료면 지금 즉시 계속하라: docs/STATUS.md 의 '다음 작업' 을 실행하거나 @ceo 를 재호출해 다음 지시를 받는다."
  echo "- 매 턴 docs/STATUS.md 를 갱신하라 — 갱신이 곧 진척 신호이며, 갱신되는 동안 무진척 카운터는 0으로 유지된다."
  echo "- 정당한 정지 사유라면 ${SENTINEL} 를 삭제한 뒤 종료하라. 정당한 사유는 셋뿐:"
  echo "  ① [DONE] 확정 후 최종 보고 완료  ② '사용자 확인 필수' 예외에 해당해 질문해야 함  ③ 사용자가 중단을 지시함"
} >&2
exit 2
