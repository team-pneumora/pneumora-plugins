# pneumora-plugins

> Claude Code plugin collection — the official marketplace maintained by [Pneumora](https://github.com/team-pneumora)

A [Claude Code plugin marketplace](https://docs.claude.com/en/docs/claude-code/plugins) that bundles Pneumora's productivity plugins. Register the marketplace once and you can install any plugin listed here with a single command.

---

## Quick Install

### 1. Register the marketplace

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

---

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [`claude-md-harness`](./claude-md-harness) | Distribute `CLAUDE.md` across your project in an OOP inheritance model (Root → Module → Leaf) |

> This table is updated whenever a new plugin is added.

---

## Marketplace Layout

This repository follows the Claude Code multi-plugin marketplace spec:

```
pneumora-plugins/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace metadata + plugin registry
├── claude-md-harness/             # Plugin 1
│   ├── .claude-plugin/
│   │   └── plugin.json            # Plugin metadata
│   ├── skills/
│   │   └── claude-md-harness/
│   │       └── SKILL.md           # Auto-triggered skill body
│   └── README.md
├── scripts/
│   └── new-plugin.sh              # Scaffolding script for new plugins
└── README.md                      # ← this file
```

Each plugin lives in its own directory with a local `.claude-plugin/plugin.json` and `skills/<name>/SKILL.md`.

---

## Adding a New Plugin (Contributors)

Run the scaffolding script from the repository root. It creates the required files and registers the plugin in `marketplace.json` automatically.

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
- Creates `<plugin-name>/skills/<plugin-name>/SKILL.md` from a TODO template
- Creates `<plugin-name>/README.md`
- Appends the new entry to `.claude-plugin/marketplace.json`
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
