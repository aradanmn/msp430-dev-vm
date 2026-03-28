# Tutorial 02 — Sending and Receiving Data

## The Transmit/Receive Cycle

Sending a byte over SPI is a three-step process:

1. **Wait** until the transmit buffer is ready to accept new data
2. **Write** the byte to the transmit buffer register
3. **Wait** until the transfer is fully complete, then **read** the
   receive buffer register

The hardware shifts your byte out on MOSI one bit at a time, clocked by
the SPI clock. Simultaneously, it shifts in whatever arrives on MISO.
When all 8 bits have been clocked, the received byte is ready.

---

## Polling Flags

Two flags tell you what the SPI hardware is doing. Both live in the same
interrupt flag register (find it in SLAU144 Chapter 16):

| Flag | Meaning |
|------|---------|
| TX flag | Transmit buffer empty — safe to write a new byte |
| RX flag | Receive buffer full — a received byte is available |

The TX flag is set after reset (the buffer starts empty). Writing to the
transmit buffer clears it; the hardware sets it again once the byte has
moved to the shift register.

The RX flag is set when a received byte is available. Reading the receive
buffer clears it.

---

## Building `spi_tx_byte`

Your subroutine needs to:

1. Poll the TX flag — loop until it's set (buffer ready)
2. Write R12 to the transmit buffer
3. Poll the RX flag — loop until it's set (transfer complete)
4. Read the receive buffer into R12
5. Return

This is straightforward polling — the same pattern you used for Timer_A
in Lesson 04, just different flags and registers.

### Why poll the RX flag for completion?

The TX flag tells you the transmit buffer is empty — but that only means
the byte moved to the shift register. The shift register might still be
clocking bits out. The RX flag is set when all 8 bits have been clocked,
which means the transfer is truly complete.

**Always poll the RX flag before reading the receive buffer or sending
the next byte** if you need the received data or need to know the transfer
finished.

---

## Chip Select (CS)

Most SPI slaves require the master to assert CS (pull LOW) before the
first byte and deassert it (pull HIGH) after the last byte of a
transaction. On the MSP430, CS is just a GPIO pin you manage yourself —
set it as an output, pull it low before sending, raise it when done.

For the exercises in this lesson, there is no external slave — you use a
**loopback wire** (MOSI → MISO), so CS is not needed. You'll manage CS
in Lesson 07 when driving the OLED display.

---

## Loopback Testing

Without an external SPI device, you can verify your SPI configuration by
connecting MOSI directly to MISO with a jumper wire. Every byte you send
comes right back. Send a known value (like 0xA5), read the result, and
compare. If they match, your SPI configuration is correct.

If the received byte doesn't match:
- Check the jumper wire (correct pins?)
- Check both P1SEL and P1SEL2 (both must be set for the SPI pins)
- Check that the LED2 jumper (J5) is removed
- Check clock phase setting

---

## SPI Speed vs. Display Budget

At 1 MHz SPI clock, one byte takes 8 us. The SSD1325 OLED has 128x64
pixels at 4 bits per pixel = 4096 bytes per frame. A full frame transfer
takes:

```
4096 bytes x 8 us = 32.8 ms
```

At 50 fps (20 ms per frame), that's too slow for a full redraw every
frame. Solutions:
- Only send the rows that changed (dirty-rectangle tracking)
- Accept a lower frame rate for full redraws

This is a real constraint you'll work with in later lessons. For now,
just get the byte-level transfer working.

---

## Common Mistakes

**Reading the receive buffer without checking the RX flag:** the buffer
might contain stale data from a previous transfer. Always poll the flag
before reading.

**Forgetting to read the receive buffer:** even if you don't care about
the received byte, you still need to read it to clear the RX flag.
Otherwise, the flag stays set and your next polling loop exits immediately
with stale data.

**Sending too fast:** if you write to the transmit buffer before the
previous transfer finishes, the new byte overwrites the old one. Always
poll the TX flag before each write.

**Not clearing the RX flag before a new transfer:** if the flag is still
set from a previous transfer (because you didn't read the receive buffer),
your next RX poll will return immediately. Read the receive buffer after
every transfer, even if you don't need the value.
