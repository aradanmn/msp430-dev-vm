# Exercise 2 — Find the Bugs: Grade Report

**Grade: A-**

## Functionality (Pass/Fail): PASS

All 3 bugs correctly identified, fixed, and the code produces the correct output: LED1 flashes 5x, LED2 flashes 5x, 500ms pause, repeat.

## Bug Analysis

### Bug 1: `bic.b #LED2, &P1DIR` → `bis.b #LED2, &P1DIR` — FOUND

**Student explanation:** "you are setting the GPIO direction as an input instead of an output"

Correct. `bic.b` clears the direction bit, making P1.6 an input — LED2 can never drive the pin. `bis.b` sets it as an output. Good explanation.

### Bug 2: `mov.b #150, R12` → `mov.w #150, R12` — FOUND

**Student explanation:** "you need to use the 16bit op vs. 8bit"

The fix is correct, but the explanation is thin. For this specific value (150 = 0x96), `mov.b` and `mov.w` actually produce the same result in R12 — byte operations on registers clear the high byte, so R12 ends up as 0x0096 either way. The bug is really about **habit and correctness at scale**: `delay_ms` treats R12 as a 16-bit counter (`dec.w R12`), so loading it with a byte operation is a latent bug. If the delay value were ever > 255 (say, 500ms — which happens in this very same file on line 64), `mov.b` would silently truncate it. Using `.w` consistently for word-sized data is the correct practice.

### Bug 3: `bis.b #LED2, &P1OUT` → `bic.b #LED2, &P1OUT` — FOUND

**Student explanation:** "LED is already on, need to turn it OFF"

Correct. The original code turns LED2 ON twice — it never turns off, so no visible flash. `bic.b` clears the bit to turn it off. This is exactly the kind of `bis`/`bic` confusion that Tutorial 02's "Why Not XOR" section warns about.

## Code Quality

- Original buggy code left as comments with the bug number marked — easy to review
- Fixes are clean and minimal (single instruction changes)
- No unnecessary modifications to surrounding code

## What Could Be Stronger

The explanations are correct but brief. Bug 2 in particular deserved a note about *why* `.w` matters when the value fits in a byte — the answer is that it's a word-sized counter and you're one value change away from silent truncation. Understanding when something "works by accident" vs "works by design" is a key embedded debugging skill.

## Summary

All three bugs found and fixed correctly. The debugging instinct is solid — you're reading `bis` vs `bic` and `.b` vs `.w` with the right level of suspicion. Strengthen your explanations by asking "would this still work if the value changed?" — that's how you distinguish a real bug from a style issue.
