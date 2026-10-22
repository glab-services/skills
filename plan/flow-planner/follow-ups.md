# Follow-ups — flow-planner (developer)

- FD1 `plugins/glab/scripts/context-size.sh` l. 37, the contract sentence S7 prescribes verbatim: "the run goes on with the default and still prints its JSON". In mode `stop` below a step the run prints nothing, warning or not, so "its JSON" is true only where the run would have printed one. Out of scope: the wording is the plan's, and changing it is a plan amendment. Closed in fix round 1: reworded on the manager's instruction (result.md *Fix round 1*).
- FD2 The contract comment now has the S7 sentence as its own unwrapped line (l. 37) between two wrapped ones, so the searched phrase stays on one line as S7 asks. A reflow of that paragraph was not done: it is a formatting change no step names. Open, cosmetic.
