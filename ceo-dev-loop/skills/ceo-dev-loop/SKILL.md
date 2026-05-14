---
name: ceo-dev-loop
description: Goal-driven CEO-Dev workflow for Codex and Claude Code. Use when the user asks to initialize, start, continue, or inspect a CEO-Dev loop; mentions /ceo-dev-loop:init, /ceo-dev-loop:start, /ceo-dev-loop:status, GOAL.md, STATUS.md, DECISIONS.md, autonomous coding loops, or a CEO/PM review loop for implementation work.
---

# CEO Dev Loop

## Dispatch

Map Claude slash-command style requests to Codex skill workflows:

- `init`, `/ceo-dev-loop:init <goal>`, "CEO-Dev 루프 초기화": read `../../commands/init.md` and `../../agents/ceo.md`, then create or update the loop files.
- `start`, `/ceo-dev-loop:start`, "루프 계속 진행": read `../../commands/start.md` and `../../agents/ceo.md`, then continue from `docs/GOAL.md`, `docs/STATUS.md`, and `docs/DECISIONS.md`.
- `status`, `/ceo-dev-loop:status`, "루프 상태 보여줘": read `../../commands/status.md`, then summarize the current loop state.

Load only the command files needed for the current request plus `../../agents/ceo.md` when CEO judgment rules are needed.

## Codex Adaptation

This plugin was originally written for Claude Code slash commands and `@ceo` agents. In Codex:

- Treat slash-command requests as natural-language skill invocations.
- Write Codex loop rules to `AGENTS.md`; if the project already uses `CLAUDE.md` or the user asks for Claude compatibility, also keep `CLAUDE.md` in sync.
- Use `docs/GOAL.md`, `docs/STATUS.md`, and `docs/DECISIONS.md` as the source of truth for handoff state.
- Apply the CEO review criteria from `../../agents/ceo.md` in-process unless the user explicitly asks for sub-agents or delegation.
- If the user explicitly asks for a CEO subagent and the environment supports it, pass only the project loop files and the CEO role file needed for that review.

## Execution Rules

- During `init`, classify the project as A/B/C/D using the command file, gather concise context, then write the loop docs.
- Do not ask for confirmation except for the safety cases in the command file: overwriting an existing `docs/GOAL.md` or genuinely missing information.
- During `start`, read GOAL -> STATUS -> DECISIONS before changing code.
- After each meaningful work unit, update `docs/STATUS.md` and record durable decisions in `docs/DECISIONS.md`.
- `[DONE]` requires all required checkboxes and DoD items to be satisfied; phase or milestone completion is not enough.
- If context refresh is needed, update STATUS/DECISIONS first, then ask the user for the one required `/compact` or `/clear` input.
