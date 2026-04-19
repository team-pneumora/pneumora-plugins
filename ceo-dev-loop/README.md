# ceo-dev-loop

> **v0.4.0** — init 단계 GOAL 분해를 CEO 에게 위임 + 사용자 승인 0회 + 진행 문서 자동 흡수

Claude Code 안에서 돌아가는 **CEO-Dev 2-에이전트 자동화 루프** 플러그인.

메인 세션이 Dev 역할로 코드를 작성하고, 체크포인트마다 CEO 서브에이전트(Sonnet, Read-only)가 검토·결정·승인합니다. 목표 달성까지 자동 반복되며, Max 구독 안에서 동작해 추가 API 비용이 없습니다.

기본 조합은 **Dev = Opus (메인 세션) / CEO = Sonnet (서브)** — Dev가 깊은 코딩을 맡고 CEO 는 빠르고 가볍게 방향성만 잡는 역할. (메인 세션 모델은 `claude` 실행 시점이나 `/model` 로 선택)

## 설치

```
/plugin marketplace add team-pneumora/pneumora-plugins
/plugin install ceo-dev-loop@pneumora-plugins
```

## 사용법

```bash
cd my-project
claude

# 초기화 — 단계 자동 감지 (Greenfield / Brownfield 무문서 / Brownfield 부분문서 / Brownfield 완전문서)
# CEO 가 GOAL 분해까지 자동, 끝나면 즉시 자율 루프 시작 (사용자 승인 0회)
/ceo-dev-loop:init "React Todo 앱 with TypeScript"
/ceo-dev-loop:init "로그인 플로우에 2FA 추가"
/ceo-dev-loop:init "ADR 0006 의 Phase 1.4 부터 이어서"   # 진행 문서가 있으면 자동 흡수

# 진행 상태만 보고 싶을 때
/ceo-dev-loop:status

# 자율 루프가 멈췄을 때 다시 시작
/ceo-dev-loop:start
```

> v0.4.0 부터 init 1회로 GOAL 분해 + 자율 루프 시작까지 한 번에 끝납니다. 사용자 입력은 두 가지 안전장치 외에는 받지 않습니다 — ① 기존 `docs/GOAL.md` 덮어쓰기 ② CEO 가 정보 부족을 명시 신고할 때.

## 동작 흐름

```
Dev(메인) → 코드 작성 → STATUS.md 갱신 → @ceo 호출
                                              ↓
                                    CEO 검토 → 결정/지시
                                              ↓
[DONE]이면 종료  ←─────────  Dev가 받아서 다음 작업 진행
```

## 파일 기반 핸드오프

| 파일 | 역할 | 갱신 주체 |
|---|---|---|
| `docs/GOAL.md` | 고정 목표 | 사용자 |
| `docs/STATUS.md` | 현재 진행 상태 | Dev (매 턴) |
| `docs/DECISIONS.md` | 결정 로그 | CEO (결정 시) |

## 제공 요소

- **명령어**: `/ceo-dev-loop:init`, `/ceo-dev-loop:start`, `/ceo-dev-loop:status`
- **서브에이전트**: `@ceo` (Sonnet, Read/Grep/Glob 전용)

## 비용 주의

Claude Max 구독 안에서 처리됩니다.

```bash
# API 키가 환경변수에 있으면 API로 과금됨
unset ANTHROPIC_API_KEY

# 인증 방식 확인
claude
> /status
```

## 커스터마이징

- CEO 판단 기준: `agents/ceo.md`
- Dev 행동 규칙: `init` 이 생성한 `CLAUDE.md`
- 호출 타이밍: `CLAUDE.md` 의 "@ceo 호출이 반드시 필요한 시점" 섹션

### CEO 모델 변경

현재 CEO 모델은 `agents/ceo.md` frontmatter (`model: sonnet`) 에 고정되어 있습니다. 다른 모델로 바꾸고 싶으면:

- **프로젝트 단위 오버라이드 (권장)**: 프로젝트 루트에 `.claude/agents/ceo.md` 를 만들고 원하는 `model:` 값(`opus`, `sonnet`, `haiku`) 으로 작성. 플러그인 agent 보다 우선 적용됨 — 플러그인 업데이트에 영향받지 않음
- **플러그인 직접 수정**: `agents/ceo.md` 편집 (단, 플러그인 업데이트 시 덮어쓰임)

