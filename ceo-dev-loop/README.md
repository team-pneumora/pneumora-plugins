# ceo-dev-loop

> **v0.8.0** — 검증 신뢰성: CEO 독립 검증(완료 경계에서 검증 명령 직접 재실행), Stop hook 안전밸브 2중화(연속 무진척 + 누적 절대 상한), 센티널 경로 fail-open 수정, `effort: high`
> **v0.7.0** — 자율성 강화: Stop hook 루프 강제(어휘 차단 → 하네스 강제), 가정 프로토콜(질문 → 기록된 가정), 정책 fast-path(선례 재사용), 권한 사전 위임, 작업 패키지, 증거 기반 체크박스

Claude Code와 Codex에서 돌아가는 **CEO-Dev 자동화 루프** 플러그인.

메인 세션이 Dev 역할로 코드를 작성하고, 체크포인트마다 CEO 서브에이전트(Sonnet, 읽기 + 검증 실행 전용)가 검토·결정·승인합니다. 목표 달성까지 자동 반복되며, Max 구독 안에서 동작해 추가 API 비용이 없습니다.

기본 조합은 **Dev = Opus (메인 세션) / CEO = Sonnet (서브)** — Dev가 깊은 코딩을 맡고 CEO 는 빠르고 가볍게 방향성만 잡는 역할. (메인 세션 모델은 `claude` 실행 시점이나 `/model` 로 선택)

## 설치

### Claude Code

```
/plugin marketplace add team-pneumora/pneumora-plugins
/plugin install ceo-dev-loop@pneumora-plugins
```

### Codex

이 플러그인은 `.codex-plugin/plugin.json`과 `skills/ceo-dev-loop/SKILL.md`를 포함합니다. Codex에서 이 저장소를 플러그인 marketplace로 불러오거나, 스킬만 직접 쓰려면 `skills/ceo-dev-loop/`를 `$CODEX_HOME/skills/`로 복사하세요.

## 사용법

Claude Code:

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

Codex:

```text
Use $ceo-dev-loop to initialize this project loop: React Todo 앱 with TypeScript
Use $ceo-dev-loop to continue the current loop.
Use $ceo-dev-loop to show the current loop status.
```

> v0.4.0 부터 init 1회로 GOAL 분해 + 자율 루프 시작까지 한 번에 끝납니다. 사용자 입력은 두 가지 안전장치 외에는 받지 않습니다 — ① 기존 `docs/GOAL.md` 덮어쓰기 ② CEO 가 정보 부족을 명시 신고할 때. (v0.5.0 부터 `[DONE]` 직전 5-시나리오 검증을 Dev 가 자동 실행 — 사용자 추가 입력 없음)

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

> v0.6.0: GOAL.md 는 다시 거의 고정 — CEO 가 GOAL.md 를 건드리는 건 완료 게이트에서 "완료를 막는 in-scope 누락" 을 발견했을 때뿐. 평상시 인접 작업은 DECISIONS.md 로 흐른다.

## 제공 요소

- **명령어**: `/ceo-dev-loop:init`, `/ceo-dev-loop:start`, `/ceo-dev-loop:status`
- **서브에이전트**: `@ceo` (Sonnet, `effort: high`, Read/Grep/Glob + 검증 전용 Bash)
- **Stop hook** (v0.8.0, Claude Code 전용): `hooks/loop-gate.sh` — `docs/.ceo-loop-active` 센티널 존재 중 턴 종료를 하네스 레벨에서 차단해 자율 루프를 강제. 안전밸브 2중 — 연속 무진척 200회(`CEO_LOOP_MAX_CONTINUES`, STATUS.md 갱신 시 리셋) 또는 누적 차단 1000회(`CEO_LOOP_MAX_TOTAL`, 리셋 없음)
- **Codex 스킬**: `$ceo-dev-loop` (`docs/GOAL.md`, `docs/STATUS.md`, `docs/DECISIONS.md` 기반 — 센티널/hook 미사용, 프롬프트 규칙으로 대체)

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

