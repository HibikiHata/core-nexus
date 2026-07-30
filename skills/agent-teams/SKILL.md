---
name: agent-teams
description: Conventions for running a parallel team of Claude subagents (leader + up to 4 teammates) — when to parallelize, whiteboard coordination, spawn context, result files, and coordination via SendMessage. Use when the user asks to run work as a parallel subagent team, e.g. "agent team", "parallel subagents", "fan out to subagents", "split this across subagents", "investigate/review in parallel". Also referenced by any other skill or workflow that spawns multiple subagents.
user-invocable: false
---

# Parallel Agent Team Conventions

Conventions for coordinating multiple subagents spawned via the Agent tool. In the current harness there is one implicit team per session: spawn teammates with the Agent tool (giving each a `name`), continue them with SendMessage, and let them run in the background by default.

> **Scope:** these are conventions for subagents spawned with the Agent tool, which work in any session. They are NOT the experimental built-in agent-teams feature (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, off by default), which adds a shared task list and an agent panel. When that feature is enabled, use its task list for coordination and this whiteboard for findings. If the harness exposes task-based tools instead of an `Agent` tool, adapt the tool names — the conventions still apply.

## When to Parallelize

> **Default: parallelize when there is room to.** If any part of the work can proceed independently, split it.

**Use a team (when in doubt, use one):**
- Reviews: multiple perspectives (code quality, security, performance, tests) in parallel
- Investigation: dig into code and data (DB) simultaneously
- New features: independent, non-interfering modules in parallel
- Debugging with competing hypotheses: test different theories in parallel
- Cross-layer work: frontend, backend, and tests at the same time

**Stay with a single agent (exceptions):**
- Strictly order-dependent tasks (each step needs the previous result)
- Unavoidable concurrent edits to the same file
- Small tasks a single agent finishes in a few minutes — team coordination overhead exceeds the benefit

> Decision rule: **"Is there at least one parallelizable part?"** If yes, use a team.

## Typical Parallel Patterns

### Reviews
| Task | Agent A | Agent B | Agent C |
|------|---------|---------|---------|
| Code review | Quality & design | Security & vulnerabilities | Tests & coverage |
| Feature-spec review | Code implementation | DB & data consistency | Business logic |
| Performance investigation | Queries & DB side | Application code side | — |

### Investigation & Debugging
| Task | Agent A | Agent B |
|------|---------|---------|
| Bug investigation | Trace the code logic | Check actual DB data |
| Spec investigation | Server-side implementation | DB schema & data |
| Error investigation | Stack-trace analysis | Related DB records |

## Team Size and Task Design

### Size
- **Cap: 4 working members** (5 including the leader)
- Beyond that, context consumption grows and returns diminish
- When a skill defines its own team structure, follow that skill

### Task size (per teammate)
- **Guideline: 5-6 tasks** each
- Too small: coordination cost exceeds the benefit
- Too large: long unsupervised runs increase wasted-effort risk
- Just right: self-contained units with a clear deliverable (a function, a test file, a review)

### Avoiding file conflicts
- Two teammates editing the same file **will overwrite each other**
- Split tasks so each teammate **owns a distinct file set**
- **The whiteboard is the one shared exception.** To keep it safe: the leader creates every member's section heading up front; each member edits ONLY its own section; on an Edit conflict (stale content), re-read the whiteboard and retry the edit

## Spawning Teammates

Teammates do NOT inherit the leader's conversation history. CLAUDE.md, MCP servers, and preloaded skills load automatically, but task-specific details must be in the spawn prompt.

- **Tool**: Agent tool with a `name` (e.g. `reviewer-a`) so the teammate is addressable via SendMessage
- **Type**: use a matching workflow agent when one exists; otherwise `subagent_type: "general-purpose"`
- **Model**: omit `model` to inherit the leader's model; override only deliberately (e.g. `sonnet` for lightweight mechanical tasks)
- **Permissions**: teammates inherit the leader's permission mode; per-teammate modes cannot be set at spawn (the Agent tool's `mode` input is deprecated and ignored). Pre-approve the tools the tasks will need before spawning — teammate permission prompts surface in the leader's session and stall the run until answered. Additionally, require skipped-call reporting in every spawn prompt (below): a denied or skipped call produces an empty result that can masquerade as a finding ("nothing found" vs "could not look")
- **No user prompts**: a background teammate has no AskUserQuestion tool. Instruct teammates to SendMessage the leader with their question and pause, rather than guessing
- **Background**: agents run in the background by default and their final message returns to the leader automatically on completion

