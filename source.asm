ORG 40000
INITALCLEAR	; Code to clear the screen. Taken from Lab 3.
		LD	A,0
		;Colour bit. We want solid black for this.
		LD	HL,4000h
		;We're drawing to the display file, which
		;starts at address 4000h.
		LD	BC,1800h
CLEARSCREEN	;Draws on the entire screen.
		LD	(HL),
		LD	D, H
		LD	E, 1
		LDIR ;Go to the start point.

DRAWBLACKLINE	;Draws a black square on the screen.
		LD	(HL), A
		;Dump colour bit to display file
		
		OR	C

		LD	A,7Fh
		IN	A,(0FEh)
		RRA
		JP	NC,MOVEBLOCK

		JP	INITALCLEAR

MOVEBLOCK	INC	HL
		JP	CLEARSCREEN

RUNAWAY		RET
