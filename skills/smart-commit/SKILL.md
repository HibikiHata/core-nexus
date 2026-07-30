---
name: smart-commit
description: Analyzes uncommitted changes, groups them by nature, and creates one semantic commit per group — excluding files configured as never-commit. Never pushes. Triggers on "smart commit", "commit these changes in groups", "commit my work".
disable-model-invocation: true
---

# Smart Commit

Analyzes the working tree, splits changes into coherent groups, and creates one semantic commit per group. Never pushes.

## User Settings

The following items can be customized per project. On first run, confirm them with the user as needed.

### Excluded files (never `git add`)

- `.env`

### Diff-check exceptions (group by path only, without reading the diff)

None (default)

<!-- Examples:
- `logs/**` — log files have large diffs; judge by path only
- `docs/archives/**` — archives need no content review
-->

### Pre-commit checks (auto-stage if untracked or modified)

None (default)

### Additional rules

- Configuration changes (`chore`) and documentation updates (`docs`) go in separate commits. Exception: when a configuration change and its accompanying documentation belong to the same piece of work, they may be combined.

## Procedure

### A. When staged files exist

1. List staged files with `git diff --cached --name-only`
2. Commit exactly what is staged
3. Report the created commit (do not push)
4. **Stop here. Do not run procedure B.**

### B. When nothing is staged (default)

1. Get the list of modified and untracked files with `git status`
2. Remove the excluded files from the list
3. If any pre-commit check targets exist, stage them with `git add -f`
4. Review each remaining file's changes (`git diff` or read the content)
5. Group the files by the nature of the change (see criteria below)
6. For each group, run `git add` → `git commit` in sequence
7. Report the list of created commits (do not push)

## Grouping Criteria

| prefix | Examples |
|--------|----------|
| `feat` | New features, scripts, or modules |
| `fix` | Bug fixes |
| `chore` | Configuration files, dependencies, build settings |
| `docs` | Documentation, README, comments |
| `refactor` | Structural improvement of existing code (no behavior change) |
| `test` | Adding or fixing tests |

Changes sharing a prefix but **weakly related** go in separate commits.
Files on the same topic may share one commit.

## Commit Message Format

```
<prefix>: <concise description in English>

Co-Authored-By: Claude <model name> <noreply@anthropic.com>
```
