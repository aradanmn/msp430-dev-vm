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
    ├── examples/               ← Working demo (Makefile + *.s) — study AFTER exercises
    └── exercises/
        ├── README.md
        ├── ex1/                ← Explore: build it from concepts + datasheet
        ├── ex2/                ← Challenge: debug broken code or solve a design problem
        └── ex3/                ← Milestone (L02+): write real handheld/ module from spec

handheld/                           ← Growing skeleton project (the capstone)
├── Makefile                        ← TARGET=main
├── registers.md                    ← Register allocation convention
├── main.s                          ← Minimal stub (student grows this via milestones)
├── hal/                            ← ALL modules are student-created via milestone exercises
│   ├── leds.s                      ← LED init + test pattern                (L02 milestone)
│   ├── input.s                     ← Button debounce + read                 (L03 milestone)
│   ├── timer.s                     ← Timer_A polling tick                   (L04 milestone)
│   │                                  → converted to CC0 ISR + LPM0         (L05 milestone)
│   ├── spi.s                       ← USCI_B0 SPI driver                    (L06 milestone)
│   ├── display.s                   ← SSD1325 OLED init + commands           (L07 milestone)
│   └── audio.s                     ← Timer_A PWM for buzzer                 (L09 milestone)
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

Solution directories do not exist. Do not create them.

Each lesson has **3 exercises** (not 4), each with a distinct purpose:

- **Ex1 — Explore:** Build something that works. Tutorials provide conceptual understanding; from L04 onward the datasheet (SLAU144) provides register details. The student figures out the configuration, not copies it. Standalone LaunchPad demo.
- **Ex2 — Challenge:** Debug broken code, solve a constraint problem, or make a design decision with real tradeoffs. Bugs must be realistic (config errors, not syntax tricks) and the buggy code must compile. At least one debug exercise per lesson from L02 onward.
- **Ex3 — Milestone (L02+):** Write a real `handheld/hal/*.s` module from a behavioral spec and interface contract. This is permanent, cumulative code the student creates. No pre-built version is provided. L01 has no milestone (pure fundamentals).

**Key principles:**
- Tutorials teach concepts, not register recipes. Never hand out exact register bit patterns in exercises.
- The MSP430x2xx Family User's Guide (SLAU144) is the primary reference from L04 onward.
- If the student can solve an exercise by copying from the tutorial, it's too easy.
- The student writes ALL handheld modules — nothing is pre-built.
- Each exercise states which prior lessons/exercises it builds on.

**When grading:** compare to the spec (not a solution file), note correctness first, call out one cosmetic issue max. Do not show the correct implementation. When the student has a bug, guide them toward finding it themselves rather than giving the fix.

GAS constant arithmetic (`.equ FOO, (TICK_MS * 1000) - 1`) is the expected style for all timing constants from lesson 04 onward.

## Datasheet References

The student should download these free PDFs from TI:

- **MSP430x2xx Family User's Guide (SLAU144)** — the primary reference for all peripheral configuration
  - Ch 8: Digital I/O (GPIO)
  - Ch 12: Timer_A
  - Ch 15: USCI — UART Mode
  - Ch 16: USCI — SPI Mode
  - Ch 17: USCI — I2C Mode
  - Ch 22: ADC10
- **MSP430G2553 Datasheet (SLAS735)** — pinout, electrical specs, pin function tables

## Student Progress

**Last session:** 2026-03-27

**Course restart:** Student completed L01–L05 under the old recipe-style format, then chose to restart from L01 with a redesigned approach (concept-driven, datasheet-referenced, student-builds-everything). Prior exercise solutions are in git history but no longer referenced.

**Current position:** Lesson 01 (restart)

**Student patterns observed (from first pass):**
- Strong on constants and formulas; reaches for `.equ` arithmetic unprompted
- Gets flow control right once the bug is identified
- Does not need pseudocode hints; spec alone is sufficient
- Makes transcription errors when copying patterns (not understanding errors) — further evidence the old approach wasn't teaching the material
- Discovered `clr.w` independently

**Course design (current):**
- `handheld/` skeleton grows via student-created milestone exercises (ex3)
- Each lesson adds one module: LEDs (L02), input (L03), timer (L04), ISR+LPM0 (L05), SPI (L06)
- Tutorials teach concepts; datasheet (SLAU144) is the register reference from L04+
- Debug exercises in every lesson from L02 onward
- Student writes all code — no pre-built modules
