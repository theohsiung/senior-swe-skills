# Project doc paths

This file tells the senior-swe skills where to read and write project artifacts. Skills read it first; if missing, they fall back to the defaults shown below.

See [`docs/skill-contracts.md` §1 and §6](../../../docs/skill-contracts.md) for the full ownership matrix and resolution rules.

## How skills read this file

Skills extract values by simple key matching from the YAML block(s) below: `key: value` lines inside the fenced `yaml` blocks are authoritative. Lines outside the fenced blocks (including this paragraph) are documentation only and ignored. Per-package overrides under `packages.<name>.<key>` take precedence over top-level keys when a skill is operating inside that package.

## Single-root layout (default)

Most repos. All artifacts live at the repo root.

```yaml
architecture: docs/architecture.md
adr_root: docs/adr/
features: docs/features/
plans: docs/plans/
prd: docs/prd/
context: CONTEXT.md
out_of_scope: .out-of-scope/
```

## Multi-context / monorepo layout

When `CONTEXT-MAP.md` exists, set `context: CONTEXT-MAP.md` and document per-package overrides under `packages:`. Each package can override any of the keys above.

```yaml
architecture: docs/architecture.md
adr_root: docs/adr/
features: docs/features/
plans: docs/plans/
prd: docs/prd/
context: CONTEXT-MAP.md
out_of_scope: .out-of-scope/

packages:
  ordering:
    context: src/ordering/CONTEXT.md
    adr_root: src/ordering/docs/adr/
  billing:
    context: src/billing/CONTEXT.md
    adr_root: src/billing/docs/adr/
```

When a skill operates on a feature inside a package, it picks the package whose root contains the feature's primary module and resolves keys against that package's overrides first, falling back to the top level.
