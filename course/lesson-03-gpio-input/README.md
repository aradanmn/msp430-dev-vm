# Lesson 03 — GPIO Input & Buttons

**Goal:** Read a physical button and react to it — first as a level signal,
then as a debounced edge so each press registers exactly once.

**Game connection:** Every game needs input. The techniques here — polling,
debouncing, edge detection, and the press/release subroutine — are the same
primitives you'll use to advance game state, navigate menus, and fire.

---

## What You'll Learn

- `P1DIR`, `P1REN`, `P1OUT` working together to configure an input with pull-up
- `P1IN` — reading the actual voltage on a pin
- `bit.b` + `jz`/`jnz` for conditional branching on pin state
- Level detection: LED tracks button continuously
- Why buttons bounce and what it looks like to the MCU
- Software debounce: delay + re-read to confirm
- Edge detection: detect press, debounce, wait for release
- Wrapping the pattern into a reusable `wait_button_press` subroutine

---

## Hardware

**MSP-EXP430G2 LaunchPad** — USB only, no external components needed.

| Signal | Pin | Notes |
|--------|-----|-------|
| LED1 | P1.0 | Red |
| LED2 | P1.6 | Green |
| S2 (BTN) | P1.3 | Active LOW, needs pull-up |

---

## Files

```
lesson-03-gpio-input/
├── README.md                          ← you are here
├── tutorial-01-gpio-input.md          ← P1IN, P1REN, pull-up, bit.b, jz/jnz
├── tutorial-02-debounce-and-edge.md   ← bounce explanation, software debounce, edge pattern
├── examples/
│   ├── Makefile
│   └── button.s                       ← three input modes in one demo
└── exercises/
    ├── README.md                      ← exercise descriptions
    ├── ex1/                           ← toggle without debounce (see the problem)
    ├── ex2/                           ← design your own debounce (fix the problem)
    └── ex3/                           ← milestone: create handheld/hal/input.s
```

---

## Suggested Path

1. Read `tutorial-01-gpio-input.md`
2. Read `tutorial-02-debounce-and-edge.md`
3. Run the example: `cd examples && make flash`
   - Hold S2: LED1 follows the button (level mode)
   - Release: watch the transition phase
   - After 3 seconds: edge mode — each press toggles LED1
4. Attempt the exercises — study the example *after*, not before

---

## Key Facts to Memorize

```
Active LOW button:
  released → P1.3 = 1 (HIGH, pulled up)
  pressed  → P1.3 = 0 (LOW, shorted to GND)

bit.b result:
  pin HIGH → Zero flag CLEAR → jnz branches
  pin LOW  → Zero flag SET   → jz  branches

Input setup (always all three):
  bic.b #BTN, &P1DIR   ; input
  bis.b #BTN, &P1REN   ; enable resistor
  bis.b #BTN, &P1OUT   ; pull-up
```

| Waiting for... | Loop test |
|----------------|-----------|
| Press (LOW) | `bit.b #BTN, &P1IN` / `jnz wait` |
| Release (HIGH) | `bit.b #BTN, &P1IN` / `jz wait` |
