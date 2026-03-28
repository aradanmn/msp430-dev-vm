;******************************************************************************
; Lesson 06 — Exercise 2: Find the Bugs
;
; This code is supposed to:
;   1. Init SPI and run a loopback test (LED1 ON if pass)
;   2. Start Timer_A and blink LED1 at 1 Hz via ISR
;
; It compiles, but has 4 bugs. Find each one, fix it, and explain
; what was wrong as a comment.
;
; Hardware: loopback wire P1.7→P1.6, LED2 jumper removed.
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

.equ TICK_MS,       5
.equ TICK_PERIOD,   (TICK_MS * 1000) - 1
.equ BLINK_TICKS,   500 / TICK_MS

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

    ; --- SPI init ---
    bis.b   #UCSWRST, &UCB0CTL1
    mov.b   #(UCCKPH|UCMSB|UCMST|UCSYNC), &UCB0CTL0
    mov.b   #UCSSEL_2, &UCB0CTL1           ; BUG 1: what happens to UCSWRST?
    mov.b   #1, &UCB0BR0
    mov.b   #0, &UCB0BR0                   ; BUG 2: wrong register
    bis.b   #(BIT5|BIT6|BIT7), &P1SEL
    ; P1SEL2 not set                       ; BUG 3: missing P1SEL2
    bic.b   #UCSWRST, &UCB0CTL1

    ; --- SPI loopback test ---
    mov.b   #0xA5, R12
    call    #spi_tx_byte
    cmp.b   #0xA5, R12
    jne     test_fail
    bis.b   #LED1, &P1OUT                  ; pass — LED1 ON
    jmp     start_timer
test_fail:
    bic.b   #LED1, &P1OUT

start_timer:
    ; --- Timer_A: 5 ms tick, CC0 ISR ---
    mov.w   #TICK_PERIOD, &TACCR0
    mov.w   #CCIE, &TACCTL0
    mov.w   #(TASSEL_2|MC_1|TACLR), &TACTL

    mov.w   #BLINK_TICKS, R6
    bis.w   #(GIE|CPUOFF), SR

;==============================================================================
; timer_isr
;==============================================================================
timer_isr:
    dec.w   R6
    jnz     .Lno_blink
    xor.b   #LED1, P1OUT                    ; BUG 4: missing &
    mov.w   #BLINK_TICKS, R6
.Lno_blink:
    reti

;==============================================================================
; spi_tx_byte
;==============================================================================
spi_tx_byte:
.Ltx_wait:
    bit.b   #UCB0TXIFG, &IFG2
    jz      .Ltx_wait
    mov.b   R12, &UCB0TXBUF
.Lrx_wait:
    bit.b   #UCB0RXIFG, &IFG2
    jz      .Lrx_wait
    mov.b   &UCB0RXBUF, R12
    ret

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0           ; 0xFFE0
    .word   0           ; 0xFFE2
    .word   0           ; 0xFFE4
    .word   0           ; 0xFFE6
    .word   0           ; 0xFFE8
    .word   0           ; 0xFFEA
    .word   0           ; 0xFFEC
    .word   0           ; 0xFFEE
    .word   0           ; 0xFFF0
    .word   timer_isr   ; 0xFFF2
    .word   0           ; 0xFFF4
    .word   0           ; 0xFFF6
    .word   0           ; 0xFFF8
    .word   0           ; 0xFFFA
    .word   0           ; 0xFFFC
    .word   _start      ; 0xFFFE
    .end
