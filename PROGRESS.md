# PROGRESS

> 세션 연속성용. 규칙·구조는 `CLAUDE.md` 참조.
> 최종 업데이트: 2026-06-24

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
