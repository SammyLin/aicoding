# rigging

Node CLI that installs team AI-coding standards into a project — Claude Code, Kiro CLI, or AGENTS.md-compatible tools. Replaces the legacy `setup.sh`. See `docs/exec-plans/active/v2-cli-rewrite.md` for the design.

## Public usage

```bash
npx rigging init                  # auto-detect language, install Claude Code config
npx rigging init --target kiro    # install Kiro CLI config
npx rigging init --target all     # both

npx rigging upgrade --target all  # refresh after a new release
npx rigging uninstall             # remove rigging-managed files (keeps user files)
```

## Dev

```bash
cd cli
pnpm install
pnpm dev -- init --dry-run     # run a command via tsx
pnpm build                     # compile to dist/
node dist/index.js init        # run the built artifact
pnpm test                      # vitest
pnpm lint                      # eslint + prettier --check
```

## Publish

```bash
pnpm pack                      # produce rigging-*.tgz (prepack copies sources, postpack cleans up)
pnpm publish                   # to npm (only after verifying the tarball)
```

`prepack` runs `scripts/copy-sources.mjs` to bundle `rules/` / `skills/` / `agents/` / `commands/` / `hooks/` / `settings.json` from the repo root into `cli/`. `postpack` runs the same script with `--clean` so the dev tree stays tidy.

## Local link

```bash
pnpm build
pnpm link --global
rigging --help
```
