# Exercise 3 — Milestone: LED Test Module: Grade Report

**Grade: A-**

## Functionality (Pass/Fail): PASS

On reset: LED1 flashes 3x (150ms), LED2 flashes 3x (150ms), both flash 2x (250ms), both OFF, halt. Success criteria fully met.

## What You Got Right

- **`leds_init`** — clean and correct. Sets both LED pins as outputs, clears both. Two instructions, no waste.
- **`leds_test`** — produces the exact pattern from the spec. All three phases (LED1, LED2, both) with correct counts and timing.
- **Flash count loop** — you added the `dec.w R10` / `jnz` loop inside `leds_test` that was missing from Ex 2-1. That's direct growth from the grading feedback.
- **`.Lflash_led` subroutine** — clean interface: R8 = LED mask, R9 = delay. R12 reload after `delay_ms` is correct.
- **Local labels** — all internal labels use `.L` prefix (`.Lstate_zero`, `.Lflash_led`, `.Ldelay_ms`, etc.) per the interface contract.
- **`delay_ms` included** — module is self-contained as specified.
- **Integration** — `main.s` calls `leds_init` then `leds_test`, halts after. `#include` placed after halt loop so `_start` stays at 0xC000.
- **`delay_ms` comments** — the cycle-count breakdown (333 × 3 = 999 ≈ 1ms) shows you understand *why* 333, not just that it's the number to use.

## Where Points Were Lost

**R4–R11 clobbering.** The interface contract states "Must NOT clobber R4–R11," but `leds_test` writes to R8, R9, and R10 without preserving them. Right now this doesn't matter — `main.s` doesn't use those registers before the call. But as the handheld grows, other modules will depend on R4–R11 being safe across calls. The fix is `push`/`pop`, which you'll learn in Lesson 04. This is noted, not penalized heavily — you don't have the tool yet.

## File Naming

The spec says `leds.s` (plural); you created `led.s`. Not a functional issue, but worth aligning with the spec for consistency as modules accumulate.

## Growth from Ex 2-1

The biggest improvement: you now use a count register (R10) with a `dec`/`jnz` loop inside the subroutine, instead of calling `flash_led` N times manually. That's the pattern the Ex 2-1 feedback pointed to, and you applied it here without being told to. That's exactly how this course is supposed to work.

## Summary

This is a solid first handheld module. The behavioral spec is met exactly, the code is well-structured, and the integration with `main.s` is correct. The R4–R11 contract violation is the only real issue, and you'll have the tools to fix it in two lessons.
