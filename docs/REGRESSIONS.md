# Regression Log (아카이브)

> 루트 `CLAUDE.md` 는 상시 주입 = 상시 과금이므로, 회귀 이력 전문은 여기에 보관한다.
> 루트에는 한 줄 포인터만 남긴다. 새 항목은 `/pneumora:log-regression` 으로 추가.
> 재발 방지 규칙 중 **상시 각인이 필요한 것만** 루트 `## ⚠️ CRITICAL` 로 승격한다.

## 2026-05-14

### scripts/new-plugin.sh 가 $DESCRIPTION 을 JSON/YAML heredoc 에 직접 삽입

큰따옴표·백슬래시·개행이 포함된 입력이 들어오면 plugin.json·openai.yaml 이 파싱 불가 상태로 생성됨.

- **영향**: `scripts/new-plugin.sh:75-122, 156-164, 167-192`
- **재발 방지**: 스캐폴딩 스크립트에서 사용자 입력값을 매니페스트·YAML 에 박을 때 반드시 Python heredoc(argv 경유) 또는 `jq -Rs` 로 escape
- **상태**: 해결 (2026-07-25) — 파일 생성·marketplace 등록 전체를 단일 Python 블록으로 이관, 값은 argv 로만 전달하고 JSON/YAML 은 `json.dumps` 로 인코딩. 적대적 입력 8종(큰따옴표·백슬래시·개행·명령치환·YAML 특수문자 등)으로 검증

### Codex 용 디렉토리가 git 에 미추적 — Codex 쪽 좀비 상태

`.codex-plugin/` · `skills/` · `agents/` 가 트래킹되지 않은 채로 Claude 마켓플레이스만 동작.

- **영향**: `pneumora/`, `ceo-dev-loop/`, `claude-md-harness/` 의 미추적 6개 경로
- **재발 방지**: `git push` 직전 `git status --short` 결과에 `??` 로 시작하는 `plugin.json` · `SKILL.md` · `.codex-plugin/` 가 있으면 차단 (`/pneumora:check-deploy` 활용)
- **상태**: 해결 — `scripts/validate-plugins.sh` + PreToolUse hook 으로 기계 강제

### new-plugin.sh 가 Python 부재 시 marketplace 등록을 silent skip 후 exit 0

디렉토리는 생성됐는데 마켓플레이스에는 등록 안 된 좀비 플러그인 발생 가능.

- **영향**: `scripts/new-plugin.sh:258-266`
- **재발 방지**: Python 부재 시 `exit 1` 로 강제 실패하거나 bash fallback 으로 marketplace 등록 보강
- **상태**: 해결 (2026-07-25) — Python 3 를 전제조건으로 승격. 없으면 아무것도 생성하지 않고 `exit 1`, 생성 중 실패 시 디렉토리와 marketplace 를 원상 복구

## 2026-07-25

### ceo-dev-loop Stop hook 카운터가 진척과 무관하게 단조 증가

`loop-gate.sh` 가 차단할 때마다 카운터를 올리기만 하고 진척 시 리셋하지 않아, 200회 한도가 "무한 루프 backstop" 이 아니라 "프로젝트 총 턴 상한" 으로 동작. 정상 진행 중인 장기 루프가 GOAL 미완 상태에서 조용히 정지.

- **영향**: `ceo-dev-loop/hooks/loop-gate.sh` (v0.7.0)
- **재발 방지**: 카운터는 항상 **"연속 실패/무진척"** 을 세야 한다. 진척 신호(여기서는 `docs/STATUS.md` mtime 변화)를 정의하고, 신호가 오면 0으로 리셋. 누적 카운터를 backstop 으로 쓰지 말 것
- **상태**: 해결 (v0.8.0)

### ceo-dev-loop Stop hook 이 센티널을 상대 경로로 조회 — fail-open

`SENTINEL="docs/.ceo-loop-active"` 가 cwd 기준이라, 세션 cwd 가 프로젝트 하위 디렉토리면 센티널을 찾지 못하고 `exit 0` → 루프 강제가 조용히 무력화. 에러도 로그도 없음.

- **영향**: `ceo-dev-loop/hooks/loop-gate.sh` (v0.7.0)
- **재발 방지**: hook 스크립트에서 프로젝트 파일을 참조할 때는 **항상 `$CLAUDE_PROJECT_DIR` 로 앵커**한다 (`pneumora/hooks/hooks.json` 은 이미 이 방식). 상대 경로 + "없으면 통과" 조합은 안전장치를 조용히 끄는 패턴
- **상태**: 해결 (v0.8.0)

### 업그레이드 안내가 "플러그인 파일은 자동 적용" 이라고 잘못 서술 — 캐시 갱신 단계 누락

`ceo-dev-loop/README.md` 의 v0.7.0→v0.8.0 절이 "플러그인 파일은 매 호출 fresh 로 읽히므로 **자동 적용**됩니다" 라고 썼다. 절반만 맞다 — fresh 로 읽는 대상은 레포가 아니라 `~/.claude/plugins/cache/` 사본이고, **서드파티 마켓플레이스는 auto-update 가 기본 꺼져 있다.** 그 안내를 그대로 따른 사용자는 v0.8.0 을 쓰고 있다고 믿으면서 실제로는 v0.7.0 Stop hook(단조 카운터 + 상대경로 fail-open)을 계속 돌린다.

