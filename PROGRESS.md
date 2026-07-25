# PROGRESS

> 세션 연속성용. 규칙·구조는 `CLAUDE.md` 참조.
> 최종 업데이트: 2026-07-25

## 활성 컨텍스트

<!-- auto-compact 후 여기부터 읽는다. 작업 중 매 턴 갱신. -->

- **현재 만지는 파일**: (없음 — 2026-07-25 세션 종료)
- **미해결 결정**: `claude-md-harness` 는 이번 감사 범위 밖이었음 (유일하게 버전 그대로 1.1.0) — 같은 수준으로 점검할지 판단 필요
- **다음 작업 첫 단계**: 실제 프로젝트에서 `/ceo-dev-loop:init "목표"` 로 루프 1회 완주 — 유일한 미검증 영역. 캐시는 이미 0.8.0/0.3.0/0.2.1 로 갱신·reload 완료
- **커밋 상태**: `a01bc75..81489f2` 푸시 완료 + 핸드오프 커밋
- **진입점**: `docs/handoff/HANDOFF.md`
- **하네스 여유**: CLAUDE.md 790/800, AGENTS.md 796/800 — 7번째 CRITICAL 추가 시 기계 강제되는 규칙(#2·#3)부터 축약

## 2026-07-25 세션 — 플러그인 감사 + 후속 수정 (ceo-dev-loop 0.8.0 / pneumora 0.3.0 / handoff 0.2.0)

전체 감사 후 발견된 결함 5건 수정. 공통 성격: **안전장치가 조용히 무력화되는 유형** — 겉으로는 정상 동작으로 보여 발견이 늦었다.

### ceo-dev-loop v0.7.0 → v0.8.0
- **CEO 독립 검증**: `tools` 에 Bash 추가(`effort: high` 동반). 7-gate·5-시나리오·증거 체크박스가 전부 "Dev 자기 보고" 라는 같은 신뢰 가정 위에 있어 겹쳐도 두께가 안 늘던 문제. 완료 경계에서 CEO 가 검증 명령을 직접 재실행해 대조, 불일치 시 종료성 신호 차단. 8-gate 로 확장. 쓰기·커밋·배포는 금지 유지
- **Stop hook 카운터 교정**: 진척과 무관한 단조 증가 → `docs/STATUS.md` mtime 을 진척 신호로 읽어 리셋. 200회가 "프로젝트 총 턴 상한" 이던 것을 "연속 무진척 200회" 로
- **센티널 fail-open 수정**: 상대 경로 → `$CLAUDE_PROJECT_DIR` 앵커. cwd 가 하위 디렉토리면 루프 강제가 에러 없이 풀리던 문제
- STATUS.md 120줄 압축 게이트 추가, `/status` 에 무진척 카운터 노출
- 검증: 9개 시나리오 통과 (fail-open 회귀 재현 포함)

### pneumora v0.2.0 → v0.3.0
- README·marketplace 가 광고하던 `codebase-explorer` 를 실제로 동봉 (`agents/` 에 `.gitkeep` 뿐이었음). 개발 환경의 사용자 레벨 에이전트가 결함을 가리고 있었다
- `scripts/validate-plugins.sh` 좀비 패턴에 `agents|commands|hooks` 추가 — 2026-05-14 회귀 B 의 원인이던 미추적 `agents/` 가 기존 패턴에 안 걸렸다

### handoff v0.1.0 → v0.2.0
- **0단계 신설**: `docs/.ceo-loop-active` 감지 시 센티널 삭제 + 재개 지점 확보. 루프 활성 중 핸드오프하면 Stop hook 이 종료를 차단하던 충돌
- 기존 관례 존중 표 추가 (`DECISIONS.md`/`STATUS.md`/`PROGRESS.md` 가 있으면 거기 기록 — 경쟁 저장소 방지)
- HANDOFF 템플릿에 브랜치·미커밋 상태·환경 전제·루프 재개 항목 추가
- codex 매니페스트 스캐폴딩 잔재 정리 (description 3중복, 제네릭 defaultPrompt)

### `/handoff` 도그푸딩 (v0.2.0 → 0.2.1) — 발견 2건
플러그인 스킬 로더로 v0.2.0 을 호출했더니 **캐시의 v0.1.0 이 로드**됐다. 확인해보니 설치된 4개 플러그인이 전부 stale (ceo-dev-loop 0.7.0 / pneumora 0.2.0 / handoff 0.1.0). 절차는 레포 소스대로 수동 수행.

- **[문서 오류] "플러그인 파일은 자동 적용" 이 틀렸다**: fresh 로 읽는 대상은 레포가 아니라 `~/.claude/plugins/cache/` 사본이고, 서드파티 마켓플레이스는 **auto-update 가 기본 꺼짐**. 그 안내를 따른 사용자는 v0.8.0 을 쓴다고 믿으며 v0.7.0 Stop hook 을 계속 돌린다. 두 README 에 `/plugin marketplace update` + `/reload-plugins` 0단계와 캐시 버전 확인법 추가 — 상세는 `docs/REGRESSIONS.md`
- **[스킬 갭] 기존 관례 표에 `docs/REGRESSIONS.md` 누락**: 이 레포가 정확히 그 관례(pneumora 단일 파일 로테이션)를 쓰는데 표에 없어, 규칙대로면 `docs/regressions/` 를 새로 만들 뻔했다. 회귀 기록이 두 곳으로 갈리는 것이 이 표가 막으려는 상황 자체 → 행 추가 후 **0.2.1** bump
- **검증된 것**: 기존 관례 존중 규칙이 실제로 작동 (`docs/sessions/` 대신 `PROGRESS.md` 에 기록), HANDOFF 템플릿의 신규 항목(브랜치·미커밋·환경 전제·루프 재개)이 실제로 채울 내용이 있음

### harness 재감사 (세션 종료 전)
lint 양쪽 0 경고. lint 가 못 잡는 항목을 수동 점검해 1건 발견·수정:

- **`docs/handoff/HANDOFF.md` 가 루트 CLAUDE.md 에서 언급 0회** — 다음 작업자 진입점인데 하네스에서 발견 불가였음. `## 참고` 에 추가 (AGENTS.md 도 동일)
- **분산은 하지 않기로 판단**: 4개 플러그인 디렉토리가 파일 수(>3) 기준으로는 Module CLAUDE.md 후보지만 ① CRITICAL #1 이 향하는 `scripts/` 는 2파일이라 스킬 자체 규칙상 대상이 아니고 ② hook 규칙(#5·#6)은 두 플러그인에 흩어져 있어 내리면 DRY 위반이며 ③ **CRITICAL 은 파일 규칙이 아니라 패턴 교훈** — #5 는 *앞으로 만들* hook 에도 적용되는데 아직 없는 디렉토리엔 CLAUDE.md 를 미리 둘 수 없다. ④ 플러그인별 CLAUDE.md 는 각 README 와 중복될 뿐 쓸 내용이 없음
- **누적 파일**: `docs/REGRESSIONS.md` 9항목(~2.8K토큰), `PROGRESS.md` 4세션(~6.6K토큰). 둘 다 상시 주입이 아니라 토큰 누수는 없음. PROGRESS 는 `## 활성 컨텍스트` 가 맨 위라 부분 읽기가 가능한 구조 — 세션이 더 쌓이면 오래된 것부터 아카이브 검토

### Stop hook 실전 검증 (캐시 갱신 후)
`claude plugin marketplace update` + `claude plugin update` ×3 → `/reload-plugins` 로 0.8.0/0.3.0/0.2.1 반영. `pneumora:codebase-explorer` 가 새 에이전트로 등장한 것이 0.3.0 로드의 직접 증거.

센티널(`docs/.ceo-loop-active`)을 심고 턴을 의도적으로 종료해 **훅이 실제로 발동하는 것을 확인**:

- 차단 메시지가 `무진척 0/200, 누적 0/1000` — **2중 밸브 표기**. v0.7.0 이면 단일 카운터만 나옴
- 메시지의 센티널 경로가 **절대경로** — `$CLAUDE_PROJECT_DIR` 앵커 작동. v0.7.0 이면 상대경로
- 훅이 쓴 센티널 내용 `1 0 1` — 3필드 형식, 양쪽 카운터 +1, `STATUS.md` 부재로 mtime=0
- handoff 0단계대로 중단 사유 ③ 판정 후 삭제 → 훅 exit 0, 워킹트리 잔여물 0

즉 **등록·경로 앵커·2중 카운터·센티널 해제 경로가 실환경에서 확인됨**. 남은 미검증은 `init` → `[DONE]` 전체 사이클뿐 (Stop hook 이 세션의 프로젝트 디렉토리에만 걸려 이 레포에서는 대신 검증 불가).

### new-plugin.sh 하드닝 — CRITICAL #1·#5 해소 (2026-05-14 부터 미해결이던 건)
- **인젝션 표면 5곳 제거**: `plugin.json` ×2 · `SKILL.md` 프론트매터 · `openai.yaml` · `README.md` 를 셸 heredoc 보간에서 빼고, 파일 생성 + 두 marketplace 등록 전체를 **단일 Python 블록**으로 이관. 값은 argv 로만 전달하고 JSON 은 `json.dumps`, YAML 은 JSON 문자열 문법(YAML 부분집합)으로 인코딩
- **Python 3 를 전제조건으로 승격**: 없으면 **아무것도 생성하지 않고 exit 1**. 이전엔 경고만 찍고 exit 0 이라 "디렉토리는 있는데 marketplace 엔 없는" 좀비가 생길 수 있었다
- **실패 시 롤백**: 생성 도중 예외가 나면 플러그인 디렉토리 삭제 + 두 marketplace 원상 복구
- **cp949 콘솔 크래시 수정** (작업 중 발견): Python 이 한글·기호를 그대로 출력하면 한국어 Windows 콘솔에서 `UnicodeEncodeError` 로 죽는다. `set -e` 와 겹쳐 **정상 생성됐는데도 스크립트가 실패로 종료**했고, 에러 경로에서는 진짜 에러 대신 인코딩 트레이스백이 떴다. stdout/stderr 를 UTF-8 + `errors="replace"` 로 reconfigure
- 검증: 적대적 입력 8종(큰따옴표·백슬래시·개행·명령치환·YAML 특수문자·이모지·공백만·셸 인젝션)을 실제 JSON/YAML 파서로 파싱 + 값 원본 보존까지 확인해 8/8 통과. **동일 입력에서 구버전은 JSON 2개·YAML 1개가 파싱 불가**로 재현됨. Python 부재·중복 이름·롤백 경로도 각각 확인

### push 직전 적대적 리뷰 (24 에이전트 / 6차원 · 확정 7건, 기각 11건)
공개 마켓플레이스로 나가는 변경이라 커밋 전에 6차원 리뷰 + 건별 독립 검증을 돌렸다. 확정 7건 전부 반영:

- **[자체 유입 회귀] 안전밸브 도달 불가**: 연속 카운터만 두면 훅 자신이 리셋 조건을 유발해 밸브가 영원히 안 열린다 (실행 확인: 20/20턴 차단). `CEO_LOOP_MAX_TOTAL` 절대 상한 추가로 2중화 — 상세는 `docs/REGRESSIONS.md`
- **좀비 검사 재설계**: 컴포넌트 디렉토리 나열식(`agents|commands|hooks`)은 `skills/*/scripts/` 를 놓치고 `.claude/hooks/` 를 오탐한다. "최상위 세그먼트가 플러그인 디렉토리인가" 로 교체 — 4개 케이스 실측 통과
- **`CEO_LOOP_MAX_CONTINUES` 미검증**: 사용자가 타이핑하는 유일한 값인데 가드가 없어 `200회` 같은 입력에서 비교문이 에러 → 밸브 무력화. `case` 가드 추가
- **AGENTS.md 에 CRITICAL #6 누락**: Codex 는 hook 을 실행하진 않지만 이 레포에서 hook 을 *작성*한다. 빠지면 방금 고친 fail-open 을 Codex 세션이 재생산
- **handoff `skills/handoff/agents/openai.yaml` 스캐폴딩 잔재**: `.codex-plugin/plugin.json` 만 고치고 스킬 레벨 매니페스트를 빠뜨려 Codex 쪽 메타데이터가 서로 모순. PROGRESS 의 "잔재 정리" 주장도 반쪽이었음 → 수정
- **`7-gate` 라벨 stale**: 항목이 8개인데 헤더·본문 4곳이 7-gate. ceo.md 현재 규칙은 8-gate 로, README 과거 changelog 는 유지

기각 11건은 검증자가 코드를 직접 실행하거나 git baseline 과 대조해 반증 (예: "gate 8 을 건너뛸 수 있다" → 4개 근거로 반박, "응답 템플릿에 슬롯 없음" → 파일이 요구하는 출력은 모두 슬롯 존재).

### 줄바꿈 (push 직전 발견)
- **`.gitattributes` 신설** — `core.autocrlf=true` + `.gitattributes` 부재라 Windows clone 시 `.sh` 가 CRLF 로 체크아웃됨. 실측 결과 `validate-plugins.sh` 가 CRLF 에서 실존 파일을 "없음" 으로 보고하며 exit 1 (hook 2개는 CRLF 에서도 정상 — 하나만 깨져서 발견이 늦었다). 레포 워킹트리는 LF 라 로컬 재현 불가였음

### 하네스
- 루트 `CLAUDE.md` **1628 → 766 토큰** (예산 800). 회귀 이력 전문을 `docs/REGRESSIONS.md` 로 로테이션, CRITICAL 압축, Compact Recovery 앵커 신설, CRITICAL #6(`$CLAUDE_PROJECT_DIR` 앵커) 추가
- **`AGENTS.md` 신설 (791 토큰)** — 듀얼 타깃인데 Codex 세션엔 CRITICAL 이 하나도 전달되지 않던 상태. Codex 는 hook 이 없으므로 "push 전 validate 수동 실행" 을 명시
- `PROGRESS.md` 에 `## 활성 컨텍스트` 추가 (compact 생존 레이어)

### 검증
- `validate-plugins.sh` ✅ (4개 버전 동기, 좀비 없음, pre-push hook 모드 정상)
- `harness-lint.sh` ✅ CLAUDE.md 766/800 · AGENTS.md 791/800, 경고 0
- `bash -n` ✅ 수정한 스크립트 2개

### 다음 후보
- **`/handoff` 도그푸딩** — v0.2.0 이 아직 실전 0회. 이 레포에 돌려 `docs/handoff/HANDOFF.md` 생성하고 템플릿 검증
- `new-plugin.sh` CRITICAL #1 (heredoc 인젝션) 미수정 — Python argv 경유로 통일
- 커밋·push 미실행 (staged 상태) — push 시 `team-pneumora` 계정 확인 필요

---

## 2026-06-24 세션 — 마켓플레이스 정리(7→3) + handoff 추가(→4)

자주 쓰는 `ceo-dev-loop`·`claude-md-harness` + 레포 운영용 `pneumora` 3개만 유지(mattpocock/skills 기반 4개 derivative 제거), 이후 신규 `handoff` 추가.

### 제거 (4개)
- `dev-discipline`, `domain-language`, `comm-modes`, `gh-flow` — 디렉토리 `git rm -r` + 두 marketplace.json 엔트리
- README Credits 섹션(mattpocock 적응 내역 전체) + CLAUDE.md Directory Map 4행 / 참고 1줄 동기 제거

### 검증
- `scripts/validate-plugins.sh` ✅ 통과 — 3개 버전 동기(0.7.0/1.1.0/0.2.0), 두 marketplace 파싱, 좀비 없음
- `git status` — M: 두 marketplace·CLAUDE·README / D: 4개 디렉토리 staged / `??` 없음

### 신규 플러그인: handoff (v0.1.0)
- 작업 종료 → 다음 작업자 핸드오프 자동화. `scripts/new-plugin.sh` 경유 스캐폴딩 후 SKILL.md 재작성
- 파이프라인(트리거 1회 → 자동): 상태 수집 → 회귀 가드 → harness 점검·보완 → docs 기록 → `docs/handoff/HANDOFF.md` 진입점
- docs 구조: 분리형(handoff·sessions·decisions·regressions). 트리거 "작업 종료/마무리/핸드오프/인수인계" + /handoff (한·영 병기)
- `pneumora`·`claude-md-harness`·`ceo-dev-loop` 와 soft 연계 (설치 시 활용)
- validate ✅ — 0.1.0 동기, 두 marketplace 등록, 좀비 없음

### 다음 후보
- handoff dogfooding: 실제 `/handoff` 로 이 레포 docs/ 생성해보고 템플릿 개선
- new-plugin.sh CRITICAL #1 (description heredoc 직접 삽입) 미수정 — 향후 Python argv 경유로 통일

---

## 2026-06-10 세션 — 플러그인 강화 (토큰 효율 + 맥락 유지 + 자율성)

사용자 방향 2개: ① harness = 토큰 효율 + 맥락 손실 방지, ② ceo-dev-loop = 자율 결정·개입 최소화.
11개 항목 전부 구현, 플러그인별 커밋 4개.

### 적용 내역
1. **claude-md-harness v1.1.0** (`642f1bc`)
   - SKILL.md: 로딩 의미론 비용 모델(루트=상시 과금/leaf=작업 시), 배치 휴리스틱, @import 경고, 토큰 예산(Root≤800/Module≤600/Leaf≤400, bytes÷3 근사), compact 생존 레이어(루트 Compact Recovery 앵커 + PROGRESS.md `## 활성 컨텍스트`), 4단계 압축 패스, 유지보수 모드("harness 점검")
   - 신규 `scripts/harness-lint.sh`: 예산·빈 섹션·계층 중복·맵 동기화 검사 (테스트 통과)
2. **pneumora v0.2.0** (`39b4491`)
   - log-regression: 6건 이상이면 최신 5건만 유지, 나머지 `docs/REGRESSIONS.md` 아카이브 로테이션
   - 신규 `hooks/check-deploy-gate.sh` (PreToolUse:Bash): 미추적 plugin.json/SKILL.md/.codex-plugin 있으면 git push 차단. `-uall` 로 미추적 디렉토리 내부 파일까지 검사 (테스트 통과)
3. **ceo-dev-loop v0.7.0** (`e0c3505`)
   - 신규 `hooks/loop-gate.sh` (Stop hook): `docs/.ceo-loop-active` 센티널 존재 중 턴 종료 차단. 정당 정지 3경우(DONE/예외 질문/사용자 중단)만 센티널 삭제로 허용, 연속 200회 한도 (테스트 통과)
   - 가정 프로토콜(질문→DECISIONS.md `## 가정` 기록 후 진행, [DONE] 보고에 목록), 정책 fast-path(`## 정책` 매칭 시 CEO 호출 생략), 권한 사전 위임(GOAL.md `## 권한`), 작업 패키지(1~3개), 증거 기반 체크박스, DECISIONS 150줄 압축 게이트
   - agents/ceo.md 다이어트: 버전 서사 → README Changelog 이전, 운영 규칙만 유지
4. **공통 인프라** (이 커밋)
   - 신규 `scripts/validate-plugins.sh`: 버전 동기(CRITICAL #2)·JSON 파싱·마켓플레이스 등록·좀비(CRITICAL #3) 일괄 검증 + `--pre-push-hook` 모드
   - `.claude/settings.json` PreToolUse hook 등록 (push 시 자동 실행), CLAUDE.md CRITICAL #2/#3 에 자동화 명시

### 미해결 / 다음 후보
- **이 레포 루트 CLAUDE.md 가 토큰 예산 초과** (~1649 est > 800) — harness-lint 가 검출. Tech Stack/Global Rules 압축 또는 Regression Log 조기 로테이션 후보 (현재 3건이라 5건 규칙 미달)
- push 미실행 — 사용자 확인 대기 (push 시 새 hook 들이 처음 실전 작동)
- 기존 v0.6.0 으로 init 된 프로젝트는 README "기존 프로젝트 업그레이드 (v0.6.0 → v0.7.0)" 절차 필요

---

## 2026-05-29 세션 — ceo-dev-loop v0.6.0 (매-턴 의식 → 완료 경계 게이트)

사용자 관찰 2건의 뿌리가 동일 — "경계에서만 발동할 게이트를 매 턴 의식으로 돌림":
- **compact 잦음**: `agents/ceo.md` 내부 모순(권한 범위 "컨텍스트 자체판단 금지" ↔ 컨텍스트 관리 "5턴/milestone/빌드그린마다 [COMPACT]"). 구체 휴리스틱이 이겨 과발동.
- **goal 잦은 갱신**: v0.5.0 `[GOAL drift]` 를 매 응답 의식으로 → drift>0 정상 개발에서 GOAL.md 가 매 턴 출렁.

### 적용 (3개 다 권장안)
1. **compact = 빌트인 auto-compact 위임** — `[COMPACT]/[CLEAR]` 신호·턴 카운터·수동 /compact 절차·에스컬레이션 사다리·"보고 최소화" 전부 삭제
2. **drift = 완료 경계 전용 게이트** — `[SPRINT COMPLETE]`/`[DONE 후보]` 직전에만 full 감사. 평상시 범위 밖 작업은 DECISIONS.md, GOAL.md 편집은 "완료 막는 in-scope 누락" 일 때만
3. **v0.6.0 동기 bump** — 두 plugin.json + claude marketplace 엔트리

### 수정 파일 (9)
`agents/ceo.md` · `commands/{init,start,status}.md` · `skills/ceo-dev-loop/SKILL.md` · `README.md` · `ceo-dev-loop/.claude-plugin/plugin.json` · `ceo-dev-loop/.codex-plugin/plugin.json` · `.claude-plugin/marketplace.json`

### 상태
- 버전 동기 ✓ (둘 다 0.6.0), JSON 4종 파싱 ✓, 미추적 plugin.json/SKILL.md/.codex-plugin 없음 (CRITICAL #3 안전)
- **커밋 미실행** — 사용자 확인 대기. 커밋 시 위 9파일 한 커밋 (CRITICAL #2)

---

## (이전 세션) 2026-05-14 — new-plugin.sh 하드닝 로드맵

## 이번 세션 목표

전체 코드를 깊이 감사해서 회귀·안전성 강화. Pneumora 플러그인 자체 도구로 자기 레포 하드닝.

## 감사 결과 — 발견된 약점 (5건)

| # | 위치 | 종류 | 요약 |
|---|---|---|---|
| A | `scripts/new-plugin.sh:75-122, 156-164, 167-192` | **HIGH** | `$DESCRIPTION` / `$PLUGIN_NAME` 을 JSON/YAML heredoc 에 직접 박음 — 큰따옴표·백슬래시·개행이면 매니페스트 파싱 깨짐 |
| B | git status 미추적 6건 | **HIGH** | Codex 측 `.codex-plugin/`·`skills/`·`agents/` 가 미추적이라 Codex 좀비 상태 |
| C | `scripts/new-plugin.sh:258-266` | **MED** | Python 없으면 marketplace.json 업데이트 silent skip 후 exit 0 — 등록 안 된 좀비 디렉토리 |
| D | `.claude-plugin/marketplace.json` ↔ `.codex-plugin/marketplace.json` | **MED** | 같은 플러그인 두 매니페스트 버전 드리프트 잡아주는 게이트 없음 |
| E | SKILL.md frontmatter | **LOW** | 일부 description 의 한·영 트리거 키워드 빈약 → 자동 로드 실패 |

## 강화 로드맵 (6단계)

1. ✅ **`/pneumora:log-regression`** — A·B·C 를 Regression Log 에 박기
2. ✅ **`claude-md-harness`** — 루트 `CLAUDE.md` 신설, CRITICAL 명시
3. ✅ **미추적 6건 git add + 커밋 + 푸시**
4. ⏳ **`/dev-discipline:request-refactor-plan`** — `new-plugin.sh` JSON 인젝션 통합 fix 마이크로커밋 분해
5. ⏳ **`update-config`** — `.claude/settings.json` 에 pre-push hook 등록 (`scripts/validate-plugins.sh`)
6. ⏳ **(선택) `/gh-flow:to-issues`** — 잔여 항목을 GitHub issue 로 분리

## 완료된 작업 (2026-05-14)

### 1단계 — Regression Log 작성
- 루트 `CLAUDE.md` 의 `## 📋 Regression Log` 에 A·B·C 3건 기록
- 포맷: `[YYYY-MM-DD] <증상>` + `영향:` + `재발 방지:`

### 2단계 — 루트 CLAUDE.md 하네스
- `CLAUDE.md` 신설 (64줄, Root 가이드라인 30~80줄 내)
- 섹션: `⚠️ CRITICAL` (5개 규칙) · `📋 Regression Log` (3건) · Tech Stack · Global Rules · Directory Map · 참고
- Module/Leaf 레이어는 미생성 (`scripts/` 1파일이라 스킵, 플러그인별은 자체 README/SKILL.md 가 이미 커버)

### 3단계 — 미추적 파일 트래킹 + 푸시
3개 커밋, origin/main 푸시 완료 (`765519f..ac5b26a`):

- `475467a` — chore: Codex 매니페스트·SKILL.md·agents/openai.yaml 9개 트래킹
  - `pneumora/`, `ceo-dev-loop/`, `claude-md-harness/` 의 미추적 메타데이터
- `c187295` — docs: 루트 CLAUDE.md harness with CRITICAL and Regression Log
- `ac5b26a` — feat(scaffolding): `new-plugin.sh` 듀얼 타깃 확장 + README/SKILL Codex 표기
  - 이 커밋이 회귀 A 의 표면을 3 → 5 heredoc 으로 확장. 4단계에서 통합 처리 예정

## 다음 세션 재개 지점

```
4번부터 시작:
/dev-discipline:request-refactor-plan
```

목표: `scripts/new-plugin.sh` 의 모든 `cat > ... <<EOF "$VAR" EOF` 패턴을 Python heredoc(argv 경유) 으로 통일. 마이크로커밋 분해해서 `REFACTOR-PLAN.md` 작성.

### 작업 트리 상태 (2026-05-14 종료 시점)

```
$ git status
On branch main
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

### 참고할 파일

- `CLAUDE.md` — CRITICAL/Regression Log/Directory Map
- `scripts/new-plugin.sh` — 4단계 리팩터 대상 (282줄)
- `README.md` 의 "Adding a New Plugin" — 스캐폴딩 의도된 사용 흐름
