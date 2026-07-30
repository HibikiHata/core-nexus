---
name: smart-commit
description: Analyzes uncommitted changes, groups them by nature, and creates one semantic commit per group — excluding files configured as never-commit. Never pushes.
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git diff *) Bash(git log *) Bash(git add *) Bash(git commit *)
---

# Smart Commit

Analyzes the working tree, splits changes into coherent groups, and creates one semantic commit per group. Never pushes — `git push` is deliberately absent from `allowed-tools`.

## Preconditions (check before anything else)

1. Not a git repository (`git rev-parse --git-dir` fails) → stop and report
2. Nothing to commit (clean tree, nothing staged) → report that and stop; never create an empty commit
3. Unmerged/conflicted paths in `git status` → stop and report; never commit a half-resolved merge
4. Detached HEAD → tell the user and get confirmation before committing
5. If a pre-commit hook fails during any commit: fix the reported problem and retry. Never use `--no-verify`

## User Settings

Read `.claude/smart-commit.local.md` in the project root if it exists and use its settings; otherwise use the defaults below. When the user wants to customize, offer to create that file. Never edit this SKILL.md to store settings — it lives in the plugin install directory and is overwritten on every plugin update.

### Excluded files (never `git add`)

- `.env`, `.env.*`, `.envrc`
- `*.pem`, `*.key`, `*_rsa`
- `**/credentials*`

### Diff-check exceptions (group by path only, without reading the diff)

None (default)

<!-- Example:
- `logs/**` — log files have large diffs; judge by path only
-->

### Pre-commit checks (auto-stage if untracked or modified)

None (default)

**Safety rule**: if a pre-commit check target matches the excluded-files list, stop and report instead of staging it. Never pass `git add -f` for a path matching the excluded-files list — `-f` bypasses .gitignore.

### Additional rules

- Configuration changes (`chore`) and documentation updates (`docs`) go in separate commits. Exception: when a configuration change and its accompanying documentation belong to the same piece of work, they may be combined.

## Procedure

### A. When staged files exist

Manual staging is the user's intentional commit unit — respect it. Do NOT regroup or split what is staged.

1. List staged files with `git diff --cached --name-only`
2. Read the staged diff (`git diff --cached`) to choose the semantic prefix and write the message
3. Commit exactly what is staged, as one commit
4. Report the created commit (do not push)
5. **Stop here. Do not run procedure B.**

### B. When nothing is staged (default)

1. Get the list of modified and untracked files with `git status`
2. Remove the excluded files from the list
3. If any pre-commit check targets exist, stage them (subject to the safety rule above)
4. Review each remaining file's changes (`git diff` or read the content)
5. Group the files by the nature of the change (criteria below)
6. For each group, run `git add <explicit paths>` → `git commit` in sequence
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

Two files belong in the same commit only when BOTH hold:

1. They take the same prefix
2. A reviewer reading the commit message would expect every file in the diff (same feature, same fix, same topic)

When in doubt, split — small commits are cheaper to combine later than mixed commits are to untangle.

## Commit Message Format

First check the repository's convention with `git log -20 --format=%s` (language, prefix style, scope usage) and match it. When no clear convention exists, use:

```
<prefix>: <concise description>

Co-Authored-By: Claude <noreply@anthropic.com>
```

Write the description in the repository's dominant commit-message language. Output the `Co-Authored-By` line exactly as shown above — do not insert a model name in angle brackets (git parses the first `<...>` as the email address and the real address would be lost).
