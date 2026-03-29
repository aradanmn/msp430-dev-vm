;******************************************************************************
; Lesson 02 — Exercise 2: Find the Bugs
;
; This code is supposed to:
;   1. Flash LED1 five times (150 ms on/off)
;   2. Flash LED2 five times (150 ms on/off)
;   3. Pause 500 ms
;   4. Repeat
;
; It compiles, but doesn't work correctly. There are 3 bugs.
;
; Find each bug, fix it, and write a comment explaining what was wrong
; and why the fix is correct.
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

    bis.b   #LED1, &P1DIR               ; LED1 output
; the bug is that you are setting the GPIO direction as an input instead of
; an output
;    bic.b   #LED2, &P1DIR               ; LED2 output          ; BUG 1
    bis.b   #LED2,  &P1DIR              ; this is correct
    bic.b   #(LED1|LED2), &P1OUT

main_loop:
    ; --- Flash LED1 five times ---
    mov.w   #5, R7
.Lflash1:
    bis.b   #LED1, &P1OUT
;    mov.b   #150, R12                                           ; BUG 2
    mov.w   #150, R12   ; correct you need to use the 16bit op vs. 8bit
    call    #delay_ms
    bic.b   #LED1, &P1OUT
    mov.w   #150, R12
    call    #delay_ms
    dec.w   R7
    jnz     .Lflash1

    ; --- Flash LED2 five times ---
    mov.w   #5, R7
.Lflash2:
    bis.b   #LED2, &P1OUT
    mov.w   #150, R12
    call    #delay_ms
; LED is already on, need to turn it OFF
    ;    bis.b   #LED2, &P1OUT                                       ; BUG 3
    bic.b   #LED2,  &P1OUT  ; correct
    mov.w   #150, R12
    call    #delay_ms
    dec.w   R7
    jnz     .Lflash2

    ; --- Pause ---
    mov.w   #500, R12
    call    #delay_ms

    jmp     main_loop

;==============================================================================
; delay_ms
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
