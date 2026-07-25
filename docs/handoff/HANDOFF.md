# HANDOFF — pneumora-plugins

> 최종 갱신: 2026-07-25 · 다음 작업자는 이 파일부터 읽으세요.

## 🎯 현재 목표

플러그인 4종(ceo-dev-loop · pneumora · claude-md-harness · handoff)의 **안전장치가 실제로 작동하는 상태로 배포되도록** 하드닝. 이번 세션은 전체 감사 → 결함 수정 → 적대적 리뷰 → 배포까지 완료했습니다.

## ✅ 방금 끝낸 작업

`a01bc75..a7d8d25` (4커밋, 26파일, +753/-290) — 전부 `origin/main` 반영됨

| 커밋 | 내용 |
|---|---|
| `1dc081e` | `.gitattributes` 로 `.sh` LF 고정 + 좀비 검사 재설계 |
| `fb585a8` | ceo-dev-loop **0.8.0** / pneumora **0.3.0** / handoff **0.2.0** |
| `66fc13f` | 루트 CLAUDE.md 압축(1628→780) · `AGENTS.md` 신설 · 회귀 로그 로테이션 |
| `a7d8d25` | `new-plugin.sh` 인젝션 제거 (CRITICAL #1·#5 해소) |

미커밋 상태로 남은 것: 이 핸드오프 커밋(README 갱신 절차 · handoff 0.2.1 · HANDOFF.md).

핵심 수정 5건 — 전부 **"안전장치가 조용히 무력화되는"** 유형이었습니다:

1. **CEO 가 검증을 못 하던 문제** — 7-gate·5-시나리오·증거 체크박스가 전부 "Dev 자기 보고" 라는 같은 가정 위에 있어 겹쳐도 두께가 안 늘었음. CEO 에 검증 전용 Bash + `effort: high`, 완료 경계에서 명령 재실행해 대조 (8-gate)
2. **Stop hook 안전밸브 도달 불가** — 훅 자신이 "매 턴 STATUS.md 갱신" 을 지시하므로 리셋 조건이 매 턴 충족돼 밸브가 영원히 안 열림. `CEO_LOOP_MAX_TOTAL` 절대 상한 추가로 2중화
3. **센티널 상대경로 fail-open** — cwd 가 하위 디렉토리면 루프 강제가 에러 없이 풀림. `$CLAUDE_PROJECT_DIR` 앵커
4. **CRLF 체크아웃** — Windows clone 시 `validate-plugins.sh` 가 실존 파일을 "없음" 으로 오탐 (exit 1). `.gitattributes`
5. **스캐폴딩 인젝션** — 2026-05-14 부터 미해결이던 CRITICAL #1·#5

## 🔜 다음 단계 (바로 착수)

1. **실제 프로젝트에서 루프 1회 완주** — 목표가 있는 프로젝트에서 `cd` 후 `claude` → `/ceo-dev-loop:init "목표"`. 지금까지 검증은 스크립트 단위 실측 + Stop hook 실전 확인까지이고, **`init` → `[DONE]` 전체 사이클(CEO 독립 검증·8-gate·5-시나리오)은 아직 안 돌려봤음**. Stop hook 은 세션의 프로젝트 디렉토리에만 걸리므로 이 레포에서는 대신 검증할 수 없음
2. `claude-md-harness` 는 이번 감사에서 손대지 않았음 — 유일하게 버전이 그대로(1.1.0). 같은 수준으로 점검할지 판단 필요

## ⚠️ 회귀 주의 / 함정

1. **설치된 플러그인은 캐시에서 돈다. 레포에 푸시해도 세션은 안 바뀐다.**
   서드파티 마켓플레이스는 auto-update 가 **기본 꺼짐**입니다.
   ```
   claude plugin marketplace update pneumora-plugins   # 또는 /plugin marketplace update ...
   claude plugin update ceo-dev-loop@pneumora-plugins  # 플러그인별로
   /reload-plugins                                     # 세션 반영 (인세션 전용)
   ```
   확인: `ls ~/.claude/plugins/cache/pneumora-plugins/ceo-dev-loop/` → `0.8.0` 이어야 함.
   CLI 갱신은 디스크만 바꾸고, 세션 반영은 `/reload-plugins` 또는 재시작이 필요합니다.
   `/plugin` → Marketplaces 탭에서 auto-update 를 켜두면 이후엔 자동입니다.

2. **`docs/.ceo-loop-active` 를 남긴 채 세션을 끝내지 말 것** — Stop hook 이 턴 종료를 계속 차단합니다. 정당한 정지는 셋뿐(`[DONE]` / 사용자 확인 필수 예외 / 중단 지시). 이 레포는 루프를 쓰지 않아 센티널이 없습니다.

3. **`new-plugin.sh` 수정 시 사용자 입력을 heredoc 에 되돌리지 말 것** — CRITICAL #1. 모든 값은 Python argv 경유 + `json.dumps`. 되돌리면 2026-05-14 회귀가 그대로 재현됩니다.

4. **하네스 토큰 예산이 빡빡함** — `CLAUDE.md` 780/800, `AGENTS.md` 797/800. CRITICAL 한 줄만 늘려도 초과합니다. 추가 시 다른 항목을 줄이고 `harness-lint.sh` 로 확인하세요.

5. **`bash -n` 은 CRLF 문제를 못 잡습니다** — 스크립트 검증은 LF 원본뿐 아니라 CRLF 사본으로도 해볼 것 (`sed 's/$/\r/'`).

## 🧭 재개 지점

- 브랜치: `main` · 작업 트리: 이 핸드오프 커밋 전까지 clean, `origin/main` 과 동기
- 시작 파일: `PROGRESS.md` (`## 활성 컨텍스트` → 최신 세션 순)
- 실행·검증:
  ```bash
  bash scripts/validate-plugins.sh                                                   # 버전 동기·JSON·좀비
  bash claude-md-harness/skills/claude-md-harness/scripts/harness-lint.sh CLAUDE.md  # 토큰 예산
  bash claude-md-harness/skills/claude-md-harness/scripts/harness-lint.sh AGENTS.md
  for f in $(git ls-files '*.sh'); do bash -n "$f"; done
  ```
- 환경 전제: **Python 3 필수** (`new-plugin.sh`·`validate-plugins.sh`). PyYAML 은 스캐폴딩 검증에만 사용(선택). 빌드·테스트 프레임워크 없음 — 검증은 위 셸 스크립트가 전부
- push 계정: `gh` 활성 계정이 `Mombin` 이면 **403**. 전역 전환 없이:
  ```bash
  GH_TOKEN="$(gh auth token --user team-pneumora --hostname github.com)" git push origin main
  ```
- 자율 루프: 이 레포는 ceo-dev-loop 를 사용하지 않음 (센티널 없음)

## 🔗 관련 기록

- 세션 로그: `PROGRESS.md` — 2026-07-25 항목 (이 레포는 `docs/sessions/` 대신 루트 `PROGRESS.md` 관례를 씁니다)
- 회귀: `docs/REGRESSIONS.md` — 이번 세션 발견 6건 포함 총 9건
- 결정: 별도 ADR 없음. 버전별 설계 근거는 각 플러그인 README 의 Changelog
- 규칙·구조: `CLAUDE.md` (Claude) / `AGENTS.md` (Codex) — CRITICAL 6개 동일
