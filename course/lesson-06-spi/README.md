# Lesson 06 — SPI Communication

## What You'll Learn

- How SPI works (clock, data lines, chip select)
- Configuring USCI_B0 as SPI master on the MSP430G2553
- The UCSWRST reset-while-configuring pattern
- Sending and receiving bytes over SPI
- Why SPI is the interface to the OLED display

## How This Connects to the Handheld

| Lesson | Skill | Game use |
|--------|-------|----------|
| 01–02 | GPIO output | Drive the display and LEDs |
| 03 | GPIO input | Read the buttons |
| 04 | Timer_A polling | Consistent tick rate |
| 05 | Timer_A ISR + LPM0 | Game loop: wake on tick, process, sleep |
| **06** | **SPI** | **Send frames to the OLED** |
| 07 | Display driver | SSD1325 OLED init + framebuffer |
| 08 | Shift-register input | Read 8 buttons via SPI-like protocol |
| 09+ | Combine everything | Tetris |

The OLED display (SSD1325) speaks SPI. Every frame, the game loop sends
pixel data over the SPI bus to update the screen. This lesson teaches the
bus itself; Lesson 07 adds the display protocol on top.

## Read First

1. `tutorial-01-spi-fundamentals.md` — what SPI is, MSP430 USCI_B0 config
2. `tutorial-02-sending-receiving.md` — transmit/receive bytes, polling TXIFG

## Then

**Hardware setup:** connect a jumper wire from P1.7 (MOSI) to P1.6 (MISO)
on the LaunchPad header. **Remove the LED2 jumper** (J5) — P1.6 is shared
with LED2 and cannot serve both functions.

```sh
cd examples && make flash
```

Observe LED1 turn ON — it confirms the SPI loopback test passed.

## Exercises

See `exercises/README.md`.
