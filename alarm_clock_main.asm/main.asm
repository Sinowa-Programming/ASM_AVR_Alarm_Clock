;
; alarm_clock_main.asm.asm
;
; Created: 4/23/2024 1:39:52 PM
; Author : Peeps
;


; Define segment and digit control pin mappings to PORTB and PORTD
;.def PORTB = PORTB
;.def DIG_PORT = PORTD


; Define bit positions for segments A-G and DP
//rjmp main
.equ A = PB3    ; PORTB5 (pin 11)
.equ B = PD4    ; PORTB4 (pin 7)
.equ C = PD3    ; PORTB3 (pin 4)
.equ D = PD2    ; PORTB2 (pin 2)
.equ E = PD1    ; PORTB1 (pin 1)
.equ F = PB2    ; PORTB6 (pin 10)
.equ G = PD5    ; PORTB0 (pin 5)
.equ DP = PD3   ; PORTB7 (pin 3)




; Define bit positions for digits D1-D4
.equ D1 = PB4   ; PORTD4 (pin 12) PB4
.equ D2 = PB1   ; PORTD3 (pin 9) PB1
.equ D3 = PB0   ; PORTD2 (pin 8) PB0
.equ D4 = PD6   ; PORTD1 (pin 6) PD6

jmp main


; Initialization routine to set data direction registers
init_display:
    ldi r21, 0xFF            ; Set all pins as output
    out DDRB, r21            ; For PORTB (Segments)
    out DDRD, r21            ; For PORTD (Digits)
    ret




; Clear display by turning off all segments and digits
clear_display:
    ldi r21, 0x00            ; Clear segments
    out PORTB, r21
    ldi r21, 0x00            ; Turn off all digits
    out PORTD, r21
    ret




; Turn off digit and decimal point
; Input: r22 = digit position (0-3)
turn_off_digit:
    sbrs r22, 0	; if r22 bit 0 is not set : skip:
    sbi PORTB, D1	;     set D1 high. Turn off digit D1 
    sbrs r22, 1	; if r22 bit 1 is set : skip:
    sbi PORTB, D2	;     set D2 high. Turn off digit D2
    sbrs r22, 2	; if r22 bit 2 is set : skip:
    sbi PORTB, D3	;     set D3 high. Turn off digit D3
    sbrs r22, 3	; if r22 bit 3 is set : skip:
    sbi PORTB, D4	;     set D4 high. Turn off digit D4

    ret


; Set specific digits, using generic function to set segments
; Examples for digits 0 to 3. Continue similarly for 4 to 9.




; Set digit to '0'
set_digit_0:
    ldi r23, 0b00111111      ; Segment pattern for '0'
    rjmp set_digit_generic




; Set digit to '1'
set_digit_1:
    ldi r23, 0b00000110      ; Segment pattern for '1'
    rjmp set_digit_generic




; Set digit to '2'
set_digit_2:
    ldi r23, 0b010110011      ; Segment pattern for '2'
    rjmp set_digit_generic




; Set digit to '3'
set_digit_3:
    ldi r23, 0b01001111      ; Segment pattern for '3'
    rjmp set_digit_generic




; Set digit to '4'
set_digit_4:
    ldi r23, 0b01100110      ; Segment pattern for '4' (F, B, G, C)
    rjmp set_digit_generic




; Set digit to '5'
set_digit_5:
    ldi r23, 0b01101101      ; Segment pattern for '5' (A, F, G, C, D)
    rjmp set_digit_generic




; Set digit to '6'
set_digit_6:
    ldi r23, 0b01111101      ; Segment pattern for '6' (A, F, G, E, C, D)
    rjmp set_digit_generic




; Set digit to '7'
set_digit_7:
    ldi r23, 0b00000111      ; Segment pattern for '7' (A, B, C)
    rjmp set_digit_generic




; Set digit to '8'
set_digit_8:
    ldi r23, 0b01111111      ; Segment pattern for '8' (All segments)
    rjmp set_digit_generic




; Set digit to '9'
set_digit_9:
    ldi r23, 0b01101111      ; Segment pattern for '9' (A, B, C, D, F, G)
    rjmp set_digit_generic




; Generic function to set digit and segments
; Expects r23 with segment pattern, r22 with digit position
set_digit_generic:
    rcall turn_off_digit     ; update data pins
    
    mov r24, r23	; copy r23 into  r14 
    andi r24, ((1<<A) | (1<<F))
    out PORTB, r24         ; Mask segment pattern to pins A and F
    
    mov r24, r23	; copy r23 into  r14 
    andi r24, ((1<<B) | (1<<C) | (1<<D) | (1<<E) | (1<<G))
    out PORTD, r24
    
    ret




main:
    ; Initialize the display (set data direction registers)
   rcall init_display



loop:
   ldi r22, 0b0001
   rcall clear_display

   rcall set_digit_8        ; Call function to display '8' on the first digit
    

   ; Loop infinitely to maintain the display
   rjmp loop;





