---
name: claude-md-harness
description: CLAUDE.md 또는 AGENTS.md 파일을 객체지향적 하네스(harness) 구조로 분산시키는 스킬. "CLAUDE.md 쪼개줘", "AGENTS.md 쪼개줘", "하네스 구조로 만들어줘", "instruction 파일 분산", "CLAUDE.md 리팩토링", "AGENTS.md 정리", "프로젝트 instruction 구조화", "디렉토리별 CLAUDE.md/AGENTS.md" 등의 요청 시 반드시 이 스킬을 사용한다. 새 프로젝트 셋업 시 Claude Code 또는 Codex instruction 파일 초기 구조를 잡을 때도 사용한다.
---

# CLAUDE.md / AGENTS.md Harness — 객체지향 분산 구조화

## 대상 파일 선택

- Claude Code 맥락이면 `CLAUDE.md`를 대상으로 한다.
- Codex 맥락이면 `AGENTS.md`를 대상으로 한다.
- 사용자가 파일명을 명시하면 그 파일명을 따른다.
- 두 파일이 모두 있고 사용자가 "둘 다" 또는 "Claude와 Codex 호환"을 요청하면 같은 하네스 구조를 양쪽에 적용하되, 각 파일의 제품별 규칙은 섞지 않는다.
- 아래 절차에서 `CLAUDE.md`라고 적힌 부분은 선택된 대상 파일명으로 치환해서 적용한다.

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

## 실행 절차

### 1단계: 현재 상태 분석

```bash
# 기존 CLAUDE.md 확인
find . -name "CLAUDE.md" -not -path "*/node_modules/*" -not -path "*/.git/*" | sort

# 루트 CLAUDE.md 내용 확인
cat CLAUDE.md

# 프로젝트 구조 파악
find . -type d -maxdepth 3 -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/__pycache__/*" | sort
```

### 2단계: 분산 계획 수립

기존 CLAUDE.md의 내용을 분석하여 다음을 판단:

1. **글로벌 vs 로컬 분류**: 각 규칙/정보가 프로젝트 전체에 적용되는지, 특정 디렉토리에만 적용되는지
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

### 4단계: 루트 CLAUDE.md 업데이트

분산 완료 후 루트 CLAUDE.md를:
- 하위로 이동한 내용을 제거
- Directory Map 테이블 업데이트
- 글로벌 규칙만 남긴 간결한 형태로 정리

### 5단계: 검증

```bash
# 생성된 모든 CLAUDE.md 목록
find . -name "CLAUDE.md" -not -path "*/node_modules/*" | sort

# 각 파일의 라인 수 확인 (너무 길면 추가 분산 필요)
find . -name "CLAUDE.md" -not -path "*/node_modules/*" -exec sh -c 'echo "$(wc -l < "$1") $1"' _ {} \; | sort -rn
```

**적정 크기 가이드라인**:
- Root: 30~80줄
- Module (Level 1): 20~60줄
- Leaf (Level 2+): 10~40줄
- 80줄 초과 시 추가 분산 검토

## 주의사항

1. **과도한 분산 금지**: 파일 3개 이하인 디렉토리에 CLAUDE.md를 만들지 않는다
2. **상속 원칙**: 상위 규칙을 하위에서 반복하지 않는다 (DRY)
3. **실용성 우선**: 형식보다 내용. 해당 디렉토리 작업 시 실제로 도움이 되는 정보만 넣는다
4. **PROGRESS.md는 별도**: 세션 연속성/진행 상황은 PROGRESS.md에, 규칙/구조는 CLAUDE.md에
5. **gitignore 체크**: 대상 instruction 파일이 .gitignore에 포함되어 있지 않은지 확인
