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
.equ A = 5    ; PORTB5 (pin 11)
.equ B = 4    ; PORTB4 (pin 7)
.equ C = 3    ; PORTB3 (pin 4)
.equ D = 2    ; PORTB2 (pin 2)
.equ E = 1    ; PORTB1 (pin 1)
.equ F = 6    ; PORTB6 (pin 10)
.equ G = 0    ; PORTB0 (pin 5)
.equ DP = 7   ; PORTB7 (pin 3)




; Define bit positions for digits D1-D4
.equ D1 = 4   ; PORTD4 (pin 12)
.equ D2 = 3   ; PORTD3 (pin 9)
.equ D3 = 2   ; PORTD2 (pin 8)
.equ D4 = 1   ; PORTD1 (pin 6)
       rjmp main


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
    ldi r21, 0xFF            ; Prepare to turn off digit
    sbrc r22, 0              ; Check if r22 is 0 (D1)
    cbr r21, (1<<D1)         ; Clear D1 bit
    sbrc r22, 1              ; Check if r22 is 1 (D2)
    cbr r21, (1<<D2)         ; Clear D2 bit
    sbrc r22, 2              ; Check if r22 is 2 (D3)
    cbr r21, (1<<D3)         ; Clear D3 bit
    sbrc r22, 3              ; Check if r22 is 3 (D4)
    cbr r21, (1<<D4)         ; Clear D4 bit
    out PORTD, r21        ; Apply to digit port
    Ret












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
    ldi r23, 0b01011011      ; Segment pattern for '2'
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
    out PORTB, r23        ; Output to segment port
    rcall turn_off_digit     ; Turn off previous digit
    ldi r21, 0xFF            ; Prepare to turn on specific digit
    sbrc r22, 0
    cbr r21, (1<<D1)
    sbrc r22, 1
    cbr r21, (1<<D2)
    sbrc r22, 2
    cbr r21, (1<<D3)
    sbrc r22, 3
    cbr r21, (1<<D4)
    out PORTD, r21        ; Apply to digit port
    Ret




main:
    ; Initialize the display (set data direction registers)
   rcall init_display




    ; Clear the display to ensure it starts blank
   rcall clear_display




    ; Set the first digit to '8'
    ; Prepare r22 with the digit position (0 for D1, the first digit)
    ldi r22, 0


   rcall set_digit_8        ; Call function to display '8' on the first digit


Loop:


    ; Loop infinitely to maintain the display
   rcall set_digit_8        ; Call function to display '8' on the first digit
    rjmp loop;





