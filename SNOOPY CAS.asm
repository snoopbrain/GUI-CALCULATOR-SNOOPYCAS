.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword



INCLUDE irvine32.inc
INCLUDE macros.inc
INCLUDELIB	user32.lib



GCD PROTO  x:SDWORD, y:SDWORD
abs PROTO, x:PTR SDWORD



; Macros:
mGotoxy MACRO X:REQ, Y:REQ								; Reposition cursor to x,y position
	PUSH	EDX
	MOV	DH, Y
	MOV	DL, X
	CALL	Gotoxy
	POP	EDX
ENDM


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


mWriteString MACRO buffer:REQ								; Write string variables
	PUSH	EDX
	MOV	EDX, OFFSET buffer
	CALL	WriteString
	POP	EDX
ENDM


mReadString MACRO var:REQ								; Read string from console
	PUSH	ECX
	PUSH	EDX
	MOV	EDX, OFFSET var
	MOV	ECX, SIZEOF var
	CALL	ReadString
	POP	EDX
	POP	ECX
ENDM

; Structs:
AXIS STRUCT										; estructura de cordenadas para generar nuestros botones
    x BYTE 0
    y BYTE 0
AXIS ENDS


; KeyCodes:
	VK_BACKSPACE   EQU	000000008h
	VK_LEFT		EQU	000000025h
	VK_UP		EQU	000000026h
	VK_RIGHT	EQU	000000027h
	VK_DOWN		EQU	000000028h
	maxCol      EQU     76
	maxRow      EQU     20
	VK_Carriage	EQU	00000000Dh
	


; Game "Window" Setup:
	maxX		EQU       79							; Se adapta al tamaño estándar de la consola
	maxY		EQU       23
	wallHor       	EQU       "--------------------------------------------------------------------------------"
	wallVert      	EQU       '|'
	maxSize		EQU       255



; Prototypes:
GetKeyState PROTO, nVirtKey:DWORD
.data


choice BYTE    0							;variable para la seleccion del menu
playerName BYTE 13 + 1 DUP (?)				;string para nombre de usuario
    BotonPointSuma	AXIS    <36,7>						; posicion de mi boton suma
	BotonPointRes	AXIS    <36,9>						; posicion de mi boton Res
	BotonPointMul	AXIS    <36,11>						; posicion de mi boton Mul
	BotonPointDiv	AXIS    <36,13>						; posicion de mi boton div
	BotonPointsen	AXIS    <10,7>						; posicion de mi boton sen 
	BotonPointcos	AXIS    <18,7>						; posicion de mi boton cos
	BotonPointtan	AXIS    <26,7>						; posicion de mi boton tan
	BotonPointsec	AXIS    <10,9>						; posicion de mi boton sec
	BotonPointcsc	AXIS    <18,9>						; posicion de mi boton csc
	BotonPointcot	AXIS    <26,9>						; posicion de mi boton cot
	BotonPoint1	AXIS    <10,11>						; posicion de mi boton 1  
	BotonPoint2 AXIS    <18,11>						; posicion de mi boton 2
	BotonPoint3	AXIS    <26,11>						; posicion de mi boton 3
	BotonPoint4	AXIS    <10,13>						; posicion de mi boton 4
	BotonPoint5	AXIS    <18,13>						; posicion de mi boton 5
	BotonPoint6	AXIS    <26,13>						; posicion de mi boton 6
	BotonPoint7	AXIS    <10,15>						; posicion de mi boton 7
	BotonPoint8	AXIS    <18,15>						; posicion de mi boton 8
	BotonPoint9	AXIS    <26,15>						; posicion de mi boton 9
	BotonPoint0	AXIS    <18,17>						; posicion de mi boton 0
	BotonPointEqual	AXIS    <36,20>						; posicion de mi boton =


    currentX	BYTE    4							; spawn point x
    currentY	BYTE    4							; spawn point y

	
	times db 0
	
	
	UNO SDWORD ?
	DOS SDWORD ?
   
	acumulador dword ?
	segundo_val dword ?
	primer_val dword ?
.code



main PROC
	CALL StartSnoopycas
	RET
main ENDP



MovimientoLibre PROC

