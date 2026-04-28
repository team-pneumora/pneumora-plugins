---
name: comm-modes
description: Index for output-style modes and skill-authoring meta-tools. The plugin bundles two sub-skills — `caveman` (token-saving terse mode) and `write-a-skill` (meta-skill for authoring new skills with Pneumora conventions). Use this dispatcher only when user invokes `/comm-modes` or asks "what's in comm-modes". 한국어 트리거 — "comm-modes 뭐 있어", "출력 스타일".
---

# comm-modes (dispatcher)

This plugin bundles two skills:

| Sub-skill | When it fires |
|---|---|
| [`caveman`](../caveman/SKILL.md) | "caveman", "캐이브맨", "토큰 줄여" — ~75% 토큰 절감 모드. `stop caveman`로 해제 |
| [`write-a-skill`](../write-a-skill/SKILL.md) | "새 skill 만들어줘", "SKILL.md 템플릿", "플러그인 저작 가이드" — Pneumora 컨벤션 포함 |

Each sub-skill auto-loads on its own trigger keywords.
