# Verification recipe

How an agent proves a change works on the **real running system**, not just in the test suite. Readers are listed in `docs/skill-contracts.md` §1 (`/tdd` Finishing, `/diagnose` Phase 1, `/triage` Verify the claim, `/where-am-i`). Evidence levels are defined in `docs/skill-contracts.md` §8 — driving the system through this recipe is what gets a claim to level 5.

> Status: verified end-to-end on <YYYY-MM-DD> | DRAFT — steps marked `(unverified)` were never run

## Launch

One command that boots everything a feature needs (app, DB, queues). Prefer the repo's own script.

```bash
# e.g. docker compose up -d && npm run dev
```

## Doctor

One command that exits 0 only when the system is ready to drive. Run it after Launch; don't guess with `sleep`.

```bash
# e.g. curl -fsS localhost:3000/ready
```

## Drive

How to exercise a feature through its **system-public** entry point (see `docs/skill-contracts.md` §3). Pick whichever applies:

- **CLI**: `./bin/<tool> <subcommand> --fixture tests/fixtures/<x>`
- **HTTP**: `curl -sS -X POST localhost:3000/<route> -H 'content-type: application/json' -d @fixture.json`
- **UI**: headless browser script at `<path>` (Playwright / Puppeteer)

Credentials come from env vars (`$API_TOKEN`), never inline. Redact secrets in anything you paste.

## Evidence

Where to read the outcome, through the app's own read paths:

- stdout / response body / exit code
- logs: `<command>` (grep the `request_id`)
- state: a paired read endpoint or CLI command — not a direct DB query

## Cleanup

```bash
# e.g. docker compose down -v
```

## Feature map

The 3–5 features that matter most, each with the observable end state that proves it works.

| Feature | Drive | Observable end state |
|---|---|---|
| <e.g. Create booking> | `curl -X POST /bookings -d @booking.json` | `201` + `GET /bookings/<id>` returns `status: confirmed` |
