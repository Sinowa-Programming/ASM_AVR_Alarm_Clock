.equ DELAY_CNT = 65536 - (1000000/16) ; 16==1 

.def led = r21

.org OVF1addr                         ; Timer overflow
    jmp tm1_ISR 

tm1_init:
; initialize timer1 with interrupts
;-------------------------------------------------------
    ldi r20, HIGH (DELAY_CNT)
    sts TCNT1H, r20
    ldi r20, LOW (DELAY_CNT)
    sts TCNT1L, r20

    clr r20
    sts TCCR1A, r20                 ; normal mode

    ldi r20, (1<<CS12)              ; normal mode
    sts TCCR1B, r20                 ; clock started

    ldi r20, (1<<TOIE1)             ; enable timer overflow
    sts TIMSK1,r20

    ret

; void gpioInit()
; ------------------------------------------------------------
gpioInit:
; set input button
	      cbi       DDRD,ButtonPin      ; set Blue LED Btn to input (D2)
          sbi       PORTD,ButtonPin     ; engage pull-up
          sbi       EIMSK,INT0          ; enable external interrupt 0 for Blue LED Btn
          ldi       r20,0b00000010      ; set falling edge sense bits for ext int 0
          sts       EICRA,r20

          ret       



