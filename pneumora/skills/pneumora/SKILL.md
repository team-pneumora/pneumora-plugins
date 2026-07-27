---
name: pneumora
description: Intentional project memory and regression-prevention workflows for Codex and Claude Code. Use when the user asks for CRITICAL notes, Regression Log review, regression recording, pre-push deploy checks, project memory, "pneumora critical", "pneumora log-regression", "pneumora check-deploy", or similar requests involving CLAUDE.md or AGENTS.md guardrails.
---

# Pneumora

## Dispatch

Map Claude slash-command style requests to Codex skill workflows:

- `critical`, `/pneumora:critical`, "CRITICAL 보여줘", "회귀 이력 확인": read `../../commands/critical.md`, then execute the same workflow.
- `log-regression`, `/pneumora:log-regression <증상>`, "회귀 기록해줘": read `../../commands/log-regression.md`, then execute the same workflow.
- `check-deploy`, `/pneumora:check-deploy`, "push 전 배포 체크": read `../../commands/check-deploy.md`, then execute the same workflow.

Load only the command file needed for the current request.

## Codex Adaptation

Support both instruction-file conventions:

- Claude Code projects usually use `CLAUDE.md`.
- Codex projects usually use `AGENTS.md`.
- If both exist on the path from the current directory to the git root, read both and preserve the source filename in output.
- If a workflow must write project memory, prefer the nearest existing `AGENTS.md` in Codex sessions, the nearest existing `CLAUDE.md` in Claude sessions, or ask the user when both are equally plausible.

When applying a command file that says `CLAUDE.md`, treat it as `CLAUDE.md or AGENTS.md` unless the user explicitly requested one filename.

## Deploy Gate Hook (Claude Code only)

- This plugin ships a `PreToolUse` hook (`hooks/check-deploy-gate.sh`) that automatically blocks `git push` while untracked `plugin.json` / `SKILL.md` / `.codex-plugin` paths exist (zombie-deploy prevention).
- The hook is mechanical enforcement of the same rule the `check-deploy` workflow re-reads; do not treat a hook block as an error — fix tracking (`git add` + commit) and retry.
- Codex does not run Claude Code hooks: in Codex sessions, run the `check-deploy` workflow manually before any push.

## Shared Rules

- Preserve extracted CRITICAL, Regression Log, and deploy text verbatim; do not summarize or rewrite it.
- Never run `git push`, `git commit`, deploy commands, or tests unless the user explicitly asks.
- For deploy checks, only read project memory and git/account status.
- For regression logging, ask at most two follow-up questions: affected area and prevention condition.
- Use the current date in `YYYY-MM-DD` format for new regression entries.
- Keep edits scoped to one chosen instruction file; do not duplicate the same regression across multiple files.
- Run these workflows in the current session. Do not spawn a subagent for them — each is a handful of reads plus one edit, and delegating costs more than doing it.
- **Report, do not repair.** These commands surface project memory and git state; they never fix what they find (no `git add` for untracked deploy files, no version-mismatch edits, no root-causing a logged regression). The user decides what to do with the report.
- Output only what the command file's format specifies. No preamble, no closing summary, no "let me know if you'd like me to…" offer.
