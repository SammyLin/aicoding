# Harness Engineering Standards

Harness Engineering is the practice of building the environment — documentation structure, guardrails, feedback loops, and architectural constraints — that enables AI agents to do reliable work at scale. The bottleneck is never the agent's ability to write code, but the lack of structure surrounding it.

When the agent struggles, treat it as an environment design problem. Ask: what is missing — tools, guardrails, documentation — for the agent to proceed reliably? Fix the harness, not the prompt.

## Structured Documentation

Treat agent instruction files (CLAUDE.md, AGENTS.md, .kiro/steering/) as a table of contents, not an encyclopedia.

- Keep the entry file short (~100 lines). It is a map, not a manual.
- Deep knowledge lives in a structured `docs/` directory, versioned alongside code.
- Use progressive disclosure: agents start from a small stable entry point and follow pointers to deeper sources.
- Avoid monolithic instruction files. Large context crowds out the actual task.

### Knowledge Base Structure

```
CLAUDE.md / AGENTS.md          ← Short map (~100 lines), pointers to deeper sources
docs/
├── design-docs/               ← Design decisions, core beliefs, verified specs
├── exec-plans/
│   ├── active/                ← In-progress execution plans
│   ├── completed/             ← Finished plans for reference
│   └── tech-debt-tracker.md   ← Known debt, tracked and versioned
├── generated/                 ← Auto-generated docs (e.g., DB schema)
├── product-specs/             ← Product requirements and acceptance criteria
└── references/                ← External docs pulled into repo (llms.txt, etc.)
```

### Execution Plans

- For complex work, create execution plans as first-class artifacts checked into the repo.
- Track progress, decisions, and open questions inside the plan document.
- Separate active plans, completed plans, and known tech debt.
- For small changes, use lightweight ephemeral plans (e.g., PR description or commit message).

### Documentation Hygiene

- Documentation for agents, maintained by agents. Use periodic scans to detect stale docs.
- When adding a new module or pattern, update the relevant docs in the same PR.
- Remove outdated docs immediately. Stale docs are worse than no docs.
- Enforce documentation freshness mechanically via CI checks and cross-link validation.

## Agent Legibility

Anything the agent can't access in-context effectively doesn't exist. Knowledge that lives in chat threads, Google Docs, or people's heads is invisible to the system.

- Push all relevant context into the repo. That Slack discussion that aligned the team? Encode it as a design doc or decision record.
- Favor dependencies and abstractions that can be fully internalized and reasoned about in-repo.
- Prefer "boring" technologies: composable, stable APIs, well-represented in training data.
- When an external library is opaque or poorly documented, consider reimplementing the subset you need with full test coverage.

### Application Legibility

Make the running application itself observable and drivable by agents:

- Make the app bootable per git worktree so agents can launch isolated instances.
- Expose logs, metrics, and traces to agents via local observability tools (e.g., LogQL, PromQL).
- Enable agents to reproduce bugs, validate fixes, and record evidence of resolution.

### Frontend Verification with Browser Agent

For any frontend change, you MUST visually verify the result using a browser automation tool (e.g., Playwright MCP, Puppeteer MCP, or Browserbase).

**Verification sequence for frontend changes:**

```
1. Start the dev server         → docker compose up -d
2. Open the target page         → browser.navigate("http://localhost:3000/target-page")
3. Take a screenshot            → browser.screenshot()
4. Verify the result visually   → confirm the UI matches the expected behavior
5. If the UI is wrong           → fix the code, repeat from step 2
6. Take a final screenshot      → attach as evidence in the completion report
```

**What to verify:**
- Layout renders correctly (no overflow, no missing elements)
- Interactive states work (hover, click, form submission)
- Responsive behavior (test at mobile and desktop widths if applicable)
- Error states display correctly (empty states, validation errors, loading states)

**Rules:**
- Never report a frontend task as "done" without a screenshot verification.
- If the browser tool is unavailable, inform the user and ask how to verify.
- Screenshots are evidence. Include them in the completion report or PR description.

## Custom Linters as Teaching Tools

Standard linters catch syntax; custom linters enforce project-specific architectural rules. Write linter error messages as remediation instructions so the agent learns while it works.

- Enforce naming conventions, file size limits, structured logging, and schema rules via custom lint rules.
- Error messages MUST include what is wrong AND how to fix it.
- Generate custom linters with the AI agent itself. The harness builds the harness.

Example of a teaching error message:

```
ERROR: Direct import of UserRepository in handler layer.
FIX: Inject via interface in the service layer. See docs/architecture/dependency-rules.md
```

## Architectural Constraints as Guardrails

