---
name: write-a-skill
description: Create new agent skills with proper structure, progressive disclosure, and bundled resources. Use when user wants to create, write, or build a new skill. 한국어 트리거 — "새 skill 만들어줘", "스킬 작성", "SKILL.md 템플릿", "플러그인 저작 가이드".
---

> Adapted from [mattpocock/skills/write-a-skill](https://github.com/mattpocock/skills/tree/main/write-a-skill) (MIT). Body kept in English; Korean triggers added. **Pneumora Plugins conventions** appended at the bottom — read those before scaffolding inside this repo.

# Writing Skills

## Process

1. **Gather requirements** - ask user about:
   - What task/domain does the skill cover?
   - What specific use cases should it handle?
   - Does it need executable scripts or just instructions?
   - Any reference materials to include?

2. **Draft the skill** - create:
   - SKILL.md with concise instructions
   - Additional reference files if content exceeds 500 lines
   - Utility scripts if deterministic operations needed

3. **Review with user** - present draft and ask:
   - Does this cover your use cases?
   - Anything missing or unclear?
   - Should any section be more/less detailed?

## Skill Structure

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (if needed)
├── EXAMPLES.md        # Usage examples (if needed)
└── scripts/           # Utility scripts (if needed)
    └── helper.js
```

## SKILL.md Template

```md
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---

# Skill Name

## Quick start

[Minimal working example]

## Workflows

[Step-by-step processes with checklists for complex tasks]

## Advanced features

[Link to separate files: See [REFERENCE.md](REFERENCE.md)]
```

## Description Requirements

The description is **the only thing your agent sees** when deciding which skill to load. It's surfaced in the system prompt alongside all other installed skills. Your agent reads these descriptions and picks the relevant skill based on the user's request.

**Goal**: Give your agent just enough info to know:

1. What capability this skill provides
2. When/why to trigger it (specific keywords, contexts, file types)

**Format**:

- Max 1024 chars
- Write in third person
- First sentence: what it does
- Second sentence: "Use when [specific triggers]"

**Good example**:

```
Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

**Bad example**:

```
Helps with documents.
```

The bad example gives your agent no way to distinguish this from other document skills.

## When to Add Scripts

Add utility scripts when:

- Operation is deterministic (validation, formatting)
- Same code would be generated repeatedly
- Errors need explicit handling

Scripts save tokens and improve reliability vs generated code.

## When to Split Files

Split into separate files when:

- SKILL.md exceeds 100 lines
- Content has distinct domains (finance vs sales schemas)
- Advanced features are rarely needed

## Review Checklist

After drafting, verify:

- [ ] Description includes triggers ("Use when...")
- [ ] SKILL.md under 100 lines
- [ ] No time-sensitive info
- [ ] Consistent terminology
- [ ] Concrete examples included
- [ ] References one level deep

---

# Pneumora Plugins conventions

When authoring inside the **`team-pneumora/pneumora-plugins`** repo, follow these additions to Matt Pocock's general guidance.

## 1. Always scaffold with the helper script

Don't hand-create directories. Use:

```bash
scripts/new-plugin.sh <plugin-name> "<description>"
```

This creates dual manifests (`.claude-plugin/plugin.json` + `.codex-plugin/plugin.json`), a starter `skills/<plugin-name>/SKILL.md`, `agents/openai.yaml`, `README.md`, and registers the plugin in **both** `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`.

## 2. One plugin can hold multiple skills

The script generates `skills/<plugin-name>/SKILL.md` (a dispatcher). For multi-skill plugins, add additional skill directories alongside it:

```
my-plugin/
├── skills/
│   ├── my-plugin/SKILL.md           ← dispatcher (lists sub-skills)
│   ├── sub-skill-a/SKILL.md
│   └── sub-skill-b/SKILL.md
```

Each sub-skill has its own `name:` in frontmatter and is independently auto-loaded.

## 3. Hybrid Korean/English in SKILL.md

- **Frontmatter `description`** — include both English use-cases AND a `한국어 트리거 — "키워드1", "키워드2"` segment so auto-loading fires on Korean prompts.
- **Body** — English is fine for adapted upstream content, Korean for new Pneumora-specific sections.

## 4. Mandatory dual manifests

Every plugin must have both:
- `.claude-plugin/plugin.json` — Claude Code metadata
- `.codex-plugin/plugin.json` — Codex metadata (with `interface` block: `displayName`, `category`, `capabilities`, `defaultPrompt`)

The script bootstraps both. **Don't delete either** even if one platform isn't used yet.

## 5. Codex agent UI metadata

For each skill that should appear as a Codex agent, add:

```
skills/<skill>/agents/openai.yaml
```

with `interface.display_name`, `short_description`, `default_prompt`, and `policy.allow_implicit_invocation`. The script creates one for the dispatcher; replicate it for each sub-skill that needs Codex UI presence.

## 6. Attribution for adapted skills

When adapting an external skill (e.g. from `mattpocock/skills`), add a blockquote at the top of `SKILL.md`:

```markdown
> Adapted from [<author>/<repo>/<skill>](<url>) (MIT). Body kept in English; Korean triggers added.
```

## 7. Don't duplicate global commands

Before creating a skill, check `~/.claude/commands/` for overlap. Existing global slash commands include `/careful`, `/qa`, `/debug`, `/plan-review`, `/code-review`, `/retro`. If a new skill overlaps, **rename it** or merge its concepts into an existing plugin rather than creating a duplicate trigger.

## 8. Verification after authoring

Before committing:

```bash
# Validate all manifests
for p in */.claude-plugin/plugin.json */.codex-plugin/plugin.json; do jq . "$p" >/dev/null; done

# Confirm marketplace registration
jq '.plugins[].name' .claude-plugin/marketplace.json
jq '.plugins[].name' .agents/plugins/marketplace.json
```

Both marketplaces should list the new plugin name exactly once.
