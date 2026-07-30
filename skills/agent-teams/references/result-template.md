<!-- When using this template, replace every example inside [ ] with real values. Never output them literally. -->
# RESULT: [task name]

## Mission

[State the purpose and goal of the investigation in 1-3 sentences]

### Preconditions

<!-- optional -->

- [Scope, impact range, constraints]

### Requirements Summary

<!-- optional -->

- [Concrete requirements and conditions]

---

## Terminology

<!-- optional -->

| Term | Definition |
|------|------------|
| **[Term 1]** | [Explanation — DB column, name in code, etc.] |
| **[Term 2]** | [Explanation] |

---

## Findings

<!-- Add one section per area -->

### 1. [Title of finding 1]

[What was investigated and discovered]

#### Evidence

- [file:line] — [explanation]
- [evidence source]

### 2. [Title of finding 2]

| Item | Detail |
|------|--------|
| **[Item name]** | [value / explanation] |

---

## Out of Scope

> Make explicit what this investigation did NOT cover.

- [e.g. Write paths to table X were not verified]
- [e.g. Frontend behavior was out of scope]

---

## Impact Map

<!-- optional -->

### Must change (🔴)

| # | File | Line | Purpose | Current behavior | Required change |
|---|------|------|---------|------------------|-----------------|
| M1 | [path] | Lxxx | [purpose] | [current] | [change] |

### Should change (🟡)

| # | File | Line | Purpose | Current behavior | Recommended change |
|---|------|------|---------|------------------|--------------------|
| R1 | [path] | Lxxx | [purpose] | [current] | [change] |

### No change needed (🟢)

| # | File | Line | Purpose | Reason |
|---|------|------|---------|--------|
| N1 | [path] | Lxxx | [purpose] | [why no change is needed] |

---

## Effort Estimate

<!-- optional -->

| Phase | Effort | Depends on | Can start |
|-------|--------|------------|-----------|
| Phase 1 | X.X person-days | [dependency] | [when] |
| Phase 2 | X.X person-days | [dependency] | [when] |
| **Total** | **X.X person-days** | | |

---

## Final Assessment

### Conclusion

[State the conclusion in 2-5 sentences]

### Recommended Approach

- [Recommended implementation approach, phased plan, etc.]

> **Confidence**: [HIGH / MEDIUM / LOW] — [reasons / unverified items]
>
> HIGH: all evidence verified in code / MEDIUM: partially unverified / LOW: includes speculation

---

**Investigation team**: [list of participating agents]
