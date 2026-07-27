# pneumora-plugins

> Claude Code + Codex 듀얼 플러그인 마켓플레이스 — Bash + Python 3 / JSON 매니페스트 / Markdown+YAML 스킬

## ⚠️ CRITICAL

1. **사용자 입력을 셸 heredoc 에 박지 말 것** — JSON/YAML 이 깨진다. Python argv + `json.dumps` 경유
2. **버전은 `.claude-plugin` ↔ `.codex-plugin` ↔ 두 marketplace.json 을 한 커밋에 동시 bump** — 한쪽만 올리면 Codex 가 stale 서빙
3. **미추적 `plugin.json` / `SKILL.md` / `.codex-plugin/` 있으면 push 금지** — Codex 좀비 상태
4. **새 플러그인은 `scripts/new-plugin.sh` 경유 필수** — 수동 편집은 marketplace 한쪽만 갱신되는 회귀
5. **hook 은 프로젝트 파일을 `$CLAUDE_PROJECT_DIR` 로 앵커** — 상대 경로 + "없으면 통과" 는 안전장치를 조용히 끄는 패턴
6. **안전장치가 자기 리셋 조건을 스스로 유발하지 않는지 확인** — 리셋 카운터 + 리셋 없는 절대 상한을 쌍으로

기계 강제: 2·3 → `validate-plugins.sh` / 1·4 → `new-plugin.sh` (push hook 자동)

## Compact Recovery

컨텍스트 요약 정황이 보이면 `PROGRESS.md` `## 활성 컨텍스트` 재독 후 그 지점부터 재개 (다시 묻지 않는다).

## Global Rules

- 모든 플러그인은 듀얼 매니페스트 필수
- SKILL.md `description` 은 한·영 트리거 키워드 병기
- 회귀 발견 시 즉시 `/pneumora:log-regression` 기록 후 진행
- **프롬프트 작성 4원칙** (SKILL.md·commands·agents) — 모델은 자기검증·위임·장문을 스스로 과하게 한다: ① 자기 재검증 지시 금지 ② 위임 조건·상한 명시 ③ 산출물 분량 예산 명시 ④ 보고 cadence 명시
- 진행 상황 → `PROGRESS.md`, 규칙·구조 → 이 파일 (Codex 는 `AGENTS.md` — 함께 갱신)

## Directory Map

| Path | Description |
|------|-------------|
| `scripts/` | `new-plugin.sh` 스캐폴딩 · `validate-plugins.sh` 검증 |
| `.claude-plugin/` · `.agents/plugins/` | 두 레지스트리 — 동시 갱신 |
| `claude-md-harness/` | 하네스 구조화 |
| `pneumora/` | CRITICAL·회귀·배포 가드 |
| `ceo-dev-loop/` | 자율 루프 (Dev ↔ CEO) |
| `handoff/` | 종료 핸드오프 |

## 참고

이어받기 → `docs/handoff/HANDOFF.md` / 회귀 → `docs/REGRESSIONS.md` / 설치 → `README.md`
