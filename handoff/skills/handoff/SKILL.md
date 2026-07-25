---
name: handoff
description: 작업 종료 시 다음 작업자(사람·AI)가 즉시 이어받을 수 있도록 핸드오프를 자동 생성하는 스킬. 한 번의 트리거로 상태 수집 → 회귀 가드 → CLAUDE.md/AGENTS.md harness 점검·보완 → docs/ 체계적 기록(sessions·decisions·regressions) → docs/handoff/HANDOFF.md 진입점 생성까지 자동 진행한다. "작업 종료", "작업 끝내자", "마무리하자", "마무리해줘", "핸드오프", "인수인계", "다음 작업자", "넘겨줘", "정리하고 끝내자", "세션 종료", "/handoff", "work handoff", "session closeout", "hand off", "wrap up" 등의 요청 시 반드시 이 스킬을 사용한다. 세션을 닫거나 작업을 다른 사람/에이전트에게 넘기는 맥락이면 무조건 트리거.
---

# handoff

> 작업 종료 한마디 → 다음 작업자가 즉시 착수 가능한 상태를 자동 생성한다.

## 핵심 원칙

- **간단한 입력 한 번 → 0~6단계 끝까지 자동 진행.** 단계마다 사용자에게 묻지 않는다. 모호하면 합리적 기본값으로 진행하고, 마지막 보고에서 내린 가정을 밝힌다.
- **다음 작업자는 `docs/handoff/HANDOFF.md` 한 파일만 읽으면 이어받을 수 있어야 한다.** 이게 단일 진입점이다.
- **회귀를 남기지 않는다.** 미추적 좀비 파일·깨진 빌드·되돌린 변경을 그대로 두고 핸드오프하지 않는다.
- **harness를 다음 세션이 읽기 좋게 보완한다.** 점검만 하지 말고 고친다.
- **기존 프로젝트 관례를 존중한다.** 이미 PROGRESS.md·CHANGELOG·ADR 폴더 등이 있으면 새 구조를 강요하지 말고 그 자리에 기록한다.

## docs 구조 (관심사별 분리)

```
docs/
├─ handoff/HANDOFF.md            진입점 — 항상 최신 1개만, 덮어쓴다
├─ sessions/YYYY-MM-DD-<slug>.md  세션별 작업 로그 — 누적 보존
├─ decisions/ADR-NNN-<slug>.md    결정 기록(ADR) — 결정이 있을 때만
└─ regressions/YYYY-MM-DD-<slug>.md  회귀 이력 — 발생했을 때만
```

폴더가 없으면 만든다. 프로젝트가 다른 위치를 쓰면(예: 루트 PROGRESS.md) 거기에 맞춘다.

**이미 있는 기록 체계를 존중한다 — 경쟁하는 두 번째 저장소를 만들지 않는다:**

| 이미 있으면 | 새로 만들지 말고 |
|---|---|
| `docs/DECISIONS.md` (ceo-dev-loop) | `## 이력` 에 추가. `docs/decisions/` 을 따로 만들지 않는다 |
| `docs/STATUS.md` (ceo-dev-loop) | 세션 로그 요약을 여기 반영하고, `docs/sessions/` 는 상세 기록용으로만 |
| 루트 `PROGRESS.md` | 세션 로그를 여기에 append |
| `CHANGELOG.md` · `docs/adr/` 등 기존 관례 | 그 자리에 맞춰 기록 |

`docs/handoff/HANDOFF.md` 진입점만은 항상 만든다 — 어떤 관례를 쓰든 "여기부터 읽으세요" 파일 하나는 필요하다.

## 실행 절차

### 0. 자율 루프 정지 (해당 시 — 가장 먼저)

`docs/.ceo-loop-active` 가 있으면 **ceo-dev-loop 자율 루프가 돌고 있는 중**이다. 이 상태로는 Stop hook 이 턴 종료를 차단해 핸드오프를 끝낼 수 없다.

1. 사용자의 종료 요청은 루프 규약상 **"③ 사용자가 중단을 지시함"** 에 해당한다 → **센티널을 삭제한다.**
2. 삭제 전에 `docs/GOAL.md` 의 진척(N/M)과 `docs/STATUS.md` 의 `## 다음 작업` 을 읽어둔다 — HANDOFF.md 재개 지점에 그대로 넣는다.
3. HANDOFF.md 에 재개 방법을 명시한다: `/ceo-dev-loop:start` (센티널 재생성 + 루프 재개).

GOAL 이 미완인 상태로 끝내는 것이면 HANDOFF.md ⚠️ 에 "루프 중단 — GOAL N/M 미완" 을 적는다.

