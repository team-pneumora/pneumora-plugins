# pneumora-plugins

> Claude Code and Codex plugin collection — the official marketplace maintained by [Pneumora](https://github.com/team-pneumora)

A dual-compatible plugin marketplace that bundles Pneumora's productivity plugins. Claude Code reads the `.claude-plugin/` metadata, and Codex reads the `.agents/plugins/marketplace.json` plus each plugin's `.codex-plugin/plugin.json`.

---

## Quick Install

### Claude Code

Run this once in Claude Code CLI:

```bash
claude plugin marketplace add team-pneumora/pneumora-plugins
```

### 2. Install a plugin

```bash
claude plugin install <plugin-name>@pneumora-plugins
```

Example:

```bash
claude plugin install claude-md-harness@pneumora-plugins
```

Restart Claude Code after installation and the skill will load automatically.

### Codex

This repository includes Codex-compatible plugin metadata:

- Marketplace: `.agents/plugins/marketplace.json`
- Plugin manifests: `<plugin-name>/.codex-plugin/plugin.json`
- Skills: `<plugin-name>/skills/<skill-name>/SKILL.md`

Add or import this repository as a local Codex plugin marketplace, then install one of the plugin entries from the `pneumora-plugins` marketplace. If your Codex environment only supports direct skills, copy the desired `<plugin-name>/skills/<name>/` folder into `$CODEX_HOME/skills/`.

---

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [`claude-md-harness`](./claude-md-harness) | Distribute `CLAUDE.md` or `AGENTS.md` across your project in an OOP inheritance model (Root → Module → Leaf) |
| [`pneumora`](./pneumora) | Intentional memory & regression-prevention workflow — CRITICAL section, regression log, deploy guard, exploration workflow |
| [`ceo-dev-loop`](./ceo-dev-loop) | Goal-driven automation loop — Dev implements, CEO/PM review criteria guide checkpoints until the goal is met |
| [`dev-discipline`](./dev-discipline) | TDD red-green-refactor (vertical slices), architecture deepening, micro-commit refactor planning. Adapted from `mattpocock/skills` (MIT) |
| [`domain-language`](./domain-language) | DDD ubiquitous-language glossary, domain-model interview that updates `CONTEXT.md`/ADRs inline, plan grilling, zoom-out. Adapted from `mattpocock/skills` (MIT) |
| [`comm-modes`](./comm-modes) | Caveman terse mode (~75% token saving) + skill-authoring meta with Pneumora conventions. Adapted from `mattpocock/skills` (MIT) |
| [`gh-flow`](./gh-flow) | GitHub-issue-driven workflow — PRD synthesis, plan-to-issues breakdown, TDD-plan triage, label-based state-machine triage, conversational QA-to-issues. Requires `gh` CLI. Adapted from `mattpocock/skills` (MIT) |

> This table is updated whenever a new plugin is added.

---

## Credits / 출처

`dev-discipline`, `domain-language`, `comm-modes`, `gh-flow` 4개 플러그인은 [**mattpocock/skills**](https://github.com/mattpocock/skills) (MIT, 원저자 [Matt Pocock](https://github.com/mattpocock)) 의 14개 skill을 적응한 derivative work 입니다.

- **원본 저장소**: https://github.com/mattpocock/skills
- **임포트 시점 commit**: [`90ea8ee`](https://github.com/mattpocock/skills/tree/90ea8ee) (2026-04-26)
- **라이선스**: MIT (원본·적응본 동일)
- **각 SKILL.md** 상단 blockquote에 개별 출처 링크 보존

### Pneumora 측 적응 사항

| 항목 | 내용 |
|---|---|
| Frontmatter | `description`에 한국어 트리거 키워드 추가 (하이브리드 한·영 자동 로드) |
| 로컬 파일 변형 | `request-refactor-plan` → GH issue 대신 로컬 `REFACTOR-PLAN.md` 작성 |
| 전제조건 가드 | `gh-flow/*` sub-skill — `git remote -v`로 GitHub remote 검증 |
| 트리거 충돌 회피 | Matt의 `qa` → `qa-to-issue`로 리네임 (사용자의 글로벌 `/qa`와 분리) |
| 컨벤션 부가 | `write-a-skill` 본문에 Pneumora 플러그인 저작 컨벤션 섹션 append |
| 듀얼 매니페스트 | `.claude-plugin/plugin.json` + `.codex-plugin/plugin.json` 양쪽 제공 |

### 채택·스킵 결정

22개 원본 중 **14개 채택** / **8개 스킵**.

스킵 사유:
- `git-guardrails-claude-code` — 사용자의 글로벌 `/careful` 슬래시 커맨드가 상위호환(rm -rf, DROP TABLE, docker, prisma reset 등 광범위 가드)
- `migrate-to-shoehorn`, `scaffold-exercises`, `obsidian-vault`, `setup-pre-commit`, `edit-article`, `design-an-interface` — 도메인이 너무 좁거나 우리 스택과 불일치

원본 skill 전체 목록은 [mattpocock/skills 저장소 README](https://github.com/mattpocock/skills#readme) 참고.

---

## Marketplace Layout

This repository follows both Claude Code and Codex marketplace layouts:

```
pneumora-plugins/
├── .claude-plugin/
│   └── marketplace.json          # Claude Code marketplace metadata + plugin registry
├── .agents/
│   └── plugins/
│       └── marketplace.json      # Codex marketplace metadata + plugin registry
├── claude-md-harness/             # Plugin 1
│   ├── .claude-plugin/
│   │   └── plugin.json            # Claude Code plugin metadata
│   ├── .codex-plugin/
│   │   └── plugin.json            # Codex plugin metadata
│   ├── skills/
│   │   └── claude-md-harness/
│   │       └── SKILL.md           # Auto-triggered skill body
│   └── README.md
├── scripts/
│   └── new-plugin.sh              # Scaffolding script for new plugins
└── README.md                      # ← this file
```

Each plugin lives in its own directory with both `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`. Shared skills live under `skills/<name>/SKILL.md`.

---

## Adding a New Plugin (Contributors)

Run the scaffolding script from the repository root. It creates the required Claude Code and Codex files and registers the plugin in both marketplace files automatically.

```bash
bash scripts/new-plugin.sh <plugin-name> "One-line plugin description"
```

Example:

```bash
bash scripts/new-plugin.sh my-cool-skill "Description of my cool skill"
```

After running:

1. Fill in the `TODO` sections in `<plugin-name>/skills/<plugin-name>/SKILL.md` with the actual skill content
2. Update `<plugin-name>/README.md`
3. Add a row to the "Available Plugins" table in the root `README.md`
4. Commit & push

### What the script does

- Validates the plugin name (kebab-case)
- Creates `<plugin-name>/.claude-plugin/plugin.json` with default Pneumora metadata
- Creates `<plugin-name>/.codex-plugin/plugin.json` with Codex metadata and interface fields
- Creates `<plugin-name>/skills/<plugin-name>/SKILL.md` from a TODO template
- Creates `<plugin-name>/README.md`
- Appends the new entry to `.claude-plugin/marketplace.json`
- Appends the new entry to `.agents/plugins/marketplace.json`
- Rejects duplicate plugin names with a clear error

---

## Development Principles

1. **Write specific skill trigger descriptions** — auto-load accuracy depends on this
2. **DRY** — don't repeat in sub-plugins what's already stated at a higher level
3. **Meaningful versioning** — `version` in `plugin.json` follows semver
4. **Korean docs first, English code** — consistent with Pneumora's overall conventions

---

## License

MIT © [Pneumora](https://github.com/team-pneumora)
