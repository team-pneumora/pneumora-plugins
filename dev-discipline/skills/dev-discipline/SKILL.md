---
name: dev-discipline
description: Index for TDD + architecture deepening + micro-commit refactor planning. The plugin bundles three sub-skills — `tdd`, `improve-codebase-architecture`, `request-refactor-plan` — auto-loaded by their own descriptions. Use this dispatcher only when the user asks "what's in dev-discipline" or invokes `/dev-discipline` without a specific sub-task. 한국어 트리거 — "dev-discipline 뭐 있어", "디시플린 모음 보여줘".
---

# dev-discipline (dispatcher)

This plugin bundles three Matt Pocock skills, adapted for Pneumora:

| Sub-skill | When it fires |
|---|---|
| [`tdd`](../tdd/SKILL.md) | "TDD 시작", "레드그린", "tracer bullet", behavior-first 테스트 |
| [`improve-codebase-architecture`](../improve-codebase-architecture/SKILL.md) | "아키텍처 개선", "shallow module 정리", "deepening 기회" |
| [`request-refactor-plan`](../request-refactor-plan/SKILL.md) | "리팩터 계획", "마이크로커밋 분해", Martin Fowler식 RFC. Local `REFACTOR-PLAN.md` 작성 (GH 비의존) |

Each sub-skill auto-loads on its own trigger keywords. This dispatcher does nothing on its own — it only exists so `dev-discipline` shows up in the marketplace listing.

## When to read which sub-skill
- 새 기능을 안전하게 짓기 → `tdd`
- 기존 코드를 더 깊은 모듈로 합치기 → `improve-codebase-architecture`
- 큰 리팩터를 작은 커밋들로 분해 → `request-refactor-plan`
