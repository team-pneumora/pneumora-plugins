# pneumora-plugins

> Claude Code 플러그인 모음 — [Pneumora](https://github.com/team-pneumora)에서 운영하는 공식 마켓플레이스

Claude Code CLI의 [플러그인 마켓플레이스](https://docs.claude.com/en/docs/claude-code/plugins) 형식으로 배포되며, 한 번 등록하면 여기 있는 모든 플러그인을 손쉽게 설치할 수 있습니다.

---

## 빠른 설치

### 1. 마켓플레이스 등록

Claude Code CLI에서 한 번만 실행하면 됩니다:

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
```

### 2. 플러그인 설치

```bash
claude plugin install <plugin-name>@pneumora-plugins
```

예시:

```bash
claude plugin install claude-md-harness@pneumora-plugins
```

설치 후 Claude Code를 재시작하면 스킬이 자동으로 로드됩니다.

---

## 수록된 플러그인

| 플러그인 | 설명 |
|---------|-----|
| [`claude-md-harness`](./claude-md-harness) | CLAUDE.md를 OOP 상속 구조(Root → Module → Leaf)로 계층 분산시키는 스킬 |

> 새 플러그인이 추가되면 이 테이블도 같이 업데이트됩니다.

---

## 마켓플레이스 구조

이 저장소는 Claude Code 멀티-플러그인 마켓플레이스 규격을 따릅니다:

```
pneumora-plugins/
├── .claude-plugin/
│   └── marketplace.json          # 마켓플레이스 메타데이터 + 플러그인 목록
├── claude-md-harness/             # 플러그인 1
│   ├── .claude-plugin/
│   │   └── plugin.json            # 플러그인 메타데이터
│   ├── skills/
│   │   └── claude-md-harness/
│   │       └── SKILL.md           # 자동 트리거되는 스킬 본체
│   └── README.md
├── scripts/
│   └── new-plugin.sh              # 새 플러그인 스캐폴딩 스크립트
└── README.md                      # ← 이 파일
```

각 플러그인은 독립적인 디렉토리를 가지며, 내부에 `.claude-plugin/plugin.json`과 `skills/<name>/SKILL.md`를 둡니다.

---

## 새 플러그인 추가하기 (기여자용)

저장소 루트에서 스캐폴딩 스크립트를 실행하면 필요한 파일들이 자동 생성되고 `marketplace.json`에도 등록됩니다.

```bash
bash scripts/new-plugin.sh <plugin-name> "플러그인 한 줄 설명"
```

예시:

```bash
bash scripts/new-plugin.sh my-cool-skill "내 멋진 스킬에 대한 설명"
```

실행 후:

1. `<plugin-name>/skills/<plugin-name>/SKILL.md` 의 TODO 항목을 실제 스킬 내용으로 채웁니다
2. `<plugin-name>/README.md` 를 업데이트합니다
3. 루트 `README.md` 의 "수록된 플러그인" 테이블에 새 항목을 추가합니다
4. 커밋 & 푸시

### 스크립트가 하는 일

- kebab-case 이름 검증
- `<plugin-name>/.claude-plugin/plugin.json` 생성 (Pneumora 기본 메타데이터)
- `<plugin-name>/skills/<plugin-name>/SKILL.md` 생성 (TODO 템플릿)
- `<plugin-name>/README.md` 생성
- `.claude-plugin/marketplace.json` 의 `plugins` 배열에 신규 항목 자동 등록
- 중복 이름은 거부하고 에러 출력

---

## 개발 원칙

1. **스킬 트리거 description을 구체적으로 작성한다** — 자동 로드 정확도가 여기서 결정됩니다
2. **DRY** — 상위에 있는 내용은 하위 플러그인/스킬에서 반복하지 않습니다
3. **의미 있는 버전 관리** — `plugin.json` 의 `version` 은 semver를 따릅니다
4. **한국어 문서 우선, 영어 코드** — Pneumora 전체 규칙과 일치

---

## 라이선스

MIT © [Pneumora](https://github.com/team-pneumora)
