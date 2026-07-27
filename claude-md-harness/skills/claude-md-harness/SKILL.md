---
name: claude-md-harness
description: CLAUDE.md 또는 AGENTS.md 파일을 객체지향적 하네스(harness) 구조로 분산시키고 점검하는 스킬. "CLAUDE.md 쪼개줘", "AGENTS.md 쪼개줘", "하네스 구조로 만들어줘", "instruction 파일 분산", "CLAUDE.md 리팩토링", "AGENTS.md 정리", "프로젝트 instruction 구조화", "디렉토리별 CLAUDE.md/AGENTS.md", "harness 점검", "CLAUDE.md 감사", "토큰 예산 점검", "instruction file lint/audit" 등의 요청 시 반드시 이 스킬을 사용한다. 새 프로젝트 셋업 시 Claude Code 또는 Codex instruction 파일 초기 구조를 잡을 때도 사용한다.
---

# CLAUDE.md / AGENTS.md Harness — 객체지향 분산 구조화

## 대상 파일 선택

- Claude Code 맥락이면 `CLAUDE.md`를 대상으로 한다.
- Codex 맥락이면 `AGENTS.md`를 대상으로 한다.
- 사용자가 파일명을 명시하면 그 파일명을 따른다.
- 두 파일이 모두 있고 사용자가 "둘 다" 또는 "Claude와 Codex 호환"을 요청하면 같은 하네스 구조를 양쪽에 적용하되, 각 파일의 제품별 규칙은 섞지 않는다.
- 아래 절차에서 `CLAUDE.md`라고 적힌 부분은 선택된 대상 파일명으로 치환해서 적용한다.

## 로딩 의미론 — 분산이 토큰을 아끼는 이유

분산 배치는 미학이 아니라 **토큰 과금 모델 최적화**다:

| 파일 위치 | 로드 시점 | 비용 성격 |
|---|---|---|
| 루트(및 cwd 조상) CLAUDE.md | 세션 시작부터 매 프롬프트 재주입 | **상시 과금** |
| 하위 디렉토리 CLAUDE.md | 그 디렉토리의 파일을 읽거나 수정할 때만 로드 | 작업 시에만 과금 |

Codex의 `AGENTS.md`도 루트→작업 디렉토리 체인 로드로 같은 모델이 적용된다.

여기서 따라 나오는 규칙:

1. **배치 휴리스틱**: *"이 규칙을 어겼을 때 깨지는 파일이 있는 디렉토리에 규칙을 둔다."*
   루트로 승격되는 것은 전역 규칙·CRITICAL·디렉토리 맵뿐이다. 특정 모듈에서만 의미 있는
   규칙이 루트에 있으면 그 규칙은 모든 무관한 작업에서도 토큰을 소비한다.
2. **`@import` 사용 금지**: `@path/to/file` 임포트는 eager 로드라 분산 효과를 무효화한다.
   대신 일반 경로 참조(`→ docs/x.md 참조`)로 적어 모델이 필요할 때만 읽게 한다.
3. **누적 섹션은 로테이션**: Regression Log 같은 무한 증식 섹션이 루트에 있으면 상시 토큰
   누수가 된다. 최신 5건만 루트에 유지하고 이전 항목은 `docs/REGRESSIONS.md` 등으로
   아카이브 + 한 줄 포인터만 남긴다.

## 핵심 원칙

instruction 파일을 **OOP 상속 모델**처럼 계층화한다:

```
project-root/
├── CLAUDE.md              ← "Base Class": 프로젝트 전체 방향성, 글로벌 규칙, 하위 맵
├── src/
│   ├── CLAUDE.md          ← "Abstract Class": src 전체 아키텍처, 공통 코딩 컨벤션
│   ├── api/
│   │   └── CLAUDE.md      ← "Concrete Class": API 라우트 규칙, 인증 로직, 에러 핸들링
│   ├── services/
│   │   └── CLAUDE.md      ← "Concrete Class": 비즈니스 로직 규칙, 외부 API 연동 주의사항
│   └── models/
│       └── CLAUDE.md      ← "Concrete Class": DB 스키마 규칙, 마이그레이션 제약사항
├── tests/
│   └── CLAUDE.md          ← 테스트 컨벤션, 커버리지 기준
└── docs/
    └── CLAUDE.md          ← 문서화 규칙
```

