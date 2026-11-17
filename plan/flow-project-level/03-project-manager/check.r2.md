BUILDABLE

The amended plan fixes all twelve round 1 findings. Its sums add up and every HEAD line of PM has an owner. The risk left is P12's PM budget, which the named cuts do not reach.

1. **medium, P12 budget table (W22).** Two rows cannot hold their *Keeps* with the cuts the plan names. Two of the stated savings are also too high. (Inferred from the measures below.)
   - *The pipeline*, 2655 → 2200. Row 1's *Writes* cell is 206 B, so replacing it with "the plan files (`glab:project-plan` Step 3)" (43 B) saves 163, not ≈250. The `plan/` rationale sentence is 124 B. The Run cells net about −10. W12 adds about 180 and the gate clause about 110. That gives about 2340 using the plan's own figures, and about 2420 using mine.
   - *The master plan and sub-plans*, 2761 → 1350. The kept text alone comes to about 1650: `80` 216, `85-87` 478, `:274` 193, the `:82` line about 110, `:83` without its approval sentence about 345, and `:84`'s order rule plus pointer about 280.
   - *Dispatching the planner*, 2198 → 1600. "Planning here is the user's choice… Rule 5." is 79 B, not ≈150. With the other cuts it comes to about 2020, so `:137` and `:139` must give up another ~420 of their 1179 B.
   - *The rules of every level*: 285 − 14 = 271, against a budget of 250.
   - Total: about 10.1–10.5k against the ≤ 10000 target, and it can pass G1's 10240.
   - Commands: `sed -n 39p PM | awk -F' \\| ' '{print length($4)}'` printed `206`. `printf '%s' "Planning here … Rule 5. " | wc -c` printed `79`. `sed -n <r>p PM | wc -c` printed 80 → 216, 83 → 574, 84 → 578, 85 → 255, 86 → 147, 87 → 76, 274 → 193.
   - Fix: name about 400 B more cuts across *The pipeline* and *The master plan and sub-plans* (say which `:83` and `:85-87` clauses get condensed), and correct the two savings figures.
2. **low, P1.** The plan says "about 300 B" for the one cut it names. The two examples measure 69 + 91 = 160 B. The total still fits: about 5550 − 160 ≈ 5390, under 5600. Fix: say about 160 B.
3. **low, P12 table.** The row `## Without subagent dispatch` renames the HEAD heading `## When subagent dispatch is not available`, and W1 does not mention the rename. `grep -rnF` in plugins, README, tests and AGENTS finds the old heading only at PM:121, so no pointer breaks. Fix: add the rename to W1.
4. **low, P12 post (existing before this round).** No post-condition checks the new Run cells or the three new *Your skills* names. A PM that keeps HEAD's 1b and 8 cells still passes P12. Fix: add `grep -cF` checks for `/glab:project-plan-accept`, `/glab:project-plan-analyze` and `/glab:project-record`, each ≥ 1.

Round 1 status:
- 1, resolved: P4 sends `:200` to `glab:project-plan-accept` and adds the check → 0. `sed -n 189,203p | grep -cF` printed `1` (only `:200`).
- 2, resolved: the check is now `/glab:project-plan-analyze` ≥ 1, and the pointer sentence is spelled out.
- 3, partly resolved: the budget table exists, but see finding 1.
- 4, resolved: P1 and the byte table now cite `:83`. `:84` is used only for the brief exception.
- 5, resolved: the target is 5600 and the cut is named. The cut's size is wrong (finding 2).
- 6, resolved: the search printed `29` on HEAD.
- 7, resolved: description bytes are `576` and `673`. 9663 − 276 − 273 + 660 + 60 = 9834.
- 8, resolved: P13 maps 15 mentions. Per line: 3, 22, 35, 83, 99, 105, 109, 118×4, 122, 126, 154, 155.
- 9, resolved: W1 no longer gives that reason.
- 10, resolved: `project-planner.md:28` holds the line.
- 11, resolved: eight `grep -cxF` heading checks.
- 12: no change was needed.

Checked:
- 14 HEAD source ranges re-measured, all equal to the table: 1,9 772; 10,13 285; 14,22 765; 23,30 927; 31,34 224; 35,52 2431; 53,77 1905; 78,88 2568; 274 193; 89,120 2479; 121,132 1196; 133,142 2198; 301,311 771; and 82/83/84/139 686/574/578/715.
- The budgets total 9950. `proj` 44247, `task` 80694 (1226 under the cap) and `list` 9834 each equal what their terms add up to.
- Coverage: PM has 311 lines, not 320, and every line 1–311 is owned by the table, P1–P11, W9 or a blank.
- The new description line measures 234 B, so the frontmatter row comes to about 430 against its 500.
- *Your skills* comes to about 811 (budget 830) and *What you never do* to about 197 (budget 400).

Not checked:
- Whether *What this session owns* fits 750.
- *Pick the tier*'s cell savings beyond a rough estimate (about 1.07k, fits).
- *Final check* step 5 in master.md, which I may not read.
- Steps P2, P3, P5–P11 and P14–P18 beyond the diff.

Tokens used: about 38k. I created no temporary files.
