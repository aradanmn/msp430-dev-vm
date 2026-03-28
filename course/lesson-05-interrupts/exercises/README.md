# Lesson 05 Exercises

Read both tutorials first. Then flash the example (`cd examples && make flash`)
to see an interrupt-driven blink with the CPU sleeping.

---

## Exercise 1 — Convert to Interrupt-Driven

**Requires:** Lessons 01–04 + Tutorial 01 (CC0 interrupt, CCIE, reti)

**File:** `ex1/ex1.s`

Take your Timer_A polling blink from Lesson 04 and convert it to use the
CC0 interrupt + LPM0. The LED1 heartbeat behavior is identical — only the
mechanism changes.

**What changes:**
- The TAIFG polling loop disappears entirely
- CCIE bit enables the CC0 interrupt (look up where it goes — which register?)
- `_start` ends with `bis.w #(GIE|CPUOFF), SR` — CPU sleeps
- The decrement/toggle/reload logic moves into a `timer_isr` ending with `reti`
- The vector table needs `timer_isr` at the correct address (which one? Check
  SLAU144 or the interrupt vector table in `msp430g2553-defs.s`)

**Key question:** Why `reti` and not `ret`? What does `reti` restore that
`ret` doesn't? What happens if you use `ret` instead? (Try it.)

**Success criteria:** LED1 blinks at 2 Hz. No polling loop exists. CPU is in LPM0.

---

## Exercise 2 — ISR Timing Budget

**Requires:** Lessons 01–04 + Exercise 1 (working ISR)

**File:** `ex2/ex2.s`

This exercise teaches you what happens when an ISR takes too long.

A 5 ms tick gives you 5000 CPU cycles per ISR invocation. What happens when
the ISR uses more than that?

**Part A — Observe the failure:**
The provided code has a `timer_isr` that calls `slow_work` — a subroutine
that burns ~6 ms (6000 cycles). With a 5 ms tick, the ISR takes longer than
one tick period.

Build and flash. What happens to LED1? It should blink at 2 Hz — does it?
Why not?

**Part B — Fix it:**
Redesign so the work is spread across multiple ticks. Instead of doing 6 ms
of work every tick, do 1 ms of work on 6 consecutive ticks (or skip work on
most ticks and only run it every Nth tick).

Your redesigned ISR must complete well within 5 ms on every tick.

**Success criteria:** LED1 blinks at 2 Hz again. The ISR never overruns
the tick period. Write comments explaining your timing budget.

---

## Exercise 3 — Milestone: Game Loop Shell

**Requires:** Lessons 01–05 + Exercises 1–2

**What to modify:** `handheld/hal/timer.s` and `handheld/main.s`

See `ex3/README.md` for the full spec.

**Build & test:** `cd handheld && make && make flash`

**Success criteria:** LED1 blinks at 2 Hz. LED2 pulses once on startup.
CPU sleeps in LPM0 between ticks.
