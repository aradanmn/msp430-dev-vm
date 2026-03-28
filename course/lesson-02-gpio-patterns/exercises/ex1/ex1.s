;******************************************************************************
; Lesson 02 — Exercise 1: Build a Flash Subroutine
;
; Write a flash_led subroutine, then use it to produce:
;   1. Flash LED1 3 times at 200 ms on/off
;   2. Flash LED2 4 times at 100 ms on/off
;   3. 500 ms pause
;   4. Repeat forever
;
; You design the subroutine interface:
;   - Which register = LED bitmask?
;   - Which register = flash count?
;   - Which register = on/off time (ms)?
;
; Remember: delay_ms clobbers R12 and R13.
; Registers R4–R11 survive delay_ms calls.
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

    bis.b   #(LED1|LED2), &P1DIR
    bic.b   #(LED1|LED2), &P1OUT

main_loop:
    ; Your code here: call flash_led for LED1, then LED2, then pause

    jmp     main_loop

;==============================================================================
; flash_led — your subroutine (design the interface yourself)
;==============================================================================
; Your code here

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

    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0
    .word   0,0,0,0, 0,0,0
    .word   _start
    .end
