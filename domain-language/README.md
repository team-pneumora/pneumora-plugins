# domain-language

> DDD 디시플린 묶음 — 용어집, 도메인 모델 인터뷰, plan grilling, zoom-out

[mattpocock/skills](https://github.com/mattpocock/skills) (MIT) 의 4개 skill을 Pneumora 컨벤션에 맞춰 적응한 묶음.

## 설치

### Claude Code

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install domain-language@pneumora-plugins
```

### Codex

이 저장소를 Codex 플러그인 marketplace로 불러오거나, 직접 쓰려면 `skills/`를 `$CODEX_HOME/skills/`로 복사.

## 제공 sub-skill

| 이름 | 트리거 예시 | 출력물 |
|---|---|---|
| `ubiquitous-language` | "용어집 만들어줘", "DDD 글로사리" | `UBIQUITOUS_LANGUAGE.md` |
| `domain-model` | "CONTEXT.md 갱신하면서 grill", "ADR 살피며 플랜 검증" | `CONTEXT.md`, `docs/adr/*` 인라인 갱신 |
| `grill-me` | "grill me", "구워줘" | 결정 트리 인터뷰 (출력 없음, 대화) |
| `zoom-out` | "줌아웃", "한 층 위로" | 모듈/콜러 지도 (대화) |

## Matt 원본과의 차이

- **frontmatter** — 한국어 트리거 키워드 추가
- **`domain-model`** — `CONTEXT-FORMAT.md`, `ADR-FORMAT.md` 보조파일 그대로 포함 (다른 플러그인 `dev-discipline/improve-codebase-architecture`도 이 경로 참조)
- **`disable-model-invocation: true`** — `ubiquitous-language`, `domain-model`, `zoom-out`은 명시적 호출만 허용 (원본 그대로)

## 권장 페어링

- **개념 정의** → `ubiquitous-language` 로 시작
- **계획 검증** → `domain-model` (도메인 인지) 또는 `grill-me` (도메인 무관)
- **익숙하지 않은 코드** → `zoom-out` 후 본 작업
- **아키텍처 개선** → 본 플러그인 + `dev-discipline/improve-codebase-architecture`

## 라이선스

MIT. 원작자 Matt Pocock의 저작권 표기는 각 SKILL.md 상단 인용문에 보존.
