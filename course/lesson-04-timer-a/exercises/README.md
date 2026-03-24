# Lesson 04 Exercises

Run the example first (`cd examples && make flash`) and observe LED1 (2 Hz)
and LED2 (5 Hz) blinking independently — both driven by one 10 ms timer tick.

Each exercise builds on the previous. By Exercise 3 you are combining Timer_A,
dual-channel counting, and button edge detection with no assistance from the
skeleton beyond the behaviour spec.

---

## Exercise 1 — Hardware Blink

**Requires:** Lessons 1–3 (GPIO setup, register operations)

**File:** `ex1/ex1.s`

Replace the `delay_ms` software loop with a Timer_A polling loop.
Blink LED1 at exactly **2 Hz** (toggle every 250 ms).

**What to implement:**
- Define `TICK_PERIOD` and `BLINK_TICKS` as `.equ` constants (compute the values)
- Write TACCR0 then TACTL to start Timer_A
- Main loop: poll TAIFG, clear it, decrement counter, toggle + reload when zero
- No `delay_ms` or `call` instructions

**New instructions:** `bit.w`, `bic.w` (16-bit equivalents of `bit.b`/`bic.b`)

**Success criteria:** LED1 blinks at 2 Hz. Rate doesn't drift. Changing only
`TICK_PERIOD` adjusts timing throughout with no other edits.

---

## Exercise 2 — Dual-Rate Blinker

**Requires:** Lessons 1–3 + Exercise 1 (Timer_A polling loop)

**File:** `ex2/ex2.s`

Drive two LEDs at different rates from one timer — one TAIFG poll, two channels:
- **LED1** toggles every **500 ms** (1 Hz)
- **LED2** toggles every **125 ms** (4 Hz)

**What to implement:**
- Choose a tick period that divides evenly into both intervals
- Define `TICK_PERIOD`, `LED1_TICKS`, `LED2_TICKS` as `.equ` constants
- Two independent tick-down counters; service both after every tick

**Success criteria:** Both LEDs blink at their rates simultaneously.
Neither channel affects the other.

---

## Exercise 3 — Adjustable-Speed Blinker

**Requires:** Lessons 1–3 + Exercises 1–2 (timer tick + dual-channel counting)

**File:** `ex3/ex3.s`

LED1 blinks continuously. Each button press cycles through four speeds:

| Speed | Toggle period | Rate |
|-------|--------------|------|
| 0 (slow) | 500 ms | 1 Hz |
| 1 | 250 ms | 2 Hz |
| 2 | 100 ms | 5 Hz |
| 3 (fast) | 50 ms | 10 Hz |

LED2 flashes for 200 ms to acknowledge each speed change.

**What to implement:**
- `apply_speed` subroutine: reads speed index from R8, writes tick count to R9
- Button edge detection on each tick — no `delay_ms`, no blocking wait
- LED2 acknowledgement countdown driven by the same tick

**Success criteria:** Each press advances the speed exactly once. LED1 rate
changes immediately. LED2 flashes briefly on each press.

---

## Common Traps

- Writing TACTL before TACCR0 — timer fires at rate zero
- Forgetting `bic.w #TAIFG, &TACTL` — next poll fires instantly
- Using `bit.b` on TACTL — TACTL is a 16-bit register
- Reloading the counter before the action (toggle first, then reload)