## 계층별 역할

### Level 0 — Root CLAUDE.md (Base Class)
- 프로젝트 한 줄 소개 & 목적
- 기술 스택 요약 (언어, 프레임워크, 주요 라이브러리)
- **글로벌 규칙** (모든 하위에 적용): 커밋 컨벤션, 언어 설정, 금지 사항
- **디렉토리 맵**: 각 하위 CLAUDE.md 위치와 한 줄 설명
- **Compact Recovery 앵커** (아래 "세션 연속성 레이어" 참조)
- PROGRESS.md, TODO.md 등 세션 연속성 파일 참조

```markdown
# Project Name

> 한 줄 소개

## Tech Stack
- Backend: FastAPI (Python 3.11+)
- Frontend: Next.js 14
- DB: Supabase (PostgreSQL)

## Global Rules
- 한국어 주석, 영어 코드
- 커밋: conventional commits
- 절대 .env 파일을 코드에 포함하지 않는다

## Compact Recovery
컨텍스트가 요약된 정황이 보이면:
1. `PROGRESS.md` 재독 — `## 활성 컨텍스트` 우선
2. 활성 작업을 그 지점부터 재개 (사용자에게 다시 묻지 않는다)

## Directory Map
| Path | Description |
|------|------------|
| `src/CLAUDE.md` | 소스코드 아키텍처 및 코딩 컨벤션 |
| `src/api/CLAUDE.md` | API 엔드포인트 규칙 |
| `tests/CLAUDE.md` | 테스트 작성 가이드 |
```

### Level 1 — Module CLAUDE.md (Abstract Class)
- 해당 디렉토리의 **아키텍처 개요**
- 하위 모듈 간 의존성/관계
- 공통 패턴 (에러 핸들링, 로깅 등)
- 하위 CLAUDE.md 참조 맵

### Level 2+ — Leaf CLAUDE.md (Concrete Class)
- **구체적 구현 규칙**: 함수 네이밍, 파라미터 검증, 리턴 포맷
- 해당 디렉토리 고유 제약사항
- 외부 API/서비스 연동 시 주의사항
- 자주 발생하는 실수와 해결 패턴

## 세션 연속성 레이어 — compact 생존 설계

auto-compact(컨텍스트 자동 요약) 시 **생존하는 정보와 소실되는 정보**를 구분해서 배치한다:

| 정보 종류 | 저장처 | 이유 |
|---|---|---|
| 규칙·구조·제약 | CLAUDE.md 계층 | 매 프롬프트 재주입되므로 요약에서 생존 |
| 진행 상황·활성 작업 | PROGRESS.md | 요약이 무엇을 버려도 디스크에서 복구 가능 |
| 세션 대화에만 있는 결정 | 즉시 PROGRESS.md(진행) 또는 CLAUDE.md(규칙)로 격상 | 대화에만 있으면 요약 시 소실 |

하네스 구조화 시 다음 두 가지를 함께 설치한다:

1. **루트 CLAUDE.md에 Compact Recovery 앵커** (위 Level 0 템플릿의 3~4줄짜리 섹션).
   재주입되는 유일한 파일에 복구 절차를 박아, 요약 후 첫 행동이 디스크 재독이 되게 한다.
2. **PROGRESS.md에 `## 활성 컨텍스트` 섹션**:

```markdown
## 활성 컨텍스트
- 현재 만지는 파일: ...
- 미해결 결정: ...
- 다음 작업 첫 단계: ...
```

