# comm-modes

> 출력 스타일 모드 + 새 skill 작성 메타-가이드

## 출처 (Source)

이 플러그인은 [**mattpocock/skills**](https://github.com/mattpocock/skills) (MIT, [Matt Pocock](https://github.com/mattpocock)) 의 2개 skill을 Pneumora 컨벤션에 맞춰 적응한 derivative work 입니다.

| Pneumora skill | 원본 |
|---|---|
| `caveman` | [mattpocock/skills/caveman](https://github.com/mattpocock/skills/tree/main/caveman) |
| `write-a-skill` | [mattpocock/skills/write-a-skill](https://github.com/mattpocock/skills/tree/main/write-a-skill) |

- **임포트 시점 commit**: [`90ea8ee`](https://github.com/mattpocock/skills/tree/90ea8ee) (2026-04-26)
- **라이선스**: MIT (원본·적응본 동일)

## 설치

### Claude Code

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install comm-modes@pneumora-plugins
```

### Codex

이 저장소를 Codex 플러그인 marketplace로 불러오거나, 직접 쓰려면 `skills/`를 `$CODEX_HOME/skills/`로 복사.

## 제공 sub-skill

| 이름 | 트리거 예시 | 효과 |
|---|---|---|
| `caveman` | "caveman", "캐이브맨", "토큰 줄여" | 응답 토큰 ~75% 절감 (관사·추임새·예의어 제거). `stop caveman`으로 해제 |
| `write-a-skill` | "새 skill 만들어줘", "SKILL.md 템플릿" | 새 skill 작성 가이드 + Pneumora 컨벤션 |

## Matt 원본과의 차이

- **`caveman`** — 한국어 모드에서도 적용되도록 한국어 전용 규칙 섹션 추가 (조사 일부 생략 / 추임새 제거 / 약어 우선)
- **`write-a-skill`** — 본문 끝에 **Pneumora Plugins conventions** 섹션 추가:
  - `scripts/new-plugin.sh` 사용 (수동 스캐폴드 금지)
  - 한 플러그인 안에 다중 sub-skill 가능
  - 하이브리드 한/영 frontmatter (한국어 트리거 키워드 필수)
  - 듀얼 매니페스트 (`.claude-plugin` + `.codex-plugin`)
  - Codex agents/openai.yaml 메타데이터
  - 외부 skill 적응 시 출처 표기 양식
  - 글로벌 슬래시 커맨드와 트리거 충돌 검사
  - 커밋 전 jq + marketplace 검증

## 라이선스

MIT. 원작자 Matt Pocock의 저작권 표기는 각 SKILL.md 상단 인용문에 보존.
