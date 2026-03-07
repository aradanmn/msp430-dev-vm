;******************************************************************************
; msp430g2553-defs.s
;
; MSP430G2553 register and bit definitions for GNU assembler.
; Include this file at the top of every .s file:
;
;   from examples/         use  #include "../../common/msp430g2553-defs.s"
;   from exercises/exN/    use  #include "../../../common/msp430g2553-defs.s"
;   from exN/solution/     use  #include "../../../../common/msp430g2553-defs.s"
;
; MSP430G2553 at a glance:
;   - 16-bit RISC CPU, 16 registers (R0=PC, R1=SP, R2=SR, R3=CG, R4-R15=general)
;   - 16 KB Flash  (0xC000–0xFFFF)
;   - 512 B RAM    (0x0200–0x03FF)
;   - Peripherals  (0x0000–0x01FF, byte-addressable)
;   - Info Flash   (0x1000–0x10FF, holds calibration data)
;
; LaunchPad (MSP-EXP430G2) pin assignments:
;   P1.0 = LED1  (Red,   active HIGH)
;   P1.6 = LED2  (Green, active HIGH — shares SPI MISO in later lessons)
;   P1.3 = S2 Button  (active LOW, use internal pull-up)
;   P1.1 = UCA0RXD   (UART receive)
;   P1.2 = UCA0TXD   (UART transmit)
;   P1.5 = UCB0CLK   (SPI clock)
;   P1.6 = UCB0SOMI  (SPI MISO — same as LED2!)
;   P1.7 = UCB0SIMO  (SPI MOSI)
;******************************************************************************

;==============================================================================
; Bit masks
;==============================================================================
.equ    BIT0,   0x01
.equ    BIT1,   0x02
.equ    BIT2,   0x04
.equ    BIT3,   0x08
.equ    BIT4,   0x10
.equ    BIT5,   0x20
.equ    BIT6,   0x40
.equ    BIT7,   0x80

; LaunchPad aliases
.equ    LED1,       BIT0        ; P1.0 Red LED
.equ    LED2,       BIT6        ; P1.6 Green LED
.equ    BTN,        BIT3        ; P1.3 Button (active low)
.equ    UART_RX,    BIT1        ; P1.1 UCA0RXD
.equ    UART_TX,    BIT2        ; P1.2 UCA0TXD

;==============================================================================
; Special Function Registers (0x0000–0x000F)
;==============================================================================
.equ    IE1,    0x0000          ; Interrupt Enable 1
.equ    IFG1,   0x0002          ; Interrupt Flag 1
.equ    IE2,    0x0001          ; Interrupt Enable 2
.equ    IFG2,   0x0003          ; Interrupt Flag 2
.equ    ME2,    0x0005          ; Module Enable 2

;==============================================================================
; Port 1  (8-bit, 0x0020–0x0027)
;==============================================================================
.equ    P1IN,   0x0020          ; Input register
.equ    P1OUT,  0x0021          ; Output register
.equ    P1DIR,  0x0022          ; Direction  (0=input, 1=output)
.equ    P1IFG,  0x0023          ; Interrupt flag
.equ    P1IES,  0x0024          ; Interrupt edge select (0=rising, 1=falling)
.equ    P1IE,   0x0025          ; Interrupt enable
.equ    P1SEL,  0x0026          ; Function select (0=GPIO, 1=peripheral)
.equ    P1REN,  0x0027          ; Resistor enable

;==============================================================================
; Port 2  (8-bit, 0x0028–0x002F)
;==============================================================================
.equ    P2IN,   0x0028
.equ    P2OUT,  0x0029
.equ    P2DIR,  0x002A
.equ    P2IFG,  0x002B
.equ    P2IES,  0x002C
.equ    P2IE,   0x002D
.equ    P2SEL,  0x002E
.equ    P2REN,  0x002F

;==============================================================================
; Port 1/2 Secondary Function Select (0x0041–0x0042)
;==============================================================================
.equ    P1SEL2, 0x0041
.equ    P2SEL2, 0x0042

;==============================================================================
; Watchdog Timer  (16-bit, 0x0120)
;==============================================================================
.equ    WDTCTL,     0x0120
.equ    WDTPW,      0x5A00      ; Password — always write with control bits
.equ    WDTHOLD,    0x0080      ; Hold (stop) the watchdog

; Watchdog interval timer presets
.equ    WDTTMSEL,   0x0010      ; Interval timer mode
.equ    WDTCNTCL,   0x0008      ; Clear counter
.equ    WDTSSEL,    0x0004      ; Clock: 0=SMCLK, 1=ACLK
.equ    WDTIS1,     0x0002
.equ    WDTIS0,     0x0001

