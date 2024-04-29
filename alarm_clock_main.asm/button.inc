.equ pinT = PD5
.equ pinA = PD4
.equ pinH = PD3
.equ pinM = PD2
.def flagRegister = r7

.equ buttonStatus = PC5
.equ timeStatus = PC4
.equ alarmStatus = PC3

; void
; gpioInit()
; ------------------------------------------------------------
gpioInit:
	clr flagRegister

	; Make led buttons output
	sbi DDRC, buttonStatus
	sbi DDRC, timeStatus
	sbi DDRC, alarmStatus

	; set input button
          cbi       DDRD, pinT      ; set pin to input (D1)
          sbi       PORTD,pinT      ; engage pull-up

          cbi       DDRD,pinA       ; set pinA to input (D3)
          sbi       PORTD,pinA      ; engage pull-up

          cbi       DDRD,pinH       ; set pinH to input (D4)
          sbi       PORTD,pinH      ; engage pull-up

          cbi       DDRD,pinM       ; set pinM to input (D5)
          sbi       PORTD,pinM      ; engage pull-up
          
          ret       


; void buttonPoll()
; ------------------------------------------------------------
buttonPoll:
	sbi PORTC, buttonStatus 	
	
          sbis      PIND, PIND5          ; skip rjmp when pin goes high
          rcall      setTime            ; wait for pin to be driven high

          sbis      PIND, PIND4          ; skip rjmp when pin goes high
          rcall      setAlarm            ; wait for pin to be driven high

          sbis      PIND, PIND3          ; skip rjmp when pin goes high
          rcall      setHour            ; wait for pin to be driven high  
	
          sbis      PIND, PIND2          ; skip rjmp when pin goes high    
          rcall      setMin            ; wait for pin to be driven high

          ret                          ; buttonISR

; void setAlarm()
; ------------------------------------------------------------
.def alarmM = r5                        
.def alarmH = r6

setAlarm:
          cbi PORTC, PD0		; turn off the alarm when any button is pressed
	
	clr r8
          inc r8
	eor flagRegister,r8

	push r19
	in r8, PORTC
	ldi r19, (1<<alarmStatus)
	eor r8, r19
	out PORTC, r8
	pop r19


          ret

; void setTime()
; ------------------------------------------------------------
setTime:
	cbi PORTC, PD0		; turn off the alarm when any button is pressed
	
          clr r8
          inc r8
          inc r8
          eor flagRegister,r8

	push r19
	in r8, PORTC
	ldi r19, (1<<timeStatus)
	eor r8, r19
	out PORTC, r8
	pop r19
          
	
	;sei
          ;SBRC flagRegister, 1
          ;cli

          ret

; void setHour()
; ------------------------------------------------------------
setHour:
	cbi PORTC, PD0		; turn off the alarm when any button is pressed
	
	push r19
	ldi r19, 24
          sbrc flagRegister, 0
          inc alarmH
          sbrc flagRegister, 1
          inc r3

	cbi PORTC, PC5 	

	cp alarmH, r19
	brne exit
	clr alarmH                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)
	
	cp r3, r19
	brne exit
	clr r3                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)


          rjmp exit

; void setMin()
; ------------------------------------------------------------
setMin:
	cbi PORTC, PD0		; turn off the alarm when any button is pressed
	
	push r19
	sbrc flagRegister, 0
          inc alarmM
          sbrc flagRegister, 1
          inc r2

	cbi PORTC, PC5 	

	cp alarmM, r15
	brne exit
	clr alarmM                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)

	
	cp r2, r15
	brne exit
	clr r2                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)


exit:	
	pop r19
       ret



