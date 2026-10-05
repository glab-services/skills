# Audit Document Template

Copy this template and fill in each section. Delete unused subsections.

---

# <Service Name> — <Audit | Examination | Review>

**Date**: YYYY-MM-DD
**Scope**: <what was examined — specific files, modules, or subsystems>
**Status**: draft

## Architecture Summary

<1-2 paragraphs: what the service does, its tech stack, its role in the larger system.>

```
<Optional ASCII architecture diagram>
```

## Working Flow

### Phase 1 — <Name>

<Step-by-step: what happens, key function calls, data transformations.>

### Phase 2 — <Name>

...

## Key Findings

### What Works Well

- <positive observation>

### Issues & Concerns

- <negative observation>

### Duplication / Copy-Paste

- <where code is duplicated across services>

### Configuration Issues

- <wrong names, hardcoded secrets, missing env vars>

### Proven vs Inferred

- **Proven**: <behavior confirmed by reading the code or running it>
- **Inferred**: <behavior assumed but not verified — flag anything load-bearing>

## Issues Table

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | Critical | <description> | `path/file.go:line` |
| 2 | High | <description> | `path/file.go:line` |

## Recommendations

### Critical (fix immediately)

- **[#N]** <actionable fix>

### High (fix soon)

- **[#N]** <actionable fix>

### Medium (fix when convenient)

- **[#N]** <actionable fix>

### Low (nice to have)

- **[#N]** <actionable fix>

## Next Steps

- [ ] <concrete next action>
- [ ] <decision needed>
- [ ] <further investigation>
