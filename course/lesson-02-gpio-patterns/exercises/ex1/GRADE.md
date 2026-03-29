# Exercise 1 — Build a Flash Subroutine: Grade Report

**Grade: B+**

## Functionality (Pass/Fail): PASS

LED1 flashes 3x at 200ms on/off, LED2 flashes 4x at 100ms on/off, 500ms pause, repeat. Success criteria fully met.

## Concept Understanding

Demonstrates solid understanding of register safety — the core concept of this exercise:

1. **Register clobbering:** Correctly identified that `delay_ms` destroys R12 and R13, making them unsafe for persistent values across calls.
2. **Safe register choice:** Moved LED bitmask to R8 and delay time to R4, both in the R4–R11 safe range. The commented-out R12/R13 attempts document the debugging journey.
3. **R12 reload:** Correctly reloads `R4 → R12` before the second `delay_ms` call inside `flash_led` — a detail many students miss.

## Where Points Were Lost

**The subroutine doesn't accept a flash count parameter.** The spec asks for a subroutine that flashes "a given number of times" — meaning the count should be a register argument with a loop inside `flash_led`. Instead, the caller invokes `flash_led` N times manually:

```asm
call    #flash_led
call    #flash_led
call    #flash_led
```

This produces correct output but doesn't scale. A count register (e.g., R5) with a `dec.w` / `jnz` loop inside the subroutine is the intended pattern. The subroutine interface has 2 of the 3 specified parameters (LED bitmask, delay time — but not count).

## Debugging Process

The commented-out code tells a clear story: the initial approach tried passing arguments in R12/R13 (the C-like convention), then copying them to safe registers inside `flash_led`. This broke on repeated calls because the caller only loaded R12/R13 once but called `flash_led` multiple times — after the first call, `delay_ms` had destroyed both argument registers. The student diagnosed this through GDB stepping and arrived at the correct fix: put persistent values in R4–R11 at the call site.

This is exactly the kind of reasoning the exercise is designed to develop.

## Code Quality

- Clean boilerplate (SP, WDT, DCO calibration)
- GPIO init correct (`bis.b` for P1DIR, `bic.b` for P1OUT)
- Main loop structure is readable with labeled phases
- One incorrect comment: line 87 says `; wait R8 ms` but R8 holds the LED bitmask, not the delay

## Summary

The code works and the register-safety lesson landed. The missing piece is parameterizing the flash count inside the subroutine — the `dec.w R5` / `jnz flash_led` loop pattern. That's the difference between a subroutine that encapsulates behavior and a subroutine that requires the caller to manage repetition.