looop:   
    mov ah, 0
    INVOKE GetKeyState, VK_DOWN
	.IF ah && currentY < maxRow
        ;mWriteLn "DOWN"
        INC currentY
  	.ENDIF

	INVOKE GetKeyState, VK_UP
    .IF ah && currentY > 2
        ;mWriteLn "UP"
        DEC currentY
	.ENDIF     

	INVOKE GetKeyState, VK_LEFT
    .IF ah && currentX > 2
        ;mWriteLn "LEFT"
        DEC currentX
	.ENDIF  

	INVOKE GetKeyState, VK_RIGHT
    .IF ah && currentX < maxCol
        ;mWriteLn "RIGHT"
        INC currentX
	.ENDIF 
	


    mov  dl, currentX        ; column
    mov  dh, currentY        ; currentY
    call Gotoxy         ; Change position according to new input
        
    mov  al, '*'          
    call WriteChar      ; Write point on new place
 
    ;mov eax, 0
    ;mov al, currentX
    ;call WriteInt
    ;mov al, '-'
    ;call WriteChar
    ;mov al, currentY
    ;call WriteInt
    ;call Crlf
	mov al,0
	INVOKE GetKeyState, VK_RSHIFT
		test al,1
		.IF !Zero?
		  mgotoxy 6,3
		  mwrite "              "
		  mgotoxy 43,8
		
		mwrite "ShiftR => Borrando salida   "
		mov times,0

		.ENDIF

	INVOKE GetKeyState, VK_Carriage 	;se oprimio enter?
	test al,1
	.IF !Zero?
	 call boton
	.ENDIF
	
    invoke Sleep, 25
    
    
    ; Erase Point
    mov  dl, currentX        ; column
    mov  dh, currentY        ; currentY
    call Gotoxy         ; Change position according to new input
    
    mov  al,' '     
    call WriteChar      ; Remove previous data

	call PrintBotones
    mgotoxy 43,8
	mwrite "ShiftR => deseas Borrar?       " 
	mgotoxy 43,10
	mwrite "Enter => Algun boton?        "
	
    jmp looop

	exit
MovimientoLibre ENDP



boton PROC										; verifica si hemos oprimido un boton
		mov ecx,4
		X00:
		
		mgotoxy 43,10
		
		mwrite "Enter=> Presionando Botones   "

		MOV     AH, currentX
        MOV     AL, currentY

		CMP     AH, BotonPoint1.x
		JNE     X01
		CMP     AL, BotonPoint1.y
		JNE     X01
		cmp times,0
		mov eax,1
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10

	segundo:
		
		mov segundo_val,eax
		mGotoxy 9, 3
		call writeint
		jmp X10
		

	X01:	
		
		CMP     AH, BotonPoint2.x
		JNE     X02
		CMP     AL, BotonPoint2.y
		JNE     X02
		cmp times,0
		mov eax,2
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10

	X02:
		CMP     AH, BotonPoint3.x
		JNE     X03
		CMP     AL, BotonPoint3.y
		JNE     X03
		cmp times,0
		mov eax,3
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10
	X03:
		CMP     AH, BotonPoint4.x
		JNE     X04
		CMP     AL, BotonPoint4.y
		JNE     X04
		cmp times,0
		mov eax,4
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10
	X04:
		CMP     AH, BotonPoint5.x
		JNE     X05
		CMP     AL, BotonPoint5.y
		JNE     X05
		cmp times,0
		mov eax,5
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10
	X05:

		CMP     AH, BotonPoint6.x
		JNE     X06
		CMP     AL, BotonPoint6.y
		JNE     X06
		cmp times,0
		mov eax,6
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10
	X06:
		CMP     AH, BotonPoint7.x
		JNE     X07
		CMP     AL, BotonPoint7.y
		JNE     X07
		cmp times,0
		mov eax,7
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10
	X07:
		CMP     AH, BotonPoint8.x
		JNE     X08
		CMP     AL, BotonPoint8.y
		JNE     X08
		cmp times,0
		mov eax,8
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10
	X08:
		CMP     AH, BotonPoint9.x
		JNE     X09
		CMP     AL, BotonPoint9.y
		JNE     X09
		cmp times,0
		mov eax,9
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10
	X09:
		CMP     AH, BotonPoint0.x
		JNE     X10
		CMP     AL, BotonPoint0.y
		JNE     X10
		cmp times,0
		mov eax,0
		jne segundo
		mov primer_val,eax
		mGotoxy 6, 3
		call writeint
		jmp X10
		
	X10:
		
        CMP     AH, BotonPointSuma.x							; es mi X igual a la posicion x de mi boton
        JNE     X11									; Si no es asi entonces Exit proc
        CMP     AL, BotonPointSuma.y							; es mi Y igual a la posicion y de mi boton
        JNE     X11
		mgotoxy 8,3
		mwrite "+"
		inc times
		cmp times,1
		je X13
		mov eax,segundo_val
		add eax,primer_val
		mov acumulador,eax


	X11:
		CMP     AH,BotonPointEqual.x								; es mi X igual a la posicion x de mi boton
        JNE     X13									; Si no es asi entonces Exit proc
        CMP     AL,BotonPointEqual.y							; es mi Y igual a la posicion y de mi boton
        JNE     X13
		mov eax,acumulador
		mgotoxy 11,3
		mwrite "="
		mgotoxy 13,3
		call writeint
		
   
	X13:
        RET
		
