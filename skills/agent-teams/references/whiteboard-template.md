<!-- When using this template, replace every example inside [ ] / { } with real values. Never output them literally. -->
# 📝 TEAM WHITEBOARD: [task name]

## 🎯 Goal
- [ ] [e.g. Fix the bug in feature X and resolve the resulting DB inconsistency]
- [ ] [e.g. Achieve the performance target (LCP under 2.5s)]

## 🏗 Team Structure
| Name | Role / Specialty | Main tasks |
| :--- | :--- | :--- |
| **Leader** | Overall coordination & integration | Whiteboard consolidation, final code integration |
| **Agent A** | [e.g. Logic & API] | [e.g. Fix the controller, add validation] |
| **Agent B** | [e.g. DB & infrastructure] | [e.g. Analyze query plans, write the migration] |

## 🔗 Shared Context
- **Target repository**: [repository name]
- **Databases/tables under investigation**: [e.g. app_main / users, orders]
- **Related docs/PRs**: [URLs or paths]

---

## 🚦 Task Board
- [ ] [Leader] Initial analysis complete
- [ ] [Agent A] Logic fix proposed
- [ ] [Agent B] Index addition validated
- [ ] [Leader] Integration tests run

---

## 💡 Findings Storage

### 🟦 Agent A: [logic perspective]
- (Record discovered spec quirks and the blast radius of the fix here)
- **Request to Agent B**: [e.g. Check whether this query actually uses the index]

### 🟩 Agent B: [DB/data perspective]
- (Record query-plan results and evidence of actual data problems here)
- **Request to Agent A**: [e.g. Some cases return over 10k rows, so pagination is required]

---

## 🧠 Cross-Cutting Observations
> Collect the cross-domain insights here that no one sees while working alone.
1. **[Insight 1]**: (e.g. A DB constraint is safer than enforcing this in application logic)
2. **[Insight 2]**: (e.g. Changing X also affects the Y component on the frontend)

---

## 🚫 Blocking Issues / Q&A
- **[Q]**: [e.g. Is `deleted_at` on this table actually used as a soft delete?]
- **[A]**: [append the answer here]
