;******************************************************************************
; Lesson 01 — Exercise 3 SOLUTION: SOS Morse Code
;
; Demonstrates how to sequence multiple delay values to produce a pattern —
; a preview of how the Tetris game loop will sequence game events.
;
; Two helper subroutines (dot and dash) reduce repetition and make the
; main_loop readable as a direct transcription of the Morse pattern.
;******************************************************************************

#include "../../../../common/msp430g2553-defs.s"

    .text
    .global _start

;==============================================================================
; Timing constants (milliseconds)
;==============================================================================
.equ    T_DOT,          150     ; dot on-time
.equ    T_DASH,         450     ; dash on-time (3× dot)
.equ    T_SYMBOL_GAP,   150     ; off-time between symbols in same letter
.equ    T_LETTER_GAP,   450     ; off-time between letters (150 + 300 extra)
.equ    T_WORD_GAP,     1000    ; off-time after full SOS before repeating

_start:
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

;==============================================================================
; main_loop — S O S pattern
;==============================================================================
main_loop:
    ; --- S: three dots ---
    call    #dot
    call    #dot
    call    #dot

    ; --- inter-letter gap (total = T_LETTER_GAP = 450 ms) ---
    ; last dot already left 150 ms gap, so add 300 ms more
    mov.w   #300, R12
    call    #delay_ms

    ; --- O: three dashes ---
    call    #dash
    call    #dash
    call    #dash

    mov.w   #300, R12
    call    #delay_ms

    ; --- S: three dots ---
    call    #dot
    call    #dot
    call    #dot

    ; --- end-of-word gap ---
    ; last dot left 150 ms, add 850 ms more for total 1000 ms
    mov.w   #850, R12
    call    #delay_ms

    jmp     main_loop

;==============================================================================
; dot — flash LED1 for T_DOT ms, then pause T_SYMBOL_GAP ms
;==============================================================================
dot:
    bis.b   #LED1, &P1OUT
    mov.w   #T_DOT, R12
    call    #delay_ms

    bic.b   #LED1, &P1OUT
    mov.w   #T_SYMBOL_GAP, R12
    call    #delay_ms
    ret

;==============================================================================
; dash — flash LED1 for T_DASH ms, then pause T_SYMBOL_GAP ms
;==============================================================================
dash:
    bis.b   #LED1, &P1OUT
    mov.w   #T_DASH, R12
    call    #delay_ms

    bic.b   #LED1, &P1OUT
    mov.w   #T_SYMBOL_GAP, R12
    call    #delay_ms
    ret

;==============================================================================
; delay_ms — wait approximately R12 milliseconds
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
    .word   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .word   _start
    .end