대표 조합:
- `Dev=Opus / CEO=Sonnet` (기본) — 깊은 코딩 + 빠른 리뷰, Opus 쿼터 절약
- `Dev=Sonnet / CEO=Opus` — 빠른 코딩 + 신중한 리뷰
- `Dev=Opus / CEO=Haiku` — 최대 속도·최저 비용, 판단 품질은 낮아짐

## 컨텍스트 관리 (v0.3.0)

자율 루프는 메인 Dev 세션 컨텍스트가 누적된다는 약점이 있습니다. 이를 다음 4단계로 방어합니다.

1. **CEO 가 매번 fresh 로 GOAL/STATUS/DECISIONS 재독** — 서브에이전트라 매 호출 fresh, 목표 drift 차단
2. **CEO 응답에 `[컨텍스트]` 신호** — milestone 완료 직후, 5턴 이상 누적, 안전 시점에 `[COMPACT]` (필요 시 `[CLEAR]`)
3. **STATUS.md `## 활성 컨텍스트` 섹션** — 컴팩트/클리어 후 재시작이 가능한 수준의 메모. 현재 만지는 파일·미해결 결정·다음 첫 단계
4. **턴 카운터** — `STATUS.md` 에 `마지막 컴팩트 이후 N 턴` 누적, `/ceo-dev-loop:status` 가 5 이상이면 경고 표시

리프레시 절차 (CLAUDE.md 에 자동 주입):
1. STATUS.md `활성 컨텍스트` 보강 → 2. DECISIONS.md 누적 → 3. (선택) `docs/checkpoints/NN-{slug}.md` 스냅샷 → 4. `/compact` 또는 `/clear` → 5. 재진입 후 GOAL → STATUS → DECISIONS 다시 읽고 카운터 리셋

## 목표 고수 (v0.3.0)

CEO 응답 형식이 강화되었습니다:
- 첫 줄에 `[목표 진척] N/M` 강제 — drift 방지
- DONE 판정은 GOAL.md `## 완료 기준 (DoD)` 항목을 **하나씩 인용해 체크**한 뒤에만
- 같은 작업 2회 연속 실패 시 접근 변경 또는 사용자 확인 강제
- 같은 방향 3턴 이상 진척 없으면 CEO 자가 점검 ("내가 목표를 잘못 이해했나?")
- Dev 지시는 항상 파일/함수 단위 + 검증 명령 동봉

## Changelog

### v0.4.0 (init 자율화)
init 단계가 약했음. 사용자가 목표 한 줄을 던져도 GOAL.md 의 "필수 요구사항" 은 빈 채로 만들어지고 `/start` 까지 가서야 CEO 가 등장. 그 사이 사용자 승인이 4~5회 필요했음. v0.4.0 은 init 자체에서 CEO 에게 GOAL 분해를 위임하고 끝나면 자율 루프로 자동 진입.

- **프로젝트 성숙도 4단계 자동 분류**: A(Greenfield) / B(Brownfield 무문서) / C(Brownfield 부분문서) / D(Brownfield 완전문서). 코드 존재 + 진행 문서 존재 두 축
- **진행 문서 자동 흡수 (C/D)**: `docs/PROGRESS*.md`, `docs/ROADMAP*.md`, `docs/PHASE_*.md`, `docs/ADR*/**`, `docs/DECISIONS*/**`, `TASKS.md`, `BACKLOG.md`, `RFC*.md`, `TODO.md`, README 의 Roadmap/Status 섹션 — 자동 검색 + 100줄 제한 스캔으로 현재 phase·완료/미완·결정 이력 추출
- **GOAL 분해를 CEO 에게 위임**: Dev 가 컨텍스트 패키지 작성 → `@ceo init:` 호출 → CEO 가 [필수 요구사항] [DoD] [기존 진행 매핑] [정보 부족] [자율 권한 부여] 응답. Dev 는 그대로 GOAL.md 에 기록만
- **사용자 승인 0회 default**: D 단계 덮어쓰기 + CEO "정보 부족" 신고 — 이 두 가지만 묻고 그 외 자동. CEO 응답에 정보 부족이 없으면 init 끝까지 사용자 입력 0
- **init 끝나면 즉시 `/start` 자동 진입**: 별도 명령 호출 불필요. 사용자 명령은 init 한 번이면 끝
- **모든 v0.3.x 안전장치 유지**: `[DONE]` 5-gate, 자율 루프 권한, Dev 1차 필터, `[COMPACT]/[CLEAR]` 리프레시, 2회 실패 에스컬레이션, 파괴적 작업 보호 — 그대로

