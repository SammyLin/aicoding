# Harness Engineering Standards

Harness Engineering is the practice of building the environment — documentation structure, guardrails, feedback loops, and architectural constraints — that enables AI agents to do reliable work at scale. The bottleneck is never the agent's ability to write code, but the lack of structure surrounding it.

**Core principle: you don't fix the result, you fix the system that produced the result.**

When the agent writes bad code, don't jump in and fix that code. Instead, ask: why was this bad code allowed to pass? Then fix the system — add a linter rule, write a structural test, update CI, improve documentation. Next time the agent (or any agent) makes the same mistake, the system catches it automatically. Humans steer, agents execute.

## Encode Rules as Enforcement, Not Just Documentation

Writing a rule in a markdown file is necessary but not sufficient. Rules that only exist as documentation will eventually be violated. Every important rule should also be encoded as a mechanical check:

| Rule Category | Documentation | Enforcement |
|--------------|---------------|-------------|
| **Security** | security.md checklist | CI pipeline: dependency audit, secret scanning, SAST |
| **Error handling** | lang-*.md error patterns | Custom lint rule: all errors must be wrapped with context |
| **Architecture boundaries** | architecture.md layer rules | Structural test: handler cannot import repository |
| **Naming conventions** | lang-*.md naming section | Linter config: enforce naming rules per language |
| **Commit messages** | project-ops.md git rules | commitlint + husky: reject non-conventional commits |
| **File size** | project-ops.md (<250 lines) | CI check or custom lint: flag files exceeding limit |
| **Test coverage** | code-quality.md (>70%) | CI: fail PR if coverage drops below threshold |

### How to Promote a Rule from Docs to Code

When you notice a rule being violated repeatedly:

```
1. First violation: fix the code, note the pattern.
2. Second violation: this is now a systemic issue.
3. Create enforcement:
   a. Can a linter catch this? → Add a lint rule with remediation message.
   b. Can a test catch this? → Add a structural test.
   c. Can CI catch this? → Add a CI check.
4. The rule now enforces itself. Humans don't need to review for it.
```

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
- Include Prometheus + Grafana in the docker-compose stack so agents can query metrics and verify behavior via dashboards (see project-ops.md Observability section).
- Agents should verify observability instrumentation as part of the implementation: if a new endpoint or service method has no counter/histogram, that's a missing requirement — not an optional extra.

### Frontend Verification with agent-browser

