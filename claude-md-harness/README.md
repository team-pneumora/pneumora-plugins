# claude-md-harness

CLAUDE.md를 객체지향(OOP) 하네스 구조로 분산시키는 Claude Code 플러그인.

## 왜 필요한가?

프로젝트가 커지면 하나의 CLAUDE.md에 모든 규칙을 담기 어렵습니다. 이 플러그인은 CLAUDE.md를 OOP 상속 모델처럼 계층적으로 분산합니다:

- **Root** (Base Class) — 프로젝트 소개, 글로벌 규칙, 디렉토리 맵
- **Module** (Abstract Class) — 아키텍처 개요, 공통 패턴
- **Leaf** (Concrete Class) — 구체적 구현 규칙, 제약사항

## 설치

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
claude plugin install claude-md-harness@pneumora-plugins
```

## 사용법

Claude Code에서 다음과 같이 요청하면 자동으로 트리거됩니다:

```
CLAUDE.md 하네스 구조로 쪼개줘
CLAUDE.md 분산시켜줘
디렉토리별 CLAUDE.md 만들어줘
```

## 핵심 원칙

1. **DRY** — 상위에 있는 내용을 하위에서 반복하지 않는다
2. **최소 단위** — 파일 3개 이하 디렉토리에는 CLAUDE.md를 만들지 않는다
3. **적정 크기** — Root 30~80줄, Module 20~60줄, Leaf 10~40줄
4. **실용성** — 빈 섹션은 만들지 않는다

## 라이선스

MIT

## Author

[Pneumora](https://github.com/pneumora)
