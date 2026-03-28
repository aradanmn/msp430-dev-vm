# Exercise 3 — Milestone: LED Test Module

**Requires:** Lessons 01–02 + Exercises 1–2

This is your first **handheld milestone**. You create a real module that
becomes a permanent part of the growing handheld platform.

---

## What to Create

```
handheld/
├── main.s       ← modify: add #include and init calls
└── hal/
    └── leds.s   ← NEW: you create this
```

## Behavioral Spec

1. **`leds_init`** configures LED1 (P1.0) and LED2 (P1.6) as outputs, both OFF
2. **`leds_test`** runs a visible self-test pattern:
   - LED1 flashes 3 times (150 ms on/off)
   - LED2 flashes 3 times (150 ms on/off)
   - Both LEDs flash together 2 times (250 ms on/off)
   - Both LEDs OFF when done
3. Include your `delay_ms` subroutine from Lesson 01 in the module

## Interface Contract

- **Public labels:** `leds_init`, `leds_test` (module-prefixed names)
- **Local labels:** use `.L` prefix (e.g., `.Lflash_loop`)
- **Clobbers:** R12, R13 (caller-saved). Must NOT clobber R4–R11.
- **Dependencies:** none — this module is self-contained (includes its own delay)

## Integration

In `handheld/main.s`:
1. Add `#include "hal/leds.s"` after the `_start` code (before the vector table)
2. Add `call #leds_init` and `call #leds_test` to the init sequence

## Build & Test

```sh
cd handheld
make              # should compile cleanly
make flash        # flash to LaunchPad
```

**Verify:**
- On reset: LED test pattern plays (LED1 3x, LED2 3x, both 2x)
- After the test: both LEDs OFF, program halts
- Press the reset button to see the pattern again
