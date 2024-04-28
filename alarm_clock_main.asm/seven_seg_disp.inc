; --------------------------------------------
; 7 segment display defines
; Define bit positions for segments A-G and DP
/*
.equ A = 5 
.equ B = 4    
.equ C = 3
.equ D = 2
.equ E = 1
.equ F = 6
.equ G = 0
.equ DP = 7
*/

; Define bit positions for digits D1-D4
.equ D1 = PD6   ; PORTD6 (pin 6)
.equ D2 = PD7   ; PORTD7 (pin 7)
.equ D3 = PB0   ; PORTB0 (pin 8)
.equ D4 = PB1   ; PORTB1 (pin 9)
       
;-------------------------------


; Initialization routine to set data direction registers
; Initialize the data pins. The segments are being handling by a serial parallel interface chip
init_display:
	call spiInitMaster	; init the serial parallel interface

	; Init the 7 segment display
	in r16, DDRD
	ori r16, (1<<D1) | (1<<D2)
	out DDRD, r16
	in r16, DDRB
	ori r16, (1<<D3) | (1<<D4)
	out DDRB, r16
	ret

; Clear display by turning off all segments and digits
clear_display:
	in r16, PORTD
	ori r16, (1<<D1) | (1<<D2)
	out PORTD, r16
	in r16, PORTB
	ori r16, (1<<D4) | (1<<D3)
	out PORTB, r16
	ret

; Turn off digit and decimal point
; Input: r22 = digit position (0-3)
update_data_pins:
    sbrc r22, 0              ; Check if r22 is 0 (D1)
    cbi PORTD, D1         ; Clear D1 bit
    sbrc r22, 1              ; Check if r22 is 1 (D2)
    cbi PORTD, D2         ; Clear D2 bit
    sbrc r22, 2              ; Check if r22 is 2 (D3)
    cbi PORTB, D3         ; Clear D3 bit
    sbrc r22, 3              ; Check if r22 is 3 (D4)
    cbi PORTB, D4         ; Clear D4 bit
    ret



; Generic function to set digit and segments
; Expects r23 with segment pattern, r22 with digit position
set_digit_generic:
	rcall clear_display
	rcall update_data_pins     ; Update the data pins
	call spiSend
	ret

; Displays the given binary digit, up to 99
; Registers used:
;	r20 - Used as turn on/off data pins
;	r16 - Temp variable
;	r23 - The segment pattern for the display
; Inputs:	
;	r21 - The binary value to display. Accepts up to 99
;	r22 - Display the high or low 2 digits on the display.
;		0b1 for low 2 digits. 0b0100 for high 2 digits
; 
display_digits:
	; temporily store variables for use in the function
	push r23
	push r16
	push r22

	; convert the value to bcd
	call binary_to_bcd

	; Setup the program memory pointer
	ldi	ZL,LOW(2*digits)		; initialize Z pointer
	ldi	ZH,HIGH(2*digits)		; to pmem array address
	
	; Load and show the one's digit
	mov	r16, r23
	andi	r16, 0x0F			; Mask to get the lower nibble( the one pos )
	add	r30, r16			; digits[ r16 ]

	lpm	r0, Z			; r0 = digits[r16] ; Load the low byte of the segment
	
	; Display the digit
	rcall set_digit_generic
	
	lsl	r22		; Turn on the digit to the left of the current digit
	
	
	; Setup the program memory pointer
	ldi	ZL,LOW(2*digits)		; initialize Z pointer
	ldi	ZH,HIGH(2*digits)		; to pmem array address
	
	; Load and show the ten's digit
	mov	r16, r23
	andi	r16, 0xF0			; Mask to get the higher nibble( the ten's pos )
	
	; Make the higher nibble lower to use it to access the digits array
	lsr	r16
	lsr	r16
	lsr	r16
	lsr	r16
	
	add	r30, r16			; digits[ r16 ]

	lpm	r0, Z			; r0 = digits[r16] ; Load the low byte of the segment
		
	; Display the digit
	rcall set_digit_generic

	
	; load old variables back to their registers
	pop r22
	pop r16
	pop r23

	ret


digits: .db 0b01111110,0b00000110,0b01101101,0b01111001,0b00110011,0b01011011,0b01011111,0b01110000,0b01111111,0b01110011

; List of digits for 7 segment display
/*
digits: .db 0b01111110,\      ; Segment pattern for '0'
	0b00000110,\	; Segment pattern for '1'
	0b01101101,\	; Segment pattern for '2'
	0b01111001,\	; Segment pattern for '3'
	0b00110011,\	; Segment pattern for '4' (F, B, G, C)
	0b01011011,\	; Segment pattern for '5' (A, F, G, C, D)
	0b01011111,\	; Segment pattern for '6' (A, F, G, E, C, D)
	0b01110000,\	; Segment pattern for '7' (A, B, C)
	0b01111111,\	; Segment pattern for '8' (All segments) except dp
	0b01110011	; Segment pattern for '9' (A, B, C, D, F, G)
*/



; Includes. Placed down here so they have to be called to be used
; ---------------------------------------------------------
.include "spi.inc"		; Handles the serial to parallel communication
.include "bin_bcd.inc"	; Converts binary to the bcd
