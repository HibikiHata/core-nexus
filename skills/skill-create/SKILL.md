---
name: skill-create
description: Interactively creates a new skill's SKILL.md following best practices. Use when creating a new skill, slash command, or reusable workflow definition.
disable-model-invocation: true
argument-hint: "[skill-name] [purpose]"
---

# Create a New Skill (skill-create)

Interactively generates a new skill's SKILL.md following best practices. Questions and reports to the user follow the language of the conversation; the generated skill definition itself is written in English (LLM-consumed context is most reliable in English).

## On Invocation

If `$ARGUMENTS` is provided, parse it as: first whitespace-delimited token = skill name, remainder = purpose. If only a name is given, ask for the purpose.
If no arguments, ask the user:

```
Tell me about the skill to create.
1. Skill name (command name): e.g. private-commit
2. Purpose: what should the skill do?
```

## Step 1: Decide the Frontmatter

Answer the following four questions to determine the frontmatter.

### Q1: Should the USER control when it runs? → `disable-model-invocation: true`

The test is timing, not side effects alone: set `true` when the workflow's effects should happen only at a moment the user chooses. Typical cases:
- Git operations that publish or finalize work (commit, push, PR/MR creation)
- Sending to external services (Slack, email, external APIs)
- Deployments and other irreversible or outward-facing actions

Creating or editing local files does NOT by itself require `true` — a skill that writes working files under the session's normal approval flow can stay model-invocable (e.g. a conventions skill that produces coordination documents).

If the user need not control timing, **omit the field** (the default lets Claude auto-apply the skill).

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
- `name` is optional. In a personal or project skill it is only the display label — the command comes from the directory name, so keep them identical to avoid confusion. In a plugin skill, `name` replaces the last segment of the command (`/plugin-name:<name>`)
- Do not reuse a bundled skill name (`code-review`, `debug`, `verify`, `run`, `loop`, `batch`, ...): a personal or project skill with that name replaces the bundled one. Check the `/` menu for collisions before deciding

### Additional frontmatter fields (set when applicable)

- `allowed-tools` — tools usable without approval prompts during the skill's turn (e.g. `Bash(git status *) Bash(git diff *)`). Big UX win for command skills that run many similar calls; scope it narrowly and leave dangerous commands out
- `when_to_use` — trigger phrases / example requests, appended to `description` in the skill listing. Combined `description` + `when_to_use` is truncated at 1,536 characters. Only meaningful for model-invocable skills
- `context: fork` — run the skill in a subagent (add `agent`/`background` as needed) when the work is heavy and its intermediate output would pollute the main context
- `paths` — auto-load the skill only when specific files are being touched

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

Use this template as the base and adjust to the purpose. **Every `{...}` below is a placeholder — replace all of them with real content; never output them literally in the generated file:**

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

**Robustness for weaker models** (authoring guidance for how YOU write the generated skill — not text to insert into it): if the skill may run on a lighter model (e.g. Sonnet or Haiku), prefer:
- Inlined criteria over references to other skills or external documents
- Deterministic, mutually exclusive decision rules ("3 or fewer → X, 4 or more → Y") over judgment calls
- Exact output templates, with a warning not to output placeholder text (`{...}`) literally

## Step 4: Confirm and Create

Decide the destination scope (ask if unclear):

| Scope | Path | When |
|-------|------|------|
| User (default) | `~/.claude/skills/{skill-name}/SKILL.md` (or `$CLAUDE_CONFIG_DIR/skills/` when set) | General-purpose skills available in every project |
| Project | `.claude/skills/{skill-name}/SKILL.md` | Skills tied to one project's hooks/rules |
| Plugin | `<plugin>/skills/{skill-name}/SKILL.md` | Skills distributed as part of a plugin (invoked as `/plugin-name:skill-name`) |

Before writing, check whether `{destination}/{skill-name}/SKILL.md` already exists. If it does, stop and ask the user whether to overwrite, rename, or abort — never overwrite silently.

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
- [ ] No literal `{...}` placeholders remain in the generated file

Then tell the user how the skill takes effect: personal and project skills are picked up live; plugin skills need `/reload-plugins`; a newly created top-level `skills/` directory needs a Claude Code restart. For plugin skills, suggest `claude plugin validate <plugin-path> --strict` (and `claude plugin eval` when eval cases exist) as the verification step.