작업 중에는 이 섹션을 갱신하는 것이 곧 맥락 보존이다 — "요약이 무엇을 버리든
루트 CLAUDE.md + PROGRESS.md 두 파일만 읽으면 재개 가능" 상태를 항상 유지한다.

## 실행 절차

### 1단계: 현재 상태 분석

```bash
# 기존 CLAUDE.md 확인
find . -name "CLAUDE.md" -not -path "*/node_modules/*" -not -path "*/.git/*" | sort

# 루트 CLAUDE.md 내용 확인
cat CLAUDE.md

# 프로젝트 구조 파악
find . -type d -maxdepth 3 -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/__pycache__/*" | sort

# 상시 주입 비용 측정 (근사: UTF-8 바이트 / 3 ≈ 토큰)
wc -c CLAUDE.md
```

### 2단계: 분산 계획 수립

기존 CLAUDE.md의 내용을 분석하여 다음을 판단:

1. **글로벌 vs 로컬 분류**: 배치 휴리스틱 적용 — "이 규칙을 어겼을 때 깨지는 파일이 있는
   디렉토리"가 한 곳이면 그 디렉토리의 Leaf로, 전체면 루트에 남긴다
2. **적절한 깊이 결정**: 디렉토리가 3개 이하의 파일을 가지면 굳이 CLAUDE.md를 만들지 않는다
3. **중복 제거**: 상위에서 이미 명시한 규칙을 하위에서 반복하지 않는다

> **원칙**: CLAUDE.md가 있는 디렉토리에서 작업할 때, Claude Code가 **해당 CLAUDE.md + 모든 상위 CLAUDE.md**를 참조한다. 따라서 상위에 있는 내용은 하위에서 반복하지 않는다.

### 3단계: 파일 생성

각 CLAUDE.md를 생성할 때 다음 템플릿을 따른다:

```markdown
# {Directory Purpose}

> 이 디렉토리의 한 줄 설명

## Architecture / Overview
(이 디렉토리의 구조와 역할)

## Rules & Conventions
(여기서만 적용되는 규칙들)

## Constraints & Gotchas
(주의사항, 알려진 제약, 자주 하는 실수)

## Dependencies
(외부 의존성, 다른 모듈과의 관계)

## Sub-modules
(하위 CLAUDE.md가 있다면 맵 테이블)
```

**섹션은 내용이 있을 때만 포함한다.** 빈 섹션은 만들지 않는다.

### 4단계: 루트 CLAUDE.md 정리 + 압축 패스

분산 완료 후 루트 CLAUDE.md를:
- 하위로 이동한 내용을 제거
- Directory Map 테이블 업데이트
- Compact Recovery 앵커 + PROGRESS.md `## 활성 컨텍스트` 설치 (없으면)
- 글로벌 규칙만 남긴 간결한 형태로 정리

이어서 **압축 패스** — 남은 모든 계층 파일에 적용:
- 서술형 → 명령형 단문 ("~하는 것이 좋습니다" → "~한다")
- 배경 설명·도입 서사·변경 이력 제거 — 가치 있으면 README/ADR로 이동하고 경로 참조만 남김
- 한 줄에 한 규칙, 장식적 마크다운(불필요한 굵게·이모지·중첩 인용) 최소화
- 목표: 분산 전 대비 루트 상시 주입량 30~50% 감축

> **압축은 사후 보정이 아니라 작성 기준이다.** 3단계에서 새 계층 파일을 만들 때부터 아래 "적정 크기"
> 예산 안에서 쓴다. 일단 길게 쓰고 나중에 줄이는 방식은 예산 초과분을 그대로 남기기 쉽다.

### 5단계: 검증

```bash
# 스킬 번들 lint — 토큰 예산·빈 섹션·계층 간 중복·디렉토리 맵 동기화 일괄 점검
bash {이 SKILL.md와 같은 디렉토리}/scripts/harness-lint.sh CLAUDE.md
```

