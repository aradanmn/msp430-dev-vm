;******************************************************************************
; Lesson 04 — Exercise 2: Timing Analysis Challenge
;
; Spec from the game designer:
;   LED1 blinks at 1.5 Hz  (toggle every 333.3 ms)
;   LED2 blinks at 3.7 Hz  (toggle every 135.1 ms)
;   Both driven from one timer tick.
;
; Your analysis (answer these as comments below):
;   1. Does a tick period exist that divides evenly into both intervals?
;   2. What tick period gives the best approximation? What's the error?
;   3. What are the actual rates achieved?
;
; Implement your chosen compromise after the analysis.
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

; --- YOUR ANALYSIS ---
; Write your tick period reasoning here as comments.
; Show the math: target ms, chosen tick, actual ticks, actual ms, error %.

; Your timing constants here

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    bis.b   #(LED1|LED2), &P1DIR
    bic.b   #(LED1|LED2), &P1OUT

    ; Your Timer_A setup and polling loop here

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0
    .word   0,0,0,0, 0,0,0
    .word   _start
    .end
