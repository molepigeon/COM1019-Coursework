ORG 40000
INITALCLEAR	; Code to clear the screen. Taken from Lab 3.
		LD	A,0
		;Colour bit. We want solid black for this.
		LD	HL,4000h
		;We're drawing to the display file, which
		;starts at address 4000h.
		LD	BC,1800h
		;Draws on the entire screen.
		LD	(HL),0
		LD	D, H
		LD	E, 1
		LDIR ;Go to the start point.

DRAWBLACKLINE	;Draws a black square on the screen.
		LD	(HL), A
		;Dump colour bit to display file
		JP	HOLDINGPATTERN

STEPRIGHT	LD	(HL),56
		;Set HL to a blank colour
		INC	L
		;Move to the next block	
		LD	(HL),0
		;Make the new block black
		LD	BC,255
		;Load B with a wait for the next jump
		JP	WAIT

WAIT		DEC	BC
		LD	A,0
		ADD	B,A
		JP	NZ,WAIT
		JP	HOLDINGPATTERN

HOLDINGPATTERN	OR	C

		LD	A,7h
		IN	A,(0FEh)
		RRA
		JP	NC,STEPRIGHT
		JP	HOLDINGPATTERN
