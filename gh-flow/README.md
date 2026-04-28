# gh-flow

> GitHub issue 기반 PRD / issues / triage / QA 워크플로

[mattpocock/skills](https://github.com/mattpocock/skills) (MIT) 의 5개 GitHub-issue 워크플로 skill 묶음.

## 전제조건

- GitHub remote 가 있는 repo (`git remote -v` 에 `github.com` 포함)
- `gh` CLI 인증 완료 (`gh auth status`)

전제 미충족 시 각 sub-skill이 거절하고 안내.

## 설치

### Claude Code

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install gh-flow@pneumora-plugins
```

### Codex

이 저장소를 Codex 플러그인 marketplace로 불러오거나, 직접 쓰려면 `skills/`를 `$CODEX_HOME/skills/`로 복사.

## 제공 sub-skill

| 이름 | 트리거 예시 | 출력물 |
|---|---|---|
| `to-prd` | "PRD 만들어줘", "현재 대화를 PRD로" | GH issue (PRD 템플릿) |
| `to-issues` | "이슈로 쪼개줘", "vertical slice 분해" | 다수 GH issues (의존성 표시) |
| `triage-issue` | "버그 트리아지", "TDD 픽스 플랜" | GH issue (Problem + Root Cause + TDD plan) |
| `github-triage` | "이슈 트리아지", "needs-triage 처리" | 라벨 변경 + 코멘트 (state machine) |
| `qa-to-issue` | "QA 세션 → issue 파일링" | 다수 GH issues (대화형) |

## Matt 원본과의 차이

- **`qa-to-issue` 리네임** — 사용자의 글로벌 `/qa` 슬래시 커맨드(Next.js 테스트+버그 수정)와 트리거 충돌을 막기 위해 `qa` → `qa-to-issue` 로 이름 변경. Matt 원본 `qa`와 같은 동작이지만 트리거가 다름.
- **Prerequisites 가드** — 각 sub-skill이 시작 시 `git remote -v` 로 GitHub remote 확인. 없으면 거절 + 대안 안내 (예: `dev-discipline/request-refactor-plan`은 로컬 파일).
- **frontmatter** — 한국어 트리거 키워드 추가
- **`github-triage`** — 보조파일 `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md` 그대로 포함

## 글로벌 `/qa`와의 관계

| 도구 | 트리거 | 목적 |
|---|---|---|
| 글로벌 `/qa` (`~/.claude/commands/qa.md`) | `/qa` 명시 호출 | Next.js 테스트 실행 + 버그 직접 수정 + 회귀 테스트 작성 |
| `gh-flow/qa-to-issue` | "QA 세션", "버그 issue 파일링" | 사용자가 신고하는 버그를 GH issue로 정리 |

둘은 **다른 축** — 충돌 없음.

## 라이선스

MIT. 원작자 Matt Pocock의 저작권 표기는 각 SKILL.md 상단 인용문에 보존.
