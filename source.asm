ORG 40000
INITALCLEAR	LD A,0  ; colour 2 is RED 
		OUT (0FEh),A ; set border to that colou
		; Code to clear the screen. Taken from Lab 3.
		LD	A,231
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
		LD	HL,5800h
		LD	(HL), A
		;Dump colour bit to display file
		JP	HOLDINGPATTERN
		;Go back to the loop.

STEPUP		CALL	EDGETOP
		CALL	COLORCHECK
		;Check if at an edge, and check the current colour
		LD	A,L
		;Can only call SBC on register A, so put L into it.
		SBC	A,32
		;We must go back 32 blocks to get to the point directly above.
		CALL	C,DECH
		;Decrement H if there's a carry.
		LD	L,A
		;Load our recalculated L.
		LD	(HL),231
		;Make the new block black
		JP	WAIT

STEPDOWN	CALL	EDGEBOTTOM
		CALL	COLORCHECK
		;Check if at an edge, and check the current colour
		LD	A,L
		;Can only call SBC on register A, so put L into it.
		ADD	A,32
		;We must go forward 32 blocks to get to the point directly below.
		CALL	C,INCH
		;Increment H if there's a carry.
		LD	L,A
		;Load our recalculated L.
		LD	(HL),231
		;Make the new block black
		JP	WAIT

STEPRIGHT	CALL	EDGERIGHT
		CALL	COLORCHECK
		;Check if at an edge, and check the current colour
		INC	HL
		;Move to the next block	
		LD	(HL),231
		;Make the new block black
		JP	WAIT

STEPLEFT	CALL	EDGELEFT
		;Try to check if the block is running away
		CALL	COLORCHECK
		;Check if at an edge, and check the current colour
		DEC	HL
		;Move to the next block			
		LD	(HL),231
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

		;--- Start Space key spotting ---
		LD	A,07Fh
		;Read break (SPACE).
		IN	A,(0FEh)
		;Read the keyboard input port.
		RRA ;Cycle to the Space key.
		CALL	NC, STARTLOOP
		;--- End Space key spotting --

		;--- Start Q key spotting ---
		LD	A,0FBh
		;Read Q - T.
		IN	A,(0FEh)
		;Read the keyboard input port.
		RRA ;Cycle to the Q key.
		CALL	NC,CLSINIT ;If Q is pressed, move up.
		;--- End Q key spotting ---

		JP	HOLDINGPATTERN ;Nothing's been pressed, so loop back.

CLSINIT		LD	HL,5800h
		CALL	CLS
		LD	HL,5800h
		LD	(HL),231
		RET

CLS		LD	(HL),63

		;Tests to ensure loops round the entire screen.
		INC	L
		LD	A,0
		CP	L
		CALL	Z,INCH

		LD	A,5Bh
		CP	H
		RET	Z
		;End loop tests.

		JP	CLS 	;Keep looping.

STARTLOOP	CALL	NC, CLEARBLOCK
		LD	HL, 5800h
		CALL	GENLOOP
		LD	HL, 5800h
		RET


DUMPBLOCK	LD	(HL),112	;Make the current block black
		JP	HOLDINGPATTERN	;Go back to checking for keys.

CLEARBLOCK	LD	(HL),63 	;Clears the block.
		RET

YELLOWBLOCK	LD	(HL),112
		RET

INCH		INC H ;Increment H.
		RET

DECH		DEC H ;Decrement H.
		RET

EDGELEFT	LD	A,0	;Check we're at the start
		CP	L	;of a chunk.
		RET	NZ	;And jump out if we're not.
		LD	A,88	;Check we're in the first
		CP	H	;chunk.
		RET	NZ	;And jump out if we're not.
		JP	WAIT
			;Co-ord is 1,1 - Block movement.

EDGERIGHT	LD	A,0FFh	;Check we're in the end
		CP	L	;of a chunk.
		RET	NZ	;And jump out if we're not.
		LD	A,5Ah	;Check we're in the last
		CP	H	;chunk.
		RET	NZ	;And jump out if we're not.
		JP 	WAIT
			;Co-ord is 31,24 - Block movement.

