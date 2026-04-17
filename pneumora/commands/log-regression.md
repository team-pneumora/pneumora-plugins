---
description: 발생한 회귀/재발 사례를 현재 프로젝트 CLAUDE.md의 Regression Log에 기록한다
argument-hint: <회귀 증상 한 줄>
allowed-tools: Read, Edit, Write, Glob, Bash(pwd), Bash(git rev-parse *)
---

# /pneumora:log-regression

한 번 겪은 회귀/재발 사례를 현재 프로젝트의 `## 📋 Regression Log` 섹션에 누적 기록한다.
**같은 실수를 두 번 하지 않기 위한 장치**다.

## Input
사용자가 전달한 증상: $ARGUMENTS

## 실행 절차

### 1. $ARGUMENTS 검증

비어있으면:
사용법: /pneumora:log-regression <회귀 증상을 한 줄로>
예: /pneumora:log-regression 구글 로그인 고친 후 다른 작업 수정하니 또 깨짐
안내 후 종료.

### 2. 추가 정보 수집

사용자에게 **두 가지만** 물어본다 (3개 이상 묻지 않음 — 피로도 관리):
📋 회귀 기록을 위해 두 가지 확인할게요.

영향받는 영역은 어디인가요? (파일 경로, 디렉토리, 또는 모듈 이름)
예: innerwhis_app/lib/providers/auth_provider.dart
또는 "SignalScreen, StockDetailScreen"
또는 "모름" (증상만 기록하고 영향 범위는 비워둠)
재발 방지 조건은? (어떤 상황에서 이 회귀가 다시 터질 수 있는지)
예: "인증 관련 파일 수정 시 로그인 플로우 수동 테스트 필수"
또는 "차트 종목 변경 시 ref.invalidate 호출 여부 확인"
또는 "모름" (원인 규명 안 됨, 증상만 기록)


답을 받으면 다음 단계로.

### 3. 대상 CLAUDE.md 선택

**/pneumora:critical과 동일한 탐색 로직**으로 가장 가까운 CLAUDE.md를 찾는다:

```bash
pwd
git rev-parse --show-toplevel
```

현재 디렉토리부터 git 루트까지 올라가며 CLAUDE.md 수집.

**CASE 1: 발견된 CLAUDE.md가 1개**
바로 그 파일에 기록.

**CASE 2: 여러 개 발견 (harness 구조)**
사용자에게 묻는다:
발견된 CLAUDE.md:
(a) <루트 경로>
(b) <현재 위치 경로>
어디에 기록할까요? (a/b)
기본값 (엔터): 가장 가까운 것 = (b)

**CASE 3: CLAUDE.md가 없음**
⚠️ 이 프로젝트에 CLAUDE.md가 없습니다.
어떻게 할까요?
(a) 현재 디렉토리에 CLAUDE.md 만들고 기록
(b) git 루트에 CLAUDE.md 만들고 기록
(c) 취소

### 4. 엔트리 포맷팅

다음 3줄 포맷으로 작성:

[YYYY-MM-DD] <$ARGUMENTS 원문 그대로>
영향: <영향 범위>
재발 방지: <재발 방지 조건>


**원칙:**
- `$ARGUMENTS` 원문을 수정·요약·교정하지 않는다
- 사용자가 "모름"이라 답한 항목은 그 줄을 **생략**한다 (빈 줄로 두지 않음)
- 영향/재발 방지가 둘 다 "모름"이면 첫 줄(증상)만 기록

### 5. Regression Log 섹션 처리

**CASE A: `## 📋 Regression Log` 섹션 존재**
- 섹션 내 마지막 항목 아래 (다음 `##` 헤딩 직전)에 새 엔트리 추가
- 기존 항목들 순서 보존 (시간순 누적)

**CASE B: 섹션 없음**
- 파일에서 `## ⚠️ CRITICAL` 섹션 존재 여부 확인
- CRITICAL 있으면 → CRITICAL 섹션 바로 다음에 Regression Log 섹션 신설
- CRITICAL 없으면 → 파일 맨 위 (`# <제목>` 바로 아래)에 Regression Log 섹션 신설

섹션 생성 시 헤딩:
```markdown

## 📋 Regression Log
<!-- /pneumora:log-regression 명령어로 누적. 한 번 겪은 문제는 다시 겪지 않는다. -->

- [YYYY-MM-DD] ...
```

### 6. 중복 방지

같은 Regression Log 섹션에 **$ARGUMENTS와 동일한 증상 라인**이 이미 있는지 확인.
있으면:
⚠️ 유사한 회귀가 이미 기록되어 있습니다:
<기존 항목>
추가로 기록할까요? (y/n)
사용자가 `y` 하면 그래도 추가 (재발이 또 일어난 것일 수 있음), `n`이면 종료.

### 7. 완료 보고
✅ 기록됨: <파일 경로>

[YYYY-MM-DD] <증상>
영향: ...
재발 방지: ...

현재 Regression Log 항목: N개

간결하게. 장황한 축하 멘트 없음.

## 날짜 포맷

오늘 날짜를 `YYYY-MM-DD` 형식으로 사용.

## 금지 사항

- ❌ $ARGUMENTS 원문 수정 (교정·요약·재구성 금지)
- ❌ 사용자에게 3개 이상 질문하기
- ❌ 같은 증상을 여러 CLAUDE.md에 동시 기록 (한 곳만 선택)
- ❌ 자동 커밋 (수동 검토 후 사용자가 커밋)
- ❌ "회귀를 기록해주셔서 감사합니다" 같은 불필요한 친절
- ❌ Regression Log 기존 항목 순서 바꾸기

## 사용 예시

사용자:
/pneumora:log-regression 구글 로그인 고친 후 다른 작업 수정하니 또 깨짐

Claude:
📋 회귀 기록을 위해 두 가지 확인할게요.

영향받는 영역은 어디인가요?
재발 방지 조건은?


사용자:

innerwhis_app/lib/providers/auth_provider.dart
인증 관련 파일 수정 시 로그인 플로우 수동 테스트 필수


Claude:
발견된 CLAUDE.md:
(a) C:/.../InnerWhis/projects/CLAUDE.md (git 루트)
(b) C:/.../InnerWhis/projects/innerwhis_app/CLAUDE.md (현재 위치)
어디에 기록할까요? (a/b)  기본값: b

사용자: `a`

Claude → 루트 CLAUDE.md에 기록:
✅ 기록됨: CLAUDE.md (git 루트)

[2026-04-17] 구글 로그인 고친 후 다른 작업 수정하니 또 깨짐
영향: innerwhis_app/lib/providers/auth_provider.dart
재발 방지: 인증 관련 파일 수정 시 로그인 플로우 수동 테스트 필수

현재 Regression Log 항목: 2개
