# PRP — Plan Reference Packet

Tasks that touch more than three files or make any architecture decision MUST produce a PRP before implementation. Post it in chat, in the PR description, or as a comment on the issue. The reader (human or another agent) should be able to pick up the work cold from the PRP alone — without reading the conversation that led to it.

A PRP has exactly four sections. Keep it tight; long PRPs are unread PRPs.

## 1. Context

Two to four sentences. What is being built and why. What upstream need or incident drives this. Skip background that the codebase already makes obvious.

## 2. References

Concrete pointers the implementer should read first — not exhaustive citations.

- `path/to/file.ts:42-58` — similar repository implementation to copy from
- `docs/exec-plans/active/<plan>.md` — design decisions if a plan exists
- External docs / RFC links only when behavior depends on them

If there is no relevant prior art, write `_None — greenfield_` and explain in one line why nothing in the codebase applies.

## 3. Steps

Phased plan. Each phase must be independently verifiable — i.e. you can run tests / curl / a screenshot and confirm that phase done before starting the next.

```
Phase A — <short title>
  - File: <path> — <what changes>
  - Test: <what test proves this phase>

Phase B — <short title>
  - File: <path> — <what changes>
  - Test: <what test proves this phase>
```

If the implementation is one phase, say so explicitly: `Single-phase: <description>`. Don't pad.

## 4. Acceptance

Mechanical checks the implementer (or reviewer) runs to confirm done. No subjective wording.

- Tests: `<command>` passes; coverage on new code ≥ 70%
- Lint / type check: `<command>` clean
- API: `curl <endpoint>` returns `<expected shape>`
- Frontend: screenshot shows `<expected state>` at `<URL>`
- Logs: no `ERROR` lines on the golden path

If a check is intentionally skipped, write why in one line.

## When NOT to write a PRP

- Bug fix touching 1–2 files with an obvious cause
- Doc-only change
- Trivial rename / reformat
- Dependency bump

For these, the commit message or PR description is sufficient.
