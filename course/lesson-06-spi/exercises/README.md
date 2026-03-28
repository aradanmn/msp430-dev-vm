# Lesson 06 Exercises

Read both tutorials first. For register-level details, open **SLAU144
Chapter 16: USCI — SPI Mode** and the **MSP430G2553 datasheet (SLAS735)**
for pin assignments.

**Hardware for all exercises:** jumper wire from P1.7 (MOSI) to P1.6
(MISO). Remove the LED2 jumper (J5).

Flash the example (`cd examples && make flash`) *after* completing Exercise 1.

---

## Exercise 1 — SPI from the Datasheet

**Type:** Explore
**Requires:** Lessons 01–05 + Tutorial 01 (SPI concepts, UCSWRST pattern)

**File:** `ex1/ex1.s`

Configure USCI_B0 as SPI master and verify with a loopback test. Send 0xA5,
receive it back, LED1 ON if match.

**Conceptual guidance:**
- The UCSWRST pattern: hold reset, configure, release
- You need: clock phase/polarity (Mode 0), bit order (MSB first), master mode, synchronous
- Clock source: SMCLK. Divider: 1 (full speed).
- Three pins need to be switched from GPIO to USCI function

**What to look up in SLAU144 Chapter 16:**
- Which control register holds the mode/phase/polarity bits? What are their names?
- Which control register holds the clock source? Why must you use `bis.b` and not `mov.b`?
- How do you know a byte has finished transmitting? Which flag, in which register?
- How do you know a received byte is ready?

**What to look up in the MSP430G2553 datasheet (SLAS735):**
- Which pins are UCB0CLK, UCB0SIMO, UCB0SOMI?
- What P1SEL/P1SEL2 values select the USCI_B0 function?

**Success criteria:** LED1 ON after reset (with loopback wire). LED1 OFF
without the wire.

---

## Exercise 2 — Find the Bugs

**Type:** Challenge
**Requires:** Lessons 01–06 + Exercise 1

**File:** `ex2/ex2.s`

This code configures SPI and runs a loopback test combined with a Timer_A
heartbeat. It compiles, but has **4 bugs**. Find them, fix them, and explain
each one as a comment.

**Approach:** Read each line against the datasheet. For SPI config, check
every register write. For the main flow, trace what happens step by step.

**Success criteria:** After fixing all 4 bugs, LED1 blinks at 1 Hz (proving
the timer works) and the SPI loopback test passes (LED1 ON after the test,
then starts blinking).

---

## Exercise 3 — Milestone: SPI Driver

**Type:** Milestone
**Requires:** Lessons 01–06 + Exercises 1–2

**What to create:** `handheld/hal/spi.s`

See `ex3/README.md` for the full spec.

**Build & test:** `cd handheld && make && make flash`

**Success criteria:** LED1 heartbeat continues. SPI is initialized and ready
for the display driver in Lesson 07.
