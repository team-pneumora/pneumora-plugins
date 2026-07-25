# HANDOFF — pneumora-plugins

> 최종 갱신: 2026-07-25 · 다음 작업자는 이 파일부터 읽으세요.

## 🎯 현재 목표

플러그인 4종(ceo-dev-loop · pneumora · claude-md-harness · handoff)이 **안전장치가 실제로 작동하는 상태로 배포되도록** 하드닝. 이번 세션은 전체 감사 → 결함 수정 → 적대적 리뷰 → 배포 → 실환경 검증까지 완료했습니다.

## ✅ 방금 끝낸 작업

`a01bc75..81489f2` (6커밋, 29파일, +894/-291) — 전부 `origin/main` 반영됨

| 커밋 | 내용 |
|---|---|
| `1dc081e` | `.gitattributes` 로 `.sh` LF 고정 + 좀비 검사 재설계 |
| `fb585a8` | ceo-dev-loop **0.8.0** / pneumora **0.3.0** / handoff **0.2.0** |
| `66fc13f` | 루트 CLAUDE.md 압축 · `AGENTS.md` 신설 · 회귀 로그 로테이션 |
| `a7d8d25` | `new-plugin.sh` 인젝션 제거 (CRITICAL #1·#5 해소) |
| `ec39057` | 플러그인 캐시 갱신 절차 문서화 · handoff **0.2.1** · HANDOFF.md 신설 |
| `81489f2` | Stop hook 실환경 검증 기록 · 센티널 gitignore |

수정 5건 — 전부 **"안전장치가 조용히 무력화되는"** 유형이었습니다:

1. **CEO 가 검증을 못 하던 문제** — 7-gate·5-시나리오·증거 체크박스가 전부 "Dev 자기 보고" 라는 같은 가정 위에 있어 겹쳐도 두께가 안 늘었음. 검증 전용 Bash + `effort: high`, 완료 경계에서 명령 재실행 대조 (8-gate)
2. **Stop hook 안전밸브 도달 불가** — 훅 자신이 "매 턴 STATUS.md 갱신" 을 지시하므로 리셋 조건이 매 턴 충족돼 밸브가 영원히 안 열림. `CEO_LOOP_MAX_TOTAL` 절대 상한으로 2중화
3. **센티널 상대경로 fail-open** — cwd 가 하위 디렉토리면 루프 강제가 에러 없이 풀림. `$CLAUDE_PROJECT_DIR` 앵커
4. **CRLF 체크아웃** — Windows clone 시 `validate-plugins.sh` 가 실존 파일을 "없음" 으로 오탐. `.gitattributes`
5. **스캐폴딩 인젝션** — 2026-05-14 부터 미해결이던 CRITICAL #1·#5

**실환경 검증 완료**: 캐시 갱신 후 센티널을 심고 턴을 종료해 Stop hook 이 실제로 차단하는 것을 확인. 차단 메시지의 `무진척 0/200, 누적 0/1000` 표기와 절대경로 출력이 v0.8.0 로드의 직접 증거이고, 훅이 쓴 `1 0 1` 이 3필드 형식을 확인시켜 줍니다.

## 🔜 다음 단계 (바로 착수)

1. **실제 프로젝트에서 루프 1회 완주** — 목표가 있는 프로젝트에서 `cd` 후 `claude` → `/ceo-dev-loop:init "목표"`. **유일하게 남은 미검증 영역**입니다. 관찰 포인트:
   - 완료 경계에서 **CEO 가 검증 명령을 직접 재실행**하는지 (v0.8.0 의 핵심)
   - 턴이 사용자 입력 대기로 빠지지 않고 계속 도는지
   - `/ceo-dev-loop:status` 의 `안전밸브: 무진척 N/200 · 누적 M/1000` 이 정상 범위인지
   - 목표는 한 턴에 안 끝날 규모로 — 즉시 완료되면 8-gate·5-시나리오가 발동을 안 합니다
   - Stop hook 은 **세션의 프로젝트 디렉토리에만** 걸리므로 이 레포에서는 대신 검증 불가
2. `claude-md-harness` 는 이번 감사 범위 밖이었음 — 유일하게 버전이 그대로(1.1.0). 같은 수준으로 점검할지 판단 필요

## ⚠️ 회귀 주의 / 함정

1. **설치된 플러그인은 캐시에서 돈다. 레포에 푸시해도 세션은 안 바뀐다.**
   서드파티 마켓플레이스는 auto-update 가 **기본 꺼짐**입니다.
   ```
   claude plugin marketplace update pneumora-plugins
   claude plugin update ceo-dev-loop@pneumora-plugins   # 플러그인별
   /reload-plugins                                      # 인세션 전용 — CLI 로는 불가
   ```
   확인: `ls ~/.claude/plugins/cache/pneumora-plugins/ceo-dev-loop/` → `0.8.0`.
   `/plugin` → Marketplaces → **Enable auto-update** 로 재발 방지.

2. **하네스 여유가 거의 없음** — `CLAUDE.md` 790/800, `AGENTS.md` 796/800.
   7번째 CRITICAL 을 넣으려면 뭔가 내려야 합니다. **로테이션 기준: 기계 강제되는 규칙부터 내린다.**
   현재 #2·#3 은 `validate-plugins.sh` 가 완전 강제 → 축약 여지 있음.
   #4·#5·#6 은 강제 수단이 없어 루트 유지가 맞습니다.

3. **`docs/.ceo-loop-active` 를 남긴 채 세션을 끝내지 말 것** — Stop hook 이 턴 종료를 계속 차단합니다. 정당한 정지는 셋뿐(`[DONE]` / 사용자 확인 필수 예외 / 중단 지시). `.gitignore` 에 등록돼 있어 커밋되진 않습니다.

4. **`new-plugin.sh` 수정 시 사용자 입력을 heredoc 에 되돌리지 말 것** — CRITICAL #1. 모든 값은 Python argv + `json.dumps`. 되돌리면 2026-05-14 회귀가 그대로 재현됩니다.

5. **`bash -n` 은 CRLF 문제를 못 잡습니다** — 스크립트 검증은 LF 원본뿐 아니라 CRLF 사본으로도 (`sed 's/$/\r/'`). 배포되는 `.sh` 3개 중 `validate-plugins.sh` 만 깨졌던 전례가 있어 "훅은 되는데" 로 넘어가기 쉽습니다.

6. **Python 출력에 한글·기호를 쓸 때 cp949 크래시 주의** — 한국어 Windows 콘솔에서 `UnicodeEncodeError` 로 죽고, `set -e` 와 겹치면 성공한 작업이 실패로 보고됩니다. `sys.stdout.reconfigure(encoding="utf-8", errors="replace")`.

## 🧭 재개 지점

- 브랜치: `main` · 작업 트리: 이 핸드오프 커밋 전까지 `CLAUDE.md`·`AGENTS.md` 2개 미커밋(하네스 진입점 보완), 그 외 clean
- 시작 파일: 이 파일 → `PROGRESS.md` (`## 활성 컨텍스트` 우선)
- 실행·검증:
  ```bash
  bash scripts/validate-plugins.sh                                                   # 버전 동기·JSON·좀비
  bash claude-md-harness/skills/claude-md-harness/scripts/harness-lint.sh CLAUDE.md  # 토큰 예산
  bash claude-md-harness/skills/claude-md-harness/scripts/harness-lint.sh AGENTS.md
  for f in $(git ls-files '*.sh'); do bash -n "$f"; done
  ```
- 환경 전제: **Python 3 필수** (`new-plugin.sh` · `validate-plugins.sh`). PyYAML 은 스캐폴딩 검증에만(선택). 빌드·테스트 프레임워크 없음 — 위 셸 스크립트가 검증의 전부
- push 계정: `gh` 활성 계정이 `Mombin` 이면 **403**(push 권한 없음). 전역 전환 없이:
  ```bash
  GH_TOKEN="$(gh auth token --user team-pneumora --hostname github.com)" git push origin main
  ```
- 자율 루프: 이 레포는 ceo-dev-loop 를 사용하지 않음 (센티널 없음)

## 🔗 관련 기록

- 세션 로그: `PROGRESS.md` — 2026-07-25 항목. 이 레포는 `docs/sessions/` 대신 루트 `PROGRESS.md` 관례를 씁니다 (handoff 기존 관례 존중 규칙)
- 회귀: `docs/REGRESSIONS.md` — 총 9건 (이번 세션 6건). `docs/regressions/` 를 따로 만들지 않는 것도 같은 규칙
- 결정: 별도 ADR 없음. 버전별 설계 근거는 각 플러그인 README 의 Changelog
- 규칙·구조: `CLAUDE.md` (Claude) / `AGENTS.md` (Codex) — CRITICAL 6개 동일
