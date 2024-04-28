; Reset and ISR vector setup for ATmega328P
.org 0x0000
    rjmp main           ; Jump to start of program

.org 0x0016             ; Timer1 Compare Match A vector for ATmega328P
    rjmp TIMER1_COMPA_ISR

main:
clr r1
clr r2
clr r3
ldi r19,60 
mov r15,r19
ldi r19,24
mov r14,r19
clr r19;

; Set PC0 as output


	; Initialize the display (set data direction registers)
	rcall init_display
	
	; Clear the display to ensure it starts blank
	rcall clear_display

	; Prepare r21 with the digit to be displayed( in binary )
	; Prepare r22 with the digit position (0 for D1, the first digit)
;	ldi r22, 0b100	; Display on the low two bytes
	;ldi r21, 1	; Display the number 1
	;rcall display_digits
          
	                ; Define the CPU frequency and Timer constants
.equ F_CPU = 16000000        ; CPU Frequency: 16 MHz
.equ PRESCALER = 1024        ; Timer Prescaler
.equ TICKS = 1        ; Ticks (F_CPU / PRESCALER / 1 second)

;1 = 1/15625 of a second
;5 = 1/3125 of a second
;25 = 1/625 of a second
;125 = 1/125 of second
;625 = 1/25 of second
;3125= 1/5 of second
;15625 = 1 second
;62500 = 4 seconds per 	; Timer1 CTC Setup
	ldi r24, high(TICKS)       ; High byte of TICKS
	ldi r25, low(TICKS)        ; Low byte of TICKS
	sts OCR1AH, r24              ; Set high byte of OCR1A
	sts OCR1AL, r25              ; Set low byte of OCR1A
	lds r24, TCCR1B              ; Load TCCR1B to r24
	ori r24, (1<<WGM12)          ; Configure CTC mode
	ori r24, (1<<CS12)|(1<<CS10) ; Set prescaler to 1024
	sts TCCR1B, r24              ; Store back to TCCR1B

	; Enable Timer1 Compare A Match Interrupt
	lds r24, TIMSK1
	ori r24, (1<<OCIE1A)
	sts TIMSK1, r24

	; Global Interrupt Enable
	sei
                                  
	 rjmp loop

TIMER1_COMPA_ISR:
    ; Use r1 and r31 for seconds and minutes respectively
           
    inc r1                  ; Increment seconds register (Assuming r1 holds seconds)
    cp r1, r15

    brne EXIT_ISR
    clr r1                  ; Reset seconds and check minutes
    inc r2                  ; Increment minutes register (Assuming r31 holds minutes)
    cp r2, r15
    brne EXIT_ISR
    clr r2                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)
; Set PC0 high




    ; Assuming r1 will be reused for hours as a simplistic example
    inc r3                  ; Increment hours (Note: Adjust as necessary for your system)
    cp r3, r14
    brne EXIT_ISR
    clr r3;
   



EXIT_ISR:
	sei;
	reti;



	;sbi DDRD, PD2

Loop:
	


;sbi PORTD, PD2
        mov r21,r2

ldi r22,0b1000
	rcall display_digits
               mov r21,r3;
ldi r22,0b0010
	rcall display_digits
	
	; Loop infinitely to maintain the display

; Includes. Placed down here so they have to be called to be used
; ---------------------------------------------------------
ldi r19,10
cp r3,r19
breq alarmcheck
 
       	rjmp loop;


alarmcheck:
ldi r19,10
cp r2,r19
breq alarm
rjmp loop 
alarm:
 ; Set PC0 as output

; Set PC0 as output
ldi r16, (1<<PC0)   ; Load the mask for PC0 into register r16
out DDRC, r16       ; Set PC0 as output by writing to DDRC

; Set PC0 high
ldi r16, (1<<PC0)   ; Load the mask for PC0 again into register r16
out PORTC, r16      ; Set PC0 high by writing to PORTC

rjmp loop

.include "seven_seg_disp.inc"	; Displays the binary on the seven seg disp.
