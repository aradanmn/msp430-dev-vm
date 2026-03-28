;******************************************************************************
; Lesson 01 — Exercise 2: Timing by Counting
;
; Blink LED1 at approximately 2 Hz (toggle every ~250 ms).
;
; You need to write:
;   1. A delay_ms subroutine (R12 = milliseconds to wait)
;   2. A main loop that toggles LED1 and calls delay_ms
;
; Delay loop math (work this out yourself):
;   - 1 MHz clock → 1 cycle = 1 µs
;   - dec.w = 1 cycle, jnz (taken) = 2 cycles → 3 cycles per iteration
;   - How many iterations for 1 ms (1000 µs)?
;   - How do you make it wait R12 milliseconds?
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    ; LED1 as output, start OFF
    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

    ; Your main loop here
main:

    mov.w   #250,   R12 ; 250ms
    xor.b   #LED1,  &P1OUT
    call #delay_ms

    jmp main

    ; Your delay_ms subroutine here
delay_ms:

    dec.w   R12
    mov.w   #333,   R11 ; 1MHz is 1,000,000 uS. 999 is ~ 1 mS.
    call #.Lburn_cycles
    cmp.w   #0, R12
    jnz delay_ms
    ret
.Lburn_cycles:
    dec.w   R11
    cmp.w   #0, R11
    jnz .Lburn_cycles
    ret

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0
    .word   0,0,0,0, 0,0,0
    .word   _start
    .end