lint 스크립트를 실행할 수 없는 환경이면 수동으로:

```bash
find . -name "CLAUDE.md" -not -path "*/node_modules/*" | sort
find . -name "CLAUDE.md" -not -path "*/node_modules/*" -exec sh -c 'echo "$(($(wc -c < "$1") / 3)) tokens(est) $1"' _ {} \; | sort -rn
```

**적정 크기 가이드라인** — 1차 기준은 **상시 주입 토큰 예산**, 줄 수는 보조 지표:

| 계층 | 토큰 예산 (근사) | 줄 수 (보조) |
|---|---|---|
| Root | ≤ ~800 | 30~80 |
| Module (Level 1) | ≤ ~600 | 20~60 |
| Leaf (Level 2+) | ≤ ~400 | 10~40 |

근사 공식: 토큰 ≈ UTF-8 바이트 ÷ 3 (영문 ~4자/토큰, 한글 ~1.5자/토큰의 혼합 근사).
예산 초과 시 추가 분산 또는 압축 패스 재적용.

## 유지보수 모드 — "harness 점검"

이미 분산된 프로젝트에서 "harness 점검", "CLAUDE.md 감사" 류 요청이 오면
초기 분산이 아니라 **재감사**를 수행한다. 분산 구조는 시간이 지나며 썩는다
(중복 재발, 누적 섹션 비대, 맵 불일치) — 주기적 점검이 전제다.

1. `scripts/harness-lint.sh` 실행 (대상 파일명 인자로 `CLAUDE.md` 또는 `AGENTS.md`)
2. 보고된 항목별 처리:
   - **토큰 예산 초과** → 압축 패스 또는 하위 분산
   - **계층 간 중복 라인** → 상위 한 곳만 남기고 하위에서 삭제 (DRY)
   - **빈 섹션** → 삭제
   - **디렉토리 맵 불일치** → 루트 맵 갱신 (없는 파일 참조 제거, 누락 파일 등록)
3. 누적 섹션(Regression Log 등)이 5건을 초과하면 로테이션 제안
4. 수정 전 변경 요약을 사용자에게 보여주고 적용

**재감사 스코프**: lint 가 보고한 항목만 고친다. 규칙 내용을 다시 쓰거나, 보고되지 않은 계층을
재구조화하거나, 새 섹션을 발명하지 않는다 — 점검 요청은 재작성 요청이 아니다. 구조적 개편이
필요해 보이면 실행하지 말고 한 줄 제안으로 보고하고 사용자 판단에 맡긴다.

## 주의사항

1. **과도한 분산 금지**: 파일 3개 이하인 디렉토리에 CLAUDE.md를 만들지 않는다
2. **상속 원칙**: 상위 규칙을 하위에서 반복하지 않는다 (DRY)
3. **실용성 우선**: 형식보다 내용. 해당 디렉토리 작업 시 실제로 도움이 되는 정보만 넣는다
4. **PROGRESS.md는 별도**: 세션 연속성/진행 상황은 PROGRESS.md에, 규칙/구조는 CLAUDE.md에
5. **gitignore 체크**: 대상 instruction 파일이 .gitignore에 포함되어 있지 않은지 확인
6. **루트 비대 금지**: 루트는 상시 과금 — 누적 섹션은 로테이션, 배경 서사는 README/ADR로
7. **파일당 서브에이전트 팬아웃 금지**: 이 작업의 핵심 판단(계층 간 DRY 위반, 배치 휴리스틱,
   Directory Map 동기화)은 **전 계층을 한 컨텍스트에서 봐야** 성립한다. 파일별로 에이전트를
   쪼개면 각자 자기 파일만 보고 중복을 못 찾는다. 대상 파일 수집(`find`/Glob)까지가 위임 가능
   범위이고, 분석과 편집은 현재 세션에서 한다
