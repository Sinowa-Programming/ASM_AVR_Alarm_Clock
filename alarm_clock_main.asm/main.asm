main:
	; Initialize the display (set data direction registers)
	rcall init_display
	
	; Clear the display to ensure it starts blank
	rcall clear_display

	; Prepare r21 with the digit to be displayed( in binary )
	; Prepare r22 with the digit position (0 for D1, the first digit)
	ldi r22, 0b1	; Display on the low two bytes
	ldi r21, 19	; Display the number 19
	rcall display_digits

Loop:
	; Loop infinitely to maintain the display
	rjmp loop;

; Includes. Placed down here so they have to be called to be used
; ---------------------------------------------------------
.include "seven_seg_disp.inc"	; Displays the binary on the seven seg disp.
