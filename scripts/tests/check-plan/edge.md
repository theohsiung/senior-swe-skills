# Edge-case Plan

### How to read this plan

Header subheadings must not end the header.

**Goal:** Exercise parser edge cases.
**Design doc:** `docs/features/edge/design.md`
**Task IDs:** assigned in creation order, never reused.

---

### T-001: A user sees the assertion hold in prose

**Behavior to verify**
A user can read a fenced example that mentions an assertion in prose.

```text
the assertion holds when the cart is non-empty
```

### Notes for the implementer

A task-local subheading must not end the task.

**Public interface this task introduces**
- Level: system-public

**Files**
- Modify: `src/cart.ts`

**Test framing hints (NOT test code)**
- Use "Cart".

**Anti-patterns to refuse**
- none

**Definition of done**
- RED then GREEN.
