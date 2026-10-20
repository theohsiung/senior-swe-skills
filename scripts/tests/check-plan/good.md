# Booking Tags Implementation Plan

> **For Claude:** Use /tdd to execute this plan. Each task is one RED→GREEN cycle with a stable ID (`T-NNN`). Derive the test code at execution time from the behavior description — do NOT copy or pre-write test code into this plan.

**Goal:** An operator can tag a Booking and filter Bookings by tag.
**Design doc:** `docs/features/booking-tags/design.md`
**Architecture context:** Modular monolith, Postgres.
**Tech stack:** TypeScript, vitest.
**Task IDs:** assigned in creation order, never reused. Withdrawn tasks marked `~~T-NNN~~ Withdrawn`.

---

### T-001: An operator can tag a Booking

**Behavior to verify**
An operator can add the tag "vip" to a Booking, so that it shows up in tag filters.

**Public interface this task introduces**
- Level: system-public
- New: `POST /bookings/:id/tags` — add a tag

**Files**
- Modify: `src/bookings/routes.ts`
- Test: `tests/bookings/tags.test.ts`

**Test framing hints (NOT test code)**
- Use "Booking", not "reservation".

**Anti-patterns to refuse**
- "saves to booking_tags table"

**Definition of done**
- RED then GREEN through the HTTP route.

### ~~T-002~~ Withdrawn

### T-003: An operator can filter Bookings by tag

**Behavior to verify**
An operator can list only Bookings tagged "vip".

**Public interface this task introduces**
- Level: module-public
- New: `listBookings({ tag })`

**Files**
- Modify: `src/bookings/query.ts`

**Test framing hints (NOT test code)**
- Seed through the T-001 route, read through the list route.

**Anti-patterns to refuse**
- Querying the DB directly to assert.

**Definition of done**
- RED then GREEN.