### 1. 상태 수집
- `git status`, `git log --oneline -10`, `git diff --stat`(+ staged 포함)으로 이번 작업 범위를 파악한다.
- **현재 브랜치**와 **미커밋/스테이징 상태**를 기록한다 — 다음 작업자가 제일 먼저 부딪히는 지점이다.
- 미완료 표식(TODO/FIXME, 실패 테스트, 빌드·타입 에러)을 스캔한다.
- "무엇을 끝냈고 / 무엇이 열려 있는지"를 분리해 정리한다.

### 2. 회귀 가드
- `git status --porcelain -uall`로 미추적 배포 필수 파일(plugin.json·SKILL.md·설정·매니페스트 등)을 확인한다 — 있으면 핸드오프 전에 해결하거나 HANDOFF.md ⚠️에 명시한다.
- 이번 작업 중 회귀(되돌린 변경, 재발한 버그, 깨졌다 고친 것)가 있었으면 `docs/regressions/YYYY-MM-DD-<slug>.md`에 **[증상 / 영향 / 재발 방지]** 로 기록한다.
- `pneumora` 플러그인이 설치돼 있으면 `/pneumora:check-deploy`·`/pneumora:log-regression`을 활용한다.

### 3. harness 점검·보완
- 프로젝트 CLAUDE.md / AGENTS.md가 다음 세션이 읽기 좋은 상태인지 점검한다:
  - 루트가 토큰 예산 내인지, 계층 간 중복(DRY 위반)이 없는지, **Directory Map이 실제 디렉토리 구조와 동기**인지.
  - 이번 작업으로 새 디렉토리·규칙·CRITICAL이 생겼으면 알맞은 계층(Root/Module/Leaf)에 반영한다.
- `claude-md-harness` 플러그인이 설치돼 있으면 harness-lint / "harness 점검"을 활용한다.
- **발견한 문제는 보고만 하지 말고 보완한다.**

### 4. 체계적 기록
- `docs/sessions/YYYY-MM-DD-<slug>.md`에 이번 세션 로그를 쓴다:
  목표 / 한 일 / 변경 파일 / 검증 결과 / 내린 결정 / 다음 단계 / 열린 이슈.
- 아키텍처·기술 선택 등 **되돌리기 어려운 결정**이 있었으면 `docs/decisions/ADR-NNN-<slug>.md`로 분리한다(맥락 / 결정 / 대안 / 근거).

### 5. HANDOFF 문서 생성
`docs/handoff/HANDOFF.md`를 아래 템플릿으로 **항상 최신 상태로 덮어쓴다**:

```markdown
# HANDOFF — <프로젝트>
> 최종 갱신: <YYYY-MM-DD> · 다음 작업자는 이 파일부터 읽으세요.

## 🎯 현재 목표
<지금 향하는 목표 1~2줄>

## ✅ 방금 끝낸 작업
- <핵심 변경>  (커밋 <hash>)

## 🔜 다음 단계 (바로 착수)
1. <가장 먼저 할 일 — 파일·함수까지 구체적으로>

## ⚠️ 회귀 주의 / 함정
- <밟으면 안 되는 지뢰, 미해결 위험>

## 🧭 재개 지점
- 브랜치: `<branch>` · 작업 트리: <clean | 미커밋 N개 (파일 나열)>
- 시작 파일: <path>
- 실행·검증: `<command>`
- 환경 전제: <의존성 설치 여부, 필요한 env/시크릿, 기동해야 할 서비스 — 없으면 "특별히 없음">
- 자율 루프: <해당 시 — `/ceo-dev-loop:start` 로 재개, GOAL N/M>

## 🔗 관련 기록
- 세션 로그: docs/sessions/<file>
- 결정: docs/decisions/<file>
- 회귀: docs/regressions/<file>
```

### 6. 마무리 보고
- 생성·갱신한 파일 목록과 **"다음 작업자의 첫 액션"** 을 한눈에 요약한다.
- 커밋이 필요하면 제안한다. 사용자가 커밋·push를 미리 위임했으면 진행하고, 아니면 자동 커밋하지 않는다.

## 주의사항

- **단계마다 멈추지 않는다.** 트리거 한 번으로 0→6을 끝까지 진행한다.
- **`docs/.ceo-loop-active` 를 남긴 채 끝내지 않는다.** 센티널이 남아 있으면 Stop hook 이 다음 턴 종료까지 계속 차단한다 (0단계 참조).
- **HANDOFF.md는 최신 1개만 유지**한다(덮어쓰기). 과거 이력은 `docs/sessions/`에 누적된다.
- **회귀·깨진 빌드 상태로 핸드오프하지 않는다.** 발견하면 먼저 알리고 HANDOFF.md ⚠️에 명시한다.
- 비밀키·토큰·자격증명을 docs에 기록하지 않는다.