### CEO 모델 / effort 변경

`agents/ceo.md` frontmatter 에 `model: sonnet` + `effort: high` 로 지정돼 있습니다.

**`sonnet` 은 별칭이라 provider 의 최신 Sonnet 을 자동 추종합니다** — Anthropic API 기준 현재 Sonnet 5. 버전을 고정하려면 별칭 대신 full ID(`claude-sonnet-5`)를 쓰세요.

| Provider | `sonnet` | `opus` |
|---|---|---|
| Anthropic API (Max 구독) | Sonnet 5 | Opus 5 |
| Claude Platform on AWS | Sonnet 4.6 | Opus 5 |
| Bedrock / Google Cloud | Sonnet 4.5 | Opus 5 |

바꾸는 방법:

- **프로젝트 단위 오버라이드 (권장)**: 프로젝트 루트에 `.claude/agents/ceo.md` 를 만들고 원하는 `model:` (`opus`, `sonnet`, `haiku`, `fable`, `best`, 또는 full ID) 로 작성. 플러그인 agent 보다 우선 적용됨 — 플러그인 업데이트에 영향받지 않음
- **플러그인 직접 수정**: `agents/ceo.md` 편집 (단, 플러그인 업데이트 시 덮어쓰임)

대표 조합:
- `Dev=Opus / CEO=Sonnet` (기본) — 깊은 코딩 + 빠른 리뷰, Opus 쿼터 절약
- `Dev=Sonnet / CEO=Opus` — 빠른 코딩 + 신중한 리뷰
- `Dev=Opus / CEO=Haiku` — 최대 속도·최저 비용, 판단 품질은 낮아짐

> `effort: high` 는 CEO 판단 품질을 **세션 effort 와 분리**하기 위한 것입니다. 이게 없으면 Dev 세션을 속도 위해 낮은 effort 로 돌릴 때 CEO 의 8-gate 판정·drift 감사 품질이 같이 떨어집니다. 비용이 부담되면 `medium` 으로 낮추되 `low` 는 권장하지 않습니다.

## 컨텍스트 관리 (v0.6.0 — auto-compact 위임)

자율 루프는 메인 Dev 세션 컨텍스트가 누적된다는 약점이 있습니다. v0.5.0 까지는 CEO 가 5턴/milestone/빌드그린마다 `[COMPACT]` 신호를 쏘고 사용자가 `/compact` 를 입력하는 수동 절차로 방어했지만 — 신호가 거의 매 턴 발동해 과도하게 잦았습니다. v0.6.0 은 이를 폐지하고 단순화합니다.

1. **컨텍스트 한계 = 빌트인 auto-compact 에 위임** — Claude Code 가 컨텍스트가 차면 자동 요약 후 같은 세션에서 연속 진행. CEO 도 Dev 도 컴팩트/세션/재진입을 사용자에게 언급하지 않음. `[COMPACT]/[CLEAR]` 신호·턴 카운터·수동 `/compact` 절차 전부 제거.
2. **디스크 핸드오프 규율만 유지** — `STATUS.md ## 활성 컨텍스트` (현재 만지는 파일·미해결 결정·다음 첫 단계) 를 매 턴 갱신 + 결정은 `DECISIONS.md` 누적. auto-compact 요약이 무엇을 버리든 GOAL → STATUS → DECISIONS 3파일만 읽으면 재시작 가능.
3. **CEO 는 여전히 매 호출 fresh** — 서브에이전트라 매번 GOAL/STATUS/DECISIONS 재독, 목표 drift 차단은 그대로.

## 목표 고수 (v0.3.0)

CEO 응답 형식이 강화되었습니다:
- 첫 줄에 `[목표 진척] N/M` 강제 — drift 방지
- DONE 판정은 GOAL.md `## 완료 기준 (DoD)` 항목을 **하나씩 인용해 체크**한 뒤에만
- 같은 작업 2회 연속 실패 시 접근 변경 또는 사용자 확인 강제
- 같은 방향 3턴 이상 진척 없으면 CEO 자가 점검 ("내가 목표를 잘못 이해했나?")
- Dev 지시는 항상 파일/함수 단위 + 검증 명령 동봉

