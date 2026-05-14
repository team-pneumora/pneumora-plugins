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

## Shared Rules

- Preserve extracted CRITICAL, Regression Log, and deploy text verbatim; do not summarize or rewrite it.
- Never run `git push`, `git commit`, deploy commands, or tests unless the user explicitly asks.
- For deploy checks, only read project memory and git/account status.
- For regression logging, ask at most two follow-up questions: affected area and prevention condition.
- Use the current date in `YYYY-MM-DD` format for new regression entries.
- Keep edits scoped to one chosen instruction file; do not duplicate the same regression across multiple files.
