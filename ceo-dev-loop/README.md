# ceo-dev-loop

Claude Code 안에서 돌아가는 **CEO-Dev 2-에이전트 자동화 루프** 플러그인.

메인 세션이 Dev 역할로 코드를 작성하고, 체크포인트마다 CEO 서브에이전트(Opus, Read-only)가 검토·결정·승인합니다. 목표 달성까지 자동 반복되며, Max 구독 안에서 동작해 추가 API 비용이 없습니다.

## 설치

```
/plugin marketplace add team-pneumora/pneumora-plugins
/plugin install ceo-dev-loop@pneumora-plugins
```

## 사용법

```bash
cd my-project
claude

# 초기화
/ceo-dev-loop:init "React Todo 앱 with TypeScript"
# → CLAUDE.md, docs/GOAL.md, docs/STATUS.md, docs/DECISIONS.md 자동 생성

# docs/GOAL.md 의 "필수 요구사항" 구체적으로 작성 후

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
- **서브에이전트**: `@ceo` (Opus, Read/Grep/Glob 전용)

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
