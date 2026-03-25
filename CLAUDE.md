# CLAUDE.md

This file provides guidance to Claude when working with code in this repository.

## What This Repo Is

A complete 16-lesson MSP430G2553 assembly programming course targeting the TI MSP-EXP430G2 LaunchPad. Everything runs natively on macOS (Apple Silicon or Intel). No VM required.

## Setup (one-time)

```sh
./setup-mac.sh
```

Installs `mspdebug` and `picocom` via Homebrew. The compiler comes from the TI MSP430-GCC full installer (`~/ti/msp430-gcc/`), which includes device-specific linker scripts. `libmsp430.dylib` is built from source for arm64 and installed to `~/.local/lib/`.

## Build Commands (run in Terminal on Mac)

```sh
cd course/lesson-01-architecture/examples
make          # compile → .elf
make flash    # compile + flash to LaunchPad (USB must be connected)
make disasm   # disassemble the compiled binary
make clean    # remove .elf

# First-ever flash (updates eZ-FET firmware):
DYLD_LIBRARY_PATH=~/.local/lib mspdebug --allow-fw-update tilib "prog blink.elf"

# Serial monitor (Lessons 13+)
ls /dev/cu.usbmodem*                  # find the device
picocom -b 9600 /dev/cu.usbmodem*     # exit: Ctrl-A Ctrl-X
```

All Makefiles prefer `~/ti/msp430-gcc/bin/msp430-elf-gcc` (full TI installation with device linker scripts) and use `mspdebug tilib` with `DYLD_LIBRARY_PATH=~/.local/lib` for the eZ-FET lite debugger (USB VID:PID 2047:0013) on Rev 1.5 LaunchPads.

## Course Structure

```
course/
├── common/
│   ├── msp430g2553-defs.s      ← ALL register/bit definitions (included by every .s file)
│   └── Makefile.template       ← Template for new Makefiles
└── lesson-01-architecture/ through lesson-16-low-power-modes/
    ├── README.md
    ├── tutorial-01-*.md
    ├── tutorial-02-*.md
    ├── examples/               ← Working demo (Makefile + *.s)
    └── exercises/
        ├── README.md
        ├── ex1/ ex2/ ex3/      ← Standalone concept practice (no solution/ dirs)
        └── ex4/                ← Project milestone (L05+): spec for handheld/ addition

handheld/                           ← Growing skeleton project (the capstone)
├── Makefile                        ← TARGET=main
├── registers.md                    ← Register allocation convention
├── main.s                          ← _start, init, LPM0, vector table, game_update stub
├── hal/
│   ├── timer.s                     ← Timer_A CC0 ISR + tick counter        (L05)
│   ├── spi.s                       ← USCI_B0 SPI driver                    (L06)
│   ├── display.s                   ← SSD1325 OLED init + commands           (L07)
│   ├── input.s                     ← SN74HC165N shift-register read         (L08)
│   └── audio.s                     ← Timer_A PWM for buzzer                 (L09)
├── gfx/
│   ├── framebuf.s                  ← 23LC1024 SRAM framebuffer ops          (L07)
│   └── sprites.s                   ← Tile/sprite drawing primitives         (L10)
└── game/
    ├── tetris.s                    ← Piece logic, collision, lines          (L11+)
    └── ui.s                        ← Menus, score display                   (L13+)
```

## Assembly File Conventions

**Every `.s` file begins with:**
```asm
#include "<relative-path>/common/msp430g2553-defs.s"

    .text
    .global _start

_start:
    mov.w   #0x0400, SP                 ; init stack pointer (top of RAM)
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL  ; disable watchdog — always second
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1     ; calibrate DCO to 1 MHz
    mov.b   &CALDCO_1MHZ, &DCOCTL
```

**Correct include paths by directory depth:**
- `examples/*.s` → `#include "../../common/msp430g2553-defs.s"`
- `exercises/exN/*.s` → `#include "../../../common/msp430g2553-defs.s"`
- `handheld/main.s` → `#include "../course/common/msp430g2553-defs.s"`

**Interrupt vector table** — use an explicit `.word` table (32 bytes = 16 vectors × 2 bytes):
```asm
    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0    ; 0xFFE0–0xFFEF  unused
    .word   0,0,0,0, 0,0,0      ; 0xFFF0–0xFFFC  unused
    .word   _start               ; 0xFFFE  Reset vector
```

