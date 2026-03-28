---
name: vector_table_fix
description: MSP430G2553 interrupt vector table was wrong in all files — CC0 was at WDT slot, USCI TX/RX swapped. Fixed 2026-03-24.
type: project
---

The entire course had the MSP430G2553 interrupt vector table shifted by one position from 0xFFF0 onward, and USCI TX/RX swapped. Discovered when L05 blink example wouldn't run — CC0 ISR was placed at 0xFFF4 (WDT slot) instead of 0xFFF2.

**Why:** The original table was written from memory rather than verified against the TI linker script (`msp430g2553.ld`) or datasheet. The authoritative source is `~/ti/msp430-gcc/include/msp430g2553.ld` which defines `VECT10 = 0xFFF2 = timer0_a0 (CC0)`.

**How to apply:** Always cross-check vector addresses against the TI linker script when adding new ISRs. The correct mapping for commonly used vectors:

| Address | Peripheral |
|---------|-----------|
| 0xFFE4  | Port 1 |
| 0xFFEA  | ADC10 |
| 0xFFEC  | USCI TX |
| 0xFFEE  | USCI RX |
| 0xFFF0  | Timer_A overflow (TAIV) |
| 0xFFF2  | Timer_A CC0 |
| 0xFFF4  | WDT |
| 0xFFF6  | Comparator_A+ |
| 0xFFF8  | Timer1_A1 |
| 0xFFFA  | Timer1_A0 |
| 0xFFFC  | NMI |
| 0xFFFE  | Reset |
