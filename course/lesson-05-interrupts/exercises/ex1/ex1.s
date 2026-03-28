;******************************************************************************
; Lesson 05 — Exercise 1: Convert to Interrupt-Driven
;
; Take your L04 Timer_A polling blink and convert to CC0 interrupt + LPM0.
;
; What changes from your L04 code:
;   - TAIFG polling loop → gone
;   - Add CCIE to enable the CC0 interrupt (which register? look it up)
;   - Main ends with bis.w #(GIE|CPUOFF), SR — CPU sleeps
;   - Decrement/toggle/reload logic moves into timer_isr, ending with reti
;   - Vector table: timer_isr at the CC0 vector address
;
; Questions:
;   - Where is the CCIE bit? (Hint: it's not in TACTL)
;   - What vector address is CC0? (Check SLAU144 or msp430g2553-defs.s)
;   - What's the difference between reti and ret? Try using ret — what happens?
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

; Your timing constants (carry over from L04)

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

    ; Your Timer_A setup here (add CC0 interrupt enable)

    ; Initialize tick counter, then enter LPM0

;==============================================================================
; timer_isr — your CC0 ISR
;==============================================================================
; Your ISR code here

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0           ; 0xFFE0  unused
    .word   0           ; 0xFFE2  unused
    .word   0           ; 0xFFE4  Port 1
    .word   0           ; 0xFFE6  unused
    .word   0           ; 0xFFE8  unused
    .word   0           ; 0xFFEA  ADC10
    .word   0           ; 0xFFEC  USCI TX
    .word   0           ; 0xFFEE  USCI RX
    .word   0           ; 0xFFF0  Timer_A overflow (TAIV)
    .word   0           ; 0xFFF2  Timer_A CC0
    .word   0           ; 0xFFF4  WDT
    .word   0           ; 0xFFF6  Comparator_A+
    .word   0           ; 0xFFF8  Timer1_A1
    .word   0           ; 0xFFFA  unused
    .word   0           ; 0xFFFC  unused
    .word   _start      ; 0xFFFE  Reset
    .end