## 목표 고수 강화 (v0.5.0 → v0.6.0)

v0.3.x ~ v0.4.x 가 어휘 블랙리스트로 [DONE] 회귀를 막던 것과 달리, v0.5.0 은 구조 게이트를 추가했고, v0.6.0 은 그 게이트가 매 턴 발동하던 과부하를 완료 경계로 옮겼습니다:

- **`[GOAL drift]` 게이트 (v0.6.0 — 완료 경계 전용)** — STATUS/DECISIONS 의 완료 작업이 GOAL.md 체크박스에 매핑되는지 확인하는 full 감사를 **`[SPRINT COMPLETE]`/`[DONE 후보]` 발행 직전에만** 실행. 평상시 턴은 "이번 작업 GOAL 범위 안/밖" 한 줄 판정만 하고, 범위 밖 부수작업은 DECISIONS.md 에 기록(GOAL.md 안 건드림). GOAL.md 보강은 완료를 막는 in-scope 누락일 때만 → GOAL.md 가 다시 안정적 북극성으로 복귀.
- **`[SPRINT COMPLETE]` / `[DONE]` 분리** — phase 완료와 프로젝트 완료를 다른 신호로. SPRINT COMPLETE 는 루프 계속, DONE 만 종료.
- **`[DONE 후보]` 5-시나리오 검증** — 8-gate 통과 후 즉시 DONE 아님. 사용자가 산출물 받아 처음 시도할 5가지를 Dev 가 실제 실행 → 5/5 통과 시에만 진짜 DONE. GOAL.md drift 에 강한 외부 검증.

## 기존 프로젝트 업그레이드 (v0.7.0 → v0.8.0)

### 0. 먼저 플러그인 자체를 갱신 (이거 안 하면 아무것도 안 바뀜)

```
/plugin marketplace update pneumora-plugins
/reload-plugins
```

설치된 플러그인은 `~/.claude/plugins/cache/` 사본에서 로드됩니다. **서드파티 마켓플레이스는 auto-update 가 기본 꺼져 있어**, 레포에 새 버전을 올려도 위 두 명령 전에는 계속 옛 버전이 돕니다. `/plugin` → Marketplaces 탭에서 auto-update 를 켜두면 이후 세션부터 자동 갱신됩니다.

> 확인법: `ls ~/.claude/plugins/cache/pneumora-plugins/ceo-dev-loop/` 가 `0.8.0` 을 보여야 합니다.
> `0.7.0` 이면 Stop hook 도 옛 버전(단조 카운터 + 상대경로 fail-open)이 돌고 있는 것입니다.

갱신 후에는 `agents/ceo.md` · `hooks/loop-gate.sh` · `commands/*` 가 매 호출 fresh 로 읽히므로 추가 조치가 필요 없습니다. 프로젝트 산출물만 손보면 됩니다.

### 1. 프로젝트 산출물 (둘뿐)

1. **`docs/.ceo-loop-active` 가 프로젝트 루트에 있는지 확인** — 하위 디렉토리에 있으면 hook 이 못 찾습니다. `/ceo-dev-loop:start` 로 재생성하면 정리됩니다
2. **프로젝트 `CLAUDE.md`** 의 `Stop hook 강제` 항목에 한 줄 추가 (선택이지만 권장): "매 턴 `docs/STATUS.md` 갱신 — hook 이 진척 신호로 읽어 무진척 카운터를 리셋"

기존 센티널 파일(`0` 단일 값)은 그대로 읽히므로 삭제·변환 불필요합니다.

## 기존 프로젝트 업그레이드 (v0.6.0 → v0.7.0)

v0.6.0 으로 init 한 프로젝트는 가벼운 추가만 필요합니다 (`init` 재실행 금지 — CLAUDE.md 중복 append 됨):