For ISRs, replace the relevant 0 with the ISR label (positions counted from 0xFFE0 in steps of 2):
```asm
    .section ".vectors","ax",@progbits
    .word   0           ; 0xFFE0  unused
    .word   0           ; 0xFFE2  unused
    .word   port1_isr   ; 0xFFE4  Port 1
    .word   0           ; 0xFFE6  Port 2
    .word   0           ; 0xFFE8  unused
    .word   0           ; 0xFFEA  ADC10
    .word   0           ; 0xFFEC  USCI_A0/B0 TX
    .word   0           ; 0xFFEE  USCI_A0/B0 RX
    .word   0           ; 0xFFF0  Timer_A overflow (TAIV)
    .word   0           ; 0xFFF2  Timer_A CC0
    .word   0           ; 0xFFF4  WDT
    .word   0           ; 0xFFF6  Comparator_A+
    .word   0           ; 0xFFF8  Timer1_A1
    .word   0           ; 0xFFFA  unused
    .word   0           ; 0xFFFC  unused
    .word   _start      ; 0xFFFE  Reset
```

## Key Peripheral Patterns

**LPM entry/exit** (always use GIE | ... to enable interrupts simultaneously):
```asm
bis.w   #(GIE|CPUOFF), SR           ; enter LPM0
; exit from ISR:
bic.w   #CPUOFF, 0(SP)              ; clear CPUOFF in saved SR
```

**UART 9600 baud @ 1 MHz:**
```asm
bis.b   #(UART_RX|UART_TX), &P1SEL
bis.b   #(UART_RX|UART_TX), &P1SEL2
bis.b   #UCSWRST, &UCA0CTL1
mov.b   #UCSSEL_2, &UCA0CTL1       ; SMCLK
mov.b   #104, &UCA0BR0             ; 1MHz/104 ≈ 9600
mov.b   #0, &UCA0BR1
mov.b   #0x02, &UCA0MCTL
bic.b   #UCSWRST, &UCA0CTL1
```

**ADC10 internal temperature sensor:**
```asm
mov.w   #(INCH_10|ADC10SSEL_3|CONSEQ_0), &ADC10CTL1
mov.w   #(SREF_1|ADC10SHT_3|REFON|ADC10ON), &ADC10CTL0
; wait ~30µs for reference to settle, then:
bis.w   #(ENC|ADC10SC), &ADC10CTL0
poll:   bit.w   #ADC10BUSY, &ADC10CTL1
        jnz     poll
        mov.w   &ADC10MEM, R5      ; 10-bit result
; T°C ≈ (raw − 673) / 4 + 25
```

**SPI / I2C share USCI_B0 on the same pins** (P1.5=CLK, P1.6=MISO/SDA, P1.7=MOSI/SCL). P1.6 is also LED2 — remove the LED2 jumper when using SPI/I2C.

## Interrupt Vectors Quick Reference

| Address | Peripheral |
|---------|-----------|
| 0xFFE4  | Port 1 |
| 0xFFEA  | ADC10 |
| 0xFFEC  | USCI_A0/B0 TX |
| 0xFFEE  | USCI_A0/B0 RX |
| 0xFFF0  | Timer_A overflow (TAIV) |
| 0xFFF2  | Timer_A CC0 |
| 0xFFF4  | WDT |
| 0xFFFE  | Reset |

## Makefile Template Notes

When creating a new Makefile, copy `course/common/Makefile.template` and:
1. Set `TARGET` to the `.s` filename stem
2. Set `MCU = msp430g2553`
3. `make flash` uses `mspdebug tilib` with `DYLD_LIBRARY_PATH=~/.local/lib` (handled automatically by the Makefile)

## Hardware Notes

- **MCU:** MSP430G2553 — 16 KB Flash (0xC000–0xFFFF), 512 B RAM (0x0200–0x03FF)
- **LaunchPad:** MSP-EXP430G2 Rev 1.5 with eZ-FET lite debugger (2047:0013)
- **LED1:** P1.0 (Red), **LED2:** P1.6 (Green, shared with I2C SDA)
- **Button S2:** P1.3, active LOW (requires internal pull-up via P1REN)
- **Serial port on macOS:** `/dev/cu.usbmodem*` (not `/dev/ttyACM0`)
- **Stack:** SP must be initialized to `#0x0400` (top of RAM) in `_start` when using `-nostdlib`

## Hardware Notes — Serial Port

