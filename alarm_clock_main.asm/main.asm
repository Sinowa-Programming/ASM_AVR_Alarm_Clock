main:
	; Initialize the display (set data direction registers)
	rcall init_display
	
	; Clear the display to ensure it starts blank
	rcall clear_display

	; Prepare r21 with the digit to be displayed( in binary )
	; Prepare r22 with the digit position (0 for D1, the first digit)
	ldi r22, 0b100	; Display on the low two bytes
	ldi r21, 1	; Display the number 1
	rcall display_digits

	                ; Define the CPU frequency and Timer constants
.equ F_CPU = 16000000        ; CPU Frequency: 16 MHz
.equ PRESCALER = 1024        ; Timer Prescaler
.equ TICKS = 15625          ; Ticks (F_CPU / PRESCALER / 1 second)

;1 = 1/15625 of a second
;5 = 1/3125 of a second
;25 = 1/625 of a second
;125 = 1/125 of second
;625 = 1/25 of second
;3125= 1/5 of second
;15625 = 1 second
;62500 = 4 seconds per second

	; Timer1 CTC Setup
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
       /*Comparison code example
ldi r26, low(Return) ; X register low byte
ldi r27, high(Return) ; X register high byte
ldi r28, low(Return) ; Y register low byte
ldi r2, high(Return) ; Y register high byte
ldi r17,20
ldi r18,20
rcall j1
ldi r17,20
ldi r18,20
rcall j2
ldi r17,20
ldi r18,20
rcall j8
rcall j10;
ldi r17,20
ldi r18,20
rcall j1
ldi r17,20
ldi r18,20
rcall j8
        */

     ;ldi r26, low(TRUE_ADDRESS) ; X register low byte. set to return to use call for j1-j8 
     ;ldi r27, high(TRUE_ADDRESS) ; X register high byte set to return to use call for j1-j8 
     ;ldi r28, low(FALSE_ADDRESS) ; Y register low byte  set to return to use call for j1-j8 
     ;ldi r2, high(FALSE_ADDRESS) ; Y register high byte  set to return to use call for j1-j8 
     ;jumps: cp r17, r18 for j1: = j2: != j3: < j4: <= j5: > j6: >= j7: or j8: and .     
     ;calls: j9: clear (r20) j10: move (r19->r20) 
/*
j1:
EQUAL:
    cp R17, R18
    breq TRUE_CONDITION
    rjmp FALSE_CONDITION

j2:
NOTEQUAL:
    cp R17, R18
    brne TRUE_CONDITION
    rjmp FALSE_CONDITION

j3:
LOWER:
    cp R17, R18
    brlo TRUE_CONDITION
    rjmp FALSE_CONDITION

j4:
LOWEROREQUAL:
    cp R17, R18
    brlo TRUE_CONDITION
    brsh TRUE_CONDITION
    rjmp FALSE_CONDITION

j5: 
HIGHER:
    cp R17, R18
    brsh TRUE_CONDITION
    rjmp FALSE_CONDITION

j6:
HIGHEROREQUAL:
    cp R17, R18
    brsh TRUE_CONDITION
    brne FALSE_CONDITION
    rjmp FALSE_CONDITION

j7:
LOGICOR:
    or R19, R20
    brne TRUE_CONDITION
    rjmp FALSE_CONDITION

j8:
LOGICAND:
    clr r19;
    or R19, R20
    brne TRUE_CONDITION
    rjmp FALSE_CONDITION

Return:
ret;
TRUE_CONDITION:
    ;ldi r26, low(TRUE_ADDRESS) ; X register low byte
    ;ldi r27, high(TRUE_ADDRESS) ; X register high byte
//    ldi r19,1;
    movw r1, r26   ; Move X to Z
    ijmp            ; Perform indirect jump to TRUE_ADDRESS

FALSE_CONDITION:
    ;ldi r28, low(FALSE_ADDRESS) ; Y register low byte
    ;ldi r2, high(FALSE_ADDRESS) ; Y register high byte
 //   ldi r19,0;
    movw r1, r28   ; Move Y to Z
    ijmp            ; Perform indirect jump to FALSE_ADDRESS

j9:
CLEAR:
clr r20;
ret;

j10:
MOVE:
mov r20,r19;
ret;

*/

; Interrupt Service Routine for Timer1 Compare Match A

  .org 0x16; Vector address for Timer1 CMA ISR
TIMER1_COMPA_ISR:
    ; Use r1 and r31 for seconds and minutes respectively
    inc r2                  ; Increment seconds register (Assuming r1 holds seconds)
    cpi r2, 60
    brne EXIT_ISR
    clr r2                  ; Reset seconds and check minutes
    inc r1                  ; Increment minutes register (Assuming r31 holds minutes)
    cpi r1, 60
    brne EXIT_ISR
    clr r1                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)
    ; Assuming r1 will be reused for hours as a simplistic example
    inc r31                  ; Increment hours (Note: Adjust as necessary for your system)
    cpi r31, 24
    brne EXIT_ISR
    clr r31;

EXIT_ISR:
	;sei;
	reti;



	;sbi DDRD, PD2

Loop:
	;sbi PORTD, PD2
	rcall display_digits
	;rcall clear_display

	; Loop infinitely to maintain the display
	rjmp loop;

; Includes. Placed down here so they have to be called to be used
; ---------------------------------------------------------
.include "seven_seg_disp.inc"	; Displays the binary on the seven seg disp.
