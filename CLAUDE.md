# pneumora-plugins

> Claude Code + Codex 듀얼 플러그인 마켓플레이스

## ⚠️ CRITICAL
<!-- /pneumora:critical 으로 매 세션 각인. 위반 시 회귀 또는 마켓플레이스 일관성 파괴. -->

1. **`scripts/new-plugin.sh` 의 `$DESCRIPTION` / `$PLUGIN_NAME` 을 JSON/YAML heredoc 에 직접 박지 말 것**
   - 큰따옴표·백슬래시·개행이 들어오면 `plugin.json`, `openai.yaml` 이 파싱 불가 상태로 생성된다.
   - 안전 경로: Python heredoc(argv 경유) 방식으로 통일하거나 `jq -Rs` 로 escape 후 삽입.
   - 위치: `scripts/new-plugin.sh:75-122, 156-164, 167-192`

2. **같은 플러그인의 `.claude-plugin/plugin.json` ↔ `.codex-plugin/plugin.json` 버전은 항상 동일하게**
   - 한쪽만 bump 하면 Codex 가 stale 버전을 서빙한다.
   - 버전 올릴 때 두 매니페스트 + 두 marketplace 엔트리를 한 커밋에 같이 수정.

3. **`git push` 직전 미추적 `plugin.json` / `SKILL.md` / `.codex-plugin/` 디렉토리가 있으면 push 금지**
   - Codex 쪽에서 플러그인이 작동하지 않는 좀비 상태가 된다.
   - 체크: `git status --short` 결과에 `?? .*(plugin\.json|SKILL\.md|\.codex-plugin)` 패턴이 있으면 차단.

4. **새 플러그인 추가는 반드시 `scripts/new-plugin.sh` 경유**
   - 두 marketplace.json 동기화를 보장. 수동 편집은 한쪽만 업데이트되는 회귀의 원인.

5. **Python 없는 환경에서 `new-plugin.sh` 사용 금지**
   - marketplace.json 자동 업데이트가 silent skip 되며 (`scripts/new-plugin.sh:258-266`) 등록 안 된 좀비 디렉토리만 만들어진다.

## 📋 Regression Log
<!-- /pneumora:log-regression 으로 누적. 한 번 겪은 문제는 다시 겪지 않는다. -->

- [2026-05-14] scripts/new-plugin.sh 가 $DESCRIPTION 을 JSON/YAML heredoc 에 직접 박아, 큰따옴표·백슬래시·개행이 포함된 입력이 들어오면 plugin.json·openai.yaml 이 파싱 불가 상태로 생성됨
  - 영향: `scripts/new-plugin.sh:75-122, 156-164, 167-192`
  - 재발 방지: 스캐폴딩 스크립트에서 사용자 입력값을 매니페스트·YAML 에 박을 때 반드시 Python heredoc(argv 경유) 또는 `jq -Rs` 로 escape

- [2026-05-14] Codex 용 `.codex-plugin/` · `skills/` · `agents/` 디렉토리가 git 에 트래킹되지 않은 채로 Claude 마켓플레이스만 동작 — Codex 쪽 좀비 상태
  - 영향: `pneumora/`, `ceo-dev-loop/`, `claude-md-harness/` 의 미추적 6개 경로
  - 재발 방지: `git push` 직전 `git status --short` 결과에 `??` 로 시작하는 `plugin.json` · `SKILL.md` · `.codex-plugin/` 가 있으면 차단 (`/pneumora:check-deploy` 활용)

- [2026-05-14] scripts/new-plugin.sh 가 Python 없는 환경에서 marketplace.json 자동 등록을 silent skip 하면서 exit 0 — 디렉토리는 생성됐는데 마켓플레이스에는 등록 안 된 좀비 플러그인 발생 가능
  - 영향: `scripts/new-plugin.sh:258-266`
  - 재발 방지: Python 부재 시 `exit 1` 로 강제 실패하거나 bash fallback 으로 marketplace 등록 보강

## Tech Stack

- Bash 스캐폴딩 (`scripts/new-plugin.sh`) + Python 3 (marketplace.json 업데이트)
- 메타데이터: JSON (`plugin.json`, `marketplace.json`)
- 스킬 본문: Markdown + YAML 프론트매터 (`SKILL.md`)
- 듀얼 타깃: Claude Code (`.claude-plugin/`) + Codex (`.codex-plugin/`, `.agents/plugins/`)

## Global Rules

- 모든 플러그인은 듀얼 매니페스트 (`.claude-plugin/plugin.json` + `.codex-plugin/plugin.json`) 필수
- SKILL.md `description` 프론트매터는 **한·영 트리거 키워드 병기** (자동 로드 정확도 ↑)
- 회귀 발견 시 즉시 `/pneumora:log-regression` 으로 기록 후 작업 진행
- 진행 상황은 PROGRESS.md 에, 규칙·구조는 CLAUDE.md 에 분리

## Directory Map

| Path | Description |
|------|-------------|
| `scripts/new-plugin.sh` | 새 플러그인 스캐폴딩 (듀얼 매니페스트 + 두 marketplace 등록) |
| `.claude-plugin/marketplace.json` | Claude Code 마켓플레이스 레지스트리 |
| `.agents/plugins/marketplace.json` | Codex 마켓플레이스 레지스트리 |
| `claude-md-harness/` | CLAUDE.md/AGENTS.md 하네스 구조화 스킬 |
| `pneumora/` | CRITICAL · Regression Log · check-deploy 회귀 방지 스킬 묶음 |
| `ceo-dev-loop/` | 목표 주도 자동화 루프 (Dev 구현 ↔ CEO/PM 체크포인트) |
| `dev-discipline/` | TDD + 아키텍처 deepening + 마이크로커밋 리팩터 플랜 |
| `domain-language/` | DDD 유비쿼터스 언어 + 도메인 모델 인터뷰 + grilling |
| `comm-modes/` | Caveman 토큰 절약 모드 + write-a-skill 메타 스킬 |
| `gh-flow/` | GitHub issue 기반 PRD/triage/QA 워크플로 |

## 참고

- 플러그인 추가 절차 / 사용자 설치 가이드 → `README.md`
- 출처 / mattpocock/skills 라이선스 / 적응 사항 → `README.md` Credits 섹션
