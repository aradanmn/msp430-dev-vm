;******************************************************************************
; Lesson 04 — Exercise 2: Dual-Rate Blinker
;
; Builds on Exercise 1 — your Timer_A setup carries over directly.
;
; Behaviour:
;   LED1 toggles every 500 ms  (1 Hz)
;   LED2 toggles every 125 ms  (4 Hz)
;   Both blink simultaneously, driven from one timer tick.
;
; Requirements:
;   - Choose a tick period that divides evenly into both intervals
;   - Define TICK_PERIOD, LED1_TICKS, LED2_TICKS as .equ constants
;   - Two independent tick-down counters in separate registers
;   - One TAIFG poll per loop iteration; service both channels after each tick
;   - No magic numbers
;
; Registers: R6 = LED1 countdown, R7 = LED2 countdown
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

;==============================================================================
; Timing constants — fill in the values
;==============================================================================
.equ TICK_PERIOD,   4999       ; 5 ms ticks works the best for each period
.equ LED1_TICKS,    100       ; TODO: ticks per 500 ms
.equ LED2_TICKS,    25       ; TODO: ticks per 125 ms

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    ; TODO: configure LED1 and LED2 as outputs, both OFF
    bis.b   #(LED1|LED2), &P1DIR  ; Set LEDs as outputs
    bic.b   #(LED1|LED2), &P1OUT  ; set register bits to 0

    ; TODO: configure Timer_A (TACCR0 then TACTL)
    mov.w   #TICK_PERIOD, &TACCR0 ;Set TACCR0 to 5 ms ticks
    mov.w   #(TASSEL_2|MC_1|TACLR), &TACTL

    ; TODO: load both tick-down counters
    mov.w   #LED1_TICKS, R6
    mov.w   #LED2_TICKS, R7

main_loop:
    ; TODO: poll TAIFG, clear it, then service both LED channels
    ; Wait for TA Interrupt Flag
    bit.w   #TAIFG, &TACTL
    jz  main_loop
    bic.w   #TAIFG, &TACTL

    ; toggle LED1 every LED1_TICKS
    dec.w   R6
    jnz     .Lled1_skip
    xor.b   #LED1, &P1OUT       ; toggle LED1
    mov.w   #LED1_TICKS, R6     ; reload counter
.Lled1_skip:

    ; toggle LED2 every LED2_TICKS
    dec.w   R7
    jnz     .Lled2_skip
    xor.b   #LED2, &P1OUT       ; toggle LED2
    mov.w   #LED2_TICKS, R7     ; reload counter
.Lled2_skip:

    jmp     main_loop

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .word   _start
    .end
