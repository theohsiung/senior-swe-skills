# Modular Monolith

Single deployable unit, but with enforced internal module boundaries. Modules talk through a narrow public API (function calls, in-process events) and never reach into each other's internals.

## When to choose

- Team size 3–8. Below 3, plain monolith is fine; above 8, the operational cost of services starts paying for itself.
- One language across the stack, one runtime, one deploy artifact is acceptable.
- Domain has more than one obvious bounded context, but the contexts share a database without compliance pressure to separate.
- Scale is medium — single instance with vertical scaling and a read replica covers the foreseeable load.
- Deadline is short enough that microservice bootstrap (mesh, tracing, separate pipelines) would break it.

## When to NOT choose

- Team size ≥ 10 with multiple sub-teams that need to deploy independently. The boundary becomes a coordination cost rather than a benefit.
- Sub-systems have radically different SLAs (e.g., a real-time feed at p99 < 50ms next to a nightly batch job). Co-locating these in one process means the worst tenant defines the deployment cadence.
- Regulatory boundaries force data isolation (PHI in one context, plain PII in another). Row-level security is not enough.
- Single-script CLI / tiny tool. Module boundaries are overhead with no payoff.
- The team cannot agree on or enforce module boundaries with tooling. Without enforcement, this collapses into a plain monolith within a quarter.

## What you sign up for

- **Boundary enforcement.** A linter rule, an import-graph check in CI, or a folder convention plus code review. Without enforcement, the boundaries decay.
- **Shared database with module-prefixed schemas or schemas-per-module.** Don't let modules import each other's ORM models — go through the module's public API.
- **In-process event bus or function-call API for cross-module communication.** No HTTP between modules, no shared mutable singletons.
- **Single deploy pipeline.** Every change to any module redeploys the whole binary. Acceptable at this scale, painful past 8 devs.
- **One observability stack covering all modules.** Trace IDs propagate through in-process calls.
- **ADRs at the boundary level.** When module X starts depending on module Y, that's an architectural change worth recording.

## Migration paths

**From plain monolith** — the path most projects walk:

1. Identify natural domain boundaries (often: customer, order, billing, inventory). Pick the largest or most-touched one first.
2. Extract that module behind a narrow function-call API. Move its tables into a module-prefixed schema.
3. Add a CI check that fails on cross-module imports outside the API surface.
4. Repeat for the next module.

**Toward microservices** — when team size or SLA divergence forces the next step:

1. Pick the module with the clearest API surface and the most independent operational profile.
2. Extract that module first, with its own database and deploy pipeline.
3. Replace the in-process API with HTTP / gRPC / events.
4. Resist the urge to split everything at once. One service at a time, learn the operational patterns, repeat.

## Anti-patterns to refuse

- **Modules importing each other's internal symbols.** If module A imports `module_b.internal.foo`, the boundary is fictional. Refuse this in code review and in the linter.
- **Cross-module ORM model sharing.** Module A reading module B's table directly via shared ORM models. This couples them at the schema level — the worst kind of coupling, because schema migrations break across the "boundary".
- **Modules exposing database transactions.** Once one module can `commit()` on another's behalf, transaction boundaries leak across modules and you can't reason about consistency locally.
- **God-module that imports everything.** "Common", "shared", "utils" packages tend to grow into a hub that every module depends on. If a "shared" package keeps growing, split it back out into the modules that actually use it.
- **Calling it a modular monolith without enforcing boundaries.** No linter, no CI check, no code review pressure → it's a plain monolith with optimistic naming.

## Quick check before recommending

- Is there a real domain split, or am I splitting by technical layer (controllers / services / repos)? Domain split is a modular monolith. Technical-layer split is just folder organisation. They're not the same.
- Does the team have the discipline (or tooling) to keep boundaries from rotting? If neither, recommend plain monolith and revisit when the team grows.
- Will the first ADR ("modules talk through APIs only") actually be enforced, or will the next intern bypass it? An unenforced boundary is worse than no boundary because it lies to the reader.
