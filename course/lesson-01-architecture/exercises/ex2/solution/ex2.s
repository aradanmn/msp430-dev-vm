;******************************************************************************
; Lesson 01 — Exercise 2 SOLUTION: Alternating LEDs
;
; LED1 and LED2 alternate with a 250 ms period each.
;
; Key insight: BIS sets a bit without touching others, BIC clears a bit
; without touching others. This lets you control P1.0 and P1.6 independently
; even though they're in the same 8-bit register.
;******************************************************************************

#include "../../../../common/msp430g2553-defs.s"

    .text
    .global _start

_start:
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL

    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    ; Configure both LEDs as outputs in a single instruction.
    ; LED1|LED2 = BIT0|BIT6 = 0x41
    bis.b   #(LED1|LED2), &P1DIR

    ; Initial state: LED1 on, LED2 off
    bis.b   #LED1, &P1OUT
    bic.b   #LED2, &P1OUT

main_loop:
    ; --- Phase A: LED1 ON, LED2 OFF ---
    bis.b   #LED1, &P1OUT               ; explicitly set LED1
    bic.b   #LED2, &P1OUT               ; explicitly clear LED2
    mov.w   #250, R12
    call    #delay_ms

    ; --- Phase B: LED1 OFF, LED2 ON ---
    bic.b   #LED1, &P1OUT
    bis.b   #LED2, &P1OUT
    mov.w   #250, R12
    call    #delay_ms

    jmp     main_loop

delay_ms:
    mov.w   #333, R13
.Ldms_inner:
    dec.w   R13
    jnz     .Ldms_inner
    dec.w   R12
    jnz     delay_ms
    ret

    .section ".vectors","ax",@progbits
    .word   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .word   _start
    .end
