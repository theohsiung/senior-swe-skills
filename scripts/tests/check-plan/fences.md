# Fence Plan

**Goal:** Catch test code in any fence style.
**Design doc:** `docs/features/fences/design.md`
**Task IDs:** assigned in creation order, never reused.

---

### T-001: Indented fence hides test code

**Behavior to verify**
A user can do a thing.

  ```py
  def test_thing():
      assert thing() == 1
  ```

**Public interface this task introduces**
- Level: module-public

**Files**
- Create: `src/thing.py`

**Test framing hints (NOT test code)**
- none

**Anti-patterns to refuse**
- none

**Definition of done**
- done

### T-002: Tilde fence hides test code

**Behavior to verify**
A user can do another thing.

~~~ts
expect(other()).toBe(2);
~~~

**Public interface this task introduces**
- Level: module-public

**Files**
- Create: `src/other.ts`

**Test framing hints (NOT test code)**
- none

**Anti-patterns to refuse**
- none

**Definition of done**
- done
