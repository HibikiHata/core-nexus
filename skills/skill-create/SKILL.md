---
name: skill-create
description: Interactively creates a new skill's SKILL.md following best practices. Use when creating a new skill, slash command, or reusable workflow definition.
disable-model-invocation: true
argument-hint: "[skill-name] [purpose]"
---

# Create a New Skill (skill-create)

Interactively generates a new skill's SKILL.md following best practices. Questions and reports to the user follow the language of the conversation; the generated skill definition itself is written in English (LLM-consumed context is most reliable in English).

## On Invocation

If `$ARGUMENTS` is provided, interpret it as the skill name and purpose.
If not, ask the user:

```
Tell me about the skill to create.
1. Skill name (command name): e.g. private-commit
2. Purpose: what should the skill do?
```

## Step 1: Decide the Frontmatter

Answer the following four questions to determine the frontmatter.

### Q1: Does it have side effects? → `disable-model-invocation: true`

Set `true` if any of these apply:
- Git operations (commit, push, PR/MR creation, branch operations)
- Database writes, updates, or deletions
- Sending to external services (Slack, email, external APIs)
- Creating, editing, or deleting files

If none apply, **omit the field** (the default lets Claude auto-apply the skill).

**Ripple effect — do NOT set `true` on a skill that other skills or agents depend on**: with `disable-model-invocation: true`, only the user can invoke the skill — Claude cannot call it via the Skill tool, and it cannot be preloaded into subagents via `skills:`. If such a skill must still be consumed by others, have them read its SKILL.md file and follow it instead.

### Q2: Does it take arguments? → `argument-hint`

If the skill takes arguments, set a hint. Examples:
- `argument-hint: "[topic]"`
- `argument-hint: "[product_id = value]"`
- `argument-hint: "[Issue URL]"`

### Q3: Is it background knowledge the user never calls via `/`? → `user-invocable: false`

Set only when the skill is background knowledge that Claude references but the user never invokes as a command.

### Q4: Is the argument used in the body? → `$ARGUMENTS`

If the skill takes arguments, reference `$ARGUMENTS` at the appropriate point in the SKILL.md body.

### Name constraints (Agent Skills spec)

- 1-64 characters; lowercase letters, numbers, and hyphens only
- Must not start or end with a hyphen; no consecutive hyphens (`--`)
- Must match the parent directory name

## Step 2: Write the description

Write the description by these rules:

- Start with a verb stating **what the skill does**, in the third person
- Include trigger keywords for **when to use it**
- Do NOT include redundant phrasing like "Use when the user runs /xxx"
  (that is controlled by `disable-model-invocation: true`, not the description)

**Good:**
```
Formats SQL queries: 2-space indent, leading commas in SELECT, line breaks at JOIN/ON/AND.
```

**Bad:**
```
Formats SQL queries. Use when the user runs /sql-format.
```

## Step 3: Structure the SKILL.md Body

Use this template as the base and adjust to the purpose:

```markdown
# {Skill Name}

{1-2 sentence overview}

## On Invocation

{Initial handling based on argument presence; if no argument, the question to ask the user}

## Workflow

{Concrete steps and instructions}

## Output Format

{Template for the result output}
```

**Size guideline**: keep SKILL.md within 500 lines. Move large reference material (query collections, API specs, etc.) into a `references/` directory and link it from SKILL.md, one level deep at most.

**Robustness for weaker models**: if the skill may run on a lighter model (e.g. Sonnet or Haiku), prefer:
- Inlined criteria over references to other skills or external documents
- Deterministic, mutually exclusive decision rules ("3 or fewer → X, 4 or more → Y") over judgment calls
- Exact output templates, with a warning not to output placeholder text (`{...}`) literally

## Step 4: Confirm and Create

Decide the destination scope (ask if unclear):

| Scope | Path | When |
|-------|------|------|
| User (default) | `~/.claude/skills/{skill-name}/SKILL.md` (or `$CLAUDE_CONFIG_DIR/skills/` when set) | General-purpose skills available in every project |
| Project | `.claude/skills/{skill-name}/SKILL.md` | Skills tied to one project's hooks/rules |

Show the generated SKILL.md to the user and confirm:

```
I will create SKILL.md with the following content.

Destination: {path}

{generated SKILL.md content}

Shall I proceed?
```

If the user approves:
1. Create the `{destination}/{skill-name}/` directory
2. Write SKILL.md

## Step 5: Post-Creation Checklist

After creation, verify and report:

- [ ] `name` follows the spec constraints and matches the directory name
- [ ] `description` contains trigger keywords, in the third person
- [ ] `description` has no redundant "when the user runs /xxx" phrasing
- [ ] `disable-model-invocation: true` is set if the skill has side effects
- [ ] `disable-model-invocation: true` is NOT set on a skill invoked by other skills/agents (Skill tool / `skills:` preload)
- [ ] `user-invocable: false` is set if the skill is background knowledge
- [ ] `argument-hint` is set if the skill takes arguments
- [ ] `$ARGUMENTS` is referenced in the body if arguments are used
- [ ] SKILL.md is within 500 lines
