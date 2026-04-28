# dev-discipline

> TDD + 아키텍처 deepening + 마이크로커밋 리팩터 — Matt Pocock의 디시플린 3종

[mattpocock/skills](https://github.com/mattpocock/skills) (MIT) 의 3개 skill을 Pneumora 컨벤션에 맞춰 적응한 묶음.

## 설치

### Claude Code

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install dev-discipline@pneumora-plugins
```

### Codex

이 저장소를 Codex 플러그인 marketplace로 불러오거나, 직접 쓰려면 `skills/`를 `$CODEX_HOME/skills/`로 복사.

## 제공 sub-skill

| 이름 | 트리거 예시 | 출력물 |
|---|---|---|
| `tdd` | "TDD 시작", "레드그린", "tracer bullet" | 코드 + 테스트 (대화형) |
| `improve-codebase-architecture` | "아키텍처 개선", "shallow module 정리" | deepening 후보 목록 + grilling |
| `request-refactor-plan` | "리팩터 계획", "Fowler식 마이크로커밋 RFC" | `REFACTOR-PLAN.md` (로컬, GH 비의존) |

## Matt 원본과의 차이

- **`request-refactor-plan`** — 원본은 `gh issue create`로 끝남. 여기선 **`REFACTOR-PLAN.md` 로컬 파일** 작성. GH 없이도 동작.
- **frontmatter** — 한국어 트리거 키워드 추가 (자동 로드용)
- **`tdd` 보조 5파일** (deep-modules / interface-design / mocking / refactoring / tests) 그대로 포함
- **`improve-codebase-architecture`** — `CONTEXT-FORMAT.md` / `ADR-FORMAT.md` 참조를 `domain-language` 플러그인 경로로 변경

## 권장 페어링

- 새 기능: `tdd` 단독
- 큰 리팩터: `domain-language/grill-me` (스코프 인터뷰) → `request-refactor-plan` (마이크로커밋 분해) → `tdd` (실행)
- 시스템 정리: `improve-codebase-architecture` + `domain-language/ubiquitous-language`

## 라이선스

MIT. 원작자 Matt Pocock의 저작권 표기는 각 SKILL.md 상단 인용문에 보존.
