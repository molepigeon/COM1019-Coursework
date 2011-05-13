ORG 40000
INITALCLEAR	LD A,0  ; colour 2 is RED 
		OUT (0FEh),A ; set border to that colou
		; Code to clear the screen. Taken from Lab 3.
		LD	A,167
		;Colour bit. We want solid black for this.
		LD	HL,4000h
		;We're drawing to the display file, which
		;starts at address 4000h.
		LD	BC,1800h
		;Select every pixel to clear.
		LD	(HL),0
		LD	D, H
		LD	E, 1
		LDIR ;Clear the entire screen.

DRAWBLACKLINE	;Draws a black square on the screen.
		LD	(HL), A
		;Dump colour bit to display file
		JP	HOLDINGPATTERN
		;Go back to the loop.

STEPUP		;PUSH (HL)
		CALL	NC,CLEARBLOCK
		;Set HL to a blank colour
		LD	A,L
		;Can only call SBC on register A, so put L into it.
		SBC	A,32
		;We must go back 32 blocks to get to the point directly above.
		CALL	C,DECH
		;Decrement H if there's a carry.
		LD	L,A
		;Load our recalculated L.
		LD	(HL),167
		;Make the new block black
		JP	WAIT

STEPDOWN	;PUSH (HL)
		CALL	NC,CLEARBLOCK
		;Set HL to a blank colour
		LD	A,L
		;Can only call SBC on register A, so put L into it.
		ADD	A,32
		;We must go forward 32 blocks to get to the point directly below.
		CALL	C,INCH
		;Increment H if there's a carry.
		LD	L,A
		;Load our recalculated L.
		LD	(HL),167
		;Make the new block black
		JP	WAIT

STEPRIGHT	;PUSH (HL)
		CALL	NC,CLEARBLOCK
		;Set HL to a blank colour
		INC	HL
		;Move to the next block	
		LD	(HL),167
		;Make the new block black
		JP	WAIT

STEPLEFT	CALL	EDGECHECK
		;Try to check if the block is running away
		CALL	CLEARBLOCK
		;Set HL to a blank colour
		DEC	HL
		;Move to the next block			
		LD	(HL),167
		;Make the new block black
		JP	WAIT

WAIT		HALT ;This
		HALT ;Makes
		HALT ;A
		HALT ;Nice
		HALT ;Delay
		JP	HOLDINGPATTERN

HOLDINGPATTERN	OR	C
		;Not entirely sure why this is here. We saw it in a lab,
		;and it breaks without it. So hey.

		;--- Start W key spotting ---
		LD	A,0FBh
		;Read Q - T.
		IN	A,(0FEh)
		;Read the keyboard input port.
		RRA ;Cycle to the W key.
		RRA
		JP	NC,STEPUP ;If W is pressed, move up.
		;--- End W key spotting ---

		;--- Start A key spotting ---
		LD	A,0FDh
		;Read A - G
		IN	A,(0FEh)
		;Read the keyboard input port.
		RRA ;Cycle to the A key
		JP	NC,STEPLEFT ; If A is pressed, move left.
		;--- End A key spotting ---

		;--- Start D key spotting ---
		LD	A,0FDh
		;Read A - G
		IN	A,(0FEh)
		;Read the keyboard input port.
		RRA ;Cycle to the D key.
		RRA
		RRA
		JP	NC,STEPRIGHT ;If D is pressed, move right.
		;--- End D key spotting ---

		;--- Start S key spotting ---
		LD	A,0FDh
		;Read A - G
		IN	A,(0FEh)
		;Read the keyboard input port.
		RRA ;Cycle to the S key.
		RRA
		JP	NC,STEPDOWN ;If S is pressed, move down.
		;--- End S key spotting ---

		;--- Start E key spotting ---
		LD	A,0FBh
		;Read Q - T.
		IN	A,(0FEh)
		;Read the keyboard input port.
		RRA ;Cycle to the E key.
		RRA
		RRA
		JP	NC,DUMPBLOCK ;If E is pressed, dump a block.
		;--- End E key spotting ---

		JP	HOLDINGPATTERN ;Nothing's been pressed, so loop back.

DUMPBLOCK	;PUSH (HL)
		LD (HL),0
		JP HOLDINGPATTERN

CLEARBLOCK	;POP (HL)
		LD (HL),63 ;Clears the block.
		RET

INCH		INC H ;Increment H.
		RET

DECH		DEC H ;Decrement H.
		RET

EDGECHECK	LD	A,0
		CP	L
		RET	NZ
		LD	A,64
		CP	H
		RET	Z
		JP	EDGEBLOCK

EDGEBLOCK	CALL	CLEARBLOCK
		;Set HL to a blank colour		
		LD	(HL),167
		;Make the new block black
		JP	WAIT
