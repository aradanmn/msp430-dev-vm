;******************************************************************************
; Lesson 01 — Exercise 3: SOS Morse Code
;
; Blink LED1 in SOS Morse code, then repeat.
;
; Pattern:  S=···  O=———  S=···  [pause]  [repeat]
;
; Timing:
;   Dot:   LED ON  150 ms, then OFF 150 ms
;   Dash:  LED ON  450 ms, then OFF 150 ms
;   Between letters: extra 300 ms off  (total 450 ms gap between S/O/S)
;   After full SOS: 1000 ms off before repeating
;
; Hints:
;   - Use bis.b to turn LED ON, bic.b to turn LED OFF
;   - You need delay_ms called with different values for each phase
;   - Write it out explicitly first (18 on/off calls for SOS), then
;     optionally refactor into helper subroutines
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

_start:
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

main_loop:
    ; TODO: transmit S  (three dots)

    ; TODO: gap between S and O (300 ms extra = 450 ms total inter-letter gap)

    ; TODO: transmit O  (three dashes)

    ; TODO: gap between O and S

    ; TODO: transmit S  (three dots)

    ; TODO: end-of-word pause (1000 ms)

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
