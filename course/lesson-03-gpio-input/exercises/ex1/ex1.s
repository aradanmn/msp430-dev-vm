;******************************************************************************
; Lesson 03 — Exercise 1: Button Without Debounce
;
; Toggle LED1 on each button press — but WITHOUT debounce.
;
; You will observe: pressing the button sometimes toggles LED1 once,
; sometimes multiple times, leaving it in a random state.
; This is expected. Understand WHY before moving to Exercise 2.
;
; Implementation:
;   1. Configure BTN (P1.3) as input with pull-up
;   2. Configure LED1 as output
;   3. Main loop:
;      - Wait for press (P1.3 goes LOW)
;      - Toggle LED1
;      - Wait for release (P1.3 goes HIGH)
;      - Repeat
;
; Button is active LOW:
;   pressed  → P1IN bit 3 = 0 → bit.b + jz branches
;   released → P1IN bit 3 = 1 → bit.b + jnz branches
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

    ; Your code here: configure LED1 output, BTN input with pull-up

main_loop:
    ; Your code here: wait press → toggle LED1 → wait release → repeat

    jmp     main_loop

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0
    .word   0,0,0,0, 0,0,0
    .word   _start
    .end
