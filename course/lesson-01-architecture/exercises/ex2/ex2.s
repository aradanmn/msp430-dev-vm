;******************************************************************************
; Lesson 01 — Exercise 2: Alternating LEDs
;
; Make LED1 (P1.0, Red) and LED2 (P1.6, Green) alternate:
;   - When LED1 is ON,  LED2 is OFF
;   - When LED1 is OFF, LED2 is ON
;   - Toggle every 250 ms
;   - Starting state: LED1 ON, LED2 OFF
;
; Hints:
;   - Configure both P1.0 and P1.6 as outputs (one bis.b can set both bits)
;   - Use bis.b / bic.b to explicitly set/clear each LED
;     (don't use xor.b here — practice the set/clear pattern)
;   - LED2 = BIT6 is already defined in the defs file
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

_start:
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL

    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    ; TODO: configure both LED1 and LED2 as outputs

    ; TODO: set initial state: LED1 ON, LED2 OFF

main_loop:
    ; TODO: phase A — LED1 ON, LED2 OFF, wait 250 ms

    ; TODO: phase B — LED1 OFF, LED2 ON, wait 250 ms

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
