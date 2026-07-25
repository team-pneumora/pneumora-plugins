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

Run `/reload-plugins` (or restart Claude Code) after installation and the skill loads.

### Updating

Installed plugins run from a cache under `~/.claude/plugins/cache/`, and **third-party marketplaces have auto-update disabled by default** — pushing a new version to this repository does not change what your session runs. To pick up a new version:

```
/plugin marketplace update pneumora-plugins
/reload-plugins
```

Verify with `ls ~/.claude/plugins/cache/pneumora-plugins/<plugin>/`. To make this automatic, run `/plugin` → **Marketplaces** tab → **Enable auto-update**.

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
| [`handoff`](./handoff) | Work-closeout automation — one trigger runs status capture, regression guard, harness lint, structured docs (sessions/decisions/regressions), and a `HANDOFF.md` entry point for the next worker |

> This table is updated whenever a new plugin is added.

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
