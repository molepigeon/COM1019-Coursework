ORG 40000
CLEARSCREEN	; Code to clear the screen. Taken from Lab 3.
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

DRAWBLACKLINE	;Draws a black line on the screen.
		LD	A, 0
		LD	(HL), A
		;Dump colour bit to display file
		LD	BC, 31
		;Go across the first line
		LDIR
		;Loops to draw the line.
		RET
