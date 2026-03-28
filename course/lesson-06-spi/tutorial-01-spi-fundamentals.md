# Tutorial 01 — SPI Fundamentals

## What Is SPI?

SPI (Serial Peripheral Interface) is a synchronous serial bus. It sends
data one bit at a time, clocked by a shared clock signal. Unlike UART
(which you'll see later), SPI has no start bits, stop bits, or baud rate
negotiation — the master generates the clock and both sides shift data on
each clock edge.

SPI uses up to four signals:

| Signal | Direction | Purpose |
|--------|-----------|---------|
| CLK | Master → Slave | Clock — master controls the timing |
| MOSI | Master → Slave | Master Out, Slave In — data to the slave |
| MISO | Slave → Master | Master In, Slave Out — data from the slave |
| CS | Master → Slave | Chip Select — active LOW, selects the target slave |

The MSP430 datasheet uses different names: SIMO (Slave In, Master Out) for
MOSI and SOMI (Slave Out, Master In) for MISO. Same signals, TI naming.

**CS** (chip select) is not handled by the USCI hardware on the MSP430 —
you manage it as a regular GPIO output. For loopback testing (no external
slave), CS is not needed.

---

## Full Duplex

SPI is inherently **full duplex**: every clock cycle shifts one bit out on
MOSI and simultaneously shifts one bit in on MISO. Even if you only want
to send, you receive a byte. Even if you only want to receive, you must
send a byte (usually 0x00 or 0xFF as a dummy).

This means "send a byte" and "receive a byte" are the same operation
viewed from different ends. Your `spi_tx_byte` subroutine will do both.

---

## Clock Polarity and Phase

SPI has four modes defined by two settings:

| Setting | 0 | 1 |
|---------|---|---|
| Clock polarity (CPOL) | Idle LOW | Idle HIGH |
| Clock phase (CPHA) | Data captured on first edge | Data captured on second edge |

Most SPI devices (including the SSD1325 OLED) use **Mode 0**: clock idle
low (CPOL=0), data captured on the rising edge (CPHA=0).

**Important MSP430 quirk:** the USCI module's clock phase bit is inverted
compared to the standard CPHA definition. Read SLAU144 Chapter 16 carefully
to find how the MSP430 defines its phase bit. This catches people — if data
looks shifted by one bit, the phase setting is probably wrong.

---

## USCI_B0 — The SPI Peripheral

The MSP430G2553 has two USCI modules:
- **USCI_A0** — typically used for UART (serial communication)
- **USCI_B0** — typically used for SPI or I2C

For our handheld, USCI_B0 handles SPI to the OLED display. The registers
you need are documented in **SLAU144 Chapter 16, Section 16.3 (SPI Mode)**.

---

## The UCSWRST Configuration Pattern

The USCI modules use a **reset-while-configuring** pattern. Before changing
any settings, you must hold the module in reset. After all configuration
is done, you release it. This prevents the module from doing anything
unexpected during setup.

The pattern:
1. **Set UCSWRST** — hold the module in reset
2. **Configure** — set all control registers, clock source, divider
3. **Configure GPIO pins** — switch them from GPIO to USCI function
4. **Clear UCSWRST** — release the module, SPI is now active

Which register holds UCSWRST? Look it up in SLAU144. And pay attention
to what *else* lives in that register — this matters for Step 2.

---

## Pin Configuration

USCI_B0 uses three pins for SPI: clock, MOSI, and MISO. To find which
physical pins these map to on the MSP430G2553:

1. Open the **MSP430G2553 datasheet (SLAS735)**
2. Find the pin function table
3. Look for UCB0CLK, UCB0SIMO, UCB0SOMI
4. Check what P1SEL and P1SEL2 values select the USCI function

Both P1SEL *and* P1SEL2 must be configured. Setting only P1SEL gives
you a different peripheral function (Timer_A output), not SPI.

---

## P1.6 — The LED2 Conflict

One of the SPI pins is shared with LED2 on the LaunchPad. When SPI is
active, **remove the LED2 jumper (J5)**. If you leave it in, the LED
circuit on that pin will corrupt incoming SPI data.

With SPI active, LED1 (P1.0) is your only on-board indicator.

---

## Clock Speed

The SPI clock speed is SMCLK divided by a 16-bit divider spread across
two registers. With SMCLK at 1 MHz:

| Divider | SPI Clock | Notes |
|---------|-----------|-------|
| 1 | 1 MHz | Maximum speed |
| 2 | 500 kHz | Safer for breadboard wiring |
| 10 | 100 kHz | Debugging with a logic analyzer |

For the OLED display, 1 MHz works fine.

---

## What to Look Up

Before starting Exercise 1, read **SLAU144 Chapter 16** and find:

- The two control registers for USCI_B0 and what each bit field controls
- Where the clock source selection bits live and why you must be careful
  not to disturb other bits in that register when writing them
- The baud rate registers (two of them — low byte and high byte)
- The interrupt flag register that holds the TX-ready and RX-complete flags

And from the **MSP430G2553 datasheet (SLAS735)**:
- The pin assignments for UCB0CLK, UCB0SIMO, UCB0SOMI
- The P1SEL/P1SEL2 values that select USCI_B0 function on those pins

---

## Common Pitfalls

**Forgetting UCSWRST:** configuring registers without holding reset can
leave the module in an undefined state. Always hold reset first, configure,
then release.

**Accidentally clearing UCSWRST too early:** one of the control registers
holds both configuration bits and the reset bit. If you write that register
carelessly, you might release the module from reset before configuration
is done.

**Forgetting P1SEL2:** on the MSP430G2553, USCI pins need both P1SEL
and P1SEL2 set. Setting only P1SEL gives you Timer_A output, not SPI.

**Leaving the LED2 jumper in:** corrupts MISO data. If SPI reads return
wrong values, check the jumper first.

**Wrong clock phase:** if data is consistently off by one bit (values
look shifted), the phase setting is probably wrong.
