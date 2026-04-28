---
name: gh-flow
description: Index for GitHub issue-driven workflow — PRD synthesis, plan-to-issues breakdown, bug triage with TDD plans, label-based state-machine triage, conversational QA-to-issues. All 5 sub-skills require a GitHub remote and authenticated `gh` CLI. Use this dispatcher only when user invokes `/gh-flow` or asks "what's in gh-flow". 한국어 트리거 — "gh-flow 뭐 있어", "GitHub 워크플로 도구".
---

# gh-flow (dispatcher)

This plugin bundles five Matt Pocock skills focused on GitHub-issue-driven workflows. **All require a GitHub remote** — each sub-skill checks `git remote -v` before running.

| Sub-skill | When it fires |
|---|---|
| [`to-prd`](../to-prd/SKILL.md) | "PRD 만들어줘", "현재 대화를 PRD로". 인터뷰 없이 합성 → GH issue |
| [`to-issues`](../to-issues/SKILL.md) | "이슈로 쪼개줘", "vertical slice 분해". 의존성 표시 + 병렬화 |
| [`triage-issue`](../triage-issue/SKILL.md) | "버그 트리아지", "루트원인 + TDD 픽스 플랜". 핸즈오프 조사 |
| [`github-triage`](../github-triage/SKILL.md) | "이슈 트리아지", "needs-triage 처리". 라벨 기반 state machine |
| [`qa-to-issue`](../qa-to-issue/SKILL.md) | "QA 세션 → issue 파일링". (Matt의 `qa`를 글로벌 `/qa` 충돌 회피 위해 리네임) |

## Prerequisites for the whole plugin

- `gh` CLI installed and authenticated (`gh auth status`)
- Current repo has a GitHub remote (`git remote -v` shows `github.com`)

If GH 의존이 부담스러우면:
- **PRD 대신 로컬 파일** — `dev-discipline` 플러그인의 `request-refactor-plan` (REFACTOR-PLAN.md 작성)
- **버그 신고 + 직접 수정** — 글로벌 `/qa` 슬래시 커맨드 (Next.js 테스트 + 버그 수정)
