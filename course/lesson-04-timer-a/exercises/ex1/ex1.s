;******************************************************************************
; Lesson 04 — Exercise 1: Timer from the Datasheet
;
; Blink LED1 at 2 Hz (toggle every 250 ms) using Timer_A in polling mode.
;
; Your job:
;   1. Open SLAU144 Chapter 12 (Timer_A)
;   2. Find the registers and bit fields you need
;   3. Choose a tick interval, compute the compare value
;   4. Write the polling loop
;
; What you need from the datasheet:
;   - The capture/compare register (sets the period)
;   - The control register (selects clock source and mode)
;   - The overflow flag (tells you when a tick has elapsed)
;   - How to clear the flag
;
; Clock: SMCLK = 1 MHz after DCO calibration.
; Use .equ for ALL timing constants. Define TICK_MS and derive the rest.
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

; Your timing constants here (use .equ arithmetic)

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

    ; Your Timer_A setup here

    ; Your polling main loop here

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0
    .word   0,0,0,0, 0,0,0
    .word   _start
    .end
