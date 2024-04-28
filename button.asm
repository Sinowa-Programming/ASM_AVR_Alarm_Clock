.equ interruptPin = D2

; void gpioInit()
; ------------------------------------------------------------
gpioInit:
; set input button
	      cbi       DDRD,interruptPin      ; set interruptPin to input (D2)
          sbi       PORTD,interruptPin     ; engage pull-up
          sbi       EIMSK,INT0          ; enable external interrupt 0 for Blue LED Btn
          ldi       r20,0b00000010      ; set falling edge sense bits for ext int 0
          sts       EICRA,r20

          ret       



