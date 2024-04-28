.equ interruptPin = D2
.equ pinT = D1
.equ pinA = D3
.equ pinH = D4
.equ pinM = D5
.equ flagRegister = r7

.org INT0addr
          jmp buttonISR
; void gpioInit()
; ------------------------------------------------------------
gpioInit:
; set input button
	cbi       DDRD,interruptPin      ; set interruptPin to input (D2)
          sbi       PORTD,interruptPin     ; engage pull-up
          sbi       EIMSK,INT0          ; enable external interrupt 0 for Blue LED Btn
          ldi       r20,0b00000010      ; set falling edge sense bits for ext int 0
          sts       EICRA,r20

          cbi       DDRD, pinT      ; set pin to input (D1)
          sbi       PORTD,pinT      ; engage pull-up

          cbi       DDRD,pinA       ; set pinA to input (D3)
          sbi       PORTD,pinA      ; engage pull-up

          cbi       DDRD,pinH       ; set pinH to input (D4)
          sbi       PORTD,pinH      ; engage pull-up

          cbi       DDRD,pinM       ; set pinM to input (D5)
          sbi       PORTD,pinM      ; engage pull-up
          
          ret       



; void buttonISR()
; ------------------------------------------------------------
buttonISR:
          sbic      PIND, pinT          ; skip rjmp when pin goes high
          call      setAlarm            ; wait for pin to be driven high

          sbic      PIND, pinA          ; skip rjmp when pin goes high
          call      setAlarm            ; wait for pin to be driven high

          sbic      PIND, pinH          ; skip rjmp when pin goes high
          call      setAlarm            ; wait for pin to be driven high  

          sbic      PIND, pinM          ; skip rjmp when pin goes high    
          call      setAlarm            ; wait for pin to be driven high

          reti                          ; buttonISR

; void setAlarm()
; ------------------------------------------------------------
.equ alarmM = r5                        
.equ alarmH = r6

setAlarm:
          clr r8
          inc r8
          eor flagRegister,r8

          ret

; void setTime()
; ------------------------------------------------------------
setTime:
          clr r8
          inc r8
          inc r8
          eor flagRegister,r8

          sei
          SBRC flagRegister, 1
          cli

          ret

; void setHour()
; ------------------------------------------------------------
setHour:
          sbrc flagRegister, 0
          inc alarmH
          sbrc flagRegister, 1
          inc r3

          ret

; void setMin()
; ------------------------------------------------------------
setMin:
          sbrc flagRegister, 0
          inc alarmM
          sbrc flagRegister, 1
          inc r2

          ret



