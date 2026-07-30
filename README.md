# core-nexus

Run parallel subagent teams that don't step on each other, author skills to best-practice spec, and make clean grouped semantic commits.

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
| **agent-teams** | Conventions for running a parallel team of subagents — when parallelizing actually pays, whiteboard coordination, spawn context, result files, and inter-agent messaging. Includes whiteboard and result templates. |
| **skill-create** | Interactively authors a new `SKILL.md` following current best practices — frontmatter, triggering description, progressive disclosure. Invoke with `/core-nexus:skill-create`. |
| **smart-commit** | Analyzes uncommitted changes, groups them by nature, and creates one semantic commit per group. Never pushes. Invoke with `/core-nexus:smart-commit`. |
| **translate** | Localizes the trigger descriptions of the skills above into your language, so they auto-trigger on phrasings you'd actually type. Invoke with `/core-nexus:translate [language]`. |

`agent-teams` loads automatically when your request matches its description — phrasings like "run this as a parallel subagent team". Descriptions ship in English; run `/core-nexus:translate` once to make them trigger in your language too. The other skills are explicit commands because they create files and commits.

## Usage

```
> Review this PR as a parallel agent team — code quality, security, and tests.
  (agent-teams conventions activate automatically)

> /core-nexus:skill-create sql-format "format SQL queries to our style"
  (walks you through frontmatter decisions and generates the SKILL.md)

> /core-nexus:smart-commit
  (groups your working tree into feat/fix/docs/chore commits — no push)

> /core-nexus:translate Japanese
  (skills now also trigger on e.g. 「エージェントチームで手分けして」)
```

## Why agent-teams

Spawning four subagents is easy. Getting useful work out of them is not — they overwrite each other's files, duplicate research, and report findings the leader never integrates. This skill encodes the conventions that make a team produce more than the sum of its parts: task sizing, file ownership, a shared whiteboard as the single source of truth, and a wrap-up procedure.

It was written from running such teams, not from theory.

## Requirements

- [Claude Code](https://claude.com/claude-code)

## License

MIT — see [LICENSE](LICENSE).
