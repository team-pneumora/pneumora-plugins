---
description: 현재 프로젝트 CLAUDE.md의 CRITICAL 섹션과 Regression Log를 꺼내 각인한다
allowed-tools: Read, Glob, Bash(pwd), Bash(git rev-parse *)
---

# /pneumora:critical

현재 작업 중인 프로젝트에서 **"매 작업 전 반드시 확인해야 할 것들"**을 다시 읽는다.

## 실행 절차

### 1. 대상 CLAUDE.md 찾기

현재 작업 디렉토리(`pwd`)에서 시작해서 git 레포 루트까지 올라가며 `CLAUDE.md`를 찾는다.

```bash
pwd                              # 현재 위치 확인
git rev-parse --show-toplevel    # git 루트 확인 (없으면 에러 무시)
```

**탐색 규칙:**
1. 현재 디렉토리에 `CLAUDE.md` 있으면 그것부터 읽기 (가장 가까운 것 우선)
2. 상위 디렉토리로 올라가며 추가 `CLAUDE.md`가 있으면 함께 수집
3. git 루트까지만 탐색. git 레포가 아니면 현재 디렉토리만 확인
4. 발견된 모든 CLAUDE.md를 **루트부터 현재 위치 순서**로 정렬 (상속 순서 보존)

### 2. 섹션 추출

각 CLAUDE.md에서 다음 섹션을 추출한다:

- `## ⚠️ CRITICAL` (또는 유사 헤딩: `## CRITICAL`, `## Critical`, `## ⚠️ 주의`)
- `## 📋 Regression Log` (또는 유사: `## Regression Log`, `## 회귀 이력`)

섹션은 **헤딩부터 다음 `##` 헤딩 직전까지** 전체를 그대로 추출한다. 내용 수정·요약 금지.

### 3. CLAUDE.md가 없거나 섹션이 비어있는 경우

**CASE A: CLAUDE.md 자체가 없음**
출력:
⚠️ 이 프로젝트에 CLAUDE.md가 없습니다.
현재 경로: <pwd>
git 루트: <git root 또는 "git 레포 아님">
다음 중 하나를 하세요:

/claude-md-harness:구조화  (공식 audit my CLAUDE.md files로 갈 수도 있음)
루트에 CLAUDE.md를 만들고 /pneumora:log-regression으로 회귀 이력 쌓기 시작


**CASE B: CLAUDE.md는 있으나 CRITICAL/Regression Log 섹션이 없음**
출력:
ℹ️ 발견된 CLAUDE.md: <경로>
하지만 ## ⚠️ CRITICAL 또는 ## 📋 Regression Log 섹션이 없습니다.
지금부터 회귀/중요 사항이 발견될 때:

/pneumora:log-regression <증상> 으로 회귀 이력 쌓기
중요 정보는 CLAUDE.md 상단에 "## ⚠️ CRITICAL" 섹션을 만들어 수동 추가
(또는 # 단축키 활용)


**CASE C: 섹션은 있으나 실제 항목이 없음 (헤딩만 있고 빈 경우)**
헤딩만 출력하고 "아직 기록된 항목 없음" 안내.

### 4. 출력 포맷

섹션이 존재하면 **파일별로 묶어서** 아래 포맷으로 출력:
📌 <파일 경로 - git 루트로부터의 상대 경로>
⚠️ CRITICAL
<섹션 원문 그대로>
📋 Regression Log
<섹션 원문 그대로>


여러 CLAUDE.md가 발견되면 루트 → 하위 순서로 위 블록을 반복.

### 5. 마지막에 다짐 문구

모든 섹션 출력 후 마지막 줄에:
위 내용을 이번 세션 전체에서 준수합니다.

이 문구는 **Claude가 실제로 그 규칙을 시스템 프롬프트 레벨에 각인하기 위한 자기 지시**다.
사용자에게 하는 말이 아니라 Claude 자신에게 하는 확인이다.

## 금지 사항

- ❌ 섹션 내용 요약·재구성·번역
- ❌ "이 내용 중 중요한 것은..." 같은 메타 코멘트
- ❌ CLAUDE.md 수정 (이 커맨드는 **읽기 전용**)
- ❌ 발견되지 않은 섹션 내용을 추측해서 채우기
- ❌ 서브에이전트 호출 (가볍게 직접 수행)
