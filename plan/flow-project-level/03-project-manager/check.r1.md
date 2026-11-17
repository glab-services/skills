NOT BUILDABLE

I measured against plan `plan/flow-project-level/03-project-manager/plan.md`, which is untracked, on HEAD `d6797e0`. I had no Skill tool, so I could not load the `security` and `comments` skills. I followed their evidence rule by hand: every finding below comes from a command I ran on HEAD, or is marked inferred.

1. **high, P4 (and W2).** The plan says *The master plan and sub-plans* "stays a PM pointer" in the moved Stage 1c text. That pointer is wrong once P1 runs.
   - Evidence: `sed -n 189,203p PM | grep -noE '...master plan and sub-plans...'` prints line 12 (`:200`): "is a changed request, not an amendment (*The master plan and sub-plans*)".
   - The changed-request route is `:82`, and P1 moves it to `project-plan-accept`. The pointer would then point at a section that no longer holds it.
   - If the pointer is written as `glab:project-manager` *…*, it also breaks P4's own post-condition `grep -c 'glab:project-manager'` → 0.
   - Fix: point `:200` at `glab:project-plan-accept`.

2. **medium, P6.** The post-condition `project-plan-analyzer` → 1 "(the pointer)" has no source.
   - W8 and P6 have the body point at `/glab:project-plan-analyze`, which does not match `-F project-plan-analyzer`.
   - Evidence: `sed -n '231,249p;278,283p' PM | grep -cF project-plan-analyzer` → `0`. The new description names only `glab:project-analyzer`.
   - Fix: change the post-condition to `project-plan-analyze` ≥ 1, or spell out the pointer text P6 must contain.

3. **medium, P12 / byte table (PM ≤ 9600).** The sections PM keeps, measured on HEAD, add up to about 11.1k (inferred from these measures). That is over 9600, and over G1's 10240 too.
   - Kept ranges: `1,9` 772, `10,13` 285, `14,22` 765, `23,30` 927, `35,52` 2431, `53,77` 1905, `78,88` 2568, `133,139` 1925, `301,320` 771.
   - Cuts the plan names: description 576→300, the criteria, `:82`/`:84` out (686+578), Running ≤ 450, the never-list down to 4 items.
   - Adds: `:274` 193, the W12 and gate clause, 3 skill names.
   - About 1.5k of prose that no step budgets still has to be condensed.
   - Fix: give *The pipeline*, *Dispatching the planner* and *The master plan and sub-plans* their own byte budgets, or name what each one loses.

4. **medium, P1 / byte table.** "`:84`'s full-tier sub-plan approval" cites the wrong line.
   - `sed -n 84p` is the brief exception, which P4 rightly takes. The full-tier sub-plan `## Approval` is `:83`.
   - Fix: cite `:83` in P1 and in the `project-plan-accept` row.

5. **low, project-plan-accept ≤ 5300.** Moved byte for byte, its sources come to about 5.6k (inferred): `143,157` 2706 + `158,160` 404 + `161,163` 842 + most of `:82` (686) + part of `:83`, plus frontmatter, slug rule, tier line and pointer.
   - The `task` sum has 1926 bytes of slack, so W16's overrun rule can absorb it.
   - Fix: budget about 300 bytes of condensing, or raise the target and lower another.

6. **low, P16.** The plan says the search prints 32 lines on HEAD. My run from the repo root printed `29` lines, `rc=0`. Every one of the 29 is covered by P4–P8, P13, P15 or P16, so `rc=1` afterwards is a fair test.
   - Fix: change 32 to 29.

7. **low, Evidence / W15 / `list`.** `grep '^description: ' | wc -c` prints PM 576, not 620, and `project-plan` 673, not 714. With those, `list` comes to about 9834 rather than 9749, still under 10240.
   - Fix: correct the two numbers and the sum.

8. **low, P13.** `:118` holds 4 `glab:project-manager` mentions, not 3. The unmapped one is "Under `glab:project-manager` an amendment…". The file has 15 mentions on 12 lines; the post-condition → 0 still forces all of them out.
   - Fix: map the 4th mention.

9. **low, W1 vs P13.** W1 keeps *The master plan and sub-plans* "so `project-plan`'s sub-plan pointer stays true". But P13 removes every `glab:project-manager` from `project-plan`, including `:118`'s pointer to that section.
   - Fix: drop that reason from W1.

10. **low, P14.** The "Where you write" line is `project-planner.md:28`, not `:26` (`:26` is blank). The HEAD count of 3 → 1 is right.
    - Fix: cite `:28`.

11. **low, P12 post-conditions.** Nothing checks the headings W1 keeps: *The rules of every level*, *The master plan and sub-plans*, *Running agents in parallel*, *Dispatching the planner*. A PM that drops them still passes.
    - Fix: add a `grep -cF` → 1 check for each.

12. **low, P17.** Entry 14 is wrapped across `AGENTS.md:314-315` ("`…project-manager/SKILL.md`" / "checklist item 8"), so the same-line search never sees it; HEAD count is 6. The `project-plan-accept/SKILL.md` → 3 check does catch a skipped entry 14. No fix needed.

**Checked:**
- *Final check* step 4 on HEAD matches the plan's *Evidence* exactly: hook 2631/2584, core 31826, proj 75302, prod 45222, list 9663, files = onel = 31, and the five agent sets 23437/23129/27750/16508/31557.
- The target sums add up. The planner set holds at about 30774 (inferred).
- `project-analyze` (about 5.0k) and `project-develop` (about 6.09k) fit their targets, the latter barely (both inferred).
- `session-rules` `:18`, `:117`, `:120` are 226, 555 and 271 bytes and say what the plan says.
- HEAD counts behind the post-conditions:
  - PM: `## Stage ` 11, `sha256sum` 1, `Rule 4` 2, `findings-` 1.
  - `:164-172`: UNVERIFIED 10, plansDirectory 1. `:123-131`: review4 1.
  - `session-rules`: `glab:project-manager` 3, `Without subagent dispatch` 1.
  - `project-plan`: `glab:project-manager` 12 lines.
  - `:173-188`: `NOT BUILDABLE` 2.

**Not checked:**
- P8's `*Re-reviews*` source and P18.
- Master *Final check* steps 1, 2 and 5 (not run).
- The full mapping of the 15 *One fact* entries; `AGENTS.md` beyond its `project-manager` lines.
- `:204-230` and `:258-269` beyond their byte counts.
- Whether the hook text names any PM section.

About 48k tokens used. No temp files remain under `/data/tmp/claude`.