boton ENDP



PrintParedes PROC										; Dibuja las paredes
	mov eax,31										;color fondo azul texto blanco
	call	SetTextColor
	mGotoxy 0, 1     
	mWrite	wallHor
	mGotoxy 0, maxY									; Dibuja las paredes de arriba y abajo
	mWrite	wallHor    
	MOV	CL, maxY - 1								; Prepara CL para colocación en la pared vertical
	
    X00:
	CMP	CL, 1									; WHILE CL != 0
	JE	X01									; SI lo hace, salga del ciclo WHILE
        mGotoxy 0, CL									; Escribir caracter de pared izquierda  " | "
        mWrite	wallVert								
        mGotoxy maxX, CL
        mWrite	wallVert								; Escribir caracter de pared derecha  " | "
        DEC	CL									; viajar hacia arriba en la pantalla hasta que todos estén colocados
	JMP	X00									; Saltar al principio del bucle WHILE
    
    X01:
	RET
PrintParedes ENDP





DrawTitleScreen PROC									; escribe el titulo, diseño pobre xd
	CALL	ClrScr
	CALL	PrintParedes
		
	mov eax,159
	call	SetTextColor
	
	mGotoxy 5, 4									; Dibuja titulo en  ASCII
	mWrite	" ___   _ _    ______   ______   _____  __   __    _____          ___ "	
	mGotoxy 5, 5
	mWrite	"/ __| | ' \  |  __  | |  __  | |  _  | \ \/  /   |  ___|  __ _  / __|"
	mGotoxy 5, 6
	mWrite	"\__ \ | || | | |__| | | |__| | |   __/  \   /    | |___  / _` | \__ \"
	mGotoxy 5, 7
	mWrite	"|___/ |_||_| |______| |______| |__|      \__\    |_____| \__,_| |___/"

	mGotoxy 32, 9									; Dibuja V.1
	mWrite	" __   __      _  "	
	mGotoxy 32, 10
	mWrite	" \ \ / /     / | "
	mGotoxy 32, 11
	mWrite	"  \ V /   _  | | "
	mGotoxy 32, 12
	mWrite	"   \_/   (_) |_| "
	
	mov eax,192
	call	SetTextColor
	

	mGotoxy 23, 14									; Una bella introduccion
	mWrite	"Andres Yair Carvajal Bolivar 2022"
	mGotoxy 32, 16
	mWrite	"Assembly(x86)"
	mGotoxy 23, 18
	mWrite	"UNIVERSIDAD NACIONAL DE COLOMBIA"
	mov eax,15
	call	SetTextColor
	mGotoxy 25,20
	CALL	WaitMsg
	mGotoxy 0, 0 
	RET
DrawTitleScreen ENDP

FIGGONACCI PROC
	MOV EAX,EAX

FIGGONACCI	ENDP

DrawMainMenu PROC									; Elige tipo de calculadora

	CALL	ClrScr
	CALL	PrintParedes
	mov eax,159
	call	SetTextColor

	mGotoxy 30, 5									; Visualización del menú principal y solicitud de nombre
	mWrite	"--MAIN MENU--"
	mGotoxy 30, 7
	mWrite	"Ingresa Nombre: "
	mReadString playerName								; pide nombre del usuario
	mGotoxy 30, 10
	mWrite	"--Elige Opcion--"							; Escribe las opciones
	mGotoxy 30, 12  
	mWrite	"0) Calculadora"						
	mGotoxy 30, 13 
	mWrite	"1) GCD"
	mGotoxy 30, 14 
	mWrite	"2) Figgonacci"
	mGotoxy 30, 15 
	mov eax,15
	call	SetTextColor
	mWrite	"Seleccion: "

	CALL	ReadChar    
	MOV	choice, AL								; Imprime opcion elegida
	CALL	WriteChar
											; Como si fuese un interruptor (choice) 
	CMP	choice, '0'								; caso: '0'
	JNE	X00									; SI no es igual a 0, busca otras opciones
	CALL	Calculadora
	JMP	X02									;Saltar a la lógica en la parte inferior

    X00:
	CMP	choice, '1'								; LO MISMO
	JNE	X01
	CALL GCDF
	JMP	X02

    X01:
	CMP	choice, '2'								; LO MISMO
	JNE	X02
	CALL FIGGONACCI
	JMP	X02

    X02:
	mGotoxy 0, 0 
	mov ah,0
	
	CALL	ClrScr
	INVOKE	Sleep, 200
	RET