1. **프로젝트 `CLAUDE.md`**: `## CEO-Dev 자동 루프 규칙` 섹션을 현재 `commands/init.md` 의 v0.7.0 블록으로 교체 — 추가되는 것: 정책 fast-path, 가정 프로토콜, 작업 패키지, 증거 1줄, 센티널 수명주기, 권한 위임 필터
2. **`docs/DECISIONS.md`**: 맨 위에 `## 정책 (재사용 결정)` / `## 가정 (사용자 미확인)` 섹션 추가, 기존 내용은 `## 이력` 아래로
3. **`docs/GOAL.md`**: `## 권한 (사전 위임)` 섹션 추가 (전부 "보류" 로 시작, 원하면 "위임" 으로 수정)
4. **`.gitignore`**: `docs/.ceo-loop-active` 추가
5. `/ceo-dev-loop:start` 로 재개 — start 가 센티널을 만들며 Stop hook 강제가 켜집니다

가장 빠른 방법 — 대상 프로젝트에서 한 줄 지시:

> **"ceo-dev-loop v0.7.0 으로 CLAUDE.md / docs/DECISIONS.md / docs/GOAL.md 를 동기화해줘 — 정책·가정 섹션, 권한 사전 위임 섹션, 센티널 규칙 추가. 기존 결정 이력은 ## 이력 아래로 보존."**

## 기존 프로젝트 업그레이드 (v0.5.x → v0.6.0)

플러그인을 업데이트해도 **이미 init 한 프로젝트의 산출물은 자동으로 안 바뀝니다.** 플러그인 파일(`agents/ceo.md`, `commands/*`)은 매 호출 fresh 로 읽혀 자동 갱신되지만, v0.5.x `init` 이 프로젝트에 찍어둔 `CLAUDE.md` · `docs/STATUS.md` 는 옛 규칙 그대로 남아 새 CEO(v0.6.0)와 엇박자가 납니다.

> ⚠️ `/ceo-dev-loop:init` **재실행 금지** — join 모드라도 CLAUDE.md 에 v0.6.0 섹션을 *append* 해서 v0.5.x 섹션과 중복됩니다. 아래 수술적 절차를 쓰세요.

### 1. 프로젝트 `CLAUDE.md` 동기화 (필수)
`## CEO-Dev 자동 루프 규칙 (ceo-dev-loop v0.5.x)` 섹션 전체를 현재 `commands/init.md` 가 생성하는 v0.6.0 블록으로 교체. 핵심:

- **통째로 삭제**: `### 컨텍스트 리프레시 절차`(COMPACT/CLEAR) · `### 컴팩트 보고 형식 — 최소화` · `### Dev 측 컨텍스트 한계 단계적 처리`(1/2/3차)
- **추가**: `### 컨텍스트 관리 (v0.6.0 — auto-compact 위임)` — STATUS `활성 컨텍스트` + DECISIONS 디스크 핸드오프 유지가 Dev 의 유일한 컨텍스트 책임
- **작업 흐름 step 5**: `[COMPACT]/[CLEAR]` 분기 → `[SPRINT COMPLETE]` / `[DONE 후보]` 분기
- **우회 어휘 safety-belt**: 재호출 메시지의 `[COMPACT]` 참조 제거 + "컴팩트/세션 언급"을 우회 어휘에 추가
- **CEO 신호별 Dev 행동**: `[GOAL drift] 매 응답` → 평상시 DECISIONS / 완료 게이트 GOAL.md 분리

### 2. `docs/STATUS.md` 정리 (필수 — 놓치기 쉬움)
- `## 턴 카운터` 섹션 **삭제** (v0.6.0 폐지 — auto-compact 시대엔 vestigial). 호출 형식의 "마지막 컴팩트 이후 N 턴" 줄, "@ceo 호출 시점" 의 "5턴 누적 시" 항목도 함께 제거
- `## 활성 컨텍스트` 의 "컴팩트 직후 재진입…" 줄 → "컨텍스트 요약(auto-compact) 후 우선 읽을 파일: GOAL.md → STATUS.md → DECISIONS.md"