;==============================================================================
; Basic Clock System  (8-bit, 0x0053–0x0058)
;==============================================================================
.equ    BCSCTL3,    0x0053
.equ    DCOCTL,     0x0056      ; DCO frequency fine-tune
.equ    BCSCTL1,    0x0057      ; Range select + ACLK divider
.equ    BCSCTL2,    0x0058      ; MCLK/SMCLK source + dividers

; BCSCTL1 fields
.equ    DIVA_0,     0x00        ; ACLK /1
.equ    DIVA_1,     0x10        ; ACLK /2
.equ    DIVA_2,     0x20        ; ACLK /4
.equ    DIVA_3,     0x30        ; ACLK /8

; BCSCTL2 fields
.equ    DIVM_0,     0x00        ; MCLK /1
.equ    DIVM_1,     0x10        ; MCLK /2
.equ    DIVS_0,     0x00        ; SMCLK /1
.equ    DIVS_1,     0x02        ; SMCLK /2
.equ    DIVS_2,     0x04        ; SMCLK /4
.equ    DIVS_3,     0x06        ; SMCLK /8

; DCO calibration constants — stored in Info Flash by TI at manufacture
; Read with: mov.b &CALBC1_1MHZ, &BCSCTL1
;            mov.b &CALDCO_1MHZ, &DCOCTL
.equ    CALBC1_1MHZ,    0x10FF  ; BCSCTL1 value for 1 MHz
.equ    CALDCO_1MHZ,    0x10FE  ; DCOCTL  value for 1 MHz
.equ    CALBC1_8MHZ,    0x10FD  ; BCSCTL1 value for 8 MHz
.equ    CALDCO_8MHZ,    0x10FC  ; DCOCTL  value for 8 MHz
.equ    CALBC1_16MHZ,   0x10F9  ; BCSCTL1 value for 16 MHz
.equ    CALDCO_16MHZ,   0x10F8  ; DCOCTL  value for 16 MHz

;==============================================================================
; Timer_A  (16-bit registers, 0x0160–0x0176)
;==============================================================================
.equ    TACTL,  0x0160          ; Timer_A Control
.equ    TACCTL0,0x0162          ; Capture/Compare Control 0
.equ    TACCTL1,0x0164          ; Capture/Compare Control 1
.equ    TACCTL2,0x0166          ; Capture/Compare Control 2
.equ    TAR,    0x0170          ; Timer counter
.equ    TACCR0, 0x0172          ; Period register (Up mode)
.equ    TACCR1, 0x0174          ; CCR1 compare value
.equ    TACCR2, 0x0176          ; CCR2 compare value
.equ    TAIV,   0x012E          ; Interrupt vector register

; TACTL — clock source
.equ    TASSEL_0, 0x0000        ; TACLK (external)
.equ    TASSEL_1, 0x0100        ; ACLK
.equ    TASSEL_2, 0x0200        ; SMCLK
.equ    TASSEL_3, 0x0300        ; INCLK
; TACTL — input divider
.equ    ID_0,   0x0000          ; /1
.equ    ID_1,   0x0040          ; /2
.equ    ID_2,   0x0080          ; /4
.equ    ID_3,   0x00C0          ; /8
; TACTL — mode
.equ    MC_0,   0x0000          ; Stop
.equ    MC_1,   0x0010          ; Up (count to TACCR0)
.equ    MC_2,   0x0020          ; Continuous (count to 0xFFFF)
.equ    MC_3,   0x0030          ; Up/Down
.equ    TACLR,  0x0004          ; Clear counter
.equ    TAIE,   0x0002          ; Overflow interrupt enable
.equ    TAIFG,  0x0001          ; Overflow flag

; TACCTL — output mode (for PWM)
.equ    OUTMOD_0, 0x0000        ; Output (manual)
.equ    OUTMOD_1, 0x0020        ; Set
.equ    OUTMOD_2, 0x0040        ; Toggle/Reset
.equ    OUTMOD_3, 0x0060        ; Set/Reset
.equ    OUTMOD_4, 0x0080        ; Toggle
.equ    OUTMOD_5, 0x00A0        ; Reset
.equ    OUTMOD_6, 0x00C0        ; Toggle/Set
.equ    OUTMOD_7, 0x00E0        ; Reset/Set  ← standard PWM
; TACCTL — interrupt
.equ    CCIE,   0x0010          ; Interrupt enable
.equ    CCIFG,  0x0001          ; Interrupt flag
.equ    CAP,    0x0100          ; Capture mode

;==============================================================================
; ADC10  (0x01B0–0x01B4, plus 8-bit at 0x0048–0x004C)
;==============================================================================
.equ    ADC10CTL0, 0x01B0
.equ    ADC10CTL1, 0x01B2
.equ    ADC10MEM,  0x01B4
.equ    ADC10AE0,  0x004B       ; Analog enable (disable digital for ADC pins)