`/handoff` 도그푸딩 중 발견: 스킬이 캐시의 v0.1.0 으로 로드돼 방금 푸시한 v0.2.0 내용이 없었고, 확인해보니 설치된 4개 플러그인이 전부 stale 이었다 (ceo-dev-loop 0.7.0 / pneumora 0.2.0 / handoff 0.1.0).

- **영향**: `ceo-dev-loop/README.md`, 루트 `README.md` (설치 안내에 갱신 절차 없음)
- **재발 방지**: 플러그인 배포 레포의 업그레이드 안내는 **`/plugin marketplace update <name>` + `/reload-plugins` 를 0단계로 명시**한다. "자동 적용" 은 캐시가 이미 갱신된 뒤에만 참이다. 버전 확인법(`ls ~/.claude/plugins/cache/...`)도 함께 적어 사용자가 자기 상태를 검증할 수 있게 한다
- **상태**: 해결 — 두 README 에 갱신 절차 + 캐시 버전 확인법 추가

### 안전밸브를 "연속 카운터" 로 바꾸면서 도달 불가능하게 만듦 (v0.8.0 작업 중 자체 유입)

v0.7.0 의 단조 증가 카운터를 "연속 무진척" 으로 고치면서 절대 상한을 제거했다. 그런데 **그 훅 스스로 "매 턴 STATUS.md 를 갱신하라" 고 지시**하므로 리셋 조건이 매 턴 충족되고, 카운터는 1에 고정돼 `[ "$COUNT" -ge "$LIMIT" ]` 가 영원히 거짓이 된다. 무한 루프 backstop 이 수학적으로 도달 불가능해진 것 — 원래 막으려던 폭주를 정확히 못 막는 상태.

실행으로 확인 (연속한도 5, 매 턴 mtime 변경): 20/20 턴 차단, 센티널 `[1 <mtime>]` 고정, 정지 허용 0회.

- **영향**: `ceo-dev-loop/hooks/loop-gate.sh` (v0.8.0 개발 중, 릴리스 전 발견)
- **재발 방지**: **리셋되는 카운터를 유일한 안전밸브로 삼지 않는다.** 리셋 조건을 시스템 자신이 유발할 수 있으면 그 밸브는 없는 것과 같다. "리셋되는 카운터(정상 동작 감지)" + "리셋 없는 절대 상한(폭주 차단)" 을 항상 쌍으로 둔다
- **상태**: 해결 — `CEO_LOOP_MAX_CONTINUES`(리셋 O) + `CEO_LOOP_MAX_TOTAL`(리셋 X) 2중 밸브

### `.gitattributes` 부재로 Windows clone 시 `.sh` 가 CRLF 체크아웃 — 검증 스크립트 오작동

`core.autocrlf=true`(Git for Windows 기본값) + `.gitattributes` 없음 조합. clone 하면 `.sh` 가 CRLF 로 체크아웃되는데, `scripts/validate-plugins.sh` 는 이 상태에서 **실존하는 `marketplace.json` 을 "없음" 으로 보고하며 exit 1**. CRITICAL #2·#3 을 기계 강제하는 스크립트가 오탐으로 모든 push 를 막는 상태가 된다.

실측 (LF 원본 vs `sed 's/$/\r/'` 사본):

| 스크립트 | LF | CRLF |
|---|---|---|
| `scripts/validate-plugins.sh` | exit 0 (통과) | **exit 1 (오탐)** |
| `ceo-dev-loop/hooks/loop-gate.sh` | exit 2 | exit 2 (정상) |
| `pneumora/hooks/check-deploy-gate.sh` | exit 2 | exit 2 (정상) |

같은 CRLF 인데 하나만 깨진 것이 발견을 늦추는 요인 — "훅은 되는데" 로 넘어가기 쉽다.

- **영향**: 배포되는 모든 `.sh` (플러그인 hook 포함). 레포 소유자 워킹트리는 LF 라 로컬에서는 재현되지 않음
- **재발 방지**: 셸 스크립트를 배포하는 레포는 **`.gitattributes` 에 `*.sh text eol=lf` 를 반드시 둔다.** 스크립트 검증은 LF 뿐 아니라 **실제 배포 경로(clone 결과)의 줄바꿈으로도** 해볼 것
- **상태**: 해결 — `.gitattributes` 신설

### 플러그인이 문서에만 있고 실제로 동봉되지 않은 컴포넌트를 광고

`pneumora/README.md` 와 `marketplace.json` 이 `codebase-explorer` 서브에이전트를 제공 기능으로 명시했으나 `pneumora/agents/` 에는 `.gitkeep` 만 존재. 개발 환경에서는 사용자 레벨(`~/.claude/agents/`)에 같은 이름이 있어 정상 동작하는 것처럼 보여 발견이 늦어짐.

- **영향**: `pneumora/agents/`, `pneumora/README.md`, `.claude-plugin/marketplace.json`
- **재발 방지**: 좀비 검사는 "미추적 파일" 뿐 아니라 **"문서가 약속했는데 없는 파일"** 도 봐야 한다. 개발 환경의 사용자 레벨 설정이 플러그인 결함을 가릴 수 있으므로, 컴포넌트 존재 여부는 레포 내용만으로 판정할 것
- **상태**: 해결 (pneumora v0.3.0 에서 동봉)
