;******************************************************************************
; Lesson 05 — Exercise 2: ISR Timing Budget
;
; Part A: Observe what happens when an ISR takes too long.
;   - This ISR calls slow_work which burns ~6 ms
;   - The tick period is 5 ms
;   - Build, flash, and observe LED1. Is it blinking at 2 Hz? Why not?
;
; Part B: Fix the timing by redesigning the ISR.
;   - The ISR must complete well within 5 ms on every tick
;   - Spread the work across multiple ticks, or skip ticks
;   - Write comments explaining your timing budget
;
; After fixing, LED1 should blink at 2 Hz again.
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

.equ TICK_MS,       5
.equ TICK_PERIOD,   (TICK_MS * 1000) - 1
.equ BLINK_TICKS,   250 / TICK_MS

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

    ; Timer_A: 5 ms tick, CC0 interrupt
    mov.w   #TICK_PERIOD, &TACCR0
    mov.w   #CCIE, &TACCTL0
    mov.w   #(TASSEL_2|MC_1|TACLR), &TACTL

    mov.w   #BLINK_TICKS, R6

    bis.w   #(GIE|CPUOFF), SR

;==============================================================================
; timer_isr — THIS ISR IS BROKEN (takes ~6 ms, overruns 5 ms tick)
;
; Part A: observe the behavior as-is
; Part B: redesign so ISR completes within budget
;==============================================================================
timer_isr:
    call    #slow_work              ; ~6 ms of work — too slow!

    dec.w   R6
    jnz     .Lno_blink
    xor.b   #LED1, &P1OUT
    mov.w   #BLINK_TICKS, R6
.Lno_blink:
    reti

;==============================================================================
; slow_work — simulates expensive processing (~6 ms at 1 MHz)
;
; Burns approximately 6000 cycles. In a real game this might be collision
; detection, line clearing, or framebuffer updates.
;
; DO NOT MODIFY THIS SUBROUTINE — redesign the ISR instead.
;==============================================================================
slow_work:
    push    R14
    push    R15
    mov.w   #3, R14                 ; outer loop: 3 iterations
.Lsw_outer:
    mov.w   #666, R15               ; inner: 666 × 3 cycles ≈ 2000 cycles
.Lsw_inner:
    dec.w   R15
    jnz     .Lsw_inner
    dec.w   R14
    jnz     .Lsw_outer              ; total ≈ 6000 cycles ≈ 6 ms
    pop     R15
    pop     R14
    ret

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
    .word   timer_isr   ; 0xFFF2  Timer_A CC0
    .word   0           ; 0xFFF4  WDT
    .word   0           ; 0xFFF6  Comparator_A+
    .word   0           ; 0xFFF8  Timer1_A1
    .word   0           ; 0xFFFA  unused
    .word   0           ; 0xFFFC  unused
    .word   _start      ; 0xFFFE  Reset
    .end
