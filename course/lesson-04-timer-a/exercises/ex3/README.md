# Exercise 3 — Milestone: Timer Module

**Requires:** Lessons 01–04 + Exercises 1–2

---

## What to Create

```
handheld/
├── main.s       ← modify: add #include, call timer_init, replace halt loop
└── hal/
    ├── leds.s   ← from L02 (unchanged)
    ├── input.s  ← from L03 (unchanged)
    └── timer.s  ← NEW: you create this
```

## Behavioral Spec

1. **`timer_init`** configures Timer_A for a 5 ms tick (up mode, SMCLK, TAIFG polling)
2. **LED1 heartbeat:** blinks at 2 Hz (toggle every 250 ms = 50 ticks)
3. All timing values defined with `.equ` arithmetic: `TICK_MS`, `TICK_PERIOD`, `BLINK_TICKS`

## Interface Contract

- **Public labels:** `timer_init` (module-prefixed)
- **Constants:** `TICK_MS`, `TICK_PERIOD`, `BLINK_TICKS` (used by main.s for the polling loop)
- **Clobbers:** R12, R13 (timer_init only). Main loop uses R6 as tick-down counter.

## Architecture

Timer_A runs in polling mode for now (interrupts come in Lesson 05).

The main loop structure in `main.s` should be:

```
call    #timer_init
mov.w   #BLINK_TICKS, R6

main_loop:
    poll TAIFG → clear → decrement R6
    if zero: toggle LED1, reload R6
    jmp main_loop
```

The polling loop lives in `main.s`, not in `timer.s` — the timer module only
handles setup. This keeps the main loop visible and modifiable.

## Integration

In `handheld/main.s`:
1. Add `#include "hal/timer.s"` after the other includes
2. Call `timer_init` after `leds_test` completes
3. Replace the `halt: jmp halt` with the polling main loop above
4. Remove the `input_wait_press` / toggle demo from L03 (the timer loop replaces it)

## Build & Test

```sh
cd handheld
make && make flash
```

**Verify:**
- On reset: LED test pattern plays (from leds.s)
- Then: LED1 blinks steadily at 2 Hz (timer-driven)
- Changing only `TICK_MS` adjusts all timing (verify by temporarily setting it to 10)