### 3. `docs/GOAL.md` 점검 (선택)
v0.5.x 가 매 턴 흡수한 체크박스 중 "진짜 요구사항이 아닌 부수작업"이 섞였으면 DECISIONS.md 로 내림. 강제는 아님 — 다음 `[DONE 후보]` 게이트에서 CEO 가 어차피 drift 감사를 합니다.

### 4. 재개
`/ceo-dev-loop:start`. 이후부턴 compact 신호 없이, drift 는 완료 경계에서만 돕니다.

### 가장 빠른 방법
대상 프로젝트에서 Claude 에게 한 줄로 지시:

> **"ceo-dev-loop v0.6.0 으로 CLAUDE.md 와 docs/STATUS.md 를 동기화해줘 — 턴 카운터·COMPACT/CLEAR 절차 전부 제거, drift 는 완료 경계 전용으로. 유효한 부분(@ceo 호출 시점, [DONE] 1차 필터, SPRINT COMPLETE/DONE 후보, 예외 list)은 보존."**

→ 위 1~2 를 한 번에 처리합니다. (턴 카운터 제거를 명시해야 빠짐없이 정리됩니다.)

## Changelog

### v0.8.0 (검증 신뢰성 + 루프 강제 회귀 수정)
v0.7.0 감사에서 드러난 두 결함을 고침. 둘 다 "안전장치가 조용히 무력화되는" 유형이라 겉으로는 정상 동작처럼 보였음.

- **CEO 독립 검증 (`tools` 에 Bash 추가)**: v0.7.0 의 7-gate·5-시나리오·증거 기반 체크박스는 겹겹이 쌓였지만 **전부 같은 신뢰 가정(Dev 의 자기 보고) 위에 서 있었다.** CEO 는 `Read/Grep/Glob` 뿐이라 STATUS.md 에 적힌 "✅ 통과" 를 재현할 수단이 없었고, Dev 가 테스트를 돌리지 않고 통과라고 적으면 그대로 `[DONE]` 이 나갔다. v0.8.0 은 CEO 에게 **검증 전용 Bash** 를 주고 완료 경계(`[SPRINT COMPLETE]`/`[DONE 후보]`/`[DONE]`)에서 검증 명령을 직접 재실행해 Dev 보고와 대조한다. 불일치 시 종료성 신호 차단. 7-gate 는 8-gate 로 확장. 쓰기·커밋·배포는 여전히 금지 — 고치는 순간 검증자가 사라지므로 실패는 Dev 에게 되돌린다
- **Stop hook 안전밸브 2중화**: v0.7.0 은 차단할 때마다 카운터를 올리기만 하고 진척 시 리셋하지 않아, 200회 한도가 무한 루프 backstop 이 아니라 **프로젝트 총 턴 상한**으로 동작했다 — 정상 진행 중인 장기 루프가 GOAL 미완 상태에서 조용히 멈춤. v0.8.0 은 `docs/STATUS.md` mtime 변화를 진척 신호로 읽어 리셋한다.
  다만 **연속 카운터만 두면 안전밸브가 수학적으로 도달 불가능**해진다 — 이 훅 스스로 "매 턴 STATUS.md 를 갱신하라" 고 지시하므로 카운터는 1에 고정되고, STATUS.md 만 계속 고쳐쓰는 무의미 루프를 영원히 못 끊는다(push 직전 적대적 리뷰에서 실행으로 확인: 20/20턴 차단, 센티널 `[1 …]` 고정). 그래서 밸브를 둘로 나눴다:
  - **연속 무진척** `CEO_LOOP_MAX_CONTINUES` (기본 200) — STATUS.md 갱신 시 0으로 리셋
  - **누적 차단** `CEO_LOOP_MAX_TOTAL` (기본 1000) — **리셋 없는 절대 상한**
  둘 중 하나라도 도달하면 정지 허용. 센티널은 `"<무진척> <mtime> <누적>"` 3필드가 되었고 구버전 1·2필드 형식도 그대로 읽힌다
