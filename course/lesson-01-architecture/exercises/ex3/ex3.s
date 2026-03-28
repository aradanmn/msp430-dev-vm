;******************************************************************************
; Lesson 01 — Exercise 3: SOS Morse Code
;
; Blink LED1 in the SOS pattern, repeat forever.
;
; Timing:
;   Dot:   ON 150 ms, OFF 150 ms
;   Dash:  ON 450 ms, OFF 150 ms
;   Letter gap: 450 ms total off (between S and O, between O and S)
;   Word gap:   1000 ms off (after SOS, before repeating)
;
; Design decisions (yours to make):
;   - Inline all 9 flashes, or write dot/dash subroutines?
;   - If subroutines, what interface?
;   - How do you handle the different gap lengths?
;
; delay_ms is provided (same as your Ex2 solution).
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

    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

    ; Your SOS program here

;==============================================================================
; delay_ms — wait approximately R12 milliseconds (from your Ex2)
; Input:  R12 = milliseconds
; Clobbers: R12, R13
;==============================================================================
delay_ms:
    mov.w   #333, R13
.Ldms_inner:
    dec.w   R13
    jnz     .Ldms_inner
    dec.w   R12
    jnz     delay_ms
    ret

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0
    .word   0,0,0,0, 0,0,0
    .word   _start
    .end
