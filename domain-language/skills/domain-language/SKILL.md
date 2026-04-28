---
name: domain-language
description: Index for DDD ubiquitous language + domain model interview + grilling + zoom-out. The plugin bundles four sub-skills — `ubiquitous-language`, `domain-model`, `grill-me`, `zoom-out` — auto-loaded by their own descriptions. Use this dispatcher only when user invokes `/domain-language` or asks "what's in domain-language". 한국어 트리거 — "domain-language 뭐 있어", "DDD 도구 보여줘".
---

# domain-language (dispatcher)

This plugin bundles four Matt Pocock skills, adapted for Pneumora:

| Sub-skill | When it fires |
|---|---|
| [`ubiquitous-language`](../ubiquitous-language/SKILL.md) | "용어집 만들어줘", "DDD 글로사리". `UBIQUITOUS_LANGUAGE.md` 작성 |
| [`domain-model`](../domain-model/SKILL.md) | "CONTEXT.md 갱신하면서 grill", "ADR 살피며 플랜 검증". `CONTEXT.md` / `docs/adr/` 인라인 갱신 |
| [`grill-me`](../grill-me/SKILL.md) | "grill me", "구워줘", 결정 트리 인터뷰 |
| [`zoom-out`](../zoom-out/SKILL.md) | "줌아웃", "한 층 위로", "큰 그림" |

Each sub-skill auto-loads on its own trigger keywords.

## 권장 페어링
- **`improve-codebase-architecture` (dev-discipline 플러그인)** + `domain-model` + `ubiquitous-language` — 도메인 언어를 명확히 한 뒤 아키텍처 deepening 기회 발굴.
- **`grill-me`** 단독 — 도메인과 무관한 일반 플랜 인터뷰.
