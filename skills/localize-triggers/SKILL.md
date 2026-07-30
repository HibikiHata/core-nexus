---
name: localize-triggers
description: Localizes the trigger phrases of this plugin's auto-invocable skills into another language by updating their when_to_use frontmatter, so they auto-trigger on phrasings in that language. English stays the canonical default.
disable-model-invocation: true
argument-hint: "[language]"
---

# Localize Skill Triggers

Adds trigger phrasings in the user's language to this plugin's skills so they auto-trigger on those phrasings. Skill bodies and descriptions stay in English; only the `when_to_use` frontmatter field changes.

## Scope — which skills this affects

Only skills WITHOUT `disable-model-invocation: true` benefit: for those, `description` + `when_to_use` sit in the model's context and drive auto-triggering. For user-invoked commands (`disable-model-invocation: true`) the description is never in context, so localization has no effect on triggering — skip them and tell the user why.

## On Invocation

If `$ARGUMENTS` is provided, treat it as the target language. Otherwise ask the user which language to localize into.

## Workflow

1. List this plugin's skills: read every SKILL.md under `${CLAUDE_SKILL_DIR}/../` (the parent of this skill's directory is the plugin's `skills/` directory). Skip this skill itself
2. Partition them: skills with `disable-model-invocation: true` are out of scope — list them as skipped in the final report, with the reason from the Scope section
3. For each in-scope skill, build its `when_to_use` value:
   - Keep `description` untouched — it is the canonical English definition
   - Write natural trigger phrasings in the target language, quoted — the phrases a native speaker would actually type when asking for this (e.g. for Japanese on agent-teams: 「エージェントチームで手分けして」「サブエージェントで並列に」)
   - If `when_to_use` already exists, REPLACE the entry for the target language and keep other languages' entries — never append duplicates. Re-running with the same language must produce the same result (idempotent)
4. Show the user a before/after comparison of each `when_to_use` and get approval
5. Apply the edits
6. Tell the user to run `/reload-plugins` (or restart Claude Code) so the changes take effect — plugin skills are not live-reloaded

## Constraints

- Edit only the `when_to_use` field. Never change `name`, `description`, other frontmatter fields, or the body
- Phrasings must be realistic user requests in that language, not literal translations of the English description
- Keep `description` + `when_to_use` combined under 1,536 characters per skill (the skill listing truncates beyond that)

## After a Plugin Update

Plugin updates overwrite these local edits (the plugin install directory is ephemeral by design). Re-run `/core-nexus:localize-triggers [language]` after updating the plugin to restore the localization.
