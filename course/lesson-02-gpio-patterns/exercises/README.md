# Lesson 02 Exercises

Read both tutorials and flash the example first (`cd examples && make flash`).
Study what the example does — but design your own solutions, don't copy its structure.

---

## Exercise 1 — Build a Flash Subroutine

**Requires:** Lesson 01 (delay_ms, bis.b/bic.b, subroutine calls)

**File:** `ex1/ex1.s`

Write a `flash_led` subroutine that flashes a given LED a given number of times
at a given speed. Then call it from main to produce this sequence:

1. Flash LED1 3 times at 200 ms on/off
2. Flash LED2 4 times at 100 ms on/off
3. 500 ms pause
4. Repeat forever

**You design the subroutine interface.** Decide:
- Which register holds the LED bitmask?
- Which register holds the flash count?
- Which register holds the on/off time in ms?
- Which registers does `delay_ms` clobber? Which are safe to use?

**Success criteria:** LED1 flashes 3x slow, LED2 flashes 4x fast, pause, repeat.

---

## Exercise 2 — Find the Bugs

**Requires:** Lesson 01–02 tutorials + Exercise 1

**File:** `ex2/ex2.s`

This code is supposed to flash LED1 and LED2 alternately, 5 times each, then
pause and repeat. It compiles without errors, but it doesn't work correctly.

There are **3 bugs**. Find them, explain what each one does wrong, and fix them.

Write your explanations as comments next to each fix.

**Success criteria:** After fixing all 3 bugs, LEDs alternate 5x each with
a pause between rounds.

---

## Exercise 3 — Milestone: LED Test Module

**Requires:** Lessons 01–02 + Exercises 1–2

This is your first **handheld milestone**. Create a real module for the
handheld platform.

See `ex3/README.md` for the full spec, or go straight to `handheld/`.

**What to create:** `handheld/hal/leds.s` with `leds_init` and `leds_test`.

**Build & test:** `cd handheld && make && make flash`

**Success criteria:** On reset, an LED test pattern plays once, then halts.
