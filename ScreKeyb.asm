;	Universidade Federal da Bahia
;	Departamento de Ciência da Computação
;
;	Disciplina:	MAT149 Linguagens de montagem
;	Professor:	Luiz Eduardo
;
;	Teclado & vídeo
;
;	10 de março de 2003
;
;	tasm ScreKeyb /l

		.MODEL	SMALL
		DOSSEG
		.386

		.DATA

ScreenAttr	DB	00h

		.CODE	
		PUBLIC	ScreenClear,ScreenWrite,KeyboardRead

ScreenClear	PROC	FAR

;	+--------------------------------------------------------------+
;	|	Chamada:	XCALL	ScreenClear                    |
;       +--------------------------------------------------------------+

		PUSH	DS

		MOV	AX,@DATA
		MOV	DS,AX

		CMP	ScreenAttr,00h
		JNE	ClearScreen

		MOV	AH,08h			; read attribute/character at cursor position
		MOV	BH,0
		INT	10h
		MOV	ScreenAttr,AH

ClearScreen:
		MOV	AH,02h			; set cursor position
		MOV	DH,0
		MOV	DL,0
		INT	10h

		MOV	AH,06h			; scroll up screen
		MOV	AL,0
		MOV	BH,ScreenAttr
		MOV	CH,00h
		MOV	CL,00h
		MOV	DH,18h
		MOV	DL,4Fh
		INT	10h

		POP	DS
		RET

		ENDP


ScreenWrite	PROC	FAR

;	+---------------------------------------------------------------+
;	|	Chamada:	XCALL	ScreenWrite,buffer,bufferLength |
;	+---------------------------------------------------------------+

		MOV	EDX,[EBX+4]
		MOV	ESI,[EBX+8]
		MOV	ECX,[ESI]
		MOV	EAX,0
		MOV	AH,40h			; write file/device
		MOV	EBX,1
		INT	21h

		RET

		ENDP


KeyboardRead	PROC	FAR

;	+----------------------------------------------------------------+
;	|	Chamada:	XCALL	KeyboardRead,buffer,bufferLength |
;	+----------------------------------------------------------------+

		MOV	EDX,[EBX+4]
		MOV	ESI,[EBX+8]
		MOV	ECX,[ESI]
		MOV	EAX,0
		MOV	AH,3Fh			; read file/device
		MOV	EBX,0
		INT	21h

		MOV	EDI,[EBX+8]
		MOV	[EDI],EAX
		RET

		ENDP

		END
