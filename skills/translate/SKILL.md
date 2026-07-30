---
name: translate
description: Localizes the trigger descriptions of installed core-nexus skills into another language, so they auto-trigger on phrasings in that language. English stays the canonical default.
disable-model-invocation: true
argument-hint: "[language]"
---

# Localize Skill Triggers (translate)

Rewrites the `description` frontmatter of this plugin's skills so they also trigger on phrasings in the user's language. Skill bodies stay in English; only trigger descriptions are localized.

## On Invocation

If `$ARGUMENTS` is provided, treat it as the target language. Otherwise ask the user which language to localize into.

## Workflow

1. List this plugin's skills: read every `${CLAUDE_PLUGIN_ROOT}/skills/*/SKILL.md` (skip this skill itself)
2. For each skill:
   - Keep the existing English description unchanged as the canonical base
   - Append natural trigger phrasings in the target language — the phrases a native speaker would actually type when asking for this, quoted (e.g. for Japanese on agent-teams: 「エージェントチームで手分けして」「サブエージェントで並列に」)
   - Do not translate any other frontmatter field or the body
3. Show the user a before/after comparison of every description and get approval
4. Apply the edits

## Constraints

- Edit only the `description` field. Never change `name`, other frontmatter fields, or the body
- Appended phrases must be realistic user phrasings in that language, not literal translations of the English description
- Keep each description under ~1024 characters

## After a Plugin Update

Plugin updates overwrite these local edits. Re-run `/core-nexus:translate [language]` after updating the plugin to restore the localization.
