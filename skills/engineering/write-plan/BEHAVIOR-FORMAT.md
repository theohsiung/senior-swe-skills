# Behavior description format

A behavior is what `/tdd` will write a test for. The behavior description has to be specific enough to derive a test from, but free of test code or implementation detail.

If you can't tell from the description whether the test should mock the database or call it for real, the description is missing context. Add it.

## The shape

```
A <actor> can <observable action>,
so that <outcome they care about>.

Verified through: <which public interface call shows this is true>.

Domain vocabulary: <terms from CONTEXT.md to use>.
```

## Good behaviors

### A user can retrieve a customer they just created

> **A** front-of-house operator **can** look up a Customer by the ID returned from `register_customer`, **so that** they confirm the registration succeeded before sending the welcome email.
>
> **Verified through:** call `register_customer(...)`, take the returned `customer_id`, call `get_customer(customer_id)`, assert the returned Customer has the same name.
>
> **Domain vocabulary:** Customer, register_customer, get_customer (all from CONTEXT.md).

✅ Why this is good:
- User-visible action ("look up")
- Verified entirely through public interface (no DB query)
- Outcome stated ("confirm registration")
- Pinned to domain vocabulary

### A cancelled Order releases its inventory hold

> **An** Order **can** transition from `confirmed` to `cancelled`, **so that** its inventory hold is released and the held items become available to other Orders.
>
> **Verified through:** seed an Order in `confirmed`, call `cancel_order(order_id)`, then call `available_inventory(sku)` and assert the count rose by the held quantity.
>
> **Domain vocabulary:** Order, inventory hold, cancel_order, available_inventory.

✅ Why this is good:
- The cause-and-effect is observable
- Verified through a *paired* read interface (`available_inventory`), not by querying the holds table
- The vocabulary matches the domain language

## Bad behaviors (and how to fix)

### ❌ "createUser saves to database"

Why bad: describes HOW, not WHAT. Couples test to storage choice.

✅ Fix: "A new user is retrievable by ID after creation."

### ❌ "OrderService.cancel calls inventory.release"

Why bad: testing internal collaboration. Will mock `inventory.release` and assert it was called — Matt's anti-pattern (`tests.md`).

✅ Fix: "Cancelling an Order makes its held inventory available again." (Verified through the `available_inventory` read, not by spying on the call.)

### ❌ "function returns { id: string, status: 'confirmed' }"

Why bad: testing the shape of the response, not the behavior. The shape will change when the API evolves; the test breaks for the wrong reason.

✅ Fix: "After successful checkout, the customer can fetch the order and see status `confirmed`."

### ❌ "validates email format"

Why bad: too vague. Is this through a form? An API? A library function? What's the user-visible failure mode?

✅ Fix: "Submitting registration with a malformed email returns a 400 with an error code the UI can map to the email field."

### ❌ "feature works correctly"

Why bad: not a test, not a behavior. No actor, no action, no outcome.

✅ Fix: write each user-visible behavior as a separate task; this isn't one.

## Smell test

Before locking a behavior into the plan, ask:

1. **Could a non-engineer read this and tell whether it's done?** If no, you're describing implementation.
2. **Does the verification path use only the public interface?** If you have to peek behind the interface, the design is wrong, not the test. Send the user to `/design-like-senior` to widen the public surface, or remove the behavior.
3. **Does the domain vocabulary match `CONTEXT.md`?** If you're inventing terms, you've drifted from the domain language. Update `CONTEXT.md` first via `/grill-with-docs`.
4. **Would this test survive a complete rewrite of the implementation?** If renaming an internal function would break it, it's an implementation test in disguise.

If any answer is no, rewrite the behavior before saving the plan.
