# Lesson 01 Exercises

Work through these in order. Attempt each one **without** looking at the solution. The goal is to get the code working on the LaunchPad, not just to read it.

---

## Exercise 1 — Faster Blink (Easy)

**Problem:** Change the blink rate from 1 Hz to 4 Hz (LED toggles every 125 ms).

**Hint:** You only need to change one number.

**Pass condition:** LED1 visibly blinks faster — four complete blinks per second.

**File:** `ex1/ex1.s`

---

## Exercise 2 — Alternating LEDs (Medium)

**Problem:** Make LED1 (Red, P1.0) and LED2 (Green, P1.6) alternate — when one is ON the other is OFF. Both should toggle every 250 ms.

**What you need to know:**
- LED2 is P1.6. The constant `LED2 = BIT6` is already in the defs file.
- Configure both pins as outputs.
- Use `bis.b` and `bic.b` to set/clear individual bits (don't just toggle both at once — practice the "set one, clear the other" pattern).

**Starting state:** LED1 ON, LED2 OFF.

**Pass condition:** LEDs alternate cleanly with a 250 ms period, never both on or both off at the same time.

**File:** `ex2/ex2.s`

---

## Exercise 3 — SOS Morse Code (Hard)

**Problem:** Blink LED1 in the SOS Morse code pattern, then pause and repeat.

**SOS pattern:**
```
S = · · ·     (3 short flashes)
O = — — —     (3 long flashes)
S = · · ·     (3 short flashes)
              [long pause before repeating]
```

**Timing rules (standard Morse, simplified):**
- Dot (·):   LED ON 150 ms, OFF 150 ms
- Dash (—):  LED ON 450 ms, OFF 150 ms
- Gap between letters: extra 300 ms off (so 150 + 300 = 450 ms total between letters)
- Gap after full SOS: 1000 ms off before repeating

**What you need to know:**
- You'll need to call `delay_ms` with different values for short vs long flashes.
- Use `bis.b` to turn the LED on and `bic.b` to turn it off (not `xor.b` — you need explicit on/off control here).
- You can either write out all the flashes explicitly, or try building a small helper routine.

**Pass condition:** A recognizable SOS pattern that repeats indefinitely. Compare against any online Morse decoder.

**File:** `ex3/ex3.s`

---

## Solutions

Solutions are in `exN/solution/`. Only look after you've made a genuine attempt. Understanding your own mistakes is the lesson.