**Mandatory element in every spawn prompt** (include verbatim, adjusting only the teammate name — do not drop it when paraphrasing the example):

```
End your report with a "skipped tool calls" list: every tool call that was
denied or skipped during your work, or "none". A missing list is treated as
a degraded result.
```

Example spawn prompt (replace `{whiteboard_path}` and every other placeholder with real values before sending — never send literal placeholders):

```
Review the authentication module at src/auth/ for security vulnerabilities.
Focus on token handling, session management, and input validation.
The app uses JWT tokens stored in httpOnly cookies.
Write findings to your section of the whiteboard at {whiteboard_path},
then reply with a summary and "done: security-reviewer".
End your report with a "skipped tool calls" list: every tool call that was
denied or skipped during your work, or "none". A missing list is treated as
a degraded result.
```

> **Context note:** a subagent's context window may be smaller than the leader's. Scope each teammate's task to stand alone, and keep large-context integration work at the leader.

## Whiteboard Rules

The leader creates a whiteboard immediately after kickoff, recording the mission, task list, and decisions.

| Item | Rule |
|------|------|
| Location | under `docs/agent-teams/whiteboards/` (version-controlled). If the project has no `docs/` convention, use `.claude/agent-teams/whiteboards/` instead — and always tell the user where team files were written |
| File name | `yyyyMMdd-whiteboard-<topic>.md` (e.g. `20260710-whiteboard-keyword-search-investigation.md`) |
| Template | [references/whiteboard-template.md](references/whiteboard-template.md) |
| Role | the team's single source of truth |

> Use the Glob tool (e.g. `docs/agent-teams/whiteboards/*.md`) rather than `Bash(ls ...)` to list whiteboards — Bash pipelines can trigger permission prompts.

- **Update rule**: whenever your work reaches a milestone or you make an important discovery (e.g. root cause identified), update your whiteboard section immediately
- **Start-of-work rule**: before starting work, and whenever you receive a SendMessage, re-read the whiteboard and consider the impact on your own scope
- **Information hub**: share technical detail (SQL results, stack traces) by writing it to the whiteboard and sending a short pointer message — not by pasting it into long messages

## Coordination (SendMessage)

- The leader sequences dependencies and lets members share and debate findings
- Members use SendMessage to request feedback from each other when needed
- **Direct message** to one teammate: the normal case. **Broadcast** to everyone: use sparingly (cost scales with team size) — only for changes affecting the whole team
- **Leader running ahead**: if the leader starts implementing before teammates finish, redirect it: "Wait for your teammates to complete their tasks before proceeding"
- **Monitoring**: check progress periodically and redirect approaches that are not working; long unattended runs waste effort

## RESULT File Rules

After all investigation completes, the leader writes the result report.

| Item | Rule |
|------|------|
| Location | under `docs/agent-teams/results/` (version-controlled; same fallback as the whiteboard: `.claude/agent-teams/results/` when the project has no `docs/`) |
| File name | `yyyyMMdd-result-<topic>.md` |
| Template | [references/result-template.md](references/result-template.md) |
| Author | the leader, after all work completes |
| Audience | engineers, by default |

- Sections marked "optional" in the template may be deleted when empty.
- After writing the RESULT file, the leader asks the user whether a non-engineer version is also wanted. If yes, create `yyyyMMdd-result-<topic>-non-engineer.md` with technical terms, code paths, and stack traces replaced by plain-language explanations.

## Wrap-up

Subagents end when their task completes — there is no explicit team teardown. Before finishing:

1. Confirm every teammate has reported (completion messages arrive automatically; SendMessage a teammate that appears stalled)
2. Integrate results from the whiteboard into the RESULT file
3. Report to the user in the language of the conversation

## Known Limitations

- **No resume across sessions**: `/resume` and `/rewind` do not restore running teammates. After resuming, spawn new teammates
- **Leader-only management**: teammates must not spawn their own sub-teams; only the leader manages the team
- **Permissions fixed at spawn**: teammates start with the mode given at spawn. To reduce prompts, pre-approve common operations before spawning
- **One implicit team per session**: finish and integrate the current effort before starting an unrelated parallel effort