DrawMainMenu ENDP

printbotones PROC
	 

	mov eax,5
	call	SetTextColor
	
		
	mGotoxy 5, 20
	mWrite	" _____________________________________";
	;mGotoxy 5,2 
	;mWrite	" _____________________________________"

	

	MOV	CL,20
	X00:
	
	CMP	CL, 1									; WHILE CL != 0
	JE	X01									; SI lo hace, salga del ciclo WHILE
        mGotoxy 5, CL									; Escribir caracter de pared izquierda  " | "
        mWrite	wallVert								
        mGotoxy 42, CL
        mWrite	wallVert								; Escribir caracter de pared derecha  " | "
        DEC	CL									; viajar hacia arriba en la pantalla hasta que todos estén colocados
	JMP	X00									; Saltar al principio del bucle WHILE
  
    X01:
		mov eax,181
		call	SetTextColor
		mGotoxy 6,2 
		mWrite	"                                    "
		

		mGotoxy 6,4									
		mWrite	"____________________________________"

		mov eax,158
		call	SetTextColor
		mGotoxy 32, 6									
		mWrite	"    +    "
		mGotoxy 32, 8									
		mWrite	"    -    "
		mGotoxy 32, 10									
		mWrite	"    *    "
		mGotoxy 32, 12									
		mWrite	"    /    "											
		mGotoxy 32, 19
		mwrite "   =   "
										
		
		mGotoxy 7,  6		   							
		mWrite	"  sen  "
		mGotoxy 15, 6									
		mWrite	"  cos  "
		mGotoxy 23, 6									
		mWrite	"  tan  "
		mGotoxy 7,  8									
		mWrite	"  sec  "
		mGotoxy 15, 8									
		mWrite	"  cot  "
		mGotoxy 23, 8									
		mWrite	"  csc  "


		mGotoxy 7,  10									
		mWrite	"   1   "       
		mGotoxy 15, 10									
		mWrite	"   2   "
		mGotoxy 23, 10									
		mWrite	"   3   "
		mGotoxy 7,  12									
		mWrite	"   4   "
		mGotoxy 15, 12									
		mWrite	"   5   "
		mGotoxy 23, 12									
		mWrite	"   6   "
		mGotoxy 7,  14									
		mWrite	"   7   "
		mGotoxy 15, 14									
		mWrite	"   8   "
		mGotoxy 23, 14									
		mWrite	"   9   "
		mGotoxy 15, 16									
		mWrite	"   0   "
		mov eax,48
		call SetTextColor
		mgotoxy 6,0
		mWritestring playerName
		mGotoxy 0,28 
		mov eax,15
		call	SetTextColor
		mwrite " "



	RET
	
	call readint
	RET

	

printbotones ENDP


Calculadora PROC
	Y00:										
	CALL	ClrScr										
	call	printbotones						;imprime botones
	CALL	PrintParedes
   	
    X02:										;principal loop 
        CALL	boton									; Que boton se oprimio?
        CALL	MovimientoLibre							; Que teclas se oprimio?

	RET

Calculadora ENDP

GCDF PROC

	MWRITE "Esta parte del codigo fue separado, de la interfaz para mayor comodidad"
   invoke sleep,400
   ret

GCDF ENDP







StartSnoopycas PROC										; Maneja la lógica y el bucle del estado principal de la calculadora.
	CALL	DrawTitleScreen								; Cargamos el titulo en pantalla
    X00:										; Inicio de calculadora
	CALL	DrawMainMenu									
	

																											
	INVOKE	ExitProcess, 0

	RET
StartSnoopycas ENDP



END main
