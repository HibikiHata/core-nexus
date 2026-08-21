# Security Policy

## Reporting a vulnerability

Report privately through GitHub's [Security Advisories](https://github.com/HibikiHata/core-nexus/security/advisories/new).
Please do not open a public issue for a security problem.

Expect an initial response within a week.

## What this project touches

This repository is a Claude Code plugin marketplace: Markdown skill definitions
and JSON manifests. Knowing the boundaries helps judge whether something is a
security problem here.

- **No executable code.** There are no scripts or binaries, and nothing runs at
  install time. Installation is Claude Code fetching these files.
- **Skills are instructions.** They direct Claude Code's behaviour inside the
  user's session, under the user's permission settings. A security problem in
  this repository looks like an instruction that would push Claude toward
  harmful, deceptive, or destructive actions — for example exfiltrating data,
  weakening the user's approval gates, or running destructive commands. Report
  anything of that shape, including subtle phrasing.
- **Deliberate limits.** `smart-commit` cannot push (`git push` is excluded
  from its allowed tools); the other skills operate on files in the user's
  repository only.
- **Network and secrets.** The skills read no tokens and call no external
  services themselves.
- **Supply chain.** Changes reach users only through the protected `release`
  branch, and every `uses:` in CI is pinned to a full commit SHA.
