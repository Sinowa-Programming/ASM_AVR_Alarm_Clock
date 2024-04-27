;
; Desc: This file is the implementation of the double dabble algorithm.
; Inputs:
;	r21 - The binary value to convert to bcd
; Outputs:
;	r23 - The bcd value of r21
; Registers used:
;	r20 - A temporary value to hold constants for comparisons/arithamtic
;	r21 - The binary value to convert to bcd
;	r22 - A temporary value to hold a section( one's or ten's ) of the bcd value
;	r23 - The bcd conversion of the binary value
;	r24 - The counter for the amount of the shifts done

; DEFINES ------------------------
.def binary_reg = r21
.def nibble = r22
.def bcd_result = r23
.def shift_cntr = r24
; --------------------------------

binary_to_bcd:
	; Store variables for later recall
	push binary_reg
	push nibble
	push shift_cntr
	push r20
	
	ldi shift_cntr, 8	; Converting an 8 bit number
	
low_nibble_check:	; Check if the lower nibble( the ones section ) is above 5.
	mov nibble, bcd_result	; Copy and mask the bcd result so only the one's are showing
	andi nibble, 0x0F

	cpi nibble, 0x05		; if( low nibble of bcd_result > 4 ) {
	brlo high_nibble_check	;
	ldi r20, 3		;	bcd_result += 3
	add nibble, r20		;

	andi nibble, 0x0F
	andi bcd_result, 0xF0	;	overwrite the lower nibble
	or bcd_result, nibble

high_nibble_check:	
	mov nibble, bcd_result	; Copy and mask the bcd result so only the tens's are showing
	andi nibble, 0xF0

	cpi nibble, 0x50		; if( high nibble of bcd_result > 4 ) {
	brlo shift		;
	ldi r20, 0x30		;	nibble += 3 ( added only to the high nibble)
	add nibble, r20		;

	andi nibble, 0x0F
	andi bcd_result, 0x0F	;	overwrite the higher nibble
	or bcd_result, nibble

shift:
	clc		; Clear the carry flag so it doesn't get shifted into the binary reg
	rol binary_reg	; Carry = binary_reg << 1	; Shift left by one ans send the rightmost bit to carry
	rol bcd_result	; bcd_result << Carry	; Add the carry to the one's position
	
	dec shift_cntr


shift_check:
	; Check if you should shift before shifting
	ldi r20, 0
	cpse shift_cntr, r20		; if( shift_cntr != 0 ):
	brne low_nibble_check		;	continue operating
					; else: cleanup and return
	; Clean up function and return
	pop binary_reg
	pop nibble
	pop shift_cntr
	pop r20
	ret		; end function
