
; Este programa encuentra el máximo común divisor de dos números enteros.
INCLUDE Irvine32.inc

GCD PROTO  x:SDWORD, y:SDWORD
abs PROTO, x:PTR SDWORD

mWrite MACRO text:REQ									; Write string literals.
	LOCAL string
	.data
		string BYTE text, 0
	.code
		PUSH	EDX
		MOV	EDX, OFFSET string
		CALL	WriteString
		POP	EDX
ENDM
.DATA
	UNO SDWORD ?
	DOS SDWORD ?
.CODE
main PROC
	mwrite "primer numero? "
	CALL READINT
	mov uno,eax
	call crlf
	mwrite "segundo numero? "
	Call readint
	mov dos,eax
	mwrite "maximo comun divisor entre primer y segundo numero "
	INVOKE GCD, UNO, DOS
	call	WriteInt		
	call	Crlf
main ENDP

;-----------------------------------------------------
GCD PROC USES ebx edx,
	x:SDWORD,
	y:SDWORD
;
; Calculates the GCD of two 32-bit integers.
; Returns: EAX = GCD(x,y)
;-----------------------------------------------------
	INVOKE abs, ADDR x	; x = abs(x)
	INVOKE abs, ADDR y	; y = abs(y)

LoopStart:		; do {
	mov	edx,0
	mov	eax,x
	mov	ebx,y
	div	ebx		; EDX = x % y
	mov	x,ebx	; x = y
	mov	y,edx	; y = EDX
	cmp	y,0
	jle	Done
	jmp LoopStart	; } while (y > 0)
Done:
	mov	eax,x	; return the GCD in EAX
	ret
GCD ENDP

;-----------------------------------------------------
abs PROC USES eax edx esi,
	val:PTR SDWORD
;
; Calculates the absolute value of a 32-bit integer using
; abs(val) = (val XOR val2) - val2
; where val2 = val SAR 31.
; Returns: val = abs(val)
;-----------------------------------------------------
	mov	esi,val
	mov	eax,[esi]	; [esi] is memory for val on stack
	sar	eax,31	; EAX = val2
	mov	edx,eax
	xor	edx,[esi]	; EDX = val XOR val2
	mov	[esi],edx	; [esi] is memory for output on stack
	sub	[esi],eax	; (val XOR val2) - val2
	ret
abs ENDP
END main