On macOS the LaunchPad CDC serial port appears as `/dev/cu.usbmodem*`, not `/dev/ttyACM0`. Use `ls /dev/cu.usbmodem*` to find it.

## Handheld Skeleton — Composition Model

`handheld/main.s` uses `#include "hal/timer.s"` etc. to pull in modules. This avoids multi-file linking complexity. Each module defines its own subroutines; `main.s` calls them from the init sequence and the ISR.

**Naming convention:** All public labels are prefixed by module name — `timer_init`, `timer_isr`, `spi_init`, `spi_tx_byte`, `display_init`, `display_flush`, etc. Local labels use GAS `.L` prefix (e.g., `.Ldone`).

## Register Allocation Convention

See `handheld/registers.md` for the full reference. Summary:

| Register | Role | Scope |
|----------|------|-------|
| R0–R3 | PC, SP, SR, CG — CPU-reserved | Hardware |
| **R4–R7** | Frame counter, input, prev input, game mode | ISR — persistent |
| **R8–R11** | Game-specific state | ISR — assigned per game |
| **R12–R15** | Scratch / subroutine arguments | Caller-saved — any call may clobber |

**Rules:** R4–R11 are callee-saved (push/pop if borrowed). R12–R15 are caller-saved. Aligns with MSP430 GCC ABI.

## Exercise Format Policy

Solution directories have been removed from all lessons. Do not recreate them.

Exercises use **progressive scaffold reduction** within each lesson:
- **ex1** — behaviour spec + step-by-step requirements + formula hints
- **ex2** — behaviour spec + requirements only; no pseudocode or structure hints
- **ex3** — behaviour spec only; no register assignments, no subroutine interface hints, no algorithm templates; student derives all constants and structure
- **ex4** — project milestone (L05+): spec + pointer to `handheld/`, tells student what to add/modify

Ex1–ex3 are standalone (throwaway concept practice). Ex4 is cumulative (permanent addition to the handheld skeleton).

Each exercise explicitly states which prior lessons/exercises it builds on. New exercises for future lessons should follow this pattern.

When grading: compare to the spec (not a solution file), note correctness first, call out one cosmetic issue max. Do not show the correct implementation.

GAS constant arithmetic (`.equ FOO, (TICK_MS * 1000) - 1`) has been introduced and is the expected style for all timing constants from lesson 04 onward.

`clr.w` has NOT been introduced to the student yet (as of lesson 04). Do not suggest it.

## Student Progress

**Last session:** 2026-03-24

**Completed exercises:**
- Lessons 01–03: all exercises done (lessons fully complete)
- Lesson 04 Ex1: ✅ 10/10 — Timer_A polling loop, TICK_PERIOD/BLINK_TICKS as `.equ`
- Lesson 04 Ex2: ✅ 10/10 — dual-rate blinker, 5 ms tick, arithmetic in `.equ`
- Lesson 04 Ex3: ✅ 8/10 — adjustable-speed blinker; all core logic correct; LED2 ack had label placement bug (bic.b outside branch, fixed by adding early ret); pass

**Current position:** Lesson 05 (not yet started — read tutorials first)

**Student patterns observed:**
- Strong on constants and formulas; reaches for `.equ` arithmetic unprompted
- Tends to over-scaffold subroutines (multi-case dispatch where increment-and-wrap suffices); improving
- Gets flow control right once the bug is identified
- Does not need pseudocode hints; spec alone is sufficient
- Misread "flash briefly" as "toggle every tick" in ex3 LED2 — spec wording should be unambiguous in future exercises
- Discovered `clr.w` independently (not yet formally introduced)

**Lesson 04 notes for future reference:**
- NUM_SPEEDS payoff: increment-and-wrap in change_speed (no dispatch needed there)
- SPD_STATE0–3 constants belong in apply_speed only, not change_speed
- Label placement bug pattern: code after a local label runs whether jump was taken or not

**Course redesign (implemented):**
- `handheld/` skeleton project grows with each lesson via ex4 project milestones
- Each lesson adds one layer: ISR+sleep (L05), SPI (L06), display (L07), input (L08), etc.
- By lesson 08 the skeleton is a working platform; Tetris drops in on top
- L05 ex4 is the first milestone: main.s + hal/timer.s (game loop shell, CC0 ISR, LED heartbeat)
- Student is moving to Zed editor; Claude Code runs in Zed's terminal pane (`cd project && claude`)