### v0.3.3 (과적합 정리)
v0.3.0 ~ 0.3.2 까지 phase 기반 프로젝트의 회귀를 잡으면서 단순 목표 프로젝트(예: React Todo 앱)에 불필요한 무게가 붙은 부분만 다듬음. 안전장치는 그대로 유지.

- **`[GOAL 완전성]` 라인 조건부**: 최종 목표에 phase/milestone/단계/N.M/ADR 키워드가 있을 때만 출력. 단순 목표 프로젝트에서는 라인 자체 생략. `[DONE]` 게이트의 완전성 항목은 키워드 없으면 자동 통과
- **GOAL.md 템플릿 default 뒤집기**: 단순 리스트가 default, phase 헤더는 옵션 안내. greenfield 단순 목표인데 Phase 1/2 헤더가 default 로 보여 "phase 가 필수인가?" 오해를 유발하던 문제 해소

### v0.3.2 (회귀 수정 2차)
v0.3.1 적용 후에도 같은 증상 재발 — 원인은 "GOAL.md 가 phase 1.N 까지만 체크박스로 적혀 있으면 CEO 가 N/M=100% 로 보고 정당하게 `[DONE]` 을 줌" 이라는 구조적 결함. 금지 문구만으로는 막을 수 없어 CEO 가 GOAL.md 자체의 완전성을 먼저 의심하도록 변경.

- **CEO `[GOAL 완전성]` 라인 도입**: 매 응답 첫 줄에 `[GOAL 완전성] phase 1~K 정의됨, 현재 X — 완전 | 불완전(사유)` 을 강제 출력
- **CEO GOAL.md 완전성 체크리스트**: 최종 목표에 phase/단계/ADR 참조 감지 → phase 개수 K 추정 → 체크박스가 전체를 커버하는지 검증
- **CEO `[DONE]` 게이트 5개로 확장**: 완전성 + 체크박스 + DoD + 진척 N/N + 최종 목표 문장 인용 논증
- **CEO GOAL.md 불완전 시 자동 대응**: 사용자에게 묻지 않고 Dev 에게 GOAL.md 보강을 먼저 지시
- **Dev 1차 필터 (안전벨트)**: CEO 가 `[DONE]` 을 줘도 Dev 가 GOAL.md 재검토 → phase 누락 의심되면 `@ceo` 재호출. CEO 오발을 한 번 더 차단

### v0.3.1 (회귀 수정)
phase/milestone 경계에서 자율 루프가 끊어지는 문제 두 번 재발 → 근본 수정.

- **CEO `[DONE]` 오발 방지**: milestone/phase 완료는 절대 `[DONE]` 이 아니다. GOAL.md `## 필수 요구사항` 모든 체크박스 + `## 완료 기준 (DoD)` 모든 항목 + `[목표 진척] N/N` 3개 모두 충족 시에만
- **CEO 자율 루프 권한 유지**: 사용자에게 phase 단위 재승인 묻기 금지. 다음 phase 의 첫 작업을 직접 지시
- **GOAL.md 템플릿 보강**: phase 별 요구사항을 빠짐없이 미리 작성하라는 강조 안내 (greenfield/brownfield 양쪽)
- **CLAUDE.md 루프 규칙 보강**: Dev 도 phase 경계에서 사용자 입력 대기 모드 진입 금지. CEO 가 모호하게 끝내면 즉시 `@ceo` 재호출

### v0.3.0
- `[COMPACT]/[CLEAR]` 컨텍스트 신호 + 리프레시 절차
- STATUS.md 에 `활성 컨텍스트` / 턴 카운터 추가
- CEO 응답에 `[목표 진척] N/M` 강제, DoD 인용 체크 의무화
- Dev orchestration 구체화 (파일/함수 단위, 검증 명령, 작업 단위 크기 제어, 2회 실패 처리)
- CEO 자가 점검 규칙 추가
- `/ceo-dev-loop:status` 가 활성 컨텍스트와 턴 카운터 노출

### v0.2.0
- brownfield 자동 감지 + 프로젝트 스캔 (스택/모듈/빌드 명령)
- GOAL.md `현재 프로젝트 맥락` 섹션 자동 채움

### v0.1.0
- 초기 릴리즈: CEO/Dev 2-에이전트 루프, init/start/status 명령
