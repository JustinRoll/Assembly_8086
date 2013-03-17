.model small
.stack 100h
.data
fibnos db 20 dup(0)
message db "Program Complete.",0dh, 0ah, '$' 

.code
;this program will calculate the first 20
;numbers in the fibonacci sequence
main proc
	mov ax,@data ;this is just for accessing stuff
	mov ds,ax	 ;in .data
	mov bx, offset fibnos

	mov cx,18 ;set the counter to 20

	mov ax, 1 ;keep
	mov bx, 1

	fibLoop:
		add bx, ax
		mov [fibnos], bx

		mov ax,0
		mov bx,0 ;0 out ax and bx again
		loop fibLoop


	int 21h
	mov ah, 4ch
	int 21h ;return to dos, exit program

main endp
end main