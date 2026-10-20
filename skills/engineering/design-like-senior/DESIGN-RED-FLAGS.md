# Design red flags

Screen every Step 5 / Step 6 recommendation against this list **before** presenting it. A red flag is a reason to revise the shape, or to name it explicitly under "Considered & rejected" with why it's acceptable here.

Read each flag from the point of view of the next contributor — very likely an agent — that **sees only the files it opened, copies the nearest example, and takes the shortest path that compiles**. A shape that's fine for a careful human who read everything can still rot fast under that contributor.

Vocabulary (module, interface, seam, depth, leverage, locality) is defined in [`../improve-codebase-architecture/LANGUAGE.md`](../improve-codebase-architecture/LANGUAGE.md). `/improve-codebase-architecture` and `/code-review` use the same list against existing code.

## Classic depth flags

### Shallow module

The interface is nearly as large as the implementation behind it, so there's little **leverage**. Signs:

- Callers coordinate several calls to complete one operation.
- Public options expose internal stages or implementation choices.
- Learning the interface doesn't save the caller from learning the implementation.

Don't confuse a deep module with a deep call chain: a chain scatters understanding across layers; a deep module concentrates it behind one interface.

### Information leakage

Two or more modules depend on the same internal decision (a representation, policy, wire format), so changing it needs coordinated edits — **locality** is lost. Re-exporting transport / ORM / framework types across a seam is leakage. Parse external data into domain types behind the interface.

### Temporal decomposition

Modules are split by execution order (load → validate → transform → save) instead of by the knowledge they own, so one representation and its invariants are repeated across several seams. Group by domain knowledge; methods that run at different times can still belong to one module when they protect the same decisions.

### Pass-through method

A method forwards the same arguments to another method with the same shape. It adds a seam without hiding anything. Apply the deletion test; keep a forwarding layer only when it adds policy, adaptation, or a distinct abstraction.

## Agent-amplified flags

These four are tolerable with a careful team and corrosive with agents, because agents pattern-match on whatever they opened first.

### Split ownership

More than one module writes the same state, or keeps its own copy. An agent editing one writer can't see the others, so their rules diverge. **Fix:** one owner per piece of state; everyone else reads it or asks the owner to change it.

### Two ways to do one task

The design supports more than one way to do the same thing (two clients, two date helpers, sync and async variants of the same call). An agent copies whichever it finds first, so every way keeps gaining callers. **Fix:** keep one way; migrate callers and delete the others in the same change — no compatibility shim left behind. The one sanctioned exception is a wide refactor too big for one change: run it as expand–contract (see `/to-issues`), where the two forms coexist only until the contract slice deletes the old one.

### Importable internals

A caller *can* import a module's internals. An agent takes the shortest path that compiles, so internals quietly become interface. **Fix:** make internals unreachable from outside (package-private, `internal/`, `__all__` + lint, export maps, dependency-cruiser rule) so an outside import fails the build.

### Hand-synced list

Two or more places list the same items (enum + switch + docs table + migration), and adding an item means editing every list. An agent updates the one it saw. **Fix:** keep one list and derive the rest; if a list can't be derived, make the build fail when the lists disagree.

## How to use it in design.md

For each new module or public addition, add one line under the recommendation:

```md
Red-flag screen: clean | <flag> — accepted because <constraint> | <flag> — revised: <what changed>
```

Silence is not a pass: if you didn't screen it, don't write "clean".
