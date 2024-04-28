; SPI Defines
; ---------------------------------------------------------
.equ SPIDDRD = DDRB                               ; SPI Direction Register
.equ SPIPORT = PORTB                              ; SPI Port Register
.equ SS = PB2                                     ; Shift Register Latch
.equ MOSI = PB3                                   ; Master Out Slave In Data Pin
.equ SCK = PB5                                    ; SPI Bus Master clock input

.equ DELAY_S = 1                       ; sleep 1/??? second. It delays for long enough. Don't worry about it.


; Setup of the serial to parallel interface as Master
; ---------------------------------------------------------
spiInitMaster:
          ; MOSI, SCK, and SS as output
          in	r17, SPIDDRD
	ori	r17, (1<<MOSI) | (1<<SCK) | (1<<SS)
          out       SPIDDRD, r17            

          ; enable SPI as master with clk = fck/16 and LSB 1st
          ldi       r17, (1<<SPE)
	;ori       r17, (1<<DORD)
          ori       r17, (1<<MSTR) 
          ori       r17, (0<<SPR0) 
          out       SPCR, r17

	sbi	SPIPORT, SS		; unlatch shift register

          ret


; Send data using the serial to parallel interface
; @param r0 - data to send
; ---------------------------------------------------------
spiSend:
          push      r17
	push	r18	; used for the delay
	push	r16	; used for the delay
	;rcall spiInitMaster

	cbi	SPIPORT, SS		; latch the shift register
	out	SPDR, r0			; output the 7s-digit
	
_7sDisplay_xmit:			          ; transmit digit through SPI
	in	r17, SPSR
	sbrs	r17, SPIF			; skip when transmit complete
	rjmp	_7sDisplay_xmit	          ; wait for transmit complete flag

	sbi	SPIPORT, SS		; unlatch shift register
	call	delay_ms			; Give the 4 digit 7 segment display time to show the digit	

	pop	r16
          pop       r18
	pop	r17

	ret



delay_ms:
; creates a timed delay using multiple nested loops
; ------------------------------------------------------------
          ldi       r18,DELAY_S
delay_ms_1:

          ldi       r17,50
delay_ms_2:

          ldi       r16,250
delay_ms_3:
          nop
          nop
          dec       r16
          brne      delay_ms_3          ; 250 * 5 = 1250

          dec       r17
          brne      delay_ms_2          ; 50 * 1250 = 1250K

dealy_ms_end:
          ret