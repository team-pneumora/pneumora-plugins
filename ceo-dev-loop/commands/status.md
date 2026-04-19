---
description: 현재 프로젝트의 루프 진행 상태와 결정 로그를 요약해서 보여줍니다.
---

1. `docs/GOAL.md`, `docs/STATUS.md`, `docs/DECISIONS.md`를 읽기
2. 다음 형식으로 요약 출력:

```
📋 프로젝트: (GOAL.md 첫 줄)
🔁 ceo-dev-loop v0.4.0

✅ 완료된 요구사항: N / M 개
   - [x] ...
   - [ ] ...

📍 현재 작업
   (STATUS.md 최근 작업)

🧠 활성 컨텍스트
   - 현재 만지는 파일: ...
   - 미해결 결정: ...
   - 마지막 컴팩트 이후: N 턴

🧭 주요 결정 (최근 5개)
   - ...

⏭ 다음 작업
   (STATUS.md 다음 작업)
```

3. STATUS.md 턴 카운터가 5 이상이면 한 줄 경고:
   `⚠ 컨텍스트 비대 — 다음 @ceo 호출 시 [COMPACT] 신호 받을 가능성 높음`

이후 사용자에게 "계속 진행할까요? (`/ceo-dev-loop:start`)" 안내
