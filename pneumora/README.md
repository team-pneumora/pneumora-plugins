# pneumora

> 의도적 기억과 회귀 방지를 위한 Claude Code / Codex 워크플로우 도구 모음

`claude-md-management` (공식)가 CLAUDE.md 품질 관리에 집중한다면,
`pneumora`는 **"매번 까먹는 것"과 "또 터지는 회귀"**를 시스템적으로 잡는 데 집중합니다.

## 설치

### Claude Code

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install pneumora@pneumora-plugins
```

### Codex

이 플러그인은 `.codex-plugin/plugin.json`과 `skills/pneumora/SKILL.md`를 포함합니다. Codex에서 이 저장소를 플러그인 marketplace로 불러오거나, 스킬만 직접 쓰려면 `skills/pneumora/`를 `$CODEX_HOME/skills/`로 복사하세요.

## 제공 기능

### Slash Commands

| 명령어 | 역할 |
|--------|------|
| `/pneumora:critical` | 현재 프로젝트 CLAUDE.md의 `## ⚠️ CRITICAL`과 `## 📋 Regression Log`를 꺼내 각인 |
| `/pneumora:log-regression <증상>` | 한 번 겪은 회귀를 현재 프로젝트의 Regression Log에 기록 |
| `/pneumora:check-deploy` | push 전 배포 관련 CRITICAL 정보 확인 + 미커밋 변경/로컬 테스트 체크리스트 |

### Agents

| 에이전트 | 역할 |
|---------|------|
| `codebase-explorer` | 파일 탐색·사용처 추적·피처 맵핑 전담. Read/Glob/Grep만 사용하여 메인 세션 컨텍스트 오염 방지 |

Codex에서는 slash command를 직접 등록하지 않고 같은 요청을 스킬 트리거로 처리합니다. `CLAUDE.md`뿐 아니라 Codex 프로젝트의 `AGENTS.md`도 CRITICAL/Regression Log 대상으로 취급합니다.

## 철학

1. **정보는 프로젝트 CLAUDE.md에.** 글로벌 매트릭스는 유지 부담이 크고, 프로젝트 이동 시 끊어진다.
2. **회귀는 누적된다.** 한 번 당한 것은 섹션에 남겨 다시 안 당한다.
3. **배포 사고는 체크리스트로 막는다.** Claude가 매번 기억하기를 기대하지 않는다.
4. **탐색은 서브에이전트에게.** 메인 세션은 판단·결정에 집중.

## 공식 플러그인과의 관계

`pneumora`는 공식 `claude-md-management`와 **함께 쓰도록 설계**되었습니다:

- **공식**: CLAUDE.md 품질 audit, 세션 학습 자동 캡처 (`/revise-claude-md`)
- **pneumora**: 의도적 기억 (CRITICAL), 회귀 이력, 배포 가드, 탐색 격리

역할이 겹치지 않습니다.

## 라이선스

MIT
