;	Universidade Federal da Bahia
;	Departamento de Ciência da Computação
;
;	Disciplina:	MAT149 Linguagens de montagem
;	Professor:	Luiz Eduardo
;
;	Conversao de tipo numericos - inteiros
;
;	29 de Julho de 2004
;
;	tasm IntNum /l

		.MODEL	SMALL
		DOSSEG
		.386

		.DATA

		DD	12 DUP (?)

signal		DB	?

ten		DD	10


		.CODE
		PUBLIC	AscToInt,IntToAsc


AscToInt	PROC	FAR

; +---------------------------------------------------------------------+
; | Chamada:	XCALL	AscToInt,numAsc,length,numInt,rC		|
; |									|
; |		numAsc		DB	nnn DUP (?)		<--	|
; |		length		DD	nnn			<->	|
; |		numInt		DD	?			-->	|
; |		rC		DD	?			-->	|
; |									|
; | Retorno:	rC = 0: numInt <-- numAsc				|
; |		rC = 2: numAsc nao numerico				|
; +---------------------------------------------------------------------+

		MOV	ESI,DWORD PTR [EBX+8]
		MOV	ECX,DWORD PTR [ESI]		; length
		MOV	ESI,DWORD PTR [EBX+4]		; numAsc

		PUSH	EBX

SearchNumber:
		CMP	BYTE PTR [ESI],' '
		JE	NextChar
		CMP	BYTE PTR [ESI],13		; CR
		JE	NextChar
		CMP	BYTE PTR [ESI],10		; LF
		JE	NextChar
		CMP	BYTE PTR [ESI],9		; \t
		JE	NextChar
		JMP	BeginNumber

NextChar:
		INC	ESI
		LOOP	SearchNumber
		JMP	NotNumber

BeginNumber:
		MOV	EAX,0
		MOV	EBX,0
		MOV	EDX,0
		MOV	signal,'+'
		CMP	BYTE PTR [ESI],'+'
		JE	signalNumber
		CMP	BYTE PTR [ESI],'-'
		JNE	TranslateAscii
		MOV	signal,'-'

SignalNumber:
		CMP	ECX,1
		JNG	NotNumber
		INC	ESI
		DEC	ECX
		CMP	BYTE PTR [ESI],' '
		JE	NotNumber
		CMP	BYTE PTR [ESI],13		; CR
		JE	NotNumber
		CMP	BYTE PTR [ESI],10		; LF
		JE	NotNumber

TranslateAscii:
		CMP	BYTE PTR [ESI],' '
		JE	EndNumber
		CMP	BYTE PTR [ESI],13		; CR
		JE	EndNumber
		CMP	BYTE PTR [ESI],10		; LF
		JE	EndNumber
		CMP	BYTE PTR [ESI],'0'
		JB	NotNumber
		CMP	BYTE PTR [ESI],'9'
		JA	NotNumber
		MOV	BL,BYTE PTR [ESI]
		SUB	BL,30h
		MUL	ten
		ADD	EAX,EBX
		INC	ESI
		LOOP	TranslateAscii

EndNumber:
		MOV	EDX,0
		CMP	signal,'+'
		JE	ReturnInteger
		NEG	EAX
		JMP	ReturnInteger

NotNumber:
		MOV	EDX,2
		JMP	ReturnInteger

ReturnInteger:
		POP	EBX
		MOV	EDI,DWORD PTR [EBX+8]
		SUB	DWORD PTR[EDI],ECX		; length
		MOV	EDI,DWORD PTR [EBX+12]
		MOV	DWORD PTR [EDI],EAX		; numInt
		MOV	EDI,DWORD PTR [EBX+16]
		MOV	DWORD PTR [EDI],EDX		; rC

		RET

		ENDP

					
IntToAsc	PROC	FAR

; +---------------------------------------------------------------------+
; | Chamada:	XCALL	IntToAsc,numInt,numAsclength			|
; |									|
; |		numInt		DD	?			-->	|
; |		numAsc		DB	nnn DUP (?)		<--	|
; |		length		DD	nnn			<--	|
; +---------------------------------------------------------------------+

NumAscFilling:
		MOV	EDI,DWORD PTR [EBX+8]		; numAsc
		MOV	ESI,DWORD PTR [EBX+12]		; length
		MOV	ECX,DWORD PTR [ESI]

		MOV	ESI,EDI
		LODSB
		REP	STOSB

		MOV	ESI,DWORD PTR [EBX+4]		; numInt
		MOV	EAX,DWORD PTR [ESI]

		DEC	EDI
		MOV	signal,'+'
		CMP	EAX,0
		JNL	TranslateBinary
		MOV	signal,'-'
		NEG	EAX

TranslateBinary:
		MOV	EDX,0
		DIV	ten
		ADD	DL,30h
		MOV	BYTE PTR [EDI],DL
		DEC	EDI
		CMP	EAX,0
		JG	TranslateBinary

		CMP	signal,'+'
		JE	ReturnAscii
		MOV	BYTE PTR [EDI],'-'
		DEC	EDI

ReturnAscii:
		RET
	
		ENDP		

		END
