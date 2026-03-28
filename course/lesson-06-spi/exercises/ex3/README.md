# Exercise 3 — Milestone: SPI Driver

**Requires:** Lessons 01–06 + Exercises 1–2

---

## What to Create

```
handheld/
├── main.s       ← modify: add #include, call spi_init
└── hal/
    ├── leds.s   ← from L02 (unchanged)
    ├── input.s  ← from L03 (unchanged)
    ├── timer.s  ← from L05 (unchanged)
    └── spi.s    ← NEW: you create this
```

## Behavioral Spec

1. **`spi_init`** configures USCI_B0 as SPI master (Mode 0, MSB first, SMCLK, 1 MHz)
2. **`spi_tx_byte`** sends one byte (R12 in), returns received byte (R12 out)
3. **LED1 heartbeat** continues at 2 Hz (timer_isr unchanged)
4. **SPI is ready** for Lesson 07 to use

## Interface Contract

- **Public labels:** `spi_init`, `spi_tx_byte`
- **Local labels:** `.L` prefix (e.g., `.Lspi_tx_wait`)
- **spi_tx_byte:** R12 in/out, no other registers clobbered
- **spi_init:** may clobber R12, R13

## Architecture

- `spi.s` is `#include`'d into `main.s` (same pattern as timer.s)
- `spi_init` is called from `_start` after `timer_init`
- `spi_tx_byte` uses polling (TXIFG/RXIFG in IFG2) — no interrupts needed
- The UCSWRST pattern: hold reset, configure everything, release

## Integration

In `handheld/main.s`:
1. Add `#include "hal/spi.s"` after the other includes
2. Add `call #spi_init` to the init sequence (after timer_init)

## Build & Test

```sh
cd handheld
make && make flash
```

**Verify:**
- LED1 still blinks at 2 Hz (ISR unbroken)
- No crash on reset (SPI init completes without hanging)
- Optional: add a temporary loopback test before LPM0 entry to verify
  spi_tx_byte works (send 0xA5, check LED1). Remove after confirming.

## Hardware Note

When SPI is active, P1.6 is MISO — **remove the LED2 jumper (J5)**.
LED2 is no longer available. The startup pulse from L05 will need to be
disabled or moved to LED1. Your call — either remove it or adapt it.
