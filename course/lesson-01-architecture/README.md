# Lesson 01 — Architecture & Toolchain

**Goal:** Understand what's inside the MSP430G2553, write your first assembly program, and get it running on the LaunchPad.

**Game connection:** Every Tetris game loop, every pixel update, every button read starts here — understanding the CPU registers and memory map is how you know where everything lives.

---

## What You'll Learn

- The MSP430G2553's memory map (Flash, RAM, peripherals, Info Flash)
- The 16 CPU registers and what each one does
- The most common instructions: MOV, ADD, SUB, AND, OR, BIC, BIS, BIT
- The four addressing modes: register, immediate, absolute, indirect
- How to build, flash, and debug with the toolchain
- How to write a software delay loop calibrated to 1 MHz

---

## Hardware

Just the **MSP-EXP430G2 LaunchPad** connected via USB. No extra components needed.

---

## Files

```
lesson-01-architecture/
├── README.md                        ← you are here
├── tutorial-01-msp430g2553-overview.md   ← architecture deep dive
├── tutorial-02-toolchain-workflow.md     ← build, flash, debug
├── examples/
│   ├── Makefile
│   └── blink.s                      ← LED1 blinks at 1 Hz
└── exercises/
    ├── README.md                    ← exercise descriptions
    ├── ex1/   ex1/solution/         ← change the blink rate
    ├── ex2/   ex2/solution/         ← alternate two LEDs
    └── ex3/   ex3/solution/         ← SOS in Morse code
```

---

## Suggested Path

1. Skim `../common/glossary.md` — a quick-reference for all the acronyms and terminology used in this course. You don't need to memorize it now; come back whenever an abbreviation looks unfamiliar.
2. Read `tutorial-01-msp430g2553-overview.md`
3. Read `tutorial-02-toolchain-workflow.md`
4. Run the example: `cd examples && make flash`
5. Attempt the exercises **before** looking at solutions
6. When all three exercises pass, move to Lesson 02

---

## Key Facts to Memorize

| Thing | Value |
|-------|-------|
| Flash (program storage) | 0xC000–0xFFFF (16 KB) |
| RAM (variables) | 0x0200–0x03FF (512 B) |
| Reset vector | 0xFFFE (points to `_start`) |
| LED1 (Red) | P1.0 |
| LED2 (Green) | P1.6 |
| Button S2 | P1.3 (active LOW) |
| Stack starts at | 0x0400 (top of RAM, grows down) |
| Clock after calibration | 1 MHz (MCLK = SMCLK = DCO) |