- **센티널 경로 fail-open 수정**: `SENTINEL="docs/.ceo-loop-active"` 가 cwd 기준이라 세션 cwd 가 하위 디렉토리면 센티널을 못 찾고 `exit 0` → 루프 강제가 에러 없이 풀렸다. `$CLAUDE_PROJECT_DIR` 로 앵커
- **`effort: high`**: CEO 판단 품질을 세션 effort 에서 분리. 없으면 Dev 세션을 속도 위해 낮은 effort 로 돌릴 때 7-gate·drift 감사 품질이 같이 떨어짐
- **STATUS.md 압축 게이트 추가**: DECISIONS 150줄에 이어 STATUS 120줄 초과 시 `docs/status-archive.md` 로 로테이션. CEO 는 매 호출 fresh 로 전부 재독하므로 파일 비대 = 호출당 토큰 비용
- **`/ceo-dev-loop:status` 에 무진척 카운터 노출** — 루프가 헛도는지 사용자가 직접 확인 가능

### v0.7.0 (자율성 강화 — 개입 최소화 + 토큰 효율)
"AI가 목표를 정확히 수행하고 스스로 결정해서 사용자 개입이 최소화되도록" 이라는 방향 아래, 루프 지속을 프롬프트 권고에서 하네스 강제로 격상하고, 사용자 질문을 비동기 검토로 전환.

- **Stop hook 루프 강제 (`hooks/loop-gate.sh`, Claude Code 전용)**: v0.3.1~v0.4.1 의 우회 어휘 블랙리스트는 본질적으로 두더지 잡기였음 — 모델이 새 표현으로 멈추면 막을 수 없다. v0.7.0 은 `docs/.ceo-loop-active` 센티널이 존재하는 동안 Stop hook 이 턴 종료 자체를 차단. 정당한 정지(① [DONE] ② 사용자 확인 필수 예외 ③ 사용자 중단 지시)는 센티널 삭제로 허용. 연속 차단 200회 한도로 무한 루프 방지. 어휘 차단 규칙은 1차 방어선으로 유지
- **가정 프로토콜**: 모호함 발생 시 사용자에게 묻지 않고 CEO 가 합리적 해석을 채택, DECISIONS.md `## 가정` 에 "(사용자 미확인)" 으로 기록 후 진행. [DONE] 최종 보고에 미확인 가정 전체 목록 포함 — 동기적 질문이 비동기 사후 검토로 바뀜. 핵심 스코프 변경·파괴적·과금·보안 가정만 에스컬레이션
- **정책 fast-path**: 재발할 부류의 결정을 DECISIONS.md `## 정책` 으로 승격. Dev 는 정책에 매칭되는 결정을 CEO 호출 없이 적용 (이력 1줄만 기록) — CEO 왕복 감소 = 토큰 절감 + 일관성
- **권한 사전 위임**: GOAL.md `## 권한 (사전 위임)` 섹션 신설. push/마이그레이션/대량 삭제/breaking change 를 사용자가 미리 위임하면 중간 멈춤 제거. 질문을 늘리지 않기 위해 어차피 묻는 시점(목표 질문, D 단계 덮어쓰기)에만 같이 묻고, 그 외엔 default 보류
- **작업 패키지**: CEO 가 1~3개 순차 작업을 한 번에 지시 가능 (분기 없음 + 단일 검증으로 닫힘 조건). CEO 호출 비용이 호출 횟수에 비례하므로 왕복 절반
- **증거 기반 체크박스**: `[x]` 전환은 검증 명령 + 핵심 출력 1줄이 STATUS.md 에 있어야 인정. 낙관적 체크로 인한 조기 [DONE] 의 마지막 구멍 차단
- **DECISIONS 압축 게이트**: 완료 경계에서 DECISIONS.md 가 150줄 초과면 `## 이력` 의 오래된 항목을 `docs/decisions-archive.md` 로 이동 (정책·미확인 가정은 유지). CEO 가 매 호출 fresh 재독하므로 파일 비대 = 호출당 토큰 비용
- **agents/ceo.md 다이어트**: 버전별 회귀 서사를 이 Changelog 로 이전하고 운영 규칙만 유지 — CEO 는 서브에이전트라 매 호출 fresh 로드이므로 절감이 호출 횟수만큼 곱해짐