; ADC10CTL0 fields
.equ    ADC10SC,    0x0001      ; Start conversion
.equ    ENC,        0x0002      ; Enable conversion
.equ    ADC10IFG,   0x0004      ; Interrupt flag
.equ    ADC10IE,    0x0008      ; Interrupt enable
.equ    ADC10ON,    0x0010      ; Power on ADC
.equ    REFON,      0x0020      ; Internal reference on
.equ    REF2_5V,    0x0040      ; Ref = 2.5 V (else 1.5 V)
.equ    ADC10SHT_3, 0x1800      ; Sample-hold: 64 × ADC10CLK
.equ    SREF_0,     0x0000      ; Vr+ = VCC,  Vr- = GND
.equ    SREF_1,     0x2000      ; Vr+ = Vref, Vr- = GND

; ADC10CTL1 fields
.equ    ADC10BUSY,  0x0001      ; Busy
.equ    CONSEQ_0,   0x0000      ; Single channel, single conversion
.equ    ADC10SSEL_3,0x0018      ; Clock = SMCLK
.equ    INCH_10,    0xA000      ; Channel 10 = internal temperature sensor

;==============================================================================
; USCI_A0  (UART / SPI-A, 8-bit at 0x0060–0x0067)
;==============================================================================
.equ    UCA0CTL0,   0x0060
.equ    UCA0CTL1,   0x0061
.equ    UCA0BR0,    0x0062      ; Baud rate (low byte)
.equ    UCA0BR1,    0x0063      ; Baud rate (high byte)
.equ    UCA0MCTL,   0x0064      ; Modulation (UART only)
.equ    UCA0STAT,   0x0065
.equ    UCA0RXBUF,  0x0066
.equ    UCA0TXBUF,  0x0067
; UCA0CTL1
.equ    UCSSEL_2,   0x80        ; Clock = SMCLK
.equ    UCSWRST,    0x01        ; Software reset (hold during config)
; IFG2 bits for USCI_A0
.equ    UCA0RXIFG,  0x01
.equ    UCA0TXIFG,  0x02
; IFG2 bits for USCI_B0
.equ    UCB0RXIFG,  0x04
.equ    UCB0TXIFG,  0x08
; IE2 bits
.equ    UCA0RXIE,   0x01
.equ    UCA0TXIE,   0x02
.equ    UCB0RXIE,   0x04
.equ    UCB0TXIE,   0x08

;==============================================================================
; USCI_B0  (SPI-B / I2C, 8-bit at 0x0068–0x006F)
;==============================================================================
.equ    UCB0CTL0,   0x0068
.equ    UCB0CTL1,   0x0069
.equ    UCB0BR0,    0x006A      ; Bit rate (low byte)
.equ    UCB0BR1,    0x006B      ; Bit rate (high byte)
.equ    UCB0STAT,   0x006D
.equ    UCB0RXBUF,  0x006E
.equ    UCB0TXBUF,  0x006F
; I2C registers
.equ    UCB0I2COA,  0x0118      ; Own address
.equ    UCB0I2CSA,  0x011A      ; Slave address
; UCB0CTL0 fields
.equ    UCCKPH,     0x80        ; Clock phase
.equ    UCCKPL,     0x40        ; Clock polarity (0=inactive-low)
.equ    UCMSB,      0x20        ; MSB first
.equ    UCMST,      0x08        ; Master mode
.equ    UCMODE_3,   0x06        ; I2C mode
.equ    UCSYNC,     0x01        ; Synchronous mode (SPI/I2C)
; UCB0CTL1 fields
.equ    UCTR,       0x10        ; I2C: 1=transmit, 0=receive
.equ    UCTXSTP,    0x04        ; Send STOP
.equ    UCTXSTT,    0x02        ; Send START

;==============================================================================
; Status Register (R2/SR)  — for LPM and interrupt control
;==============================================================================
.equ    C,          0x0001      ; Carry flag
.equ    Z,          0x0002      ; Zero flag
.equ    N,          0x0004      ; Negative flag
.equ    GIE,        0x0008      ; Global interrupt enable
.equ    CPUOFF,     0x0010      ; CPU off (LPM0–LPM4)
.equ    OSCOFF,     0x0020      ; Oscillator off
.equ    SCG0,       0x0040      ; System clock gen 0 off
.equ    SCG1,       0x0080      ; System clock gen 1 off
.equ    V,          0x0100      ; Overflow flag

; LPM entry — use  bis.w #LPMx_bits, SR
.equ    LPM0_bits,  CPUOFF
.equ    LPM1_bits,  SCG0|CPUOFF
.equ    LPM3_bits,  SCG1|SCG0|CPUOFF
.equ    LPM4_bits,  SCG1|SCG0|OSCOFF|CPUOFF

; LPM exit — use in ISR:  bic.w #CPUOFF, 0(SP)

; End of msp430g2553-defs.s
