# Exercise 3 — Milestone: Button Handler Module

**Requires:** Lessons 01–03 + Exercises 1–2

---

## What to Create

```
handheld/
├── main.s       ← modify: add #include, call input_init, add toggle demo
└── hal/
    ├── leds.s   ← from L02 (unchanged)
    └── input.s  ← NEW: you create this
```

## Behavioral Spec

1. **`input_init`** configures S2 (P1.3) as input with internal pull-up
2. **`input_wait_press`** blocks until a debounced button press is confirmed, then returns
3. **`input_wait_release`** blocks until a debounced button release is confirmed, then returns

Both wait subroutines include debounce (your design from Ex2).

## Interface Contract

- **Public labels:** `input_init`, `input_wait_press`, `input_wait_release`
- **Clobbers:** R12, R13 (caller-saved). Must NOT clobber R4–R11.
- **Dependencies:** needs `delay_ms` — either include it in input.s or rely on
  it being included via leds.s (since both are compiled into one file via main.s)

## Integration

In `handheld/main.s`:
1. Add `#include "hal/input.s"` after the other includes
2. After `leds_test`, add a toggle demo loop:
   - Call `input_wait_press`
   - Toggle LED1
   - Flash LED2 for 80 ms (acknowledgement)
   - Call `input_wait_release`
   - Repeat

This demo loop proves the button handler works before the timer replaces
software delays in Lesson 04.

## Build & Test

```sh
cd handheld
make && make flash
```

**Verify:**
- On reset: LED test pattern plays (from leds.s)
- Then: each button press toggles LED1 exactly once
- LED2 flashes once per press
- No ghost toggles on press or release
- Hold the button down: nothing changes until release + next press
