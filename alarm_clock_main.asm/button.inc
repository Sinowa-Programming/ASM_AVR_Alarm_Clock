; Button pin defines
.equ pinT = PD5
.equ pinA = PD4
.equ pinH = PD3
.equ pinM = PD2
; Register defines
.def flagRegister = r7

; Led pin defines
.equ buttonStatus = PC5
.equ timeStatus = PC4
.equ alarmStatus = PC3

; void
; gpioInit()
; Setups all of the status leds and buttons
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
; Poll all of the buttons and do their respective operations.
; ------------------------------------------------------------
buttonPoll:
	push r16	; For delay
	push r18
	push r17

	sbi PORTC, buttonStatus 	
	
          sbis      PIND, PIND5          ; skip rjmp when pin goes high
          rcall      setTime            ; wait for pin to be driven high

          sbis      PIND, PIND4          ; skip rjmp when pin goes high
          rcall      setAlarm            ; wait for pin to be driven high

          sbis      PIND, PIND3          ; skip rjmp when pin goes high
          rcall      setHour            ; wait for pin to be driven high  
	
          sbis      PIND, PIND2          ; skip rjmp when pin goes high    
          rcall      setMin            ; wait for pin to be driven high
	
	call	delay_ms		; Slow down the button program to slow down the button update. This function should be in a interrupt to avoid this.

	pop r17
	pop r18
	pop r16

          ret                          ; buttonISR

; void setAlarm()
; Toggles the alarm flag register
; ------------------------------------------------------------
.def alarmM = r5                        
.def alarmH = r6

setAlarm:
          cbi PORTC, PD0		; turn off the alarm when any button is pressed
	

	clr r8
          inc r8
	eor flagRegister,r8	; flagRegister alarm bit toggle

	; toggle set alarm led
	push r19
	in r8, PORTC
	ldi r19, (1<<alarmStatus)
	eor r8, r19
	out PORTC, r8
	pop r19


          ret

; void setTime()
; Toggles the time flag register
; ------------------------------------------------------------
setTime:
	cbi PORTC, PD0		; turn off the alarm when any button is pressed
	
          clr r8
          inc r8
          inc r8
          eor flagRegister,r8	; flagRegister time bit toggle

	; toggle set time led
	push r19
	in r8, PORTC
	ldi r19, (1<<timeStatus)
	eor r8, r19
	out PORTC, r8
	pop r19
          
	; Pause the timer while setting time
	sei
          SBRC flagRegister, 1
          cli

          ret

; void setHour()
; ------------------------------------------------------------
setHour:
	cbi PORTC, PD0		; turn off the alarm when any button is pressed
	
	; increment the register based on the bits set in the flag register
	push r19
	ldi r19, 24
          sbrc flagRegister, 0
          inc alarmH
          sbrc flagRegister, 1
          inc r3

	cbi PORTC, PC5 	

	; Cap the changed value
          sbrc flagRegister, 0
	jmp capAlarmH
          sbrc flagRegister, 1
	jmp capTimeH

capAlarmH:	; Prevent the alarm hour from going over 24 hours
	cp alarmH, r19
	brne exit
	clr alarmH                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)
	jmp exit
capTimeH:		; Prevent the time hour from going over 24 hours
	cp r3, r19
	brne exit
	clr r3                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)
	jmp exit

; void setMin()
; Increases the time of the alarm/time based on the flag register's bits
; ------------------------------------------------------------
setMin:
	cbi PORTC, PD0		; turn off the alarm when any button is pressed
	
	push r19
	sbrc flagRegister, 0
          inc alarmM
          sbrc flagRegister, 1
          inc r2

	cbi PORTC, PC5 	

	; Choose which to cap
          sbrc flagRegister, 0
	jmp capAlarmM
          sbrc flagRegister, 1
	jmp capTimeM

capAlarmM:	; Prevent the alarm minutes from going over 60 minutes
	cp alarmM, r15
	brne exit
	clr alarmM                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)
	jmp exit
capTimeM:		; Prevent the time minutes from going over 60 minutes
	cp r2, r15
	brne exit
	clr r2                  ; Reset minutes and increment hours (Assuming r31 also handles hours temporarily)

exit:	; Time changing is done
	pop r19
       ret