### v0.6.0 (매-턴 의식 → 완료 경계 게이트)
사용자 관찰 두 가지 — "compact 를 너무 자주 한다" + "goal 을 너무 자주 갱신한다" — 의 뿌리는 하나였음: **경계에서만 발동해야 할 게이트를 매 턴 의식(ritual)으로 돌린 것.** v0.3.1~v0.5.0 동안 회귀 패치가 누적되며 매 응답에 박는 라인·신호가 늘어 평상시 턴이 과부하 상태였음.

- **컨텍스트 = auto-compact 위임**: CEO 의 `[COMPACT]/[CLEAR]` 결정권 제거. v0.5.0 까지 `agents/ceo.md` 안에 "컨텍스트 자체 판단 금지"(CEO 권한 범위) ↔ "5턴/milestone/빌드그린마다 [COMPACT]"(컨텍스트 관리) 두 규칙이 정면충돌했고, 구체적 휴리스틱이 이겨 compact 가 과발동했음. 빌트인 auto-compact 가 처리하므로 신호·턴 카운터·수동 `/compact` 절차·단계적 에스컬레이션·"컴팩트 보고 최소화" 기계장치를 전부 삭제. CEO 는 fresh 재독 + STATUS/DECISIONS 핸드오프 규율만 유지.
- **GOAL drift = 완료 경계 전용 게이트**: v0.5.0 은 drift 역매핑을 매 응답 의식으로 돌려, drift > 0 이 정상인 실제 개발에서 거의 매 턴 GOAL.md 가 수정됨 — "고정 목표" 가 출렁이고 골대가 계속 늘어나는 반대 부작용("프로젝트가 진행될수록"의 또 다른 얼굴). v0.6.0 은 full drift 감사를 `[SPRINT COMPLETE]`/`[DONE 후보]` 발행 직전에만 실행. 평상시 범위 밖 작업은 DECISIONS.md 기록, GOAL.md 편집은 "완료를 막는 in-scope 누락" 일 때만 → 조기 DONE 방어(완료 게이트)는 유지하면서 GOAL.md 안정화.
- **유지된 안전장치**: 7-gate `[DONE]`, `[DONE 후보]` 5-시나리오 외부 검증, `[SPRINT COMPLETE]`/`[DONE]` 분리, 자율 루프 권한 + 우회 어휘 차단, Dev 1차 필터, init 자율화 — 그대로.
- **제거**: `[COMPACT]/[CLEAR]` 신호, STATUS.md 턴 카운터, `/ceo-dev-loop:status` 의 턴 경고, "컨텍스트 리프레시 절차" · "컴팩트 보고 최소화" · "Dev 측 컨텍스트 한계 단계적 처리" 섹션.

### v0.5.0 (DONE 회귀 근본 수정)
v0.3.1 ~ v0.4.1 의 어휘 블랙리스트 4번 패치에도 [DONE] 오발 회귀가 계속 돌아옴. 근본 원인은 GOAL.md 가 정적이라는 것 — 진행 중 발견된 요구사항이 GOAL 체크박스로 흡수되지 않은 채 STATUS/DECISIONS 에만 쌓여, 체크박스 100% 도달 시 정당하게 [DONE] 발사. "프로젝트가 진행될수록 DONE 주기가 짧아진다" 는 사용자 관찰이 결정적 증거. 어휘로는 못 막는 구조 결함. v0.5.0 은 3가지 구조 게이트로 차단.

