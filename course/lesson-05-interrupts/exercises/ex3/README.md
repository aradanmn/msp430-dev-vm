# Exercise 3 — Milestone: Game Loop Shell

**Requires:** Lessons 01–05 + Exercises 1–2

This milestone converts the handheld from polling to interrupt-driven operation.
After this, the CPU sleeps between ticks — the game loop foundation.

---

## What to Modify

```
handheld/
├── main.s       ← rewrite: LPM0 entry, vector table with timer_isr
└── hal/
    ├── leds.s   ← from L02 (unchanged)
    ├── input.s  ← from L03 (unchanged)
    └── timer.s  ← REWRITE: CC0 ISR replaces polling
```

## Behavioral Spec

1. **LED1 blinks at 2 Hz** (toggle every 250 ms) — driven by timer_isr
2. **LED2 pulses once on startup** (ON for 200 ms, then OFF permanently)
3. **CPU sleeps in LPM0** between ticks (`bis.w #(GIE|CPUOFF), SR`)
4. **All timing via `.equ` arithmetic** — TICK_MS, TICK_PERIOD, BLINK_TICKS, STARTUP_TICKS
5. **`game_update` stub** in main.s (just `ret`) — will be filled in later

## Architecture Changes from L04

- `timer.s` now provides: `timer_init` (adds CCIE) and `timer_isr` (CC0 ISR)
- The polling main loop in `main.s` is replaced by `bis.w #(GIE|CPUOFF), SR`
- `main.s` owns the vector table: `timer_isr` at 0xFFF2, `_start` at 0xFFFE
- LED2 startup pulse: use a one-shot countdown register (R12 works for now
  since nothing else uses it; later lessons will move it to RAM)

## Register Usage

| Register | Role |
|----------|------|
| **R4** | Blink tick counter — decremented each tick, reloaded on zero |
| **R12** | Startup countdown (one-shot) — decremented from STARTUP_TICKS to 0 |

## Build & Test

```sh
cd handheld
make && make flash
```

**Verify:**
- LED2 lights on reset, turns off after ~200 ms
- LED1 blinks steadily at 2 Hz
- No polling loop — CPU is in LPM0
- `leds_test` pattern still plays on startup (before entering LPM0)
