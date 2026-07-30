# core-nexus

Practical skills for everyday work with Claude Code — agent teams, skill authoring, semantic commits, and more.

## Install

In Claude Code:

```
/plugin marketplace add HibikiHata/core-nexus
/plugin install core-nexus@core-nexus-plugins
```

Then restart Claude Code so the skills are discovered.

## Skills

| Skill | What it does |
|---|---|
| **agent-teams** | Conventions for running a parallel team of subagents — when parallelizing actually pays, whiteboard coordination, spawn context, result files, and inter-agent messaging. Includes whiteboard and result templates. Note: teams write their coordination files into your repo (`docs/agent-teams/`, or `.claude/agent-teams/` when no `docs/` exists) |
| **skill-create** | Interactively authors a new `SKILL.md` following current best practices — frontmatter decisions, triggering description, progressive disclosure. Invoke with `/core-nexus:skill-create`. |
| **smart-commit** | Analyzes uncommitted changes, groups them by nature, and creates one semantic commit per group. Never pushes (`git push` is excluded from its allowed tools). Invoke with `/core-nexus:smart-commit`. |
| **localize-triggers** | Adds trigger phrasings in your language to this plugin's auto-invocable skills (via `when_to_use`), so they fire on requests you'd actually type. Invoke with `/core-nexus:localize-triggers [language]`. Re-run after plugin updates. |

`agent-teams` loads automatically when your request matches its description — phrasings like "run this as a parallel subagent team". The other skills are explicit commands, so they never fire unexpectedly.

## Usage

```
> Review this PR as a parallel agent team — code quality, security, and tests.
  (agent-teams conventions activate automatically)

> /core-nexus:skill-create sql-format "format SQL queries to our style"
  (walks you through frontmatter decisions and generates the SKILL.md)

> /core-nexus:smart-commit
  (groups your working tree into feat/fix/docs/chore commits — no push)
```

## Why agent-teams

Spawning four subagents is easy. Getting useful work out of them is not — they overwrite each other's files, duplicate research, and report findings the leader never integrates. This skill encodes the conventions that make a team produce more than the sum of its parts: task sizing, file ownership, a shared whiteboard as the single source of truth, and a wrap-up procedure.

It was written from running such teams, not from theory.

## Requirements

- [Claude Code](https://claude.com/claude-code) (recent version recommended — the skills rely on current frontmatter fields such as `when_to_use` and `allowed-tools`)

## License

MIT — see [LICENSE](LICENSE).