- **`[GOAL drift]` 라인 매 응답 강제**: STATUS/DECISIONS → GOAL.md 체크박스 역매핑. 미매핑 1개 이상이면 [DONE]/[SPRINT COMPLETE]/[DONE 후보] 모두 자동 금지 + GOAL.md 보강 우선 지시
- **`[SPRINT COMPLETE — phase X/K]` 신설**: phase/milestone 완료를 [DONE] 과 어휘 분리. SPRINT COMPLETE 는 루프 계속, 같은 응답에 다음 phase 첫 작업 강제 포함
- **`[DONE 후보]` 단계 + 5-시나리오 외부 검증**: 7-gate 통과해도 즉시 [DONE] 금지. CEO 가 산출물 기준 5 시나리오 작성 → Dev 실행 → 5/5 통과 시에만 진짜 [DONE]. GOAL.md 가 아닌 산출물 자체 기준이라 drift 에 강함
- **7-gate [DONE]** (v0.4 의 5-gate + drift=0 + 시나리오 통과)
- **금지 어휘 확장**: SPRINT/DONE 혼동 표현, [DONE 후보] 건너뛰기 차단
- **/ceo-dev-loop:status 에 drift 가시화**

### v0.4.2 (규약 현실화)
공식 문서 확인 결과 `/compact` `/clear` 는 built-in 슬래시 명령으로 메인 세션이 자체 실행 불가. v0.3.0 부터 박혀 있던 "Dev 가 `/compact` 실행" 규약은 물리적으로 불가능했음. 그로 인해 Dev 가 사용자 조작을 요청할 때 형식이 무거워져 "세션 종료" 처럼 보이는 부작용 발생.

- **`[COMPACT]/[CLEAR]` 처리 규약 정정**: "Dev 가 실행" → "Dev 가 1줄 요청 → 사용자 입력 → 같은 세션 자동 재개". 이건 의사결정이 아닌 인프라 조작 트리거이므로 "사용자 승인 0회" 정신 위반 아님 (의사결정은 여전히 CEO 권한)
- **Dev 컴팩트 보고 형식 최소화**: "본 세션 최종 요약 / N 커밋 / 다음 단계 / 산출물 목록" 같은 세션 결산 형태 금지. 1~3줄 인프라 조작 요청만. 보고 내용은 STATUS.md 가 보유
- **컴팩트 후 자동 재개 강화**: 사용자 `/compact` 입력 후 첫 액션은 GOAL/STATUS/DECISIONS 재독 → STATUS 의 "다음 작업" 첫 항목 즉시 시작 또는 `@ceo` 호출. "이어갈까요?" 묻지 않음

### v0.4.1 (회귀 수정 3차 — 세션 우회 차단)
v0.4.0 까지 phase 경계 [DONE] 오발은 막았지만, CEO 가 새 어휘로 우회: "세션 종료 보고 — 다음 세션 재진입 시 즉시 §G 착수 — 단일 세션 내 무한 진행은 물리적 제약". 본질적으로 phase 경계 멈춤과 동일하지만 v0.4.0 금지 어휘 목록에 없어 통과.

- **금지 어휘 확장**: "세션 종료/본 세션 성과/다음 세션 재진입/물리적 제약/단일 세션 내/재진입 가능/{슬래시 명령} 입력 시 착수" 등 추가
- **CEO 권한 범위 명시 분리**: 컨텍스트 한계·세션 길이·인프라 판단은 CEO 권한 밖. CEO 는 `[COMPACT]/[CLEAR]` **신호 발행** 만 하고, 실제 컴팩트/클리어/세션 관리는 Dev 영역
- **컨텍스트 한계 단계적 에스컬레이션**: `[COMPACT]` (1차) → `[CLEAR]` (2차) → 사용자 에스컬레이션 (3차). 1, 2차 단계에서 "세션 종료/재진입" 어휘 사용 금지 — 같은 세션 내 처리가 default
- **Dev 1차 필터 어휘 감지 확장**: `[DONE]` 외에도 응답에 우회 어휘 감지 시 사용자에게 출력하지 않고 즉시 `@ceo` 재호출. 구버전 CEO 패턴 우회까지 차단

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
