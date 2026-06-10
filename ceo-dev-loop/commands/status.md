---
description: 현재 프로젝트의 루프 진행 상태와 결정 로그를 요약해서 보여줍니다.
---

1. `docs/GOAL.md`, `docs/STATUS.md`, `docs/DECISIONS.md`를 읽기
2. 다음 형식으로 요약 출력:

```
📋 프로젝트: (GOAL.md 첫 줄)
🔁 ceo-dev-loop v0.7.0  (루프: 활성 | 비활성 — docs/.ceo-loop-active 존재 여부)

✅ 완료된 요구사항: N / M 개
   - [x] ...
   - [ ] ...

📍 현재 작업
   (STATUS.md 최근 작업)

🚨 GOAL drift (완료 경계에서만 측정)
   마지막 완료 게이트(`[SPRINT COMPLETE]`/`[DONE 후보]`) 측정값: N 개 미매핑
   - {미매핑 작업 1줄 요약}
   - ...
   (아직 완료 경계 전이면 "측정 안 됨 — 완료 게이트에서 측정 예정")

🧠 활성 컨텍스트
   - 현재 만지는 파일: ...
   - 미해결 결정: ...

📐 정책 (DECISIONS.md ## 정책)
   - ... (없으면 "없음")

❓ 미확인 가정 (DECISIONS.md ## 가정)
   - ... (없으면 "없음" — 있으면 사용자 검토 대상임을 표시)

🧭 주요 결정 (최근 5개)
   - ...

⏭ 다음 작업
   (STATUS.md 다음 작업)
```

이후 사용자에게 "계속 진행할까요? (`/ceo-dev-loop:start`)" 안내
