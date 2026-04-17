---
description: push 전 배포 관련 CRITICAL 정보 재각인과 git 상태 체크
allowed-tools: Read, Glob, Bash(pwd), Bash(git rev-parse *), Bash(git status *), Bash(git branch *), Bash(git log *), Bash(git config *), Bash(git remote *)
---

# /pneumora:check-deploy

push 직전에 **배포 관련 정보를 다시 각인하고** git 상태를 체크한다.
실제 push는 하지 않는다 — 사용자가 명시적으로 쳐야 한다.

## 실행 절차

### 1. 대상 CLAUDE.md 탐색

현재 위치부터 git 루트까지 올라가며 `CLAUDE.md` 수집 (다른 커맨드와 동일 로직).

```bash
pwd
git rev-parse --show-toplevel
```

git 레포가 아니면:
⚠️ 여기는 git 레포가 아닙니다.
현재 경로: <pwd>
배포 체크는 git 레포에서만 의미가 있습니다.
안내 후 종료.

### 2. 배포 정보 추출

각 CLAUDE.md에서 다음 **우선순위**로 배포 정보를 찾는다:

**우선순위 1: `## 🚀 Deploy` 섹션 (또는 유사)**
- `## 🚀 Deploy`
- `## 🚀 Deploy Info`
- `## Deploy`
- `## Deployment`
- `## 배포`

섹션 존재 시 **전체를 그대로** 출력 대상으로.

**우선순위 2: CRITICAL 섹션에서 배포 키워드 필터링**
(Deploy 섹션이 없을 때 fallback)

`## ⚠️ CRITICAL` 섹션의 항목 중 다음 키워드 하나라도 포함한 라인만 추출:
- push, Push, PUSH
- deploy, Deploy, 배포
- vercel, Vercel
- railway, Railway
- ec2, EC2, hetzner, Hetzner
- github account, account, 계정
- 빌드, build, Build
- production, prod, 프로덕션

**우선순위 3: 둘 다 없음**
출력:
ℹ️ <파일 경로>에 배포 정보가 없습니다.
/pneumora:log-regression 말고도, 배포 관련 주의사항이 있으면
CLAUDE.md에 "## 🚀 Deploy" 섹션을 만들어 정리해두면 좋습니다.
(또는 CRITICAL 섹션에 push/deploy/vercel 등의 키워드를 포함해서 작성)

### 3. 배포 정보 출력

발견된 정보를 파일별로 묶어서 출력:
🚀 배포 정보
📌 <파일 경로>
<Deploy 섹션 전문 또는 필터링된 CRITICAL 라인들>


여러 CLAUDE.md에서 발견되면 루트 → 하위 순서로.

**원문 보존**: 수정·요약·재구성 금지. 발견된 내용 그대로.

### 4. Git 상태 체크 (필수)

다음 정보를 모두 출력한다:

```bash
# 현재 브랜치
git branch --show-current

# 미커밋 변경 (staged + unstaged + untracked)
git status --short

# remote와의 차이
git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null
# → "N\tM" 형식: N=ahead(local), M=behind(remote)
# upstream 없으면 조용히 스킵
```

출력 포맷:
📊 Git 상태
브랜치: <branch name>
변경사항:
<git status --short 결과 또는 "없음">
Remote와 차이:
↑ N commits ahead   (push 대기)
↓ M commits behind  (pull 필요)
(upstream 미설정 시: "upstream 없음")

### 5. Git 상태 체크 (선택 — Account Safety)

다음을 출력해 **계정/레포 착각을 방지**한다:

```bash
git config user.name
git config user.email
git remote -v
```

출력 포맷:
🔑 현재 Git 설정
Commit 작성자:
Name:  <user.name>
Email: <user.email>
Remote:
<remote -v 결과>

### 6. 마지막 확인 문구
────────────────────────────────────
위 정보를 확인했습니다.
push가 준비되면 직접 git push 명령을 실행하세요.
pneumora는 push를 자동으로 수행하지 않습니다.

### 7. 복수 CLAUDE.md 처리

harness 구조에서 루트·서브 둘 다 Deploy 섹션이 있으면 **둘 다** 출력.
둘 다 CRITICAL만 있으면 **둘 다** 필터링해서 출력.
한쪽만 있으면 있는 쪽만.

## 금지 사항

- ❌ `git push` 실행 (사용자가 직접)
- ❌ `git commit` 실행
- ❌ 배포 정보 수정·요약 (원문 그대로)
- ❌ 사용자 대신 빌드/테스트 실행
- ❌ CLAUDE.md 쓰기 (이 커맨드는 읽기 전용)
- ❌ "배포 가이드를 참고하세요" 같은 메타 코멘트 (정보만 전달)

## 사용 예시

사용자:
/pneumora:check-deploy

(Deploy 섹션이 없고 CRITICAL에 배포 관련 내용 있는 경우)

출력:
🚀 배포 정보
📌 CLAUDE.md (git 루트)
(⚠️ CRITICAL 섹션에서 추출)

GitHub push는 team-pneumora 계정으로. signo 개인 계정 아님.
Vercel 자동배포: mirror / translate / landing 3개가 각자 다른 Vercel 프로젝트.


📊 Git 상태
브랜치: main
변경사항:
M  innerwhis_app/lib/screens/home.dart
?? innerwhis_app/lib/screens/new_feature.dart
Remote와 차이:
↑ 2 commits ahead
🔑 현재 Git 설정
Commit 작성자:
Name:  mombin
Email: mombin@pneumora.com
Remote:
origin  https://github.com/team-pneumora/innerwhis.git (fetch)
origin  https://github.com/team-pneumora/innerwhis.git (push)
────────────────────────────────────
위 정보를 확인했습니다.
push가 준비되면 직접 git push 명령을 실행하세요.
pneumora는 push를 자동으로 수행하지 않습니다.
