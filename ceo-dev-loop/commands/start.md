---
description: CEO-Dev 자동 루프를 시작합니다. GOAL.md 기반으로 작업이 자동 진행됩니다.
---

사용자가 `/ceo-dev-loop:start` 를 실행했습니다. 아래를 수행하세요.

## 사전 점검
1. `docs/GOAL.md`가 있는지 확인 — 없으면 `/ceo-dev-loop:init` 먼저 실행하라고 안내
2. `docs/GOAL.md`의 "필수 요구사항" 섹션이 비어있으면 사용자에게 작성 요청

## 루프 시작 (ceo-dev-loop v0.5.0)

1. `docs/GOAL.md`, `docs/STATUS.md`, `docs/DECISIONS.md` (있으면) 전부 읽기
2. 현재 상태 기반으로 첫 작업 파악 (STATUS가 "시작 전"이면 초기 세팅부터)
3. `@ceo`를 먼저 호출해 시작 승인 및 첫 작업 지시를 받기
   - 호출 메시지:
   ```
   @ceo 프로젝트 시작

   [목표]
   (GOAL.md 핵심 요약 + 진척 0/N)

   [현재 상태]
   (STATUS.md 요약 — 시작 전이면 "초기 상태")
   - 활성 컨텍스트: (있으면 요약)
   - 마지막 컴팩트 이후 0 턴

   [요청]
   첫 번째 작업 지시 바랍니다.
   ```
4. CEO 응답을 받고 CLAUDE.md 규칙에 따라 루프 실행
5. `[DONE]` 나올 때까지 자동 반복

## 주의
- 각 턴마다 사용자에게 확인받지 않음 (CEO가 승인 역할)
- 예외: CLAUDE.md 에 명시된 "사용자 확인 필수" 항목만 확인
- 에러 발생 시 자체 해결 시도 → 실패하면 CEO에게 에스컬레이션
- CEO 응답에 `[COMPACT]` / `[CLEAR]` 가 있으면 CLAUDE.md "컨텍스트 리프레시 절차" 를 먼저 수행
- CEO 응답에 `[DONE 후보]` 가 있으면 5 시나리오 모두 실행 후 결과 보고 → `@ceo` 재호출
- `[SPRINT COMPLETE]` 는 종료 신호 아님 — 같은 응답의 다음 작업 즉시 착수
- CEO 응답에 `[GOAL drift] N개 미매핑` 이 N≥1 이면 GOAL.md 보강 또는 DECISIONS.md 명시가 우선
