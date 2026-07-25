# handoff

작업 종료 한마디로 **다음 작업자(사람·AI)가 즉시 이어받을 수 있는 상태**를 자동 생성합니다. 매번 손으로 지시하던 종료 루틴 — 기록·회귀 점검·harness 정리·인수인계 문서 — 을 하나의 트리거로 묶습니다.

## 설치

### Claude Code

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install handoff@pneumora-plugins
```

### Codex

이 플러그인은 `.codex-plugin/plugin.json`과 `skills/handoff/SKILL.md`를 포함합니다. Codex에서 이 저장소를 플러그인 marketplace로 불러오거나, 스킬만 직접 쓰려면 `skills/handoff/`를 `$CODEX_HOME/skills/`로 복사하세요.

## 사용법

작업을 끝낼 때 이렇게 한마디만 하면 됩니다:

> "작업 종료", "마무리하자", "핸드오프", "인수인계해줘", "/handoff"

그러면 한 번의 입력으로 다음을 **끝까지 자동 진행**합니다(단계마다 묻지 않음):

0. **자율 루프 정지** — `docs/.ceo-loop-active` 가 있으면 센티널 삭제 + 재개 지점 확보 (ceo-dev-loop 병용 시)
1. **상태 수집** — `git status`/`log`/`diff`, 브랜치·미커밋 상태, 미완료 표식 스캔
2. **회귀 가드** — 미추적 좀비 파일 검사, 이번 작업 회귀를 `docs/regressions/`에 기록
3. **harness 점검·보완** — CLAUDE.md/AGENTS.md 토큰 예산·계층 동기·Directory Map 점검 후 보완
4. **체계적 기록** — `docs/sessions/`에 세션 로그, 필요 시 `docs/decisions/`에 ADR
5. **HANDOFF 문서** — `docs/handoff/HANDOFF.md` 진입점 생성/갱신 (다음 작업자는 이 파일만 읽으면 됨)

> 기존에 `docs/DECISIONS.md`·`docs/STATUS.md`·루트 `PROGRESS.md` 같은 관례가 있으면 **거기에 맞춰 기록**합니다 — 경쟁하는 두 번째 저장소를 만들지 않습니다.

### 산출물 구조

```
docs/
├─ handoff/HANDOFF.md            진입점 — 항상 최신 1개
├─ sessions/YYYY-MM-DD-<slug>.md  세션별 작업 로그 (누적)
├─ decisions/ADR-NNN-<slug>.md    결정 기록 (있을 때만)
└─ regressions/YYYY-MM-DD-<slug>.md  회귀 이력 (발생 시만)
```

기존 프로젝트가 다른 관례(루트 `PROGRESS.md` 등)를 쓰면 그 자리에 맞춰 기록합니다.

## 함께 쓰면 좋은 플러그인

- [`pneumora`](../pneumora) — 회귀 가드(`check-deploy`)·회귀 로그(`log-regression`)를 2단계에서 활용
- [`claude-md-harness`](../claude-md-harness) — harness-lint 를 3단계에서 활용
- [`ceo-dev-loop`](../ceo-dev-loop) — 작업 *진행* 루프. handoff 는 그 *종료·인계* 를 담당

## 라이선스

MIT