For any frontend change, you MUST visually verify the result using [agent-browser](https://github.com/vercel-labs/agent-browser).

agent-browser is a CLI tool that drives Chrome/Chromium via CDP. Install via `npm i -g agent-browser` and run `agent-browser install` to download Chrome. See `agent-browser-skill.md` for the full command reference.

**Verification sequence for frontend changes:**

```
1. Start the dev server         → docker compose up -d
2. Open the target page         → agent-browser open http://localhost:3000/target-page
3. Wait for page load           → agent-browser wait --load networkidle
4. Take a snapshot              → agent-browser snapshot -i
5. Take a screenshot            → agent-browser screenshot
6. Verify the result visually   → confirm the UI matches the expected behavior
7. If the UI is wrong           → fix the code, repeat from step 2
8. Take a final screenshot      → attach as evidence in the completion report
```

**What to verify:**
- Layout renders correctly (no overflow, no missing elements)
- Interactive states work (click, form submission via `agent-browser click @ref` / `agent-browser fill @ref "text"`)
- Responsive behavior (test at mobile and desktop widths: `agent-browser set viewport 375 812` / `agent-browser set viewport 1920 1080`)
- Error states display correctly (empty states, validation errors, loading states)

**Rules:**
- Never report a frontend task as "done" without a screenshot verification via agent-browser.
- If agent-browser is unavailable, inform the user and ask how to verify.
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

The agent does NOT just write code and report done. The agent operates in a closed loop:

```
Write code → Run tests → Run linter → Check logs → Verify behavior → Self-review → Report
    ↑                                                                       │
    └───────────────── Fix and re-run if anything fails ────────────────────┘
```

### Agent Self-Verification Checklist

Before reporting any task as complete, the agent MUST:

```
1. Run tests inside Docker           → docker compose exec app make test
2. Run linter inside Docker           → docker compose exec app make lint
3. Check for type errors              → language-specific type checker
4. Review own code for:
   - Layer violations (handler importing repo?)
   - Unwrapped errors (missing context?)
   - Hardcoded values (should be config?)
   - Missing tests for new logic
5. For frontend: take screenshot      → browser agent verification
6. For API: test with curl            → verify request/response shape
7. Read logs for warnings/errors      → docker compose logs app
8. All green → report completion
   Any red  → fix and re-run from step 1
```

### Systemic Feedback: Fix the System, Not Just the Code

When the agent makes a mistake or something slips through:

```
1. Fix the immediate issue.
2. Ask: "Why did the system allow this?"
3. Promote the fix to a permanent guardrail:
   - Forgot to wrap an error?      → Add lint rule: all errors must have context
   - Handler imported repository?   → Add structural test for layer violations
   - Missing input validation?      → Add CI check or middleware
   - Convention not followed?       → Update docs + add linter enforcement
   - Same bug could recur?          → Add regression test
4. Implement the guardrail in the SAME PR as the fix.
5. Suggest standards update to user if the rule belongs in the shared standards.
```

The goal: every mistake makes the harness stronger. The same mistake never happens twice.

### Feedback Sources

- **Test failures** → missing logic, edge cases not covered → add test + fix
- **Lint errors** → style/convention violations → the linter already caught it (good)
- **Code review comments** → human taste → encode as lint rule or doc update
- **Runtime errors / logs** → bugs in production → add regression test + monitoring
- **User-reported issues** → spec mismatch → update product docs + acceptance tests

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
| Jump in and fix agent's code manually | Fix why the system allowed bad code (add lint/test/CI) |
| Rules only in documentation | Encode rules as linter + structural test + CI check |
| Write code and report done | Closed loop: write → test → lint → logs → self-review → report |
| Monolithic AGENTS.md / CLAUDE.md | Short entry file + structured docs/ directory |
| Knowledge in Slack / Google Docs | Encode decisions as versioned docs in repo |
| Generic linter error messages | Error messages with remediation instructions |
| Architecture rules in docs only | Architecture enforced by structural tests + CI |
| Fix each agent failure one-off | Categorize failures, fix the harness systemically |
| Let docs drift from code | Automated doc freshness checks + gardening agents |
| Manual code review for layer violations | Custom linters catch violations before review |
| Giant context dumps to agent | Progressive disclosure with pointers |
| Hope agents follow conventions | Enforce conventions mechanically |
| Same mistake happens twice | Every mistake becomes a permanent guardrail |

---

## Agent Harness Fundamentals

*Source: [Anthropic Blog - Harnessing Claude's Intelligence](https://claude.com/blog/harnessing-claudes-intelligence)*

### Three Core Principles

#### 1. Use What Claude Knows
Claude is strong with general-purpose tools: bash and text editor. SWE-bench 49% was achieved with just these two. Skills, programmatic tool calling, and memory are all compositions of bash + text editor.

**Practical**: Don't invent new tools. Use what Claude already knows well.

#### 2. Ask "What Can I Stop Doing?"
Agent harnesses encode assumptions about what Claude can't do. As Claude gets stronger, those assumptions become stale.

Give Claude a **code execution tool** — it lets Claude decide what tool results to pipe into the next call, instead of everything landing in context. The orchestration decision moves from the harness to the model.

**Practical**: Don't dump all tool results back to Claude. Let it choose what matters.

#### 3. Let Claude Orchestrate Its Own Context

- **Skills = Progressive Disclosure**: YAML frontmatter as short description in context; full content read only when needed. Don't pre-load rarely-used instructions.
- **Memory folder**: Let Claude write context to files, then read as needed. Sonnet 3.5 treated memory as transcript (wrong). Opus 4.5+ writes tactical notes.
- **Subagents**: Fork a fresh context window for isolated work. Opus 4.6 + subagents → +2.8% on BrowseComp.
- **Compaction**: Summarize past context to maintain continuity on long-horizon tasks. Sonnet 4.5 flatlined at 43% regardless of budget. Opus 4.6 scaled to 84%.

**Practical**: Give Claude tools to manage its own context — don't do it for it.

### Cache Optimization

API caches context up to breakpoints. Cached tokens cost 10% of base input tokens.

| Principle | Description |
|-----------|-------------|
| Static first, dynamic last | Stable content (system prompt, tools) first, dynamic content last |
| Messages for updates | Append `<system-reminder>` instead of editing the cached prompt |
| Don't change models | Caches are model-specific; switching breaks them |
| Carefully manage tools | Tools sit in cached prefix — adding/removing one invalidates cache |
| Move breakpoints | Keep cache up-to-date by moving breakpoint to latest message |

### Dedicated Tools vs General Bash

- **Bash tool**: Broad capability, but harness only gets a command string — same shape for every action.
- **Dedicated tool**: Typed arguments, harness can intercept, gate, render, or audit.
- **When to promote**: Security boundaries, irreversible actions, user-facing actions, observability.

**Practical**: Actions requiring security confirmation or irreversible operations → dedicated tool. Regular scripting → bash.

---

## Skills Architecture

*Source: [Anthropic Blog - Skills Patterns](https://claude.com/blog/skills-patterns)*

### Skills Are Folders, Not Just Markdown

The most interesting part of skills: they're not just text files. They're folders that can include scripts, assets, data, etc. that the agent can discover, explore, and manipulate.

### 9 Types of Skills

| # | Type | Purpose | Examples |
|---|------|---------|----------|
| 1 | **Library & API Reference** | How to correctly use a library, CLI, or SDK | billing-lib, internal-platform-cli |
| 2 | **Product Verification** | Test and verify code works | signup-flow-driver, checkout-verifier |
| 3 | **Data Fetching & Analysis** | Connect to data and monitoring stacks | funnel-query, cohort-compare, grafana |
| 4 | **Business Process** | Automate repetitive workflows into one command | standup-post, weekly-recap |
| 5 | **Code Scaffolding** | Generate framework boilerplate | new-migration, create-app |
| 6 | **Code Quality & Review** | Enforce code quality and review | adversarial-review, code-style |
| 7 | **CI/CD & Deployment** | Help fetch, push, and deploy code | babysit-pr, cherry-pick-prod |
| 8 | **Runbooks** | Symptom → multi-tool investigation → report | \<service\>-debugging, log-correlator |
| 9 | **Infrastructure Ops** | Routine maintenance and operational procedures | \<resource\>-orphans, cost-investigation |

### Tips for Writing Skills

1. **Don't state the obvious** — Focus on what pushes Claude out of its normal way of thinking. Don't repeat what Claude already knows.
2. **Build a Gotchas Section** — Highest-signal content. Capture common failure points from experience. Update over time.
3. **Use the File System & Progressive Disclosure** — Split detailed content into `references/api.md`. Point to template files in `assets/`. Claude will read them at appropriate times.
4. **Avoid Railroading Claude** — Give Claude the information it needs, but the flexibility to adapt. It will generally try to stick to your instructions — be careful being too specific.
5. **Think Through Setup** — Some skills need initial config (e.g., "which Slack channel?"). Store in `config.json`. If not set, the agent asks the user.
6. **Description Field Is For the Model** — Not a title, but a description of **when to trigger this skill**. Claude scans all skill descriptions to decide "is there a skill for this request?"
7. **Memory & Storing Data** — Skills can store data in append-only logs, JSON files, or SQLite. Use `${CLAUDE_PLUGIN_DATA}` for stable per-plugin storage.
8. **Store Scripts & Generate Code** — Give Claude scripts and libraries so it spends turns on composition, not reconstructing boilerplate.

### On-Demand Hooks

Hooks that activate only when the skill is called, lasting for the session duration. For opinionated guardrails you don't want always-on:

```
/careful — blocks rm -rf, DROP TABLE, force-push, kubectl delete
/freeze — blocks any Edit/Write outside a specific directory
```

### Measuring Skills

Use a `PreToolUse` hook to log skill usage. Find skills that are popular or are under-triggering compared to expectations.

### Distributing Skills

- **Small teams**: Check skills into repo (under `.claude/skills`)
- **Scaling**: Internal plugin marketplace. Upload to sandbox → get traction → PR to move to marketplace.

**Curation tip**: Easy to create bad or redundant skills. Have a review step before release.

---

*Last updated: 2026-04-06*
