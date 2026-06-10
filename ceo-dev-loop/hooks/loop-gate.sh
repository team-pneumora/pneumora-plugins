#!/usr/bin/env bash
# loop-gate.sh — 자율 루프 강제 Stop hook (ceo-dev-loop v0.7.0)
#
# 프롬프트 레벨 "우회 어휘 차단" 을 하네스 레벨로 격상한다:
# docs/.ceo-loop-active 센티널이 존재하는 동안 Dev 세션의 턴 종료를 차단하고
# 루프 계속(@ceo 재호출) 또는 정당한 정지(센티널 삭제 후 종료)를 지시한다.
#
# 센티널 수명주기 (Dev 가 관리):
#   - init / start 시 생성 (내용: 0 — 연속 차단 카운터)
#   - 삭제 = 정지 허용: ① [DONE] 종료 절차 ② "사용자 확인 필수" 예외로 질문할 때
#     ③ 사용자의 중단 지시
#
# 무한 차단 방지: 연속 차단 횟수가 한도(기본 200)를 넘으면 정지를 허용한다.
# exit 0 = 정지 허용, exit 2 = 정지 차단 (stderr 가 Claude 에게 전달됨)
set -u

SENTINEL="docs/.ceo-loop-active"

# stdin(JSON) 은 소비만 한다 — 센티널 존재가 유일한 판단 기준
cat > /dev/null

[ -f "$SENTINEL" ] || exit 0

COUNT="$(tr -cd '0-9' < "$SENTINEL" 2>/dev/null)"
COUNT="${COUNT:-0}"
LIMIT="${CEO_LOOP_MAX_CONTINUES:-200}"

if [ "$COUNT" -ge "$LIMIT" ]; then
  echo "[ceo-dev-loop] 연속 차단 한도(${LIMIT}회) 도달 — 안전을 위해 정지를 허용합니다. 루프 재개는 /ceo-dev-loop:start (센티널 카운터 리셋)." >&2
  exit 0
fi

echo $((COUNT + 1)) > "$SENTINEL"

{
  echo "[ceo-dev-loop] 자율 루프 활성 (${SENTINEL} 존재) — 턴 종료 차단 (${COUNT}/${LIMIT})."
  echo "- GOAL 미완료면 지금 즉시 계속하라: docs/STATUS.md 의 '다음 작업' 을 실행하거나 @ceo 를 재호출해 다음 지시를 받는다."
  echo "- 정당한 정지 사유라면 ${SENTINEL} 를 삭제한 뒤 종료하라. 정당한 사유는 셋뿐:"
  echo "  ① [DONE] 확정 후 최종 보고 완료  ② '사용자 확인 필수' 예외에 해당해 질문해야 함  ③ 사용자가 중단을 지시함"
} >&2
exit 2
