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

    ; State zero is Flash LED1 3 times at 200 ms on/off
    call #state_zero
    ; State one is Flash LED2 4 times at 100 ms on/off
    call #state_one
    ; State two is 500 ms pause
    call #state_two
    ; repeat
    jmp     main_loop
;==============================================================================
; state zero — Flash LED1 3 times at 200 ms on/off
;==============================================================================
state_zero:
;    mov.b   #LED1, R13
    mov.b   #LED1, R8
;   mov.w   #200, R12
    mov.w   #200, R4
    call    #flash_led
    call    #flash_led
    call    #flash_led
    ret
;==============================================================================
; state one — Flash LED2 4 times at 100 ms on/off
;==============================================================================
state_one:
;    mov.b   #LED2, R13
    mov.b   #LED2, R8
;    mov.w   #100, R12
    mov.w   #100, R4
    call    #flash_led
    call    #flash_led
    call    #flash_led
    call    #flash_led
    ret
;==============================================================================
; state two — 500 ms pause
;==============================================================================
state_two:
    mov.w   #500, R12
    call    #delay_ms
    ret
;==============================================================================
; flash_led — your subroutine (design the interface yourself)
;==============================================================================
; Use R13 for led bitmask, use R12 for counter
flash_led:
    ; move delay into R4
    ;mov.w   R12, R4
    ; move led bitmask into R8
    ;mov.w   R13, R8
    mov.w   R4, R12
    bis.b   R8, &P1OUT  ; Turn LED ON
    call    #delay_ms   ; wait R8 ms
    mov.w   R4, R12     ; R12 clobbered reload
    bic.b   R8, &P1OUT  ; Turn LED OFF
    call    #delay_ms   ; wait R8 ms
    ret

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