EDGETOP		LD	A,58h	;Check we're in the top
		CP	H	;chunk.
		RET	NZ	;And jump out if we're not.
		LD	A,31	;Check we're in the top
		CP	L	;row.
		RET	C	;And jump out if we're not.
		JP	WAIT
			;In very top row - Block movement.

EDGEBOTTOM	LD	A,5Ah	;Check we're in the bottom
		CP	H	;chunk.
		RET	NZ	;And jump out if we're not.
		LD	A,223	;Check we're in the bottom
		CP	L	;row
		RET	NC	;And jump out if we're not.
		JP	WAIT
			;In very bottom row - Block movement.

COLORCHECK	LD	A,(HL)
		CP	63
		CALL	Z,CLEARBLOCK
		CP	231
		CALL	Z,CLEARBLOCK
		CP	112
		CALL	Z,MARKER
		RET

MARKER		LD	D,1
		RET

GENLOOP		LD	E,0		
		CALL	CHECKSUITE
		CALL	GOD
		LD	E,0

		;Tests to ensure loops round the entire screen.
		INC	L
		LD	A,0
		CP	L
		CALL	Z,INCH

		LD	A,5Bh
		CP	H
		RET	Z
		;End loop tests.

		JP	GENLOOP 	;Keep looping.

GOD		LD	A,E
		CP	0
		CALL	Z,MARKFORDELETE

		CP	1
		CALL	Z,MARKFORDELETE
		
		CP	2
		CALL	Z,MARKFORSKIP

		CP	3
		CALL	Z,MARKFORCREATE
		
		CP	4
		CALL	NC,MARKFORDELETE

		RET

MARKFORSKIP	LD	(HL),112
		RET

MARKFORDELETE	LD	A,(HL)
		CP	63
		RET	Z

		LD	(HL),16
		RET

MARKFORCREATE	LD	(HL),32
		RET

CHECKSUITE	PUSH	HL

		;Check  straight up.
		LD	A,L
		SBC	A,32
		CALL	C,DECH
		LD	L,A

		LD	A,(HL)
		CP	112 ;Is it yellow?
		CALL	Z,INCE

		POP	HL
		PUSH	HL
		;Done checking up.

		;Check up and left.
		LD	A,L
		SBC	A,33
		CALL	C,DECH
		LD	L,A

		LD	A,(HL)
		CP	112 ;Is it blank?
		CALL	Z,INCE

		POP	HL
		PUSH	HL
		;Done checking up left.

		;Check up and right..
		LD	A,L
		SBC	A,31
		CALL	C,DECH
		LD	L,A

		LD	A,(HL)
		CP	112 ;Is it blank?
		CALL	Z,INCE

		POP	HL
		PUSH	HL
		;Done checking up right.

		;Check down and left.
		LD	A,L
		ADD	A,31
		CALL	C,INCH
		LD	L,A

		LD	A,(HL)
		CP	112 ;Is it blank?
		CALL	Z,INCE

		POP	HL
		PUSH	HL
		;Done checking down left.

		;Check down.
		LD	A,L
		ADD	A,32
		CALL	C,INCH
		LD	L,A

		LD	A,(HL)
		CP	112 ;Is it blank?
		CALL	Z,INCE

		POP	HL
		PUSH	HL
		;Done checking down.

		;Check down and right.
		LD	A,L
		ADD	A,33
		CALL	C,INCH
		LD	L,A

		LD	A,(HL)
		CP	112 ;Is it blank?
		CALL	Z,INCE

		POP	HL
		PUSH	HL
		;Done checking down right.

		;Check right.
		LD	A,L
		ADD	A,1
		CALL	C,INCH
		LD	L,A
		INC	HL

		LD	A,(HL)
		CP	112 ;Is it blank?
		CALL	Z,INCE

		POP	HL
		PUSH	HL
		;Done checking right.

		;Check left
		LD	A,L
		ADD	A,1
		CALL	C,DECH
		LD	L,A
		DEC	HL

		LD	A,(HL)
		CP	112 ;Is it blank?
		CALL	Z,INCE
		;Done checking left.
		POP	HL
		
		RET

INCE		INC	E
		;LD	E,3 ;DEBUG ONLY
		RET
		
