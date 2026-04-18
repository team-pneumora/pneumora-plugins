# ceo-dev-loop

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

# 초기화 (greenfield — 빈 프로젝트)
/ceo-dev-loop:init "React Todo 앱 with TypeScript"

# 초기화 (brownfield — 기존 프로젝트)
# 자동으로 프로젝트 구조·README·의존성을 스캔해 GOAL.md 의 "현재 프로젝트 맥락" 을 채움
/ceo-dev-loop:init "로그인 플로우에 2FA 추가"

# docs/GOAL.md 의 "필수 요구사항" 확인/보강 후

/ceo-dev-loop:start    # 자동 루프 시작
/ceo-dev-loop:status   # 진행 상태 확인
```

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
