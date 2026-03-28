;******************************************************************************
; Lesson 06 — Example: SPI Loopback Test
;
; Configures USCI_B0 as SPI master and sends a test byte. A jumper wire
; from P1.7 (MOSI) to P1.6 (MISO) loops the data back. If the received
; byte matches, LED1 turns ON.
;
; Hardware setup:
;   - Jumper wire: P1.7 → P1.6
;   - Remove LED2 jumper (J5) — P1.6 is shared with LED2
;
; SPI configuration:
;   - Mode 0 (UCCKPH=1, UCCKPL=0): idle low, capture on rising edge
;   - MSB first, master, 3-wire
;   - Clock: SMCLK / 1 = 1 MHz
;******************************************************************************

#include "../../common/msp430g2553-defs.s"

    .text
    .global _start

.equ SPI_TEST_BYTE, 0xA5           ; test pattern (1010 0101)

_start:
    mov.w   #0x0400, SP
    mov.w   #(WDTPW|WDTHOLD), &WDTCTL
    clr.b   &DCOCTL
    mov.b   &CALBC1_1MHZ, &BCSCTL1
    mov.b   &CALDCO_1MHZ, &DCOCTL

    ; --- GPIO init ---
    ; LED1 as output, OFF
    bis.b   #LED1, &P1DIR
    bic.b   #LED1, &P1OUT

    ; --- SPI init (USCI_B0, Mode 0, master, 1 MHz) ---
    bis.b   #UCSWRST, &UCB0CTL1            ; hold USCI in reset

    mov.b   #(UCCKPH|UCMSB|UCMST|UCSYNC), &UCB0CTL0
    ;          capture-first | MSB-first | master | synchronous (SPI)

    bis.b   #UCSSEL_2, &UCB0CTL1           ; SMCLK (preserves UCSWRST)

    mov.b   #1, &UCB0BR0                   ; SMCLK / 1 = 1 MHz
    mov.b   #0, &UCB0BR1

    ; SPI pins: P1.5 = CLK, P1.6 = MISO, P1.7 = MOSI
    bis.b   #(BIT5|BIT6|BIT7), &P1SEL
    bis.b   #(BIT5|BIT6|BIT7), &P1SEL2

    bic.b   #UCSWRST, &UCB0CTL1            ; release reset — SPI active

    ; --- Send test byte and check loopback ---
    mov.b   #SPI_TEST_BYTE, R12
    call    #spi_tx_byte                    ; send 0xA5, receive loopback

    cmp.b   #SPI_TEST_BYTE, R12            ; did we get it back?
    jne     fail
    bis.b   #LED1, &P1OUT                  ; YES — LED1 ON (pass)
    jmp     halt
fail:
    bic.b   #LED1, &P1OUT                  ; NO — LED1 OFF (fail)

halt:
    bis.w   #(GIE|CPUOFF), SR              ; sleep forever

;==============================================================================
; spi_tx_byte — Send one byte, return received byte
;
; Input:  R12 = byte to send (low 8 bits)
; Output: R12 = byte received
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
