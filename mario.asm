.model small
.stack 100h
include macros.inc
.data
origVideo db ?
.code
main proc
	mov ax,@data
	mov ds,ax

	;fill macro row_start, col_start, row_end, col_end, color
	clearScreen
	setVideo
	cursor 0,0
	fill 450,0,600,640,1 ;draw the ground
	fill 400,400,450,450,2 ;draw a box for the pipe
	fill 390,390,400,460,2 ;draw rim of pipe

	drawMario:
		fill 10,10,11,15,4
		fill 12,9,13,18,4 ;hat
		fill 14,9,15,16,4 ;hat
		fill 16,8,17,18,4 ;hat


	checkEscape:
		mov ah,0
		int 16h
		cmp al,27
		JE exitProgram
		jmp checkEscape

	exitProgram:
		mov ah,4Ch
		int 21h
main endp
end main