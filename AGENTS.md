# pneumora-plugins

> Claude Code + Codex 듀얼 플러그인 마켓플레이스 (Codex 세션용 — Claude 는 `CLAUDE.md`)

## ⚠️ CRITICAL

1. **사용자 입력을 셸 heredoc 에 직접 박지 말 것** — JSON/YAML 이 깨진다. Python argv 경유 + `json.dumps` 인코딩 (`scripts/new-plugin.sh` 참고)
2. **버전은 `.claude-plugin` ↔ `.codex-plugin` ↔ 두 marketplace.json 을 한 커밋에 동시 bump** — 한쪽만 올리면 Codex 가 stale 서빙
3. **미추적 `plugin.json` / `SKILL.md` / `.codex-plugin/` 있으면 push 금지** — Codex 좀비 상태
4. **새 플러그인은 반드시 `scripts/new-plugin.sh` 경유** — 수동 편집은 marketplace 한쪽만 갱신되는 회귀 원인
5. **hook 스크립트는 프로젝트 파일을 `$CLAUDE_PROJECT_DIR` 로 앵커** — 상대 경로 + "없으면 통과" 는 안전장치를 조용히 끄는 패턴 (Codex 도 hook 을 *작성*한다)
6. **안전장치가 자기 리셋 조건을 스스로 유발하지 않는지 확인** — 리셋 카운터 + 리셋 없는 절대 상한을 쌍으로

> **Codex 에는 PreToolUse hook 이 없어 2·3 이 자동 차단되지 않는다.**
> push 전 `bash scripts/validate-plugins.sh` 직접 실행 — Codex 의 유일한 방어선.

## Compact Recovery

컨텍스트가 요약된 정황이 보이면 `PROGRESS.md` 의 `## 활성 컨텍스트` 를 재독하고 그 지점부터 재개 (사용자에게 다시 묻지 않는다).

## Global Rules

- 스택: Bash + Python 3 / JSON 매니페스트 / Markdown+YAML 스킬
- 모든 플러그인은 듀얼 매니페스트 필수
- SKILL.md `description` 은 한·영 트리거 키워드 병기
- 회귀 발견 시 즉시 `pneumora` 스킬 log-regression 으로 기록 후 진행
- 진행 상황 → `PROGRESS.md`, 규칙·구조 → 이 파일 (Claude 는 `CLAUDE.md` — 함께 갱신)

## Directory Map

| Path | Description |
|------|-------------|
| `scripts/` | `new-plugin.sh` 스캐폴딩 · `validate-plugins.sh` 검증 |
| `.claude-plugin/` · `.agents/plugins/` | 두 레지스트리 — 동시 갱신 |
| `claude-md-harness/` | 하네스 |
| `pneumora/` | CRITICAL·회귀·배포 가드 |
| `ceo-dev-loop/` | 자율 루프 (Codex 는 프롬프트 규칙) |
| `handoff/` | 종료 핸드오프 |

## 참고

이어받기 → `docs/handoff/HANDOFF.md` / 회귀 → `docs/REGRESSIONS.md` / 설치 → `README.md`
