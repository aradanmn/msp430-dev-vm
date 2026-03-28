;******************************************************************************
; Lesson 01 — Exercise 1: First Light
;
; Turn on LED1. That's it.
;
; LED1 is on P1.0. Figure out:
;   1. Which register makes a pin an output?
;   2. Which register drives the pin high?
;   3. Which instruction sets one bit without changing the others?
;
; Read Tutorial 01 (GPIO section) if you're stuck.
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

    ; Your code here: turn on LED1
    bis.b   #LED1,  &P1DIR
    bis.b   #LED1,  &P1OUT
halt:
    jmp     halt

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0
    .word   0,0,0,0, 0,0,0
    .word   _start
    .end
