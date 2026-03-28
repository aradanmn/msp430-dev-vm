;******************************************************************************
; Lesson 03 — Exercise 2: Design a Debounce
;
; Fix the unreliable toggle from Exercise 1.
; LED1 must toggle exactly once per physical press. Every time.
;
; The tutorial explains what button bounce is. Your job:
;   - Choose a debounce strategy (delay+re-read, two-sample, counter-based)
;   - Implement it
;   - Add LED2 flash (80 ms) after each confirmed press
;
; Define all timing as .equ constants — no magic numbers.
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

; Your timing constants here

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    ; Your GPIO setup here (LEDs + button)

    ; Your debounced toggle loop here

;==============================================================================
; delay_ms — from Lesson 01
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
