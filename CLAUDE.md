# pneumora-plugins

> Claude Code + Codex 듀얼 플러그인 마켓플레이스

## ⚠️ CRITICAL

1. **사용자 입력을 셸 heredoc 에 직접 박지 말 것** — JSON/YAML 이 깨진다. Python argv 경유 + `json.dumps` 인코딩 (`scripts/new-plugin.sh` 참고)
2. **버전은 `.claude-plugin` ↔ `.codex-plugin` ↔ 두 marketplace.json 을 한 커밋에 동시 bump** — 한쪽만 올리면 Codex 가 stale 서빙
3. **미추적 `plugin.json` / `SKILL.md` / `.codex-plugin/` 있으면 push 금지** — Codex 좀비 상태
4. **새 플러그인은 반드시 `scripts/new-plugin.sh` 경유** — 수동 편집은 marketplace 한쪽만 갱신되는 회귀 원인
5. **hook 스크립트는 프로젝트 파일을 `$CLAUDE_PROJECT_DIR` 로 앵커** — 상대 경로 + "없으면 통과" 는 안전장치를 조용히 끄는 패턴
6. **안전장치가 자기 리셋 조건을 스스로 유발하지 않는지 확인** — 리셋 카운터 + 리셋 없는 절대 상한을 쌍으로

2·3 은 `validate-plugins.sh`, 1·4 는 `new-plugin.sh` 가 기계 강제 (push 시 hook 자동).

## Compact Recovery

컨텍스트가 요약된 정황이 보이면:
1. `PROGRESS.md` 재독 — `## 활성 컨텍스트` 우선
2. 그 지점부터 재개 (사용자에게 다시 묻지 않는다)

## Tech Stack

Bash + Python 3 / JSON 매니페스트 / Markdown+YAML 스킬.

## Global Rules

- 모든 플러그인은 듀얼 매니페스트 필수
- SKILL.md `description` 은 한·영 트리거 키워드 병기
- 회귀 발견 시 즉시 `/pneumora:log-regression` 기록 후 진행
- 진행 상황 → `PROGRESS.md`, 규칙·구조 → 이 파일 (Codex 는 `AGENTS.md` — 함께 갱신)

## Directory Map

| Path | Description |
|------|-------------|
| `scripts/new-plugin.sh` | 스캐폴딩 (듀얼 매니페스트 + marketplace 등록) |
| `scripts/validate-plugins.sh` | 무결성 검증 (버전·JSON·좀비) |
| `.claude-plugin/` · `.agents/plugins/` | 두 마켓플레이스 레지스트리 — 동시 갱신 |
| `claude-md-harness/` | 하네스 구조화 스킬 |
| `pneumora/` | CRITICAL·회귀 로그·배포 가드 |
| `ceo-dev-loop/` | 목표 주도 자율 루프 (Dev ↔ CEO) |
| `handoff/` | 작업 종료 핸드오프 자동화 |

## 참고

이어받기 → `docs/handoff/HANDOFF.md` / 회귀 이력 → `docs/REGRESSIONS.md` / 설치 → `README.md`
