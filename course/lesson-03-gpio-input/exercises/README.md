# Lesson 03 Exercises

Read both tutorials and flash the example first (`cd examples && make flash`).
Observe the three input modes — level, transition, and edge detection.

---

## Exercise 1 — Button Without Debounce

**Requires:** Tutorial 01 (GPIO input, pull-up, bit.b)

**File:** `ex1/ex1.s`

Write a toggle-on-press program **without** any debounce. Each time you press
S2, LED1 should toggle (on→off→on→...).

The catch: it won't work reliably. When you press the button, LED1 will
sometimes toggle once, sometimes toggle several times (ending in a random
state). This is **by design** — you need to see the problem before you can
solve it.

To implement toggle-on-press without debounce:
- Poll P1IN for a press (bit goes LOW)
- Toggle LED1
- Poll P1IN for release (bit goes HIGH)
- Repeat

**What to observe:** Press the button slowly and watch LED1. Does it toggle
exactly once per press? Or does it sometimes end up in the wrong state?

**Success criteria:** The program runs. LED1 toggles, but unreliably.
Understand *why* it's unreliable before moving to Exercise 2.

---

## Exercise 2 — Design a Debounce

**Requires:** Tutorial 02 (debounce concept) + Exercise 1 (seeing the problem)

**File:** `ex2/ex2.s`

Fix Exercise 1. Make LED1 toggle exactly once per press, every time.

The tutorial explains what button bounce is — mechanical contacts making and
breaking rapidly for a few milliseconds after a press or release. Your job is
to design a strategy that filters it out.

There are multiple valid approaches:
- **Delay and re-read:** After detecting a press, wait N ms, re-read the pin.
  If it's still pressed, it's real. Same for release.
- **Two-sample agreement:** Read the pin on every loop iteration, only act when
  two consecutive reads agree (and differ from the previous state).
- **Counter-based:** Require the pin to be stable for N consecutive reads.

Pick one and implement it. Add an LED2 flash (80 ms) after each confirmed press
as visual acknowledgement.

**Success criteria:** LED1 toggles exactly once per press. LED2 flashes once.
No ghost toggles. Test with fast presses and long holds.

---

## Exercise 3 — Milestone: Button Handler Module

**Requires:** Lessons 01–03 + Exercises 1–2

**What to create:** `handheld/hal/input.s`

See `ex3/README.md` for the full spec.

**Build & test:** `cd handheld && make && make flash`

**Success criteria:** Press S2 to toggle LED1, with debounce. LED2 flashes on
each confirmed press.
