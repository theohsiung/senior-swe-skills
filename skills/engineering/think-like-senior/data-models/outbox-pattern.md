# Outbox Pattern

Persist domain writes and enqueue downstream work in the **same database transaction**. Workers consume the outbox table, attempt the side effect, and update the row's status atomically with the result. The outbox is in the same DB as the audit log and the source-of-truth tables — no separate broker required.

## When to choose

- "At-least-once" or "no dropped events" is a stated requirement
- The system has external side effects (HTTP calls, message publishes, emails) that must follow domain state changes
- Postgres / a transactional database is already the source of truth
- Solo or small team; minimising operational surface is valuable

## When to NOT choose

- Sustained throughput exceeds what one DB can absorb on top of normal workload (rule of thumb: > ~5K outbox writes/sec on a single Postgres instance) — at that point a dedicated broker pays for itself
- The side effect is purely fire-and-forget and "best effort" is acceptable (e.g., analytics ping) — outbox adds machinery for no benefit
- The system has no transactional database (e.g., pure event-driven over Kafka with state in compacted topics) — different architecture entirely

## What you sign up for

- One `outbox` table (or per-side-effect-type if shapes differ a lot) with at minimum: `id`, `aggregate_id`, `payload`, `status`, `attempt_count`, `next_attempt_at`, `created_at`, `last_error`
- Producer code path: write domain row + insert outbox row in the same transaction. Always.
- Worker process: `SELECT … FOR UPDATE SKIP LOCKED WHERE status='pending' AND next_attempt_at ≤ now()`, do the side effect, update the row.
- Idempotency keys forwarded to downstream sinks so retries don't duplicate
- Retention strategy for completed outbox rows (delete after N days, or archive)
- Metrics on outbox lag (oldest pending row age) — primary alert signal

## Migration paths

**From "API call inside the request handler"** (the broken default):
1. Add the outbox table and a worker.
2. Move side effect from inline to outbox-driven.
3. Verify domain commits without the side effect succeeding (controlled by the test that the worker can be paused without breaking the request path).

**Toward "Kafka / dedicated broker"** if scale forces it:
1. Keep outbox in DB for atomic enqueue.
2. Add a relay process that reads outbox and publishes to Kafka.
3. Workers consume from Kafka, not directly from DB.

## Anti-patterns to refuse

- **Two-phase write: write domain row, commit, then enqueue separately** — the classic dual-write bug. The window between commits is where events get lost.
- **Outbox without idempotency keys** — at-least-once means duplicates; downstream must dedupe or retries will double-deliver.
- **Skipping the worker, polling from the request handler** — couples request latency to side-effect speed and has no recovery story when the request crashes mid-side-effect.
- **Outbox table without retention** — the table grows forever; queries against it slow down; eventually it becomes its own scaling problem.

## Quick check before recommending

- Is the side effect *really* required to happen, or is "best effort" acceptable? Outbox is for required side effects.
- Does the downstream sink honor idempotency keys? If not, document that retries may duplicate.
- Is there exactly one source of truth (the DB), or are you trying to outbox between two stores? The pattern only protects the DB→sink direction.
- Will the worker have a graceful shutdown that re-marks in-flight rows as available? Without that, a restart re-delivers in-flight work twice.
