; Este programa produce valores N de la serie de n�meros de Fibonacci y almacena
; en una matriz de palabra doble.
INCLUDE Irvine32.inc

N = 47

.DATA?
fibonacciSequence	DWORD	N DUP(?)

.CODE
main PROC
	call	Clrscr
	mov	fibonacciSequence[0],1
	mov	fibonacciSequence[4],1
	mov	ecx,N - 2
	mov	esi,2 * TYPE DWORD
CalculateSequence:
	mov	eax,fibonacciSequence[esi - TYPE DWORD]
	add	eax,fibonacciSequence[esi - 2 * TYPE DWORD]
	mov	fibonacciSequence[esi],eax
	add	esi,TYPE DWORD
loop CalculateSequence
	mov	esi,OFFSET fibonacciSequence
	mov	ecx,LENGTHOF fibonacciSequence
	mov	ebx,TYPE fibonacciSequence
	call DumpMem
	call	Crlf
	exit
main ENDP
END main