Encode architecture as mechanically enforced rules, not just documentation. In a human-first workflow, these rules might feel pedantic. With agents, they become multipliers: once encoded, they apply everywhere at once.

- Define allowed dependency directions and enforce them with structural tests.
- Example dependency flow: `Types -> Config -> Repo -> Service -> Runtime -> UI`
- Cross-cutting concerns (auth, logging, telemetry, feature flags) enter through a single explicit interface (Providers pattern). Anything else is disallowed.
- Enforce boundaries centrally, allow autonomy locally. Care about correctness and reproducibility at the boundaries; allow freedom in how solutions are expressed within them.
- Validate data shapes at the boundary (e.g., Zod, Pydantic). Be prescriptive about the rule, not the specific library.

### Structural Tests

Write tests that validate project structure, not just business logic:

- No circular dependencies between modules.
- Handler layer does not import repository layer directly.
- All public service methods have corresponding test files.
- File size limits are respected.
- Dependency direction violations are caught in CI.

## Feedback Loops

Build closed-loop systems: trace failures, cluster error patterns, feed corrections back into the harness.

- When an agent fails a task, categorize the root cause: missing context, wrong constraint, unclear spec, or genuine bug.
- Fix the category, not just the instance. Update docs, add a lint rule, or improve the test.
- When documentation falls short, promote the rule into code (lint rule or structural test).
- Human taste is fed back into the system continuously: review comments, refactoring PRs, and user-facing bugs are captured as doc updates or encoded directly into tooling.

### How to Give Feedback as an Agent

When you encounter a problem or make a mistake, do not just fix it and move on. Strengthen the harness:

```
1. Fix the immediate issue.
2. Ask: "Could a lint rule, test, or doc update prevent this from happening again?"
3. If yes → implement the prevention in the same PR.
4. If the fix belongs in the standards → suggest the update to the user.
```

**Examples:**
- You forgot to wrap an error → add a custom lint rule that flags unwrapped errors.
- You imported a repository in a handler → add a structural test for layer violations.
- You didn't know about a project convention → update docs/ with the missing convention.
- A test was flaky → fix the root cause (shared state, timing), don't just retry.

### Continuous Harness Improvement Cycle

```
Agent fails or struggles
       ↓
Diagnose root cause
       ↓
  ┌────┴────┐
  │         │
Missing   Missing
context   guardrail
  │         │
Update    Add lint rule
docs /    or structural
plan      test
  │         │
  └────┬────┘
       ↓
Verify fix with same task
       ↓
Harness is stronger for all future tasks
```

## Entropy and Garbage Collection

Agents replicate patterns that already exist in the repository — even suboptimal ones. Over time, this leads to drift. Technical debt is a high-interest loan: pay it down continuously in small increments.

- Define "golden principles": opinionated, mechanical rules that keep the codebase legible for future agent runs.
- Prefer shared utility packages over hand-rolled helpers to keep invariants centralized.
- Don't probe data shapes speculatively — validate at boundaries or rely on typed SDKs.
- Run recurring background agents that scan for deviations, update quality grades, and open targeted refactoring PRs.
- Most cleanup PRs should be reviewable in under a minute and auto-mergeable.

## Increasing Autonomy

As more of the development loop is encoded into the harness, agents can handle progressively larger scopes:

1. **Level 1:** Agent writes code, human reviews and merges.
2. **Level 2:** Agent writes + self-reviews, human spot-checks.
3. **Level 3:** Agent-to-agent review, human reviews only flagged items.
4. **Level 4:** Agent end-to-end drives a feature: validate state, reproduce bug, implement fix, verify, open PR, respond to feedback, merge.

Escalate to humans only when judgment is required. Push review effort toward agent-to-agent workflows over time.

## Don't / Do Quick Reference

| Don't | Do Instead |
|-------|-----------|
| Monolithic AGENTS.md / CLAUDE.md | Short entry file + structured docs/ directory |
| Knowledge in Slack / Google Docs | Encode decisions as versioned docs in repo |
| Generic linter error messages | Error messages with remediation instructions |
| Architecture rules in docs only | Architecture enforced by structural tests + CI |
| Fix each agent failure one-off | Categorize failures, fix the harness systemically |
| Let docs drift from code | Automated doc freshness checks + gardening agents |
| Manual code review for layer violations | Custom linters catch violations before review |
| Giant context dumps to agent | Progressive disclosure with pointers |
| Hope agents follow conventions | Enforce conventions mechanically |
| Manual weekly cleanup of AI slop | Recurring background agents + golden principles |
| Opaque external dependencies | In-repo reimplementation with full test coverage |
