; SPI Defines
; ---------------------------------------------------------
.equ SPIDDRD = DDRB                               ; SPI Direction Register
.equ SPIPORT = PORTB                              ; SPI Port Register
.equ SS = PB3                                     ; Shift Register Latch
.equ MOSI = PB4                                   ; Master Out Slave In Data Pin
.equ SCK = PB5                                    ; SPI Bus Master clock input


; Setup of the serial to parallel interface as Master
; ---------------------------------------------------------
spiInitMaster:
          ; MOSI, SCK, and SS as output
          ldi	r17, (1<<MOSI) | (1<<SCK) | (1<<SS)
          out       SPIDDRD, r17            

          ; enable SPI as master with clk = fck/16 and MSB 1st
          ldi       r17, (1<<SPE)
         ; ori       r17, (1<<DORD)
          ori       r17, (1<<MSTR) 
          ori       r17, (1<<SPR0) 
          out       SPCR, r17

          ret


; Send data using the serial to parallel interface
; @param r0 - data to send
; ---------------------------------------------------------
spiSend:
          push      r17

	cbi	SPIPORT, SS		; latch the shift register
	out	SPDR, r0			; output the 7s-digit
	
_7sDisplay_xmit:			          ; transmit digit through SPI
	in	r17, SPSR
	sbrs	r17, SPIF			; skip when transmit complete
	rjmp	_7sDisplay_xmit	          ; wait for transmit complete flag

	sbi	SPIPORT, SS		; unlatch shift register

          pop       r17

	ret



