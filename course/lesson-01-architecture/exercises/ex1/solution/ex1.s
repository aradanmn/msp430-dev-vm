;******************************************************************************
; Lesson 01 — Exercise 1 SOLUTION: Faster Blink (4 Hz)
;
; Change: 500 ms → 125 ms delay
; Result: LED toggles every 125 ms → 4 complete blinks per second
;******************************************************************************

#include "../../../../common/msp430g2553-defs.s"

    .text
    .global _start

_start:
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL

    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

main_loop:
    xor.b   #LED1, &P1OUT

    mov.w   #125, R12               ; 125 ms → 4 Hz (toggle every 125 ms)
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
