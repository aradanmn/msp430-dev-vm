;******************************************************************************
; Lesson 06 — Exercise 1: SPI from the Datasheet
;
; Configure USCI_B0 as SPI master and run a loopback test.
; LED1 ON if loopback matches, LED1 OFF otherwise.
;
; What you need to figure out from the datasheet (SLAU144 Ch16):
;   - Which register holds mode/polarity/phase/master/sync bits?
;   - Which register holds clock source? (Why bis.b, not mov.b?)
;   - Which flags tell you TX is ready and RX has data? Where are they?
;
; What you need from the MSP430G2553 datasheet (SLAS735):
;   - Which pins are SPI CLK, MOSI, MISO?
;   - What P1SEL/P1SEL2 values select USCI_B0 function?
;
; Hardware:
;   - Jumper wire: P1.7 (MOSI) → P1.6 (MISO)
;   - Remove LED2 jumper (J5)
;
; SPI config target: Mode 0, MSB first, master, SMCLK / 1
;******************************************************************************

#include "../../../common/msp430g2553-defs.s"

    .text
    .global _start

.equ SPI_TEST_BYTE, 0xA5

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    ; LED1 as output, OFF
    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

    ; Your SPI initialization here (UCSWRST pattern)

    ; Your loopback test here: send SPI_TEST_BYTE, check result, set LED1

halt:
    bis.w   #(GIE|CPUOFF), SR

;==============================================================================
; spi_tx_byte — Send one byte, return received byte
;
; Input:  R12 = byte to send
; Output: R12 = byte received
;
; You write this subroutine.
;==============================================================================
spi_tx_byte:
    ; Your code here
    ret

;==============================================================================
; Interrupt Vector Table
;==============================================================================
    .section ".vectors","ax",@progbits
    .word   0,0,0,0, 0,0,0,0
    .word   0,0,0,0, 0,0,0
    .word   _start
    .end
