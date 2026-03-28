# Lesson 04 Exercises

Read both tutorials first. The first tutorial explains *why* hardware timers
exist and *how* they work conceptually. For register-level details, open the
**MSP430x2xx Family User's Guide (SLAU144), Chapter 12: Timer_A**.

Run the example (`cd examples && make flash`) *after* attempting Exercise 1.

---

## Exercise 1 — Timer from the Datasheet

**Requires:** Lessons 01–03 + Tutorial 01 (Timer_A concepts)

**File:** `ex1/ex1.s`

Configure Timer_A to blink LED1 at 2 Hz (toggle every 250 ms), using a
polling loop instead of `delay_ms`.

**Conceptual guidance:**
- You need Timer_A in "up mode" — the counter counts from 0 to a compare
  value, sets a flag, and resets. This is your tick.
- Choose a tick interval (e.g., 5 ms). Compute the compare value from the
  clock frequency (1 MHz). Compute how many ticks = 250 ms.
- The main loop polls the overflow flag, clears it, and decrements a counter.

**What to look up in SLAU144 Chapter 12:**
- What register holds the compare value? (Hint: "capture/compare register")
- What register controls clock source and mode? What bits select SMCLK and up mode?
- What flag indicates the counter reached the compare value? Where is it?
- How do you clear that flag?

Use `.equ` constants for all timing values. Define `TICK_MS`, then derive
everything else from it with arithmetic.

**Success criteria:** LED1 blinks at 2 Hz. No `delay_ms` or `call` in the main loop.

---

## Exercise 2 — Timing Analysis Challenge

**Requires:** Lessons 01–03 + Exercise 1 (Timer_A working)

**File:** `ex2/ex2.s`

A game designer gives you this spec:
- **LED1** blinks at **1.5 Hz** (toggle every 333.3 ms)
- **LED2** blinks at **3.7 Hz** (toggle every 135.1 ms)
- Both driven from one timer tick

Questions to answer (write your analysis as comments in the file):
1. What tick period divides evenly into both intervals? (Trick question — does one exist?)
2. What tick period gives the best approximation for both? What is the error for each?
3. Implement your chosen compromise. Document the actual rates achieved vs the spec.

This is a real embedded constraint: you can't always hit exact frequencies.
The skill is choosing the best tradeoff and knowing the error.

**Success criteria:** Both LEDs blink at approximately the specified rates.
Your analysis comments explain the tick choice and quantify the timing error.

---

## Exercise 3 — Milestone: Timer Module

**Requires:** Lessons 01–04 + Exercises 1–2

**What to create:** `handheld/hal/timer.s`

See `ex3/README.md` for the full spec.

**Build & test:** `cd handheld && make && make flash`

**Success criteria:** LED1 blinks at 2 Hz using Timer_A polling. The
`leds_test` pattern plays first (from leds.s), then the timer-driven blink
runs indefinitely